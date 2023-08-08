--
-- A simulation model of Pacman hardware
-- Copyright (c) MikeJ - September 2002
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS CODE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- You are responsible for any legal issues arising from your use of this code.
--
-- The latest version of this file can be found at: www.fpgaarcade.co.uk
--
-- Email pacman@fpgaarcade.com
--
-- Revision list
--
-- version 001 initial release
--
-- Modification history (BurchED):
-- 6 July 2004, commented out char roms 5e and 5f.
--  Put the 5e and 5f roms off-chip.
--  Added top level signals CHAR_ROM_5E5F_DOUT(7..0),
--  CHAR_ROM_ADDR(11..0), and SEL_ROM_5F.
--  Changed the p_char_data_mux process to generate SEL_ROM_5F.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_pacman_xilinx_prims.all;
use work.pkg_pacman.all;

entity PACMAN_VIDEO is
  port (
		HCNT						: in    std_logic_vector(8 downto 0);
		VCNT						: in    std_logic_vector(8 downto 0);

		AB							: in    std_logic_vector(11 downto 0);
		DB							: in    std_logic_vector( 7 downto 0);

		HBLANK					: in    std_logic;
		VBLANK					: in    std_logic;
		FLIP						: in    std_logic;
		WR2_L						: in    std_logic;

		R_OUT						: out   std_logic_vector(2 downto 0);
		G_OUT						: out   std_logic_vector(2 downto 0);
		B_OUT						: out   std_logic_vector(1 downto 0);
		CLK_6						: in    std_logic;

	 	CHAR_ROM_5E5F_DOUT 	: in std_logic_vector(7 downto 0);
		CHAR_ROM_ADDR 			: out std_logic_vector(11 downto 0);
		SEL_ROM_5F 				: out std_logic
    );
end;

architecture RTL of PACMAN_VIDEO is

  signal sprite_xy_ram_wen  : std_logic;
  signal sprite_xy_ram_temp : std_logic_vector(7 downto 0);
  signal dr                 : std_logic_vector(7 downto 0);

  signal char_reg           : std_logic_vector(7 downto 0);
  signal char_sum_reg       : std_logic_vector(3 downto 0);
  signal char_match_reg     : std_logic;
  signal char_hblank_reg    : std_logic;
  signal char_hblank_reg_t1 : std_logic;
  signal db_reg             : std_logic_vector(7 downto 0);

  signal xflip              : std_logic;
  signal yflip              : std_logic;
  signal obj_on             : std_logic;

  signal ca                 : std_logic_vector(11 downto 0);
  signal char_rom_5e_dout   : std_logic_vector(7 downto 0);
  signal char_rom_5f_dout   : std_logic_vector(7 downto 0);
  signal cd                 : std_logic_vector(7 downto 0);

  signal shift_regl         : std_logic_vector(3 downto 0);
  signal shift_regu         : std_logic_vector(3 downto 0);
  signal shift_op           : std_logic_vector(1 downto 0);
  signal shift_sel          : std_logic_vector(1 downto 0);

  signal vout_obj_on        : std_logic;
  signal vout_yflip         : std_logic;
  signal vout_hblank        : std_logic;
  signal vout_db            : std_logic_vector(4 downto 0);

  signal cntr_ld            : std_logic;
  signal ra                 : std_logic_vector(7 downto 0);
  signal sprite_ram_ip      : std_logic_vector(3 downto 0);
  signal sprite_ram_op      : std_logic_vector(3 downto 0);
  signal sprite_ram_addr    : std_logic_vector(9 downto 0);
  signal sprite_ram_addr_t1 : std_logic_vector(9 downto 0);
  signal vout_obj_on_t1     : std_logic;
  signal col_rom_addr       : std_logic_vector(7 downto 0);

  signal lut_4a             : std_logic_vector(7 downto 0);
  signal lut_4a_t1          : std_logic_vector(7 downto 0);
  signal vout_hblank_t1     : std_logic;
  signal sprite_ram_reg     : std_logic_vector(3 downto 0);

  signal video_out          : std_logic_vector(7 downto 0);
  signal video_op_sel       : std_logic;
  signal final_col          : std_logic_vector(3 downto 0);
  signal lut_7f             : std_logic_vector(7 downto 0);

