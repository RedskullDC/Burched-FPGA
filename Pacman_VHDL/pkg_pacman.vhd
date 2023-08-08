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
-- version 002 pacman_dblscan added
-- version 001 initial release
--
-- Modification history (BurchED):
-- 6 July 2004, edited PACMAN_VIDEO to add extra signals
--  CHAR_ROM_5E5F_DOUT, CHAR_ROM_ADDR, SEL_ROM_5F.

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

package pkg_pacman is

  component PACROM_6E
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_6F
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_6H
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_6J
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_5E
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_5F
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(11 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_1M
    port (
      CLK         : in    std_logic;
      ADDR        : in    std_logic_vector(8 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_7F_DST
    port (
      ADDR        : in    std_logic_vector(3 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACROM_4A_DST
    port (
      ADDR        : in    std_logic_vector(7 downto 0);
      DATA        : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACMAN_VRAM_ADDR
    port (
      AB      : out   std_logic_vector (11 downto 0);
      H256_L  : in    std_logic;
      H128    : in    std_logic;
      H64     : in    std_logic;
      H32     : in    std_logic;
      H16     : in    std_logic;
      H8      : in    std_logic;
      H4      : in    std_logic;
      H2      : in    std_logic;
      H1      : in    std_logic;
      V128    : in    std_logic;
      V64     : in    std_logic;
      V32     : in    std_logic;
      V16     : in    std_logic;
      V8      : in    std_logic;
      V4      : in    std_logic;
      V2      : in    std_logic;
      V1      : in    std_logic;
      FLIP    : in    std_logic
      );
  end component;

  component PACMAN_RAMS
    port (
      AB     : in  std_logic_vector(11 downto 0);
      DIN    : in  std_logic_vector( 7 downto 0);
      DOUT   : out std_logic_vector( 7 downto 0);
      R_W_L  : in  std_logic;
      VRAM_L : in  std_logic;
      CLK    : in  std_logic
      );
  end component;

  component PACMAN_VIDEO
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
  end component;

  component PACMAN_DBLSCAN
    port (
      R_IN          : in    std_logic_vector( 2 downto 0);
      G_IN          : in    std_logic_vector( 2 downto 0);
      B_IN          : in    std_logic_vector( 1 downto 0);

      HSYNC_IN      : in    std_logic;
      VSYNC_IN      : in    std_logic;

      R_OUT         : out   std_logic_vector( 2 downto 0);
      G_OUT         : out   std_logic_vector( 2 downto 0);
      B_OUT         : out   std_logic_vector( 1 downto 0);

      HSYNC_OUT     : out   std_logic;
      VSYNC_OUT     : out   std_logic;

      CLK_6         : in    std_logic;
      CLK_12        : in    std_logic
      );
  end component;

  component PACMAN_MUL4
    port (
      A             : in    std_logic_vector(3 downto 0);
      B             : in    std_logic_vector(3 downto 0);
      R             : out   std_logic_vector(7 downto 0)
      );
  end component;

  component PACMAN_AUDIO
    port (
      HCNT          : in    std_logic_vector(8 downto 0);

      AB            : in    std_logic_vector(11 downto 0);
      DB            : in    std_logic_vector( 7 downto 0);

      WR1_L         : in    std_logic;
      WR0_L         : in    std_logic;
      SOUND_ON      : in    std_logic;

      AUDIO_OUT     : out   std_logic_vector(7 downto 0);
      CLK_6         : in    std_logic
      );
  end component;

  component T80sed is
      generic(
          Mode : integer := 0     -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
      );
      port(
          RESET_n         : in std_logic;
          CLK_n           : in std_logic;
          CLKEN           : in std_logic;
          WAIT_n          : in std_logic;
          INT_n           : in std_logic;
          NMI_n           : in std_logic;
          BUSRQ_n         : in std_logic;
          M1_n            : out std_logic;
          MREQ_n          : out std_logic;
          IORQ_n          : out std_logic;
          RD_n            : out std_logic;
          WR_n            : out std_logic;
          RFSH_n          : out std_logic;
          HALT_n          : out std_logic;
          BUSAK_n         : out std_logic;
          A               : out std_logic_vector(15 downto 0);
          DI              : in std_logic_vector(7 downto 0);
          DO              : out std_logic_vector(7 downto 0)

      );
  end component;

end;

package body pkg_pacman is

end;
