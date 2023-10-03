library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_pipe is
	port(
		clk : in std_logic;
		instr_in : in std_logic_vector(24 downto 0);	-- instruction line from buffer
		instr_out : out std_logic_vector(24 downto 0)
	);
end IF_ID_pipe;

architecture behavior of IF_ID_pipe is
	signal instr_buffer : std_logic_vector(24 downto 0);

begin
	process (clk)
	begin
		if ( rising_edge(clk) ) then
			instr_buffer <= instr_in;
		end if;		
	end process;
	
	instr_out <= instr_buffer;
	
end behavior;