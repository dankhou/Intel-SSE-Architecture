library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity Forward_Unit is
	port(
	-- ALUinput address
		 rs1 : in STD_LOGIC_VECTOR(4 downto 0);
		 rs2 : in STD_LOGIC_VECTOR(4 downto 0);
		 rs3 : in STD_LOGIC_VECTOR(4 downto 0);	 
		 rd : in STD_LOGIC_VECTOR(4 downto 0);
		 
		  -- output from ALU
		 rd_in : in STD_LOGIC_VECTOR(127 downto 0);
		 
		 rs1_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
		 rs3_in : in STD_LOGIC_VECTOR(127 downto 0);	
		 
		 rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
		 rs3_out : out STD_LOGIC_VECTOR(127 downto 0)
	 );
end Forward_Unit;

architecture behavior of Forward_Unit is	 


begin
	process(rs1, rs2, rs3, rd) 
	begin
			if unsigned(rs1) = unsigned(rd) then
			   rs1_out <= rd_in; 
			else 
			   rs1_out <= rs1_in;
			end if;
			
			if unsigned(rs2) = unsigned(rd) then 
				rs2_out <= rd_in;
			else 
				rs2_out <= rs2_in;
			end if;

			if unsigned(rs3) = unsigned(rd) then 
				rs3_out <= rd_in;
			else
				rs3_out <= rs3_in;
			end if;
	end process;
end behavior;
