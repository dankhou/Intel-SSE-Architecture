library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_pipe is
	port(
		clk : in std_logic;
		regdata1_in : in std_logic_vector(127 downto 0);	-- read register 1
		regdata2_in : in std_logic_vector(127 downto 0);	-- read register 2
		regdata3_in : in std_logic_vector(127 downto 0);	-- read register 3
		instr_in : in std_logic_vector(24 downto 0);
		
		--	out
		regdata1_out : out std_logic_vector(127 downto 0);
		regdata2_out : out std_logic_vector(127 downto 0);
		regdata3_out : out std_logic_vector(127 downto 0);
		instr_out : out std_logic_vector(24 downto 0)
	);
end ID_EX_pipe;

architecture behavior of ID_EX_pipe is
	signal regdata1_buffer : std_logic_vector(127 downto 0);
	signal regdata2_buffer : std_logic_vector(127 downto 0);
	signal regdata3_buffer : std_logic_vector(127 downto 0);
	signal instr_buffer : std_logic_vector(24 downto 0);

begin
	process (clk)
	begin
		if ( rising_edge(clk) ) then
			regdata1_buffer <= regdata1_in;
			regdata2_buffer <= regdata2_in;
			regdata3_buffer <= regdata3_in;
			instr_buffer <= instr_in;
		end if;		
	end process;
	
		regdata1_out <= regdata1_buffer;
		regdata2_out <= regdata2_buffer;
		regdata3_out <= regdata3_buffer;
		instr_out <= instr_buffer;
	
end behavior;