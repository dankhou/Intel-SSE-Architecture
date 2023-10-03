---
--
-- Title       : Four staged Pipelined SIMD Multimedia design
-- Design      : multi_alu
-- Author      : Labeeb Abrar, Daniel Khouri (Group 8)
-- Company     : ESE 345 Fall 2022
--
---
--
-- Description : Four staged Pipelined SIMD Multimedia design with a reduced set of multimedia instructions
-- Date: 11/29/2022
--
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Register_array.all;
use work.Instruction_Buffer.all;
use work.all;

entity Four_stage_pipeline is
	port(
		clk : in std_logic;
		
		--	loading instructions from testbench
		instr_in : in instruction_buffer_array;	--	will be connected directly to tb
		write_en : in std_logic;
		
		--	reading register
		PC_end : out std_logic;	--	instr buffer will emit a flag to tb before reading register
		reg_out : out register_array
	);
end Four_stage_pipeline;

architecture structural of Four_stage_pipeline is
	--	instruction buffer
	component instr_buffer
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
	end component;
	
	signal instr_IF : std_logic_vector(24 downto 0);	--	"IF" suffix will show which stage this signal is in
	
	--	IF/ID pipeline register
	component IF_ID_pipe
		port(
			clk : in std_logic;
			instr_in : in std_logic_vector(24 downto 0);	-- instruction line from buffer
			instr_out : out std_logic_vector(24 downto 0)
		);
	end component;
	
	signal instr_ID : std_logic_vector(24 downto 0);
	
	--	Register File
	component reg_file
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
	end component;
	
	signal rs1_ID, rs2_ID, rs3_ID : std_logic_vector(127 downto 0);
					  
	--	ID/EX pipeline register
	component ID_EX_pipe
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
	end component;
	
	signal rs1_EX, rs2_EX, rs3_EX : std_logic_vector(127 downto 0);
	signal instr_EX : std_logic_vector(24 downto 0);
	
	--	Forwarding Unit
	component Forward_Unit
		port(
		-- ALUinput address
			 rs1 : in STD_LOGIC_VECTOR(4 downto 0);	--  from EX
			 rs2 : in STD_LOGIC_VECTOR(4 downto 0);
			 rs3 : in STD_LOGIC_VECTOR(4 downto 0);	 
			 rd : in STD_LOGIC_VECTOR(4 downto 0);	--	from WB
			 
			  -- output from ALU
			 rd_in : in STD_LOGIC_VECTOR(127 downto 0); --	from WB
			 
			 rs1_in : in STD_LOGIC_VECTOR(127 downto 0); --  from EX
			 rs2_in : in STD_LOGIC_VECTOR(127 downto 0);
			 rs3_in : in STD_LOGIC_VECTOR(127 downto 0);	
			 
			 rs1_out : out STD_LOGIC_VECTOR(127 downto 0);
			 rs2_out : out STD_LOGIC_VECTOR(127 downto 0);
			 rs3_out : out STD_LOGIC_VECTOR(127 downto 0)
		 );
	end component;	
	
	signal rs1_EX_FU, rs2_EX_FU, rs3_EX_FU : std_logic_vector(127 downto 0);
	
	--	Multimedia ALU
	component mult_alu
		port(
			rs1 	: in std_logic_vector(127 downto 0);
			rs2 	: in std_logic_vector(127 downto 0);
			rs3 	: in std_logic_vector(127 downto 0);
			
			opcode 	: in std_logic_vector(24 downto 15);	-- 24:15 ALUctrl
			imm		: in std_logic_vector(15 downto 0);
			
			rd	 	: out std_logic_vector(127 downto 0)
		);
	end component;
	
	signal alu_result_EX : std_logic_vector(127 downto 0);
	signal write_enable_EX : std_logic := '1';	--	all instructions write to the register file
	
	-- EX/WB pipeline register
	component EX_WB_pipe is
		port(
			clk : in std_logic;
			ALUresult_in : in std_logic_vector(127 downto 0);	-- ALU result
			regw_in : in std_logic;
			
			ALUresult_out : out std_logic_vector(127 downto 0);
			regw_out : out std_logic
		);
	end component;
	
	signal alu_result_WB : std_logic_vector(127 downto 0);
	signal reg_dest_WB : std_logic_vector(4 downto 0);
	signal write_enable_WB : std_logic;
--===========================================================--

begin
	--	IF
	instr_buffer_inst : entity instr_buffer
		port map(
			clk => clk,
			instr_in => instr_in,
			write_en => write_en,
			instr_out => instr_IF,
			PC_end => PC_end
		);
	
	--	IF/ID
	IF_ID_register : entity IF_ID_pipe
		port map(
			clk => clk,
			instr_in => instr_IF,
			instr_out => instr_ID
		);
	
	--	Register File
	reg_file_inst : entity reg_file
		port map(
			write_en => write_enable_WB,
			r1 => instr_ID(9 downto 5),
			r2 => instr_ID(14 downto 10),
			r3 => instr_ID(19 downto 15),
			reg_write => alu_result_WB,	--	aluresult
			reg_destination => reg_dest_WB,
			
			rs1 => rs1_ID,
			rs2 => rs2_ID,
			rs3 => rs3_ID,
			
			tb_file => reg_out
		);

	--	ID/EX
	ID_EX_register : entity ID_EX_pipe
		port map(
			clk => clk,
			regdata1_in => rs1_ID,
			regdata2_in => rs2_ID,
			regdata3_in => rs3_ID,
			instr_in => instr_ID,
			
			regdata1_out => rs1_EX,
			regdata2_out => rs2_EX,
			regdata3_out => rs3_EX,
			instr_out => instr_EX
		);
	--	Forwarding unit
	Forwarding_unit_inst : entity Forward_Unit
		port map(
			rs1 => instr_EX(9 downto 5),
			rs2 => instr_EX(14 downto 10),
			rs3 => instr_EX(19 downto 15),
			rd => reg_dest_WB,
			rd_in => alu_result_WB,
			rs1_in => rs1_EX,
			rs2_in => rs2_EX,
			rs3_in => rs3_EX,
			rs1_out => rs1_EX_FU,
			rs2_out => rs2_EX_FU,
			rs3_out => rs3_EX_FU
		);
	
	--	ALU
	ALU_inst : entity mult_alu
		port map(
			rs1 => rs1_EX_FU,
			rs2 => rs2_EX_FU,
			rs3 => rs3_EX_FU,
			opcode => instr_EX(24 downto 15),
			imm => instr_EX(20 downto 5),
			rd => alu_result_EX
		);		 
	
	--	EX/WB
	EX_WB_register : entity EX_WB_pipe
		port map(
			clk => clk,
			ALUresult_in => alu_result_EX,
			regw_in => write_enable_EX,
			rd_in => instr_EX(4 downto 0),
			ALUresult_out => alu_result_WB,
			regw_out => write_enable_WB,
			rd_out => reg_dest_WB
		);
		
end structural;