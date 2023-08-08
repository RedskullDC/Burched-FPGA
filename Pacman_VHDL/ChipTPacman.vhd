-- File:
--			ChipTPacman.vhd
-- Other source files needed:
--			pacman.vhd, MikeJ, www.fpgaarcade.com
-- Abstract:
--			Hardware implementation of the original Namco Pacman arcade board.
--			Built on the Pacman design, by MikeJ.
--  Notices:
-- 		(C) Copyright 2004 Burch Electronic Designs, All Rights Reserved.
--			This code is intended for academic, teaching and research purposes.
--			All references and sources consulted in producing this code are cited below.
--			Please cite all references and sources in any derivative works.
-- References:
--			Pacman, MikeJ, www.fpgaarcade.com
-- References notes:
-- Author:
--			Burch Electronic Designs, http://www.BurchED.biz
-- Target Device:
--			XC2S300e-6PQ208C
-- Build Environment:
--			WebPACK 4.1
-- Target Boards:
--			B5-X300,							Mainboard
--			B5-SRAM,							SLOTS A & B
--			B5-Periheral-Connectors,	SLOT C
--			B5-Advanced-Download,		SLOT D
--			B5-Compact-Flash,				SLOTS E & F
--			Switches,						SLOT G
--			B5-Audio-Out,					SLOT H
-- Clk Frequency:
--			48MHz
-- Modification History:
--			5 July 2004
-- Notes:
--			Number of Slices for implementation = ?
-- User constraints
-- 		(copy these constraints into your UCF file - don't forget
--			to delete the "--" at the beginning of each line):

--NET "clk" LOC = "P77";
--NET "rst_n" LOC = "P57";
--NET "SRAM_A<0>" LOC = "P24";
--NET "SRAM_A<1>" LOC = "P23";
--NET "SRAM_A<2>" LOC = "P22";
--NET "SRAM_A<3>" LOC = "P21";
--NET "SRAM_A<4>" LOC = "P20";
--NET "SRAM_A<5>" LOC = "P18";
--NET "SRAM_A<6>" LOC = "P17";
--NET "SRAM_A<7>" LOC = "P16";
--NET "SRAM_A<8>" LOC = "P15";
--NET "SRAM_A<9>" LOC = "P11";
--NET "SRAM_A<10>" LOC = "P10";
--NET "SRAM_A<11>" LOC = "P9";
--NET "SRAM_A<12>" LOC = "P8";
--NET "SRAM_A<13>" LOC = "P7";
--NET "SRAM_A<14>" LOC = "P6";
--NET "SRAM_A<15>" LOC = "P5";
--NET "SRAM_A<16>" LOC = "P4";
--NET "SRAM_D<0>" LOC = "P49";
--NET "SRAM_D<1>" LOC = "P48";
--NET "SRAM_D<2>" LOC = "P47";
--NET "SRAM_D<3>" LOC = "P46";
--NET "SRAM_D<4>" LOC = "P45";
--NET "SRAM_D<5>" LOC = "P44";
--NET "SRAM_D<6>" LOC = "P43";
--NET "SRAM_D<7>" LOC = "P42";
--#NET "SRAM_D<8>" LOC = "P41";
--#NET "SRAM_D<9>" LOC = "P40";
--#NET "SRAM_D<10>" LOC = "P36";
--#NET "SRAM_D<11>" LOC = "P35";
--#NET "SRAM_D<12>" LOC = "P34";
--#NET "SRAM_D<13>" LOC = "P33";
--#NET "SRAM_D<14>" LOC = "P31";
--#NET "SRAM_D<15>" LOC = "P30";
--NET "SRAM_CE_n" LOC = "P3";
--NET "SRAM_WE_LowerByte_n" LOC = "P29";
--NET "SRAM_WE_UpperByte_n" LOC = "P27";
--#NET "BUTTON<0>" LOC = "P178";
--#NET "BUTTON<1>" LOC = "P176";
--#NET "BUTTON<2>" LOC = "P175";
--#NET "BUTTON<3>" LOC = "P168";
--#NET "BUTTON<4>" LOC = "P167";
--#NET "BUTTON<5>" LOC = "P166";
--#NET "BUTTON<6>" LOC = "P165";
--#NET "BUTTON<7>" LOC = "P164";
--#NET "BUTTON<8>" LOC = "P163";
--#NET "BUTTON<9>" LOC = "P162";
--NET "DeltaSigmaDacOut" LOC = "P188";
--NET	"VIDEO_R_OUT<1>" LOC = "P63";
--NET "VIDEO_R_OUT<0>" LOC = "P62";
--NET	"VIDEO_G_OUT<1>" LOC = "P61";
--NET "VIDEO_G_OUT<0>" LOC = "P60";
--NET	"VIDEO_B_OUT<1>" LOC = "P59";
--NET	"VIDEO_B_OUT<0>" LOC = "P58";
--NET	"HSYNC_OUT" LOC = "P56";
--NET	"VSYNC_OUT" LOC = "P55";
--#NET "COMP_SYNC_L_OUT" LOC = "";
--NET "Keyboard_Clk" LOC = "P64";
--NET "Keyboard_Data" LOC = "P68";
--NET "Seg_b0" LOC = "P169";
--NET "Seg_a0" LOC = "P168";
--NET "Seg_f0" LOC = "P167";
--NET "Seg_g0" LOC = "P166";
--NET "Seg_c0" LOC = "P165";
--NET "Seg_d0" LOC = "P164";
--NET "Seg_e0" LOC = "P163";
--NET "Seg_b1" LOC = "P180";
--NET "Seg_a1" LOC = "P179";
--NET "Seg_f1" LOC = "P178";
--NET "Seg_g1" LOC = "P176";
--NET "Seg_c1" LOC = "P175";
--NET "Seg_d1" LOC = "P174";
--NET "Seg_e1" LOC = "P173";
--NET "Seg_dp1" LOC = "P161";
--NET "Seg_dp0" LOC = "P162";

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.pkg_pacman_xilinx_prims.all;

