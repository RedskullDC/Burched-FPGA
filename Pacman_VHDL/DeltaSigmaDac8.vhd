-- File:
--			DeltaSigmaDac8.vhd
-- Other source files needed:
--			None.
-- Abstract:
--			8-bit delta sigma DAC.
--  Notices:
-- 		(C) Copyright 2004 Burch Electronic Designs, All Rights Reserved.
--			This code is intended for academic, teaching and research purposes.
--			All references and sources consulted in producing this code are cited below.
--			Please cite all references and sources in any derivative works.
-- References:
--			DAC code written by Jayasri Joseph and Joseph Pathikulangara.
--			Xilinx application note, http://www.xilinx.com
-- References notes:
-- Author:
--			Burch Electronic Designs, http://www.BurchED.biz
-- Target Device:
--			XC2S300e-6PQ208C
-- Build Environment:
--			WebPACK 4.1
-- Target Boards:
--			B5-Audio-Out
-- Clk Frequency:
--			48MHz
-- Modification History:
--			5 July 2004
-- Notes:
--			Number of Slices for implementation = ?
-- User constraints
-- 		None.

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use  IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.all;

entity DeltaSigmaDac8 is
	port (
		Clk 		: in STD_LOGIC;
		Rst 		: in STD_LOGIC;
		DacIn 	: in STD_LOGIC_VECTOR(7 downto 0);
		DacOut 	: out STD_LOGIC 
	);
end DeltaSigmaDac8;

architecture RTL of DeltaSigmaDac8 is

signal OutDeltaAdder 	: std_logic_VECTOR(9 downto 0);
signal OutSigmaAdder 	: std_logic_VECTOR(9 downto 0);
signal OutSigmaLatch 	: std_logic_VECTOR(9 downto 0);
signal InDeltaB 			: std_logic_VECTOR(9 downto 0);
signal MSBSigmaLatch 	: std_logic;

begin

OutDeltaAdder <= DacIn + InDeltaB;
OutSigmaAdder <= OutDeltaAdder + OutSigmaLatch;
MSBSigmaLatch <= OutSigmaLatch(9);

InDeltaB <= MSBSigmaLatch & MSBSigmaLatch & "00000000";
 
SIGMA_PROC: process (Clk, Rst, OutSigmaAdder) 
begin 
	if (Rst = '1') then 
		OutSigmaLatch <= "0000000000"; 
	elsif (Clk'event and Clk = '1') then 
		OutSigmaLatch <= OutSigmaAdder; 
	end if; 
end process;

OUT_PROC: process (Clk, Rst) 
begin 
	if (Rst = '1') then 
		DacOut <= '0'; 
	elsif (Clk'event and Clk = '1') then 
		DacOut <= MSBSigmaLatch; 
	end if; 
end process;

end RTL;

