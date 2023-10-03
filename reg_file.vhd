---
--
-- Title       : Register File
-- Design      : rreg_file
-- Author      : Labeeb Abrar, Daniel Khouri (Group 8)
-- Company     : ESE 345
--
---
--
-- Description : Register File
-- 
--
-- 

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {reg_file} architecture {behavior}}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Register_array.all;

entity reg_file is
	 port(
		 write_en : in std_logic;	--	register write enable
		 r1 : in std_logic_vector(4 downto 0);
		 r2 : in std_logic_vector(4 downto 0);
		 r3 : in std_logic_vector(4 downto 0);
		 reg_write : in std_logic_vector(127 downto 0);	--	writeback
		 reg_destination : in std_logic_vector(4 downto 0);	--	rd
		 
		 rs1 : out std_logic_vector(127 downto 0);
		 rs2 : out std_logic_vector(127 downto 0);
		 rs3 : out std_logic_vector(127 downto 0);

		 --	Testbench probe
		 tb_file : out register_array
	     );
end reg_file;

--}} End of automatically maintained section

architecture behavior of reg_file is

signal reg_file : register_array := (others => x"00000000000000000000000000000000"); --	default load with 0

begin
	
--	process(write_en)
--	begin
--		if ( write_en = '1' ) then	--	on regw = 1, write data into register address "regread"
--			reg_file(to_integer(unsigned(reg_destination))) <= reg_write;
--		end if;
--	end process;
	
	reg_file(to_integer(unsigned(reg_destination))) <= reg_write;
	
	rs1 <= reg_file(to_integer(unsigned(r1)));
	rs2 <= reg_file(to_integer(unsigned(r2)));
	rs3 <= reg_file(to_integer(unsigned(r3)));
	
	tb_file <= reg_file;

end behavior;
