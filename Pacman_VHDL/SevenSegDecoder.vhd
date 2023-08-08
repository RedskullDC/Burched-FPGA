-- File: 			
--			SevenSegDecoder.vhd
-- Other source files needed:
--			None
-- Abstract:
--			Seven segment display decoder.
--			Segment output signals go high when Rst is active - allows
--			lamp test.
--
--			 aaa
--			f   b
--			f   b
--			 ggg
--			e   c
--			e   c
--			 ddd   dp
--
--  Notices:
-- 		(C) Copyright 2002 Burch Electronic Designs, All Rights Reserved.
--			This code is intended for academic, teaching and research purposes.
--			All references and sources consulted in producing this code are cited below.
--			Please cite all references and sources in any derivative works.
-- References:
--			1. Keating, M. and Bricaud, P., Reuse Methodology Manual for
--			 System-On-A-Chip Designs, Kluwer Academic Publishers, 2000.
--			2. J. Hamblen and M. Furman, Rapid Prototyping of Digital Systems,
--			 Kluwer AAcademic Publishers, 2000.
-- References notes:
--			Coding practices in [1] were consulted.
--			Used decode truth table values in "DEC_7SEC.VHD" from [2].
-- Author:
--			Burch Electronic Designs, http://www.BurchED.com	
-- Target Device:
--			XC2S300e-6PQ208C
-- Build Environment:
--			WebPACK 4.1
-- Target Boards:
--			B5-Spartan2e+
--			B5-Switches
--			B5-LEDS
-- Clk Frequency:
--			48.0 MHz
-- Modification History:
--			Last updated 10 August 2002
-- Notes:
--			Number of Slices for implementation = 4.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SevenSegDecoder is
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
end SevenSegDecoder;

architecture RTL of SevenSegDecoder is
signal SegmentData : STD_LOGIC_VECTOR(6 downto 0);
begin

	process (HexDigit)
	begin
		case HexDigit is
			when "0000" => SegmentData <= "1111110"; -- 0
			when "0001" => SegmentData <= "0110000"; -- 1
			when "0010" => SegmentData <= "1101101"; -- 2
			when "0011" => SegmentData <= "1111001"; -- 3
			when "0100" => SegmentData <= "0110011"; -- 4
			when "0101" => SegmentData <= "1011011"; -- 5
			when "0110" => SegmentData <= "1011111"; -- 6
			when "0111" => SegmentData <= "1110000"; -- 7
			when "1000" => SegmentData <= "1111111"; -- 8
			when "1001" => SegmentData <= "1111011"; -- 9
			when "1010" => SegmentData <= "1110111"; -- A
			when "1011" => SegmentData <= "0011111"; -- b
			when "1100" => SegmentData <= "1001110"; -- C
			when "1101" => SegmentData <= "0111101"; -- d
			when "1110" => SegmentData <= "1001111"; -- E
			when "1111" => SegmentData <= "1000111"; -- F
			when others => SegmentData <= "0111110"; -- U
		end case;
	end process;

	process (Clk, Rst)
	begin
		if (Rst = '1') then
			a <= '1'; -- lamp test
			b <= '1';
			c <= '1';
			d <= '1';
			e <= '1';
			f <= '1';
			g <= '1';
			dp <= '1';
		elsif (Clk'event and Clk='1') then
			a <= SegmentData(6); 
			b <= SegmentData(5); 
			c <= SegmentData(4); 
			d <= SegmentData(3); 
			e <= SegmentData(2); 
			f <= SegmentData(1); 
			g <= SegmentData(0); 
			dp <= DecimalPoint; 
		end if;
	end process;

end RTL;

