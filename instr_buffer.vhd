library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.Instruction_Buffer.all;

entity instr_buffer is 
	generic (
		b : integer := 25;
		l : integer := 64
	);	
	
	port (
		clk : in std_logic;
		--	load instructions
		instr_in : in instruction_buffer_array;
		write_en : in std_logic;
		
		instr_out : out std_logic_vector(b-1 downto 0);
		PC_end : out std_logic
	);
end instr_buffer;

architecture behavior of instr_buffer is
	signal PC : integer := 0;	--	start pc at 0
	
	signal instr_array : instruction_buffer_array;

begin
	load : process(write_en)
	begin
		if(write_en = '1') then
			instr_array <= instr_in;
		end if;
	end process load;
	
	process(clk)
	begin
		if rising_edge(clk) then
			instr_out <= instr_array(PC);
			if (PC < l) then
				PC <= PC + 1;
			end if;
		end if;
		
		if PC < l then
			PC_end <= '0';
		else
			PC_end <= '1';
		end if;
	end process;
end behavior;