entity ChipTPacman is
    Port (
	 	Clk 						: in STD_LOGIC;
		Rst_n 					: in STD_LOGIC;
		DeltaSigmaDacOut		: out STD_LOGIC;
		VIDEO_R_OUT       	: out std_logic_vector(1 downto 0);
		VIDEO_G_OUT       	: out std_logic_vector(1 downto 0);
		VIDEO_B_OUT       	: out std_logic_vector(1 downto 0);
		HSYNC_OUT         	: out std_logic;
		VSYNC_OUT         	: out std_logic;
		--COMP_SYNC_L_OUT   	: out std_logic;
		SRAM_A 					: out STD_LOGIC_VECTOR (16 downto 0);
		SRAM_D 					: inout STD_LOGIC_VECTOR (7 downto 0);
		SRAM_CE_n 				: out STD_LOGIC;
		SRAM_WE_LowerByte_n 	: out STD_LOGIC;
		SRAM_WE_UpperByte_n 	: out STD_LOGIC;
		Keyboard_Clk			: in STD_LOGIC;
		Keyboard_Data			: in STD_LOGIC;
		Seg_b0 					: out STD_LOGIC;
		Seg_a0 					: out STD_LOGIC;
		Seg_f0 					: out STD_LOGIC;
		Seg_g0 					: out STD_LOGIC;
		Seg_c0 					: out STD_LOGIC;
		Seg_d0 					: out STD_LOGIC;
		Seg_e0 					: out STD_LOGIC;
		Seg_b1 					: out STD_LOGIC;
		Seg_a1 					: out STD_LOGIC;
		Seg_f1 					: out STD_LOGIC;
		Seg_g1 					: out STD_LOGIC;
		Seg_c1 					: out STD_LOGIC;
		Seg_d1 					: out STD_LOGIC;
		Seg_e1 					: out STD_LOGIC;
		Seg_dp1 					: out STD_LOGIC;
		Seg_dp0 					: out STD_LOGIC
	);
end ChipTPacman;

architecture RTL of ChipTPacman is