begin

  p_sprite_ram_comb : process(HBLANK, HCNT, WR2_L, sprite_xy_ram_temp)
  begin
    -- ram enable is low when HBLANK_L is 0 (for sprite access) or
    -- 2H is low (for cpu writes)
    -- we can simplify this

    sprite_xy_ram_wen <= '0';
    if (WR2_L = '0') then
      sprite_xy_ram_wen <= '1';
    end if;

    if (HBLANK = '1') then
      dr <= not sprite_xy_ram_temp;
    else
      dr <= "11111111"; -- pull ups on board
    end if;
  end process;

  sprite_xy_ram : for i in 0 to 7 generate
  -- should be a latch, but we are using a clock
  -- ops are disabled when ME_L is high or WE_L is low
  begin
    inst: RAM16X1D
      port map (
        a0    => ab(0),
        a1    => ab(1),
        a2    => ab(2),
        a3    => ab(3),
        dpra0 => ab(0),
        dpra1 => ab(1),
        dpra2 => ab(2),
        dpra3 => ab(3),
        wclk  => CLK_6,
        we    => sprite_xy_ram_wen,
        d     => db(i),
        dpo   => sprite_xy_ram_temp(i)
        );
  end generate;

  p_char_regs : process
    variable inc : std_logic;
    variable sum : std_logic_vector(8 downto 0);
    variable match : std_logic;
  begin
    wait until rising_edge (CLK_6);
    if (hcnt(2 downto 0) = "011") then  -- rising 4h
      inc := (not HBLANK);
      -- 1f, 2f
      sum := (VCNT(7 downto 0) & '1') + (dr & inc);
      -- 3e
      match := '0';
      if (sum(8 downto 5) = "1111") then
        match := '1';
      end if;
      -- 1h
      char_sum_reg     <= sum(4 downto 1);
      char_match_reg   <= match;
      char_hblank_reg  <= hblank;
      -- 4d
      db_reg <= db; -- character reg
    end if;
  end process;

  p_flip_comb : process(char_hblank_reg, FLIP, db_reg)
  begin
    if (char_hblank_reg = '0') then
      xflip     <= FLIP;
      yflip     <= FLIP;
    else
      xflip     <= db_reg(1);
      yflip     <= db_reg(0);
    end if;
  end process;

  p_char_addr_comb : process(db_reg, hcnt,
                             char_match_reg, char_sum_reg, char_hblank_reg,
                             xflip, yflip)
  begin
    -- 2h, 4e
    obj_on <= char_match_reg or hcnt(8); -- 256h not 256h_l

    ca(11 downto 6) <= db_reg(7 downto 2);

    if (char_hblank_reg = '0') then
      ca(5)     <= db_reg(1);
      ca(4)     <= db_reg(0);
    else
      ca(5)     <= char_sum_reg(3) xor xflip;
      ca(4)     <= hcnt(3);
    end if;

    ca(3) <= hcnt(2)         xor yflip;
    ca(2) <= char_sum_reg(2) xor xflip;
    ca(1) <= char_sum_reg(1) xor xflip;
    ca(0) <= char_sum_reg(0) xor xflip;
  end process;

  -- char roms
  --char_rom_5e : PACROM_5E
  --  port map (
  --    CLK         => CLK_6,
  --    ADDR        => ca,
  --    DATA        => char_rom_5e_dout
  --    );

  --char_rom_5f : PACROM_5F
  --  port map (
  --    CLK         => CLK_6,
  --    ADDR        => ca,
  --    DATA        => char_rom_5f_dout
  --    );

  -- BurchED:
	--process (CLK_6)
	--begin
	--	if (CLK_6'event and CLK_6 = '1') then
	--		cd <= CHAR_ROM_5E5F_DOUT;
	--	end if;
	--end process;
	cd <= CHAR_ROM_5E5F_DOUT;

  CHAR_ROM_ADDR <= ca;

  p_char_data_mux : process(char_hblank_reg, CHAR_ROM_5E5F_DOUT)
  begin
    -- 5l
    -- 5e 1
    -- 5f 3
    if (char_hblank_reg = '0') then
      SEL_ROM_5F <= '0';
    else
      SEL_ROM_5F <= '1';
    end if;
  end process;
--  p_char_data_mux : process(char_hblank_reg, char_rom_5e_dout, char_rom_5f_dout)
--  begin
--    -- 5l
--    -- 5e 1
--    -- 5f 3
--    if (char_hblank_reg = '0') then
--      cd <= char_rom_5e_dout;
--    else
--      cd <= char_rom_5f_dout;
--    end if;
--  end process;

  p_char_shift : process
  begin
    -- 4 bit shift req
    wait until rising_edge (CLK_6);
      case shift_sel is
        when "00" => null;

        when "01" => shift_regu <= '0' & shift_regu(3 downto 1);
                     shift_regl <= '0' & shift_regl(3 downto 1);

        when "10" => shift_regu <= shift_regu(2 downto 0) & '0';
                     shift_regl <= shift_regl(2 downto 0) & '0';

        when "11" => shift_regu <= cd(7 downto 4); -- load
                     shift_regl <= cd(3 downto 0);
        when others => null;
      end case;
  end process;

  p_char_shift_comb : process(hcnt, vout_yflip, shift_regu, shift_regl)
    variable ip : std_logic;
  begin
    ip := hcnt(0) and hcnt(1);
    if (vout_yflip = '0') then

      shift_sel(0) <= ip;
      shift_sel(1) <= '1';
      shift_op(0) <= shift_regl(3);
      shift_op(1) <= shift_regu(3);
    else

      shift_sel(0) <= '1';
      shift_sel(1) <= ip;
      shift_op(0) <= shift_regl(0);
      shift_op(1) <= shift_regu(0);
    end if;
  end process;

  p_video_out_reg : process
  begin
    wait until rising_edge (CLK_6);
    if (hcnt(2 downto 0) = "111") then
      vout_obj_on   <= obj_on;
      vout_yflip    <= yflip;
      vout_hblank   <= HBLANK;
      vout_db(4 downto 0) <= db(4 downto 0); -- colour reg
    end if;
  end process;

  p_lut_4a_comb : process(vout_db, shift_op)
  begin
    col_rom_addr <= '0' & vout_db(4 downto 0) & shift_op(1 downto 0);
  end process;

  col_rom_4a : PACROM_4A_DST
    port map (
      ADDR        => col_rom_addr,
      DATA        => lut_4a
      );

  p_cntr_ld : process(hcnt, vout_obj_on, vout_hblank)
    variable ena : std_ulogic;
  begin
    ena := '0';
    if (hcnt(3 downto 0) = "0111") then
      ena := '1';
    end if;
    cntr_ld <= ena and (vout_hblank or not vout_obj_on);
  end process;

  p_ra_cnt : process
  begin
    wait until rising_edge (CLK_6);
    if (cntr_ld = '1') then
      ra <= dr;
    else
      ra <= ra + "1";
    end if;
  end process;

  sprite_ram_addr <= "00" & ra;

  u_sprite_ram : RAMB4_S4_S4
    port map (
      -- read side
      DOB   => sprite_ram_op,
      DIB   => "0000",
      ADDRB => sprite_ram_addr,
      WEB   => '0',
      ENB   => '1',
      RSTB  => '0',
      CLKB  => CLK_6,
      -- write side, 1 clk later than original
      --DOA   =>
      DIA   => sprite_ram_ip,
      ADDRA => sprite_ram_addr_t1,
      WEA   => vout_obj_on_t1,
      ENA   => '1',
      RSTA  => '0',
      CLKA  => CLK_6
      );

  p_sprite_ram_op_comb : process(sprite_ram_op, vout_obj_on_t1)
  begin
    if vout_obj_on_t1 = '1' then
      sprite_ram_reg <= sprite_ram_op;
    else
      sprite_ram_reg <= "0000";
    end if;
  end process;

  p_video_op_sel_comb : process(sprite_ram_reg)
  begin
    video_op_sel <= '0'; -- no sprite
    if not (sprite_ram_reg = "0000") then
      video_op_sel <= '1';
    end if;
  end process;

  p_sprite_ram_ip_reg : process
  begin
    wait until rising_edge (CLK_6);
    sprite_ram_addr_t1 <= sprite_ram_addr;
    vout_obj_on_t1 <= vout_obj_on;
    vout_hblank_t1 <= vout_hblank;
    lut_4a_t1 <= lut_4a;

  end process;

  p_sprite_ram_ip_comb : process(vout_hblank_t1, video_op_sel, sprite_ram_reg, lut_4a_t1)
  begin
  -- 3a
    if (vout_hblank_t1 = '0') then
      sprite_ram_ip <= (others => '0');
    else
      if (video_op_sel = '1') then
        sprite_ram_ip <= sprite_ram_reg;
      else
        sprite_ram_ip <= lut_4a_t1(3 downto 0);
      end if;
    end if;
  end process;

  p_video_op_comb : process(vout_hblank, vblank, video_op_sel, sprite_ram_reg, lut_4a)
  begin
      -- 3b
    if (vout_hblank = '1') or (vblank = '1') then
      final_col <= (others => '0');
    else
      if (video_op_sel = '1') then
        final_col <= sprite_ram_reg; -- sprite
      else
        final_col <= lut_4a(3 downto 0);
      end if;
    end if;
  end process;

  col_rom_7f : PACROM_7F_DST
    port map (
      ADDR        => final_col,
      DATA        => lut_7f
      );

  p_final_reg : process
  begin
    wait until rising_edge (CLK_6);
    -- not really registered
    video_out <= lut_7f;
  end process;

  --  assign outputs
  B_OUT(1 downto 0) <= video_out(7 downto 6);
  G_OUT(2 downto 0) <= video_out(5 downto 3);
  R_OUT(2 downto 0) <= video_out(2 downto 0);

end architecture RTL;
