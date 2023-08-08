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
use std.textio.ALL;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_pacman_xilinx_prims.all;
use work.pkg_pacman.all;


entity PACMAN_TB is
end;

architecture Sim of PACMAN_TB is

  signal rom_data : std_logic_vector(7 downto 0);
  signal rom_addr : std_logic_vector(18 downto 0);
  signal rom_we_l : std_logic;
  signal rom_oe_l : std_logic;
  signal rom_ce_l : std_logic;
  signal clk_40 : std_logic;
  signal reset_l : std_logic;
  signal reset_h : std_logic;

  constant CLKPERIOD_40 : time := 25 ns;

  component PACMAN_PROGRAM_ROM
    port (
      DATA              : inout std_logic_vector( 7 downto 0);
      ADDR              : in    std_logic_vector(18 downto 0);
      WE_L              : in    std_logic;
      OE_L              : in    std_logic;
      CE_L              : in    std_logic
      );
  end component;

  component PACMAN
    port (
      BUTTON            : inout std_logic_vector(9 downto 0); -- active low
      AUDIO_OUT         : out   std_logic_vector(7 downto 0);

      VIDEO_R_OUT       : out   std_logic_vector(2 downto 0);
      VIDEO_G_OUT       : out   std_logic_vector(2 downto 0);
      VIDEO_B_OUT       : out   std_logic_vector(1 downto 0);

      HSYNC_OUT         : out   std_logic;
      VSYNC_OUT         : out   std_logic;
      COMP_SYNC_L_OUT   : out   std_logic;

      ROM_DATA          : inout std_logic_vector( 7 downto 0);
      ROM_ADDR          : out   std_logic_vector(18 downto 0);
      ROM_WE_L          : out   std_logic;
      ROM_OE_L          : out   std_logic;
      ROM_CE_L          : out   std_logic;

      RESET_L           : in    std_logic;
      CLK_40            : in    std_logic
      );
  end component;

begin
  u0 : PACMAN
    port map (
      BUTTON            => "HHHHHHHHHH",

      ROM_DATA          => ROM_DATA,
      ROM_ADDR          => ROM_ADDR,
      ROM_WE_L          => ROM_WE_L,
      ROM_OE_L          => ROM_OE_L,
      ROM_CE_L          => ROM_CE_L,

      RESET_L           => reset_l,
      CLK_40            => clk_40
      );

  u1 : PACMAN_PROGRAM_ROM
    port map (
      DATA              => ROM_DATA,
      ADDR              => ROM_ADDR,
      WE_L              => ROM_WE_L,
      OE_L              => ROM_OE_L,
      CE_L              => ROM_CE_L
      );

  p_clk_40  : process
  begin
    CLK_40 <= '0';
    wait for CLKPERIOD_40 / 2;
    CLK_40 <= '1';
    wait for CLKPERIOD_40 - (CLKPERIOD_40 / 2);
  end process;

  p_rst : process
  begin
    reset_l <= '0';
    reset_h <= '1';
    wait for 100 ns;
    reset_l <= '1';
    reset_h <= '0';
    wait;
  end process;

end Sim;

