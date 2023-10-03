library ieee;
use ieee.std_logic_1164.all;

entity EX_MEM_pipe is
	port(
		clk : in std_logic;
		ALUresult_in : in std_logic_vector(127 downto 0);	-- ALU result
		WB_in : in std_logic_vector(1 downto 0);
		MEM_in : in std_logic_vector(2 downto 0);
		
		ALUresult_out : out std_logic_vector(127 downto 0);
		WB_out : out std_logic_vector(1 downto 0);
		MEM_out : out std_logic_vector(2 downto 0)
	);
end EX_MEM_pipe;

architecture behavior of EX_MEM_pipe is
	signal ALUresult_buffer : std_logic_vector(127 downto 0);
	signal WB_buffer : std_logic_vector(1 downto 0);
	signal MEM_buffer : std_logic_vector(2 downto 0);

begin
	process (clk)
	begin
		if ( rising_edge(clk) ) then
			ALUresult_buffer <= ALUresult_in;
			WB_buffer <= WB_in;
			MEM_buffer <= MEM_in;
		end if;		
	end process;
	
		ALUresult_out <= ALUresult_buffer;
		WB_out <= WB_buffer;
		MEM_out <= MEM_buffer;
	
end behavior;