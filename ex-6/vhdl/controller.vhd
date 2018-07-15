-- controller: controles 3 ultrasound sensors
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is port(
	clk_50 : in std_logic;
	
	finished_1 : in std_logic;
	finished_2 : in std_logic;
	finished_3 : in std_logic;
	
	enable_1 : out std_logic;
	enable_2 : out std_logic;
	enable_3 : out std_logic
);
end controller;


architecture behavior of controller is
	-- counter to ensure that the ultrasonic sensor isn't triggered to often
	signal counter : unsigned(19 downto 0) := (others => '0');
		
begin

	-- TODO: more advanced behavior
	
	-- counter (reset 50 times per second)
	process(clk_50)
	begin
		if rising_edge(clk_50) then
			if counter = 1000000-1 then
				counter <= (others => '0');
			else 
				counter <= counter + 1;
			end if;
		end if;
	end process;
	
	-- 20 clock cycles of enable signal
	enable_1 <= '1' when counter < 20 and finished_2 = '1' and finished_3 = '1' else '0';
	enable_2 <= '1' when counter < 20 and finished_1 = '1' and finished_3 = '1' else '0';
	enable_3 <= '1' when counter < 20 and finished_1 = '1' and finished_2 = '1' else '0';
end behavior;