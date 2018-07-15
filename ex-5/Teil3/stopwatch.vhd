-- stopwatch
-- increments every second


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch is port(
	clk_50 : in std_logic;
	startStop : in std_logic;
	rst : in std_logic;
	
	time_out: out std_logic_vector(5 downto 0)	-- counter output
);
end stopwatch;


architecture behavior of stopwatch is
	-- signal that counts to 62500, which is \in 2^16
	signal counter : integer  range 0 to 49999999 := 0;
	signal seconds : unsigned(5 downto 0) := "000000";
	signal running : std_ulogic := '0';

begin
	running <= '1' when rising_edge(startStop) and running = '0' else
				  '0' when rising_edge(startStop) and running = '1' else
				  running;
	
	counter <= counter + 1 when rising_edge(clk_50) and counter /= 49999999 and running = '1' else
				  0 when rising_edge(clk_50) and counter = 49999999 and running = '1' else
				  counter;
	
	seconds <= to_unsigned(0, seconds'length) when rst = '1' else
				  seconds + to_unsigned(1, seconds'length) when counter = 49999999 else
				  seconds;

	time_out <= std_logic_vector(resize(seconds, time_out'length));
end behavior;