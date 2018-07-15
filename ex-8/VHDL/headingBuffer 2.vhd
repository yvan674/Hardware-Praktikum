-- headingBuffer: serves as a buffer for the heading

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY headingBuffer IS PORT(
	dataReady: IN std_logic;	-- Data ready signal
	
	heading_in : IN std_logic_vector (7 DOWNTO 0); -- heading input
		
	-- data output
	heading_out : OUT std_logic_vector (8 DOWNTO 0) -- 9 bit output
);
END headingBuffer;


ARCHITECTURE behavior OF headingBuffer IS
	-- data output buffers
BEGIN
	-- takes the value of the serial and turns it into a natural number. Multiplies that by 2, then outputs it as a 9 bit logic vector
	heading_out <= heading_in & '0' WHEN dataReady = '1' ELSE
						"UUUUUUUUU";


END behavior;