component PACMAN
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
end component;

component DeltaSigmaDac8
	port (
		Clk 		: in STD_LOGIC;
		Rst 		: in STD_LOGIC;
		DacIn 	: in STD_LOGIC_VECTOR(7 downto 0);
		DacOut 	: out STD_LOGIC 
	);
end component;

component RomShare
	port (
		Rst 						: in STD_LOGIC;
		Clk 						: in STD_LOGIC;
		SRAM_A 					: out STD_LOGIC_VECTOR (16 downto 0);
		SRAM_D 					: inout STD_LOGIC_VECTOR (7 downto 0);
		SRAM_CE_n 				: out STD_LOGIC;
		SRAM_WE_LowerByte_n 	: out STD_LOGIC;
		SRAM_WE_UpperByte_n 	: out STD_LOGIC;
		A_Rom_Addr				: in STD_LOGIC_VECTOR (16 downto 0);
		A_Rom_Data				: inout STD_LOGIC_VECTOR (7 downto 0);
		B_Rom_Addr				: in STD_LOGIC_VECTOR (16 downto 0);
		B_Rom_Data				: inout STD_LOGIC_VECTOR (7 downto 0)
	);
end component;

component TickGen
	port (
		Rst 						: in STD_LOGIC;
		Clk 						: in STD_LOGIC;
		Tick						: out STD_LOGIC
	);
end component;

component ps2kbd
	port(
		Rst_n			: in std_logic;
		Clk			: in std_logic;
		Tick1us		: in std_logic;
		PS2_Clk		: in std_logic;
		PS2_Data		: in std_logic;
		Press			: out std_logic;
		Release		: out std_logic;
		Reset			: out std_logic;
		ScanCode		: out std_logic_vector(7 downto 0)
	);
end component;

component SevenSegDecoder
	Port (
		Clk : in STD_LOGIC;
		Rst : in STD_LOGIC;
		HexDigit : in STD_LOGIC_VECTOR(3 downto 0);
		DecimalPoint : in STD_LOGIC;
		a : out STD_LOGIC;
		b : out STD_LOGIC;
		c : out STD_LOGIC;
		d : out STD_LOGIC;
		e : out STD_LOGIC;
		f : out STD_LOGIC;
		g : out STD_LOGIC;
		dp : out STD_LOGIC
	);
end component;

signal Rst 									: STD_LOGIC;
signal Clk_Buf 							: STD_LOGIC;
signal Pacman_AUDIO_OUT 				: STD_LOGIC_VECTOR(7 downto 0);
signal Pacman_ROM_DATA 					: STD_LOGIC_VECTOR(7 downto 0);
signal Pacman_VIDEO_R_OUT				: std_logic_vector(2 downto 0);
signal Pacman_VIDEO_G_OUT				: std_logic_vector(2 downto 0);
signal Pacman_VIDEO_B_OUT				: std_logic_vector(1 downto 0);
signal Pacman_CHAR_ROM_5E5F_DOUT 	: std_logic_vector(7 downto 0);
signal Pacman_CHAR_ROM_ADDR			: std_logic_vector(11 downto 0);
signal Pacman_SEL_ROM_5F 				: std_logic;
signal A_Rom_Addr							: STD_LOGIC_VECTOR (16 downto 0);
signal A_Rom_Data							: STD_LOGIC_VECTOR (7 downto 0);
signal B_Rom_Addr							: STD_LOGIC_VECTOR (16 downto 0);
signal B_Rom_Data							: STD_LOGIC_VECTOR (7 downto 0);
signal Tick									: STD_LOGIC;
signal Keyboard_Press					: std_logic;
signal Keyboard_Release					: std_logic;
signal Keyboard_Reset					: std_logic;
signal Keyboard_ScanCode				: std_logic_vector(7 downto 0);
signal Buttons_n							: std_logic_vector(9 downto 0);
signal Buttons								: std_logic_vector(9 downto 0);
signal Seg_HexDigit0 					: STD_LOGIC_VECTOR(3 downto 0);
signal Seg_HexDigit1 					: STD_LOGIC_VECTOR(3 downto 0);
signal DecimalPoint0						: std_logic;
signal DecimalPoint1						: std_logic; 

