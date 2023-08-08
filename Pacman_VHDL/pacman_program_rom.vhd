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

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

use work.pkg_pacman_xilinx_prims.all;
use work.pkg_pacman.all;

--
-- This is a crude SIMULATION model of an external flash rom
-- If you have a big enough device you could add a real clock to it
-- and include it into the top level design.
--
entity PACMAN_PROGRAM_ROM is
  port (
    DATA              : inout std_logic_vector( 7 downto 0);
    ADDR              : in    std_logic_vector(18 downto 0);
    WE_L              : in    std_logic;
    OE_L              : in    std_logic;
    CE_L              : in    std_logic
    );
end;

architecture RTL of PACMAN_PROGRAM_ROM is
  signal clk : std_logic := '0';
  signal rom_data_0 : std_logic_vector(7 downto 0);
  signal rom_data_1 : std_logic_vector(7 downto 0);
  signal rom_data_2 : std_logic_vector(7 downto 0);
  signal rom_data_3 : std_logic_vector(7 downto 0);
  signal rom_data   : std_logic_vector(7 downto 0);

begin
  clk <= not clk after 5 ns;

  u_6e : PACROM_6E
    port map (
      CLK         => clk,
      ADDR        => ADDR(11 downto 0),
      DATA        => rom_data_0
      );

  u_6f : PACROM_6F
    port map (
      CLK         => clk,
      ADDR        => ADDR(11 downto 0),
      DATA        => rom_data_1
      );

  u_6h : PACROM_6H
    port map (
      CLK         => clk,
      ADDR        => ADDR(11 downto 0),
      DATA        => rom_data_2
      );

  u_6j : PACROM_6J
    port map (
      CLK         => clk,
      ADDR        => ADDR(11 downto 0),
      DATA        => rom_data_3
      );

  p_rom_data : process(ADDR,rom_data_0,rom_data_1,rom_data_2,rom_data_3)
  begin
    case ADDR(13 downto 12) is
      when "00" => rom_data <= rom_data_0;
      when "01" => rom_data <= rom_data_1;
      when "10" => rom_data <= rom_data_2;
      when "11" => rom_data <= rom_data_3;
      when others => null;
    end case;
  end process;

  DATA(7 downto 0) <= rom_data after 80 ns;
end RTL;
