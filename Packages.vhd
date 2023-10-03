--	libs
library ieee;			   
use ieee.std_logic_1164.all; 
use ieee.numeric_std.ALL;

package Instruction_Buffer is
	type instruction_buffer_array is array (0 to 63) of std_logic_vector(24 downto 0);
end package Instruction_Buffer;

library ieee;			   
use ieee.std_logic_1164.all; 
use ieee.numeric_std.ALL;

package Register_array is
	type register_array is array (0 to 31) of std_logic_vector(127 downto 0);
end package Register_array;
