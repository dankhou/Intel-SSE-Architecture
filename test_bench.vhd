library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use std.textio.all;
use work.Register_array.all;
use work.Instruction_Buffer.all;
use work.all;

entity test_tb is
end test_tb;

architecture tb_arch of test_tb is

	--  stimulus signals --
	signal clk : std_logic := '0';
	signal PC_end : std_logic;
	signal instr_in : instruction_buffer_array;
	signal write_en : std_logic;
	signal reg_out : register_array;
	
begin
	UUT: entity Four_stage_pipeline
	port map(
		clk => clk,
		instr_in => instr_in,
		write_en => write_en,
		reg_out => reg_out,
		PC_end => PC_end
		);
	
	stimulus : process
		file file_in, file_out : text;
		variable raw_line : line;
		variable proc_line : std_logic_vector(24 downto 0);
		variable index : integer := 0;
		
		constant period : time := 10 ns;
		
	begin
		write_en <= '1';
		file_open(file_in, "mipscode.txt", read_mode);
		
		--	write instructions to instruction buffer
		while (not endfile(file_in) and (index < 64)) loop
			readline(file_in, raw_line);
			bread(raw_line, proc_line);
			
			instr_in(index) <= proc_line;
			
			index := index+1;
			wait for 1 ns;
		end loop;
		
		write_en <= '0';
		wait for 50 ns;
		
		--	Start the cpu, stops after the last instruction
		while( PC_end = '0' ) loop
			clk <= not clk;
			wait for period;
		end loop;
		
		--	register read
		file_open(file_out, "register_out.txt", write_mode);
		index := 0;
		for i in 0 to 31 loop
			index := i;
			write(file_out, to_string(reg_out(i)));
			report to_string(reg_out(i));
			
		end loop;
		
		file_close(file_in);
		file_close(file_out);
		std.env.finish;
	end process;
	
end tb_arch;