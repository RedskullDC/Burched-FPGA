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
-- version 001 initial release
--
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_pacman_xilinx_prims.all;
use work.pkg_pacman.all;

entity PACMAN_RAMS is
  port (
  AB     : in  std_logic_vector(11 downto 0);
  DIN    : in  std_logic_vector( 7 downto 0);
  DOUT   : out std_logic_vector( 7 downto 0);
  R_W_L  : in  std_logic;
  VRAM_L : in  std_logic;
  CLK    : in  std_logic
  );
end;

architecture RTL of PACMAN_RAMS is

  signal dout_v_u : std_logic_vector(3 downto 0);
  signal dout_v_l : std_logic_vector(3 downto 0);
  signal dout_c_u : std_logic_vector(3 downto 0);
  signal dout_c_l : std_logic_vector(3 downto 0);
  signal dout_w_u : std_logic_vector(3 downto 0);
  signal dout_w_l : std_logic_vector(3 downto 0);
  signal cs       : std_logic_vector(3 downto 0);
  signal we_v     : std_logic;
  signal we_c     : std_logic;
  signal we_w     : std_logic;

begin
  v1 : component RAMB4_S4
    port map (
      do   => dout_v_u,
      di   => DIN(7 downto 4),
      addr => AB(9 downto 0),
      we   => we_v,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  v0 : component RAMB4_S4
    port map (
      do   => dout_v_l,
      di   => DIN(3 downto 0),
      addr => AB(9 downto 0),
      we   => we_v,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  c1 : component RAMB4_S4
    port map (
      do   => dout_c_u,
      di   => DIN(7 downto 4),
      addr => AB(9 downto 0),
      we   => we_c,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  c0 : component RAMB4_S4
    port map (
      do   => dout_c_l,
      di   => DIN(3 downto 0),
      addr => AB(9 downto 0),
      we   => we_c,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  w1 : component RAMB4_S4
    port map (
      do   => dout_w_u,
      di   => DIN(7 downto 4),
      addr => AB(9 downto 0),
      we   => we_w,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  w0 : component RAMB4_S4
    port map (
      do   => dout_w_l,
      di   => DIN(3 downto 0),
      addr => AB(9 downto 0),
      we   => we_w,
      en   => '1',
      rst  => '0',
      clk  => CLK
      );

  p_cs_comb  : process(AB, VRAM_L)
  begin
    cs <= "1111";
    if (VRAM_L = '0') then
      case AB(11 downto 10) is
        when "00" => cs <= "1110";
        when "01" => cs <= "1101";
        when "10" => cs <= "1011";
        when "11" => cs <= "0111";
        when others => null;
      end case;
    end if;
  end process;

  p_we_comb  : process(R_W_L, CS)
  begin
    we_v <= not cs(0) and not R_W_L;
    we_c <= not cs(1) and not R_W_L;
    we_w <= not cs(3) and not R_W_L;
  end process;

  p_mux_comb : process(AB, dout_v_u, dout_v_l, dout_c_u, dout_c_l, dout_w_u, dout_w_l)
  begin
    DOUT <= (others => '0');
    case AB(11 downto 10) is
      when "00" => DOUT <= (dout_v_u & dout_v_l);
      when "01" => DOUT <= (dout_c_u & dout_c_l);
      when "10" => DOUT <= (others => '0');
      when "11" => DOUT <= (dout_w_u & dout_w_l);
      when others => null;
    end case;
  end process;

end architecture RTL;
