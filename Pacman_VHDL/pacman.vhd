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
-- The latest version of this file can be found at: www.fpgaarcade.com
--
-- Email pacman@fpgaarcade.com
--
-- Revision list
--
-- version 002 optional vga scan doubler
-- version 001 initial release
--
--	Modification History (BurchED):
-- 5 July 2004, changed ROM_ADDR width, 18..0 to 16..0.
-- 6 July 2004, removed IBUFG on CLK_40.
--  Put MikeJ's DBLSCAN into the design.
--  Changed divide on DLLs to 8 and 4.  CLK_40 is now a 48MHz input clock.
--  Brought the character rom signals up to the top level,
-- 12 July 2004, commented out line --ROM_DATA(7 downto 0) <= (others => 'Z'); -- d

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_pacman_xilinx_prims.all;
use work.pkg_pacman.all;
    --
    -- Notes :
    --
    -- Button shorts input to ground when pressed
    -- external pull ups of 1k are recommended.
    --
    -- Audio out :
    -- Use the following resistors for audio out DAC
    -- audio_out(7) 510   (MSB)
    -- audio_out(6) 1K
    -- audio_out(5) 2K2
    -- audio_out(4) 4K7
    -- audio_out(3) 10K
    -- audio_out(2) 22K
    -- audio_out(1) 47K
    -- audio_out(0) 100K  (LSB) -- common to amplifier
    --
    -- Video out DAC's. Values here give 0.7 Volt peek video output
    -- reduce resistor values for old arcade monitors
    --
    -- Use the following resistors for Red and Green Video DACs
    --
    -- video_out(2) 510
    -- video_out(1) 1k
    -- video_out(0) 2k

    -- Use the following resistors for Blue Video DAC
    -- video_out(1) 510
    -- video_out(0) 1k
    --

entity PACMAN is
  port (
    BUTTON						: inout std_logic_vector(9 downto 0); -- active low
    --
    AUDIO_OUT					: out   std_logic_vector(7 downto 0);
    --
    VIDEO_R_OUT				: out   std_logic_vector(2 downto 0);
    VIDEO_G_OUT				: out   std_logic_vector(2 downto 0);
    VIDEO_B_OUT				: out   std_logic_vector(1 downto 0);

    HSYNC_OUT					: out   std_logic;
    VSYNC_OUT					: out   std_logic;
    COMP_SYNC_L_OUT			: out   std_logic;

    ROM_DATA					: inout std_logic_vector( 7 downto 0);
    ROM_ADDR					: out   std_logic_vector(16 downto 0);
    ROM_WE_L					: out   std_logic;
    ROM_OE_L					: out   std_logic;
    ROM_CE_L					: out   std_logic;

    RESET_L						: in    std_logic;
    CLK_40						: in    std_logic;
	 CHAR_ROM_5E5F_DOUT		: in		std_logic_vector(7 downto 0);
	 CHAR_ROM_ADDR				: out		std_logic_vector(11 downto 0);
	 SEL_ROM_5F					: out		std_logic
    );
end;

