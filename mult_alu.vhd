---
--
-- Title       : mult_alu
-- Design      : multi_alu
-- Author      : Labeeb Abrar, Daniel Khouri (Group 5)
-- Company     : ESE 345
--
---
--
-- Description : Multimedia ALU
-- 
--
-- 

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {mult_alu} architecture {struct}}

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mult_alu is
	port(
		rs1 	: in std_logic_vector(127 downto 0);
		rs2 	: in std_logic_vector(127 downto 0);
		rs3 	: in std_logic_vector(127 downto 0);
		
		opcode 	: in std_logic_vector(24 downto 15);	-- 24:15 ALUctrl
		imm		: in std_logic_vector(15 downto 0);
		
		rd	 	: out std_logic_vector(127 downto 0)
	);
end mult_alu;

--}} End of automatically maintained section

architecture struct of mult_alu is

	signal result : std_logic_vector(127 downto 0);
	
	-- Author : Labeeb Abrar
	-- Signed Multiply rs1 and rs2, and saturated add the product with rs1
	-- Inputs : rs1, rs2, and rs3 are ALU inputs, OP = add (0) or subtract (1), 
	--  HIGH_LOW = hi (1) or low (0) switch, n = number of bits of each field
	-- For R4 instructions
	procedure MultiplyAdd (	rs1 : in std_logic_vector(127 downto 0):= (others => '0');
							rs2 : in std_logic_vector(127 downto 0):= (others => '0');
							rs3 : in std_logic_vector(127 downto 0):= (others => '0');
							OP : in std_logic := '0'; -- OP = add (0) or subtract (1)
							HIGH_LOW : in std_logic := '0'; -- HIGH_LOW = hi (1) or low (0) switch
							n : in natural := 0; -- n = number of bits of each field
							signal resultout : out std_logic_vector(127 downto 0)) is
							
		variable product : signed(n downto 0) := (others => '0'); -- holds each product of each field of rs1 and rs2 (bit n is for min/max check during saturation
		variable sum : signed(n downto 0) := (others => '0');
		variable result : std_logic_vector(127 downto 0) := (others => '0');
		
		variable MIN : signed(n-1 downto 0) := (others => '0');
		variable MAX : signed(n-1 downto 0) := (others => '1');
	begin
		MIN(n-1) := '1';
		MIN(0) := '1';
		MAX(n-1) := '0';
		
		for i in 0 to (128/n)-1 loop	-- 128/64=2 64bits (1 downto 0); 128/32=4 32bits (3 downto 0)
			if (HIGH_LOW = '0') then
				--let i = iteration, n = number of bits. Lower field = rs[(i+1)n-1-n/2 : i*n]
				product := resize(signed(rs3((i+1)*n-1-(n/2) downto i*n)) * signed(rs2((i+1)*n-1-(n/2) downto i*n)), n+1);
			elsif (HIGH_LOW = '1') then
				--let i = iteration, n = number of bits. Higher field = rs[(i+1)n-1 : i*n+n/2]
				product := resize(signed(rs3((i+1)*n-1 downto i*n+(n/2))) * signed(rs2((i+1)*n-1 downto i*n+(n/2))), n+1);
			end if;
			
			if (OP = '0') then	--	saturated add
				sum := product + signed(rs1((i+1)*n-1 downto i*n));
				
				if (sum > MAX) then	--	max value of signed
					sum := MAX;
				end if;
				
				result((i+1)*n-1 downto i*n) := std_logic_vector(sum(n-1 downto 0));	-- extra bit n is for checking overflow/underflow
					
			elsif (OP = '1') then	--	saturated subtract
				sum := product - signed(rs1((i+1)*n-1 downto i*n));
				
				if (sum < MIN) then	--	max value of signed
					sum := MIN;
				end if;
				
				result((i+1)*n-1 downto i*n) := std_logic_vector(sum(n-1 downto 0));
				
			end if;		
		end loop;
	
		resultout <= result;
	end procedure;	
	
begin	

	process(rs1, rs2, rs3, opcode, imm)
		variable temp_imm : std_logic_vector(127 downto 0) := (others => '0');
		variable load_index : integer;				
		
		--# of zeros after 1
		variable zeros : integer := 0;		
		--# of ones
		variable ones : integer := 0;
		--index
		variable index : integer := 0;	
			--used for 16 bit operations
		variable maxs16 : integer := (2**15)-1;
		variable mins16 : integer := -(2**15); 	
		--rotating 
		variable rotate1 : integer; 
		variable rotate2 : integer;	 
			
		--rs1 to transfer
		variable rs1_temp : std_logic_vector(127 downto 0); 	 
		
		--temp
		variable temp : integer;
		variable temp_bit : std_logic;
	
	begin
		--	load immediate, 23:21 of opcode determines the halfword field (load index)
		-- Author of this part : Labeeb Abrar --
		if (opcode(24) = '0') then
			
			load_index := to_integer(unsigned(std_logic_vector'(opcode(23),opcode(22),opcode(21))));
			for n in 0 to 15 loop
				temp_imm(n + load_index*16) := imm(n);
			end loop;			

			result <= temp_imm;
		end if;

	-- R4 instructions ---
	-- Author of this part : Labeeb Abrar --
	if (opcode(24) = '1' and opcode(23) = '0') then
		case std_logic_vector'(opcode(22),opcode(21),opcode(20)) is
			when "000" =>	-- Signed Integer Multiply-Add Low with Saturation
				MultiplyAdd(rs1, rs2, rs3, '0', '0', 32, result);
			when "001" =>	-- Signed Integer Multiply-Add High with Saturation
				MultiplyAdd(rs1, rs2, rs3, '0', '1', 32, result);
			when "010" =>	-- Signed Integer Multiply-Sub Low with Saturation
				MultiplyAdd(rs1, rs2, rs3, '1', '0', 32, result);
			when "011" =>	-- Signed Integer Multiply-Sub High with Saturation
				MultiplyAdd(rs1, rs2, rs3, '1', '1', 32, result);
			when "100" =>	-- Signed Long Multiply-Add Low with Saturation
				MultiplyAdd(rs1, rs2, rs3, '0', '0', 64, result);
			when "101" =>	-- Signed Long Multiply-Add High with Saturation
				MultiplyAdd(rs1, rs2, rs3, '0', '1', 64, result);
			when "110" =>	-- Signed Long Multiply-Sub Low with Saturation
				MultiplyAdd(rs1, rs2, rs3, '1', '0', 64, result);
			when "111" =>	-- Signed Long Multiply-Sub High with Saturation
				MultiplyAdd(rs1, rs2, rs3, '1', '1', 64, result);
			when others =>
				result <= (others => '0');
				null;
		end case;
	end if;
	
	-- R3 instructions ---
	-- Author of this part : Daniel Khouri --
	if (opcode(24) = '1' and opcode(23) = '1') then
		--NOP
		if (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0000") then
				result <= (others => '0');
				null;		
				
		--CLZW: count leading zeroes in words
		elsif(std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0001") then
			for i in 0 to 3 loop
				--reset
				zeros := 0;
				index := 0;
				
				-- if 0s then 0s
				if rs1((i*32)+31 downto i*32) = "00000000000000000000000000000000" then	  
					result((i*32)+31 downto i*32) <= "00000000000000000000000000000000";
				
				else 	
					while rs1((i*32)+index) = '0' loop   
						index := index + 1;
					 
					end loop;
					
					while index < 32 loop
						if rs1((i*32)+index) = '0' then
							zeros := zeros + 1; 
						end if;						  
						
						index := index + 1;
				
					end loop;
				end if;
			end loop;
			--AU: Add word unsigned
		elsif(std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0010") then
			for i in 0 to 3 loop
				result(31+(i*32) downto i*32) <= std_logic_vector(unsigned(rs1(31+(i*32) downto (i*32))) + unsigned(rs2(31+(i*32) downto i*32)));
			end loop;		
			
		--AHU: add half word unsigned
		elsif(std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0011") then
			for i in 0 to 7 loop
				result(15+(i*16) downto i*16) <= std_logic_vector(unsigned(rs1(15+(i*16) downto i*16)) + unsigned(rs2(15+(i*16) downto i*16)));
			end loop;	
			
		--AHS: Add halfword saturated
		elsif(std_logic_vector'(opcode(19), opcode(18), opcode(17), opcode(16), opcode(15)) = "01000") then
			for i in 0 to 7 loop
				--positive overflow
				if rs1(15+i*16) = '0' and rs2(15+i*16) = '0' and to_integer(signed(rs1(15+i*16 downto i*16)) + signed(rs2(15+i*16 downto i*16))) <= 0 then 
					result(15+i*16 downto i*16) <= std_logic_vector(to_signed(maxs16, 16));	
				
				--negative overflow
				elsif rs1(15+i*16) = '1' and rs2(15+i*16) = '1' and to_integer(signed(rs1(15+i*16 downto i*16)) + signed(rs2(15+i*16 downto i*16))) >= 0 then 
					result(15+i*16 downto i*16) <= std_logic_vector(to_signed(mins16, 16));						
				
				--default 
				else 
					result(15+i*16 downto i*16) <= std_logic_vector(signed(rs1(15+i*16 downto i*16)) + signed(rs2(15+i*16 downto i*16)));
				
				end if;
				
			end loop; 
		--AND: bitwise logical and 
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0101") then	 
			result <= rs1 AND rs2;  
		
		--BCW: broadcast word 
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0110")then
			for i in 0 to 3 loop
				result(31+i*32 downto i*32) <= rs1(31 downto 0);
			end loop;	 
		--MAXWS: max signed word:
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "0111")then
			for i in 0 to 3 loop	
		
				if signed(rs1(31+i*32 downto i*32)) > signed(rs2(31+i*32 downto i*32)) then
					result(31+i*32 downto i*32) <= std_logic_vector(signed(rs1(31+i*32 downto i*32)));		
				else 	
					result(31+i*32 downto i*32) <= std_logic_vector(signed(rs2(31+i*32 downto i*32)));	
				end if;
			end loop;	   
			
		--MINWS: min signed word
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1000")then	
			--for MAX, switch signs
			for i in 0 to 3 loop
				if signed(rs1(31+i*32 downto i*32)) < signed(rs2(31+i*32 downto i*32)) then
					result(31+i*32 downto i*32) <= std_logic_vector(signed(rs1(31+i*32 downto i*32)));	
				else 	
					result(31+i*32 downto i*32) <= std_logic_vector(signed(rs2(31+i*32 downto i*32)));	
				end if;	
			end loop;		
			
		--MLHU: multiply low unsigned: 
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1001")then	
			for i in 0 to 3 loop
				result((i+1)*32-1 downto i*32) <= std_logic_vector(resize( unsigned(rs1((i+1)*32-1-16 downto i*32)) * unsigned(rs2(4+(i*32) downto i*32)), 32));
			end loop;
		-- MLHCU: multiply low by constant unsigned				
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1010")then	
			for i in 0 to 3 loop
				result((i+1)*32-1 downto i*32) <= std_logic_vector(resize( unsigned(rs1((i+1)*32-1-16 downto i*32)) * unsigned(rs2(4+(i*32) downto i*32)), 32));
			end loop;

		--OR: bitwise logical or  
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1011")then
			result <= rs1 OR rs2;
			
		--PCNTW: count ones in words
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1100")then 
			for i in 0 to 3 loop
			   	
				index := 0;
				ones := 0;
				--if rs1 word is 0
				if rs1(31+(i*32) downto i*32) = "00000000000000000000000000000000" then
					result(31+(i*32) downto i*32) <= "00000000000000000000000000000000";
					
				else
					while index < 32 loop
						if (rs1(index+i*32)) = '1' then
							ones := ones + 1;	   
						
						end if;
						index := index + 1;
					
					end loop;
					result(31+(i*32) downto i*32) <= std_logic_vector(to_signed(ones, 32));	
	
				end if;	
			end loop;
		--ROTW: rotate bits in word		 
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1101")then
			for i in 0 to 3 loop		 
				
				rotate2 := to_integer(unsigned(rs2(4+i*32 downto i*32)));
				--move to temp
				rs1_temp(31+i*32 downto i*32) := rs1(31+i*32 downto i*32);

				for j in 1 to rotate2 loop

					temp_bit := rs1_temp(i*32);
					--shift all right
					for k in 0 to 30 loop
						--MSB
						rs1_temp(k+(i*32)) := rs1_temp(k + (i*32) + 1);  
						
					end loop;			 
					--MSB gets 
			    	rs1_temp(i*32+31) := temp_bit;
								  
			    end loop;
			end loop;
			
		--SFWU: subtract from word unsigned				   
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1110")then	
			for i in 0 to 3 loop
				result(31+i*32 downto i*32) <= std_logic_vector(unsigned(rs2(31+i*32 downto i*32)) - unsigned(rs1(31+i*32 downto i*32)));
			end loop;				
		
		--SFHS: subtract from halfword saturated				   
		elsif (std_logic_vector'(opcode(18), opcode(17), opcode(16), opcode(15)) = "1111")then
			for i in 0 to 7 loop
					--MSB > 0?
					if rs2(15+i*16) = '1' and rs1(15+i*16) = '0' and (signed(rs2(15+i*16 downto i*16)) - signed(rs1(15+i*16 downto i*16)) > 0) then
						
						--pos. overflow
						result(15+i*16 downto i*16) <= std_logic_vector(to_signed(mins16, 16));  
					
					--MSB <0?
					elsif rs2(15+i*16) = '0' and rs1(15+i*16) = '1' and (signed(rs2(15+i*16 downto i*16)) - signed(rs1(15+i*16 downto i*16)) < 0) then
					
						--tneg. overflow
						result(15+i*16 downto i*16) <= std_logic_vector(to_signed(maxs16, 16));  
					
					--default case
					else 
						temp := to_integer(signed(rs2(15+i*16 downto i*16))) - to_integer(signed(rs1(15+i*16 downto i*16))); 
						result(15+i*16 downto i*16) <= std_logic_vector(to_signed(temp, 16));
					end if;
			end loop;
		end if;
	end if;
	end process;
	-- output --
	rd <= result;
	
end struct;