begin

	uIBUFG0001 : IBUFG port map (I=> Clk,  O => Clk_Buf);

	Rst <= not Rst_n;

	-- ROM share core.  Time multiplexes access to the external SRAM, so that
	-- it can be used as two ROMs.

	-- A_Rom is the "program Rom".
	-- B_Rom is the "video character Rom".
	uRomShare0001 : RomShare
	port map (
		Rst 						=>	Rst,							--: in STD_LOGIC;
		Clk 						=>	Clk_Buf,						--: in STD_LOGIC;
		SRAM_A 					=>	SRAM_A,						--: out STD_LOGIC_VECTOR (16 downto 0);
		SRAM_D 					=>	SRAM_D,						--: inout STD_LOGIC_VECTOR (15 downto 0);
		SRAM_CE_n 				=>	SRAM_CE_n,					--: out STD_LOGIC;
		SRAM_WE_LowerByte_n 	=>	SRAM_WE_LowerByte_n,		--: out STD_LOGIC;
		SRAM_WE_UpperByte_n 	=>	SRAM_WE_UpperByte_n,		--: out STD_LOGIC;
		A_Rom_Addr				=>	A_Rom_Addr,					--: in STD_LOGIC_VECTOR (16 downto 0);
		A_Rom_Data				=>	A_Rom_Data,					--: inout STD_LOGIC_VECTOR (15 downto 0);
		B_Rom_Addr				=>	B_Rom_Addr,					--: in STD_LOGIC_VECTOR (16 downto 0);
		B_Rom_Data				=>	B_Rom_Data					--: inout STD_LOGIC_VECTOR (15 downto 0)
	);

	Pacman_ROM_DATA 				<= A_Rom_Data;
	B_Rom_Addr(16 downto 0) 	<= ( "0010" & Pacman_SEL_ROM_5F & Pacman_CHAR_ROM_ADDR(11 downto 0) );
	Pacman_CHAR_ROM_5E5F_DOUT	<= B_Rom_Data;

	-- Object colour info is in "pacrom_7f_dst.vhd".
	VIDEO_R_OUT(0) <= Pacman_VIDEO_R_OUT(1);
	VIDEO_R_OUT(1) <= Pacman_VIDEO_R_OUT(2);
	VIDEO_G_OUT(0) <= Pacman_VIDEO_G_OUT(1);
	VIDEO_G_OUT(1) <= Pacman_VIDEO_G_OUT(2);
	VIDEO_B_OUT(0) <= Pacman_VIDEO_B_OUT(0);
	VIDEO_B_OUT(1) <= Pacman_VIDEO_B_OUT(1);

	-- The pacman core.

	uPACMAN0001 : PACMAN
	port map (
		BUTTON 					=> Buttons_n,							--: inout std_logic_vector(9 downto 0);
		AUDIO_OUT 				=> Pacman_AUDIO_OUT,					--: out   std_logic_vector(7 downto 0);
		VIDEO_R_OUT 			=> Pacman_VIDEO_R_OUT,				--: out   std_logic_vector(2 downto 0);
		VIDEO_G_OUT 			=> Pacman_VIDEO_G_OUT, 				--: out   std_logic_vector(2 downto 0);
		VIDEO_B_OUT 			=> Pacman_VIDEO_B_OUT, 				--: out   std_logic_vector(1 downto 0);
		HSYNC_OUT 				=> HSYNC_OUT, 							--: out   std_logic;
		VSYNC_OUT 				=> VSYNC_OUT, 							--: out   std_logic;
		COMP_SYNC_L_OUT 		=> open, 								--: out   std_logic;
		ROM_DATA 				=> Pacman_ROM_DATA,					--: inout std_logic_vector( 7 downto 0);
		ROM_ADDR 				=> A_Rom_Addr, 						--: out   std_logic_vector(16 downto 0);
		ROM_WE_L 				=> open, 								--: out   std_logic;		-- Always '1'
		ROM_OE_L 				=> open, 								--: out   std_logic;		-- Always '0'
		ROM_CE_L 				=> open, 								--: out   std_logic;		-- Always '0'
		RESET_L 					=> Rst_n, 								--: in    std_logic;
		CLK_40 					=> Clk_Buf, 							--: in    std_logic
	 	CHAR_ROM_5E5F_DOUT	=>	Pacman_CHAR_ROM_5E5F_DOUT,		--: in		std_logic_vector(7 downto 0);
	 	CHAR_ROM_ADDR 			=>	Pacman_CHAR_ROM_ADDR,			--: out		std_logic_vector(11 downto 0);
	 	SEL_ROM_5F				=>	Pacman_SEL_ROM_5F					--: out		std_logic
	);

	-- Delta-sigma digital to analog converter.

	uDeltaSigmaDac80001 : DeltaSigmaDac8
	port map (
		Clk 		=> Clk_Buf, 				--: in STD_LOGIC;
		Rst 		=> Rst,						--: in STD_LOGIC;
		DacIn 	=> Pacman_AUDIO_OUT,		--: in STD_LOGIC_VECTOR(7 downto 0);
		DacOut 	=> DeltaSigmaDacOut		--: out STD_LOGIC 
	);

	-- Keyboard interface.

	uTickGen0001 : TickGen
	port map (
		Rst		=> Rst, 						--: in STD_LOGIC;
		Clk		=> Clk_Buf,					--: in STD_LOGIC;
		Tick		=> Tick						--: out STD_LOGIC
	);		

	ups2kbd0001 : ps2kbd
	port map (
		Rst_n		=>	Rst_n,					--: in std_logic;
		Clk		=> Clk_Buf,					--: in std_logic;
		Tick1us	=> Tick,						--: in std_logic;
		PS2_Clk	=> Keyboard_Clk,			--: in std_logic;
		PS2_Data	=> Keyboard_Data,			--: in std_logic;
		Press		=> Keyboard_Press,		--: out std_logic;
		Release	=>	Keyboard_Release,		--: out std_logic;
		Reset		=>	Keyboard_Reset,		--: out std_logic;
		ScanCode	=> Keyboard_ScanCode		--: out std_logic_vector(7 downto 0)
	);
	
	Buttons_n(0) <= not Buttons(0);
	Buttons_n(1) <= not Buttons(1);
	Buttons_n(2) <= not Buttons(2);
	Buttons_n(3) <= not Buttons(3);
	Buttons_n(4) <= not Buttons(4);
	Buttons_n(5) <= not Buttons(5);
	Buttons_n(6) <= not Buttons(6);
	Buttons_n(7) <= not Buttons(7);
	Buttons_n(8) <= not Buttons(8);
	Buttons_n(9) <= not Buttons(9);

	process (Clk_Buf, Rst_n)
	begin
		if Rst_n = '0' then
			Buttons <= (others => '0');
		elsif Clk_Buf'event and Clk_Buf = '1' then
			if (Keyboard_Press or Keyboard_Release) = '1' then
				if Keyboard_ScanCode = x"5a" then		-- Credit, Key = Enter
					Buttons(0) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"16" then		-- Start1, Key = 1
					Buttons(1) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"1e" then		-- Start2, Key = 2
					Buttons(2) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"2c" then		-- Test1, Key = T
					Buttons(3) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"75" then		-- Player1 Up, Key = Up Arrow
					Buttons(4) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"72" then		-- Player1 Down, Key = Down Arrow
					Buttons(5) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"6b" then		-- Player1 Left, Key = Left Arrow
					Buttons(6) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"74" then		-- Player1 Right, Key = Right Arrow
					Buttons(7) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"21" then		-- Coin1, Key = C
					Buttons(8) <= Keyboard_Press;
				end if;
				if Keyboard_ScanCode = x"29" then		-- Coin2, Key = Spacebar
					Buttons(9) <= Keyboard_Press;
				end if;
			end if;
			if Keyboard_Reset = '1' then
				Buttons <= (others => '0');
			end if;
		end if;
	end process;

	-- 7-Segment-Displays.

	--Display "48".
	Seg_HexDigit0 <= "0100"; -- 4, left
	Seg_HexDigit1 <= "1000"; -- 8, right
	-- Turn off decimal points.
	DecimalPoint0 <= '0';
	DecimalPoint1 <= '0';
	-- SevenSegDecoder0, hex digit 0
	uSevenSegDecoder0 : SevenSegDecoder port map (
		Clk => Clk_Buf,
		Rst => Rst,
		HexDigit => Seg_HexDigit0,
		DecimalPoint => DecimalPoint0,
		a => Seg_a0,
		b => Seg_b0,
		c => Seg_c0,
		d => Seg_d0,
		e => Seg_e0,
		f => Seg_f0,
		g => Seg_g0,
		dp => Seg_dp0
	);
	-- SevenSegDecoder1, hex digit 1
	uSevenSegDecoder1 : SevenSegDecoder port map (
		Clk => Clk_Buf,
		Rst => Rst,
		HexDigit => Seg_HexDigit1,
		DecimalPoint => DecimalPoint1,
		a => Seg_a1,
		b => Seg_b1,
		c => Seg_c1,
		d => Seg_d1,
		e => Seg_e1,
		f => Seg_f1,
		g => Seg_g1,
		dp => Seg_dp1
	);


