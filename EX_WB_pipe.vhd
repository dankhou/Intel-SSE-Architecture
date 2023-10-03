library ieee;
use ieee.std_logic_1164.all;

entity EX_WB_pipe is
	port(
		clk : in std_logic;
		ALUresult_in : in std_logic_vector(127 downto 0);	-- ALU result
		regw_in : in std_logic;	--	write enable
		rd_in : in std_logic_vector(4 downto 0);	--	register destination
		
		ALUresult_out : out std_logic_vector(127 downto 0);
		regw_out : out std_logic;
		rd_out : out std_logic_vector(4 downto 0)
	);
end EX_WB_pipe;

architecture behavior of EX_WB_pipe is
	signal ALUresult_buffer : std_logic_vector(127 downto 0);
	signal regw_buffer : std_logic;
	signal rd_buffer : std_logic_vector(4 downto 0);

begin
	process (clk)
	begin
		if ( rising_edge(clk) ) then
			ALUresult_buffer <= ALUresult_in;
			regw_buffer <= regw_in;
			rd_buffer <= rd_in;
		end if;
	end process;
	
	ALUresult_out <= ALUresult_buffer;
	regw_out <= regw_in;
	rd_out <= rd_buffer;
	
end behavior;