library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity myCounter is port(
	count 	: in std_logic; -- count signal: increase counter on rising edge
	rst 		: in std_logic; -- reset signal: set counter to 0 if rst = 0
	countOut : out std_logic_vector(2 downto 0)); -- counter output
end myCounter;

architecture behavior of myCounter is
-- signals, etc.
	signal counter: unsigned(2 downto 0):="000";

begin
	--counter	<= to_unsigned(0, 3) when rst = '0' else
		--		counter + to_unsigned(1, 3) when count = '1' else
		--	counter;
	
	-- countOut <= std_logic_vector(counter);
	
	counter <= "000" when rst = '0' else		-- reset counter when rst = 0
				  counter + "001" when rising_edge(count);
	
	countOut <= std_logic_vector(counter);

end behavior;