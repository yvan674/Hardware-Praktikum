-- soundGenerator_d5
-- outputs the tone d5 from the Piepser when input is switched on


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soundGenerator_d5 is port(
	clk_50 : in std_logic;
	
	sound: out std_logic
);
end soundGenerator_d5;


architecture behavior of soundGenerator_d5 is
	-- signal that counts to 62500, which is \in 2^16
	signal counter : integer range 0 to 85178 := 0;
	signal sound_out : std_ulogic := '0';

begin
	counter <= counter + 1 when rising_edge(clk_50) and counter /= 85178 else
				  0 when rising_edge(clk_50) and counter = 85178 else
				  counter;
	
	sound_out <= '0' when counter = 0 else
					 '1' when counter = 42858 else
					 sound_out;

	sound <= sound_out;

end behavior;