architecture RTL of PACMAN is

    signal reset_dll_h      : std_logic;
    signal reset_l_sampled  : std_logic;
    signal clk_40_ibuf      : std_logic;

    signal clk_dlla_op0     : std_logic;
    signal clk_dlla_div     : std_logic;
    signal clk_dllb_op0     : std_logic;
    signal clk_dllb_div     : std_logic;

    signal clk_40_int       : std_logic;
    signal clk_40_intb      : std_logic;
    signal clk_12           : std_logic;
    signal clk_6            : std_logic;

    signal delay_count      : std_logic_vector (11 downto 0) := (others => '0');
    signal clk_cnt          : std_logic_vector(2 downto 0) := "000";

    -- timing
    signal hcnt             : std_logic_vector(8 downto 0) := "010000000"; -- 80
    signal vcnt             : std_logic_vector(8 downto 0) := "011111000"; -- 0F8

    signal do_hsync         : boolean;
    signal hsync            : std_logic;
    signal vsync            : std_logic;
    signal hblank           : std_logic;
    signal vblank           : std_logic := '1';
    signal h1_inv           : std_logic;
    signal comp_sync_l      : std_logic;

    -- cpu
    signal cpu_m1_l         : std_logic;
    signal cpu_mreq_l       : std_logic;
    signal cpu_iorq_l       : std_logic;
    signal cpu_rd_l         : std_logic;
    signal cpu_wr_l         : std_logic;
    signal cpu_rfsh_l       : std_logic;
    signal cpu_halt_l       : std_logic;
    signal cpu_wait_l       : std_logic;
    signal cpu_int_l        : std_logic;
    signal cpu_nmi_l        : std_logic;
    signal cpu_busrq_l      : std_logic;
    signal cpu_busak_l      : std_logic;
    signal cpu_addr         : std_logic_vector(15 downto 0);
    signal cpu_data_out     : std_logic_vector(7 downto 0);
    signal cpu_data_in      : std_logic_vector(7 downto 0);

    signal ext_rom_din      : std_logic_vector(7 downto 0);
    signal ext_rom_cs_l     : std_logic;
    signal sync_bus_cs_l    : std_logic;

    signal control_reg      : std_logic_vector(7 downto 0);
    --
    signal vram_addr_ab     : std_logic_vector(11 downto 0);
    signal ab               : std_logic_vector(11 downto 0);

    signal sync_bus_db      : std_logic_vector(7 downto 0);
    signal sync_bus_r_w_l   : std_logic;
    signal sync_bus_wreq_l  : std_logic;
    signal sync_bus_stb     : std_logic;

    signal cpu_vec_reg      : std_logic_vector(7 downto 0);
    signal sync_bus_reg     : std_logic_vector(7 downto 0);

    signal vram_l           : std_logic;
    signal rams_data_out    : std_logic_vector(7 downto 0);

    --     more decode
    signal wr0_l            : std_logic;
    signal wr1_l            : std_logic;
    signal wr2_l            : std_logic;
    signal iodec_out_l      : std_logic;
    signal iodec_wdr_l      : std_logic;
    signal iodec_in0_l      : std_logic;
    signal iodec_in1_l      : std_logic;
    signal iodec_dipsw_l    : std_logic;

    -- watchdog
    signal watchdog_cnt     : std_logic_vector(3 downto 0);
    signal watchdog_reset_l : std_logic;
    signal freeze           : std_logic;

    -- ip registers
    signal in0_reg          : std_logic_vector(7 downto 0);
    signal in1_reg          : std_logic_vector(7 downto 0);
    signal dipsw_reg        : std_logic_vector(7 downto 0);

    -- scan doubler signals
    signal video_r : std_logic_vector(2 downto 0);
    signal video_g : std_logic_vector(2 downto 0);
    signal video_b : std_logic_vector(1 downto 0);

    attribute CLKDV_DIVIDE : string;
    --attribute CLKDV_DIVIDE of CLKDLLA : label is "6.5";
    ----attribute CLKDV_DIVIDE of CLKDLLA : label is "6";
    --attribute CLKDV_DIVIDE of CLKDLLB : label is "3";

    attribute CLKDV_DIVIDE of CLKDLLA : label is "8";
    attribute CLKDV_DIVIDE of CLKDLLB : label is "4";
begin

  --
  -- Note about clocks
  --
  -- The following code is specific to Xilinx devices, and
  -- simply generates a 6 MHz clock from a 40 Mhz input.
  -- (the original uses a 6.144 MHz clock, so 40 / 6.5 = 6.15 Mhz)
  --
  -- If you are using the scan doubler, you need a clock at exactly 2x this 
  -- freq (12MHz) so it is recomended you use a 25 Mhz input clock, and divide 
  -- by 2 and 4 rather than the code here which is div 6 and div 3.
  -- Just change the attribute CLKDV_DIVIDE statements above.
  --
  --

  --IBUFG0 : IBUFG port map (I=> CLK_40,  O => clk_40_ibuf);
	clk_40_ibuf <= CLK_40;

  reset_dll_h <= not RESET_L;

  CLKDLLA : CLKDLL port map (
    CLKIN  => clk_40_ibuf,
    RST    => reset_dll_h,
    CLKFB  => clk_dlla_op0,
    CLKDV  => clk_dlla_div,
    CLK0   => clk_dlla_op0
    );

  --BUFG0 : BUFG port map (I=> clk_dlla_op0,O => clk_40_int);

  -- comment the following line out for simulation
  -- if dll model does not do divide by 6
  -- and replace with p_clkdiv process

  BUFG1 : BUFG port map (I=> clk_dlla_div,O => clk_6);

  CLKDLLB : CLKDLL port map (
    CLKIN  => clk_40_ibuf,
    RST    => reset_dll_h,
    CLKFB  => clk_dllb_op0,
    CLKDV  => clk_dllb_div,
    CLK0   => clk_dllb_op0
    );
  BUFG3 : BUFG port map (I=> clk_dllb_div,O => clk_12);

  --p_clkdiv : process
  --begin
    --wait until rising_edge(clk_40_int);
    --clk_cnt <= clk_cnt + '1';
  --end process;
  --clk_12 <= not clk_cnt(1);
  --clk_6 <= clk_cnt(2);

  --
  -- video timing
  --
  p_hvcnt : process
    variable hcarry,vcarry : boolean;
  begin
    wait until rising_edge(clk_6);
    hcarry := (hcnt = "111111111");
    if hcarry then
      hcnt <= "010000000"; -- 080
    else
      hcnt <= hcnt +"1";
    end if;
    -- hcnt 8 on circuit is 256H_L
    vcarry := (vcnt = "111111111");
    if do_hsync then
      if vcarry then
        vcnt <= "011111000"; -- 0F8
      else
        vcnt <= vcnt +"1";
      end if;
    end if;
  end process;

  p_sync_comb : process(hcnt, vcnt)
  begin
    vsync <= not vcnt(8);
    do_hsync <= (hcnt = "010101111"); -- 0AF
  end process;

  p_sync : process
  begin
    wait until rising_edge(clk_6);
    -- Timing hardware is coded differently to the real hw
    -- to avoid the use of multiple clocks. Result is identical.

    if (hcnt = "010001111") then -- 08F
      hblank <= '1';
    elsif (hcnt = "011101111") then
      hblank <= '0'; -- 0EF
    end if;

    if do_hsync then
      hsync <= '1';
    elsif (hcnt = "011001111") then -- 0CF
      hsync <= '0';
    end if;

    if do_hsync then
      if (vcnt = "111101111") then -- 1EF
        vblank <= '1';
      elsif (vcnt = "100001111") then -- 10F
        vblank <= '0';
      end if;
    end if;
  end process;

  p_comp_sync : process(hsync, vsync)
  begin
    comp_sync_l <= (not vsync) and (not hsync);
  end process;
  --
  -- cpu
  --
  p_cpu_wait_comb : process(freeze, sync_bus_wreq_l)
  begin
    cpu_wait_l  <= '1';
    if (freeze = '1') or (sync_bus_wreq_l = '0') then
      cpu_wait_l  <= '0';
    end if;
  end process;

  p_irq_req_watchdog : process
    variable rising_vblank : boolean;
  begin
    wait until rising_edge(clk_6);
    rising_vblank := do_hsync and (vcnt = "111101111"); -- 1EF
    --rising_vblank := do_hsync; -- debug
    -- interrupt 8c

    if (control_reg(0) = '0') then
      cpu_int_l <= '1';
    elsif rising_vblank then -- 1EF
      cpu_int_l <= '0';
    end if;

    -- watchdog 8c
    -- note sync reset
    if (reset_l_sampled = '0') then
      watchdog_cnt <= "1111";
    elsif (iodec_wdr_l = '0') then
      watchdog_cnt <= "0000";
    elsif rising_vblank and (freeze = '0') then
      watchdog_cnt <= watchdog_cnt + "1";
    end if;


    watchdog_reset_l <= '1';
    if (watchdog_cnt = "1111") then
      watchdog_reset_l <= '0';
    end if;
    --watchdog_reset_l <= reset_l_sampled; -- watchdog disable
  end process;

  -- other cpu signals
  cpu_busrq_l <= '1';
  cpu_nmi_l   <= '1';
  h1_inv <= not hcnt(0);

  u0 : T80sed
          generic map (Mode => 0)
          port map (
              RESET_n => watchdog_reset_l,
              CLK_n   => clk_6,
              CLKEN   => hcnt(0),
              WAIT_n  => cpu_wait_l,
              INT_n   => cpu_int_l,
              NMI_n   => cpu_nmi_l,
              BUSRQ_n => cpu_busrq_l,
              M1_n    => cpu_m1_l,
              MREQ_n  => cpu_mreq_l,
              IORQ_n  => cpu_iorq_l,
              RD_n    => cpu_rd_l,
              WR_n    => cpu_wr_l,
              RFSH_n  => cpu_rfsh_l,
              HALT_n  => cpu_halt_l,
              BUSAK_n => cpu_busak_l,
              A       => cpu_addr,
              DI      => cpu_data_in,
              DO      => cpu_data_out
              );
  --
  -- primary addr decode
  --
  p_mem_decode_comb : process(cpu_rfsh_l, cpu_rd_l, cpu_mreq_l, cpu_addr)
  begin
    -- rom     0x0000 - 0x3FFF
    -- syncbus 0x4000 - 0x7FFF

    -- 7M
    -- 7N
    sync_bus_cs_l <= '1';
    ext_rom_cs_l  <= '1';

    if (cpu_mreq_l = '0') and (cpu_rfsh_l = '1') then

      if (cpu_addr(14) = '0') and (cpu_rd_l = '0') then
        ext_rom_cs_l <= '0';
      end if;

      if (cpu_addr(14) = '1') then
        sync_bus_cs_l <= '0';
      end if;

    end if;
  end process;
  --
  -- sync bus custom ic
  --
  p_sync_bus_reg : process
  begin
    wait until rising_edge(clk_6);
    -- register on sync bus module that is used to store interrupt vector
    if (cpu_iorq_l = '0') and (cpu_m1_l = '1') then
      cpu_vec_reg <= cpu_data_out;
    end if;

    -- read holding reg
    if (hcnt(1 downto 0) = "01") then
      sync_bus_reg <= cpu_data_in;
    end if;

  end process;

  p_sync_bus_comb : process(cpu_rd_l, sync_bus_cs_l, hcnt)
  begin
    -- sync_bus_stb is now an active low clock enable signal
    sync_bus_stb <= '1';
    sync_bus_r_w_l <= '1';

    if (sync_bus_cs_l = '0') and (hcnt(1) = '0') then
      if (cpu_rd_l = '1') then
        sync_bus_r_w_l <= '0';
      end if;
      sync_bus_stb <= '0';
    end if;

    sync_bus_wreq_l <= '1';
    if (sync_bus_cs_l = '0') and (hcnt(1) = '1') and (cpu_rd_l = '0') then
      sync_bus_wreq_l <= '0';
    end if;
  end process;
  --
  -- vram addr custom ic
  --
  u_vram_addr : PACMAN_VRAM_ADDR
    port map (
      AB      => vram_addr_ab,
      H256_L  => hcnt(8),
      H128    => hcnt(7),
      H64     => hcnt(6),
      H32     => hcnt(5),
      H16     => hcnt(4),
      H8      => hcnt(3),
      H4      => hcnt(2),
      H2      => hcnt(1),
      H1      => hcnt(0),
      V128    => vcnt(7),
      V64     => vcnt(6),
      V32     => vcnt(5),
      V16     => vcnt(4),
      V8      => vcnt(3),
      V4      => vcnt(2),
      V2      => vcnt(1),
      V1      => vcnt(0),
      FLIP    => control_reg(3)
      );

  p_ab_mux_comb : process(hcnt, cpu_addr, vram_addr_ab)
  begin
    --When 2H is low, the CPU controls the bus.
    if (hcnt(1) = '0') then
      ab <= cpu_addr(11 downto 0);
    else
      ab <= vram_addr_ab;
    end if;
  end process;

  p_vram_comb : process(hcnt, cpu_addr, sync_bus_stb)
    variable a,b : std_logic;
  begin

    a := not (cpu_addr(12) or sync_bus_stb);
    b := hcnt(1) and hcnt(0);
    vram_l <= not (a or b);
  end process;

  p_io_decode_comb : process(sync_bus_r_w_l, sync_bus_stb, ab, cpu_addr)
    variable sel : std_logic_vector(2 downto 0);
    variable dec : std_logic_vector(7 downto 0);
    variable selb : std_logic_vector(1 downto 0);
    variable decb : std_logic_vector(3 downto 0);
  begin
    -- WRITE

    -- out_l 0x5000 - 0x503F control space

    -- wr0_l 0x5040 - 0x504F sound
    -- wr1_l 0x5050 - 0x505F sound
    -- wr2_l 0x5060 - 0x506F sprite

    --       0x5080 - 0x50BF unused

    -- wdr_l 0x50C0 - 0x50FF watchdog reset

    -- READ

    -- in0_l   0x5000 - 0x503F in port 0
    -- in1_l   0x5040 - 0x507F in port 1
    -- dipsw_l 0x5080 - 0x50BF dip switches

    -- 7J
    dec := "11111111";
    sel := sync_bus_r_w_l & ab(7) & ab(6);
    if (cpu_addr(12) = '1') and ( sync_bus_stb = '0')  then
      case sel is
        when "000" => dec := "11111110";
        when "001" => dec := "11111101";
        when "010" => dec := "11111011";
        when "011" => dec := "11110111";
        when "100" => dec := "11101111";
        when "101" => dec := "11011111";
        when "110" => dec := "10111111";
        when "111" => dec := "01111111";
        when others => null;
      end case;
    end if;
    iodec_out_l   <= dec(0);
    iodec_wdr_l   <= dec(3);

    iodec_in0_l   <= dec(4);
    iodec_in1_l   <= dec(5);
    iodec_dipsw_l <= dec(6);

    -- 7M
    decb := "1111";
    selb := ab(5) & ab(4);
    if (dec(1) = '0') then
      case selb is
        when "00" => decb := "1110";
        when "01" => decb := "1101";
        when "10" => decb := "1011";
        when "11" => decb := "0111";
        when others => null;
      end case;
    end if;
    wr0_l <= decb(0);
    wr1_l <= decb(1);
    wr2_l <= decb(2);

  end process;

  p_control_reg : process
    variable ena : std_logic_vector(7 downto 0);
  begin
    -- 8 bit addressable latch 7K
    -- (made into register)

    -- 0 interrupt ena
    -- 1 sound ena
    -- 2 not used
    -- 3 flip
    -- 4 1 player start lamp
    -- 5 2 player start lamp
    -- 6 coin lockout
    -- 7 coin counter

    wait until rising_edge(clk_6);

    ena := "00000000";
    if (iodec_out_l = '0') then
      case ab(2 downto 0) is
        when "000" => ena := "00000001";
        when "001" => ena := "00000010";
        when "010" => ena := "00000100";
        when "011" => ena := "00001000";
        when "100" => ena := "00010000";
        when "101" => ena := "00100000";
        when "110" => ena := "01000000";
        when "111" => ena := "10000000";
        when others => null;
      end case;
    end if;

    if (watchdog_reset_l = '0') then
      control_reg <= (others => '0');
    else
      for i in 0 to 7 loop
        if (ena(i) = '1') then
          control_reg(i) <= cpu_data_out(0);
        end if;
      end loop;
    end if;
  end process;

  p_db_mux_comb : process(hcnt, cpu_data_out, rams_data_out)
  begin
    -- simplified data source for video subsystem
    -- only cpu or ram are sources of interest
    if (hcnt(1) = '0') then
      sync_bus_db <= cpu_data_out;
    else
      sync_bus_db <= rams_data_out;
    end if;
  end process;

  p_cpu_data_in_mux_comb : process(cpu_addr, cpu_iorq_l, cpu_m1_l, cpu_vec_reg,
                                   sync_bus_wreq_l, sync_bus_reg,
                                   ext_rom_din, rams_data_out,
                                   iodec_in0_l, iodec_in1_l, iodec_dipsw_l,
                                   in0_reg, in1_reg, dipsw_reg)
  begin
    -- simplifed again
    if (cpu_iorq_l = '0') and (cpu_m1_l = '0') then
      cpu_data_in <= cpu_vec_reg;
    elsif (sync_bus_wreq_l = '0') then
      cpu_data_in <= sync_bus_reg;
    else
      if (cpu_addr(14) = '0') then
        cpu_data_in <= ext_rom_din;
      else
        cpu_data_in <= rams_data_out;
        if (iodec_in0_l = '0')   then cpu_data_in <= in0_reg; end if;
        if (iodec_in1_l = '0')   then cpu_data_in <= in1_reg; end if;
        if (iodec_dipsw_l = '0') then cpu_data_in <= dipsw_reg; end if;
      end if;
    end if;
  end process;

  u_rams : PACMAN_RAMS
    port map (
    -- note, we get a one clock delay from our rams
    AB     => ab,
    DIN    => cpu_data_out, -- cpu only source of ram data
    DOUT   => rams_data_out,
    R_W_L  => sync_bus_r_w_l,
    VRAM_L => vram_l,
    CLK    => clk_6
    );
  --
  -- video subsystem
  --
  u_video : PACMAN_VIDEO
    port map (
      HCNT						=> hcnt,
      VCNT						=> vcnt,

      AB							=> ab,
      DB							=> sync_bus_db,

      HBLANK					=> hblank,
      VBLANK					=> vblank,
      FLIP						=> control_reg(3),
      WR2_L						=> wr2_l,

      R_OUT						=> video_r,
      G_OUT						=> video_g,
      B_OUT						=> video_b,
      CLK_6						=> clk_6,
	 	CHAR_ROM_5E5F_DOUT 	=> CHAR_ROM_5E5F_DOUT,
		CHAR_ROM_ADDR 			=> CHAR_ROM_ADDR,
		SEL_ROM_5F 				=> SEL_ROM_5F
      );

  -- if PACMAN_DBLSCAN used, remember to add pacman_dblscan.vhd to the
  -- sythesis script you are using (pacman.prg for xst / webpack)
  --
  u_dblsacn : PACMAN_DBLSCAN
    port map (
      R_IN          => video_r,
      G_IN          => video_g,
      B_IN          => video_b,

      HSYNC_IN      => hsync,
      VSYNC_IN      => vsync,

      R_OUT         => VIDEO_R_OUT,
      G_OUT         => VIDEO_G_OUT,
      B_OUT         => VIDEO_B_OUT,

      HSYNC_OUT     => HSYNC_OUT,
      VSYNC_OUT     => VSYNC_OUT,

      CLK_6         => clk_6,
      CLK_12        => clk_12
      );

  -- comment out if PACMAN_DBLSCAN used
  --VIDEO_R_OUT     <= video_r;
  --VIDEO_G_OUT     <= video_g;
  --VIDEO_B_OUT     <= video_b;
  --HSYNC_OUT       <= hsync;
  --VSYNC_OUT       <= vsync;
  -- end comment out

  --
  COMP_SYNC_L_OUT <= comp_sync_l;
  --
  -- audio subsystem
  --

  u_audio : PACMAN_AUDIO
    port map (
      HCNT          => hcnt,

      AB            => ab,
      DB            => sync_bus_db,

      WR1_L         => wr1_l,
      WR0_L         => wr0_l,
      SOUND_ON      => control_reg(1),

      AUDIO_OUT     => AUDIO_OUT,
      CLK_6         => clk_6
      );

  -- optional pullups, not needed if external
  --BUTTON <= (others => 'Z');
  --p9 : PULLUP port map( O => BUTTON(9));
  --p8 : PULLUP port map( O => BUTTON(8));
  --p7 : PULLUP port map( O => BUTTON(7));
  --p6 : PULLUP port map( O => BUTTON(6));
  --p5 : PULLUP port map( O => BUTTON(5));
  --p4 : PULLUP port map( O => BUTTON(4));
  --p3 : PULLUP port map( O => BUTTON(3));
  --p2 : PULLUP port map( O => BUTTON(2));
  --p1 : PULLUP port map( O => BUTTON(1));
  --p0 : PULLUP port map( O => BUTTON(0));

  p_input_registers : process
  begin
    wait until rising_edge(clk_6);

    in0_reg(7) <= BUTTON(0); -- credit
    in0_reg(6) <= BUTTON(9); -- coin2
    in0_reg(5) <= BUTTON(8); -- coin1
    in0_reg(4) <= BUTTON(3); -- test_l dipswitch (rack advance)
    in0_reg(3) <= BUTTON(5); -- p1 down
    in0_reg(2) <= BUTTON(7); -- p1 right
    in0_reg(1) <= BUTTON(6); -- p1 left
    in0_reg(0) <= BUTTON(4); -- p1 up

    in1_reg(7) <= '0'; -- table
    in1_reg(6) <= BUTTON(2); -- start2
    in1_reg(5) <= BUTTON(1); -- start1
    in1_reg(4) <= '1'; -- test
    in1_reg(3) <= '1'; -- p2 down
    in1_reg(2) <= '1'; -- p2 right
    in1_reg(1) <= '1'; -- p2 left
    in1_reg(0) <= '1'; -- p2 up

    -- on is low
    freeze <= '0';
    dipsw_reg(7) <= '1'; -- character set ?
    dipsw_reg(6) <= '1'; -- difficulty ?
    dipsw_reg(5 downto 4) <= "00"; -- bonus pacman at 10K
    dipsw_reg(3 downto 2) <= "10"; -- pacman (3)
    dipsw_reg(1 downto 0) <= "01"; -- cost  (1 coin, 1 play)
  end process;

  p_delay : process(RESET_L, clk_6)
  begin
    if (RESET_L = '0') then
      delay_count <= x"000";
      reset_l_sampled <= '0';
    elsif rising_edge(clk_6) then
      if (delay_count(11 downto 0) = (x"FFF")) then
        delay_count <= (x"000");
        reset_l_sampled <= RESET_L;
      else
        delay_count <= delay_count + "1";
      end if;
    end if;
  end process;
  --reset_l_sampled <= RESET_L; -- simulation

  p_ext_rom : process(ROM_DATA, cpu_addr)
  begin
    --BurchED, commented out following line - don't want pullups on active driven R0M_DATA
    --ROM_DATA(7 downto 0) <= (others => 'Z'); -- d
    -- comment next line out if using internal program rom below
    ext_rom_din <= ROM_DATA(7 downto 0);
    ROM_ADDR(16 downto 0) <= "0" & cpu_addr(15 downto 0);
    ROM_WE_L <= '1'; -- we_l
    ROM_OE_L <= '0'; -- oe_l
    ROM_CE_L <= '0'; -- ce_l
  end process;

  -- example of internal program rom, if you have a big enough device
  --urom : pacrom_6e
    --port map (
      --ADDR        => cpu_addr(11 downto 0),
      --DATA        => ext_rom_din,
      --CLK         => clk_6
      --);

end RTL;