end RTL;





-- File:
--			RomShare.vhd
-- Other source files needed:
--			-
-- Abstract:
--			Time multiplexed interface, so that two devices can access a single ROM.
--  Notices:
-- 		(C) Copyright 2004 Burch Electronic Designs, All Rights Reserved.
--			This code is intended for academic, teaching and research purposes.
--			All references and sources consulted in producing this code are cited below.
--			Please cite all references and sources in any derivative works.
-- References:
--			-
-- References notes:
--			-
-- Author:
--			Burch Electronic Designs, http://www.BurchED.biz
-- Target Device:
--			XC2S300e-6PQ208C
-- Build Environment:
--			WebPACK 4.1
-- Target Boards:
--			-
-- Clk Frequency:
--			-
-- Modification History:
--			12 July 2004
-- Notes:
--			Number of Slices for implementation = ?
-- User constraints:
--			-

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RomShare is
	port (
		Rst 						: in STD_LOGIC;
		Clk 						: in STD_LOGIC;
		SRAM_A 					: out STD_LOGIC_VECTOR (16 downto 0);
		SRAM_D 					: inout STD_LOGIC_VECTOR (7 downto 0);
		SRAM_CE_n 				: out STD_LOGIC;
		SRAM_WE_LowerByte_n 	: out STD_LOGIC;
		SRAM_WE_UpperByte_n 	: out STD_LOGIC;
		A_Rom_Addr				: in STD_LOGIC_VECTOR (16 downto 0);
		A_Rom_Data				: inout STD_LOGIC_VECTOR (7 downto 0);
		B_Rom_Addr				: in STD_LOGIC_VECTOR (16 downto 0);
		B_Rom_Data				: inout STD_LOGIC_VECTOR (7 downto 0)
	);
end RomShare;

architecture RTL of RomShare is

signal PhaseA_Addr_En			: std_logic;
signal PhaseA_Data_En			: std_logic;
signal PhaseB_Addr_En			: std_logic;
signal PhaseB_Data_En			: std_logic;
signal PhaseA_Addr_En_Reg		: std_logic;
signal PhaseA_Data_En_Reg		: std_logic;
signal PhaseB_Addr_En_Reg		: std_logic;
signal PhaseB_Data_En_Reg		: std_logic;
type StateType is (St0, St1, St2, St3);
signal CurrentState, NextState : StateType;

begin

	SRAM_CE_n 					<= '0';
	SRAM_WE_LowerByte_n 		<= '1';
	SRAM_WE_UpperByte_n 		<= '1';

	Comb : process (CurrentState)
	begin
		case CurrentState is
			when St0 =>
				PhaseA_Addr_En 	<= '1';
				PhaseA_Data_En 	<= '0';
				PhaseB_Addr_En 	<= '0';
				PhaseB_Data_En 	<= '0';
				NextState 			<= St1;
			when St1 =>
				PhaseA_Addr_En 	<= '1';
				PhaseA_Data_En 	<= '1';
				PhaseB_Addr_En 	<= '0';
				PhaseB_Data_En 	<= '0';
				NextState 			<= St2;
			when St2 =>
				PhaseA_Addr_En 	<= '0';
				PhaseA_Data_En 	<= '0';
				PhaseB_Addr_En 	<= '1';
				PhaseB_Data_En 	<= '0';
				NextState 			<= St3;
			when St3 =>
				PhaseA_Addr_En 	<= '0';
				PhaseA_Data_En 	<= '0';
				PhaseB_Addr_En 	<= '1';
				PhaseB_Data_En 	<= '1';
				NextState 			<= St0;
		end case;
	end process Comb;

	Seq : process (Clk, Rst)
	begin
		if (Rst = '1') then
			CurrentState <= St0;
		elsif (Clk'event and Clk = '1') then
			CurrentState <= NextState;
		end if;
	end process Seq;

	-- Register state machine outputs.
	process (Clk)
	begin
		if (Clk'event and Clk = '1') then
			PhaseA_Addr_En_Reg <= PhaseA_Addr_En;
			PhaseA_Data_En_Reg <= PhaseA_Data_En;
			PhaseB_Addr_En_Reg <= PhaseB_Addr_En;
			PhaseB_Data_En_Reg <= PhaseB_Data_En;
		end if;
	end process;


	A_Data_Register_Proc : process (Clk, Rst) 
	begin 
		if (Rst = '1') then 
			A_Rom_Data <= (others => '0'); 
		elsif (Clk'event and Clk = '1') then
			if (PhaseA_Data_En_Reg = '1') then
				A_Rom_Data <= SRAM_D;
			end if;
		end if; 
	end process;

	B_Data_Register_Proc : process (Clk, Rst) 
	begin 
		if (Rst = '1') then 
			B_Rom_Data <= (others => '0'); 
		elsif (Clk'event and Clk = '1') then
			if (PhaseB_Data_En_Reg = '1') then
				B_Rom_Data <= SRAM_D;
			end if;
		end if; 
	end process;

	-- Address mux.
	SRAM_A <= A_Rom_Addr when (PhaseA_Addr_En_Reg = '1') else B_Rom_Addr;

end RTL;





-- File:
--			TickGen.vhd
-- Other source files needed:
--			-
-- Abstract:
--			A "tick" generator.  Generates a clock enable pulse (the tick) every 1us,
--			from a 48MHz input clock.
--  Notices:
-- 		(C) Copyright 2004 Burch Electronic Designs, All Rights Reserved.
--			This code is intended for academic, teaching and research purposes.
--			All references and sources consulted in producing this code are cited below.
--			Please cite all references and sources in any derivative works.
-- References:
--			The space invaders with ps2 keyboard interface code, written by Daniel Wallner.
--			Code from http://www.fpgaarcade.com
-- References notes:
--			-
-- Author:
--			Burch Electronic Designs, http://www.BurchED.biz
-- Target Device:
--			XC2S300e-6PQ208C
-- Build Environment:
--			WebPACK 4.1
-- Target Boards:
--			-
-- Clk Frequency:
--			-
-- Modification History:
--			14 July 2004
-- Notes:
--			Number of Slices for implementation = ?
-- User constraints:
--			-

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TickGen is
	port (
		Rst 						: in STD_LOGIC;
		Clk 						: in STD_LOGIC;
		Tick						: out STD_LOGIC
	);
end TickGen;

architecture RTL of TickGen is

begin

	process (Rst, Clk)
	variable cnt : unsigned(5 downto 0);
	begin
		if Rst = '1' then
			cnt := "000000";
			Tick <= '0';
		elsif Clk'event and Clk = '1' then
			Tick <= '0';
			if cnt = 47 then
				Tick <= '1';
				cnt := "000000";
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;

end RTL;

