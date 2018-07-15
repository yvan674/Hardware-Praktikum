-- analogToButtons
-- converts the reading of the adc into the corresponding button


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity analogToButtons is port(
	analogIn : in std_logic_vector(11 downto 0);
	
	select_out: out std_logic_vector(2 downto 0)
);
end analogToButtons;


architecture behavior of analogToButtons is
begin
	-- if no button
	select_out <= "000" when analogIn < "001001011000" else	-- button 1 pressed
					  "001" when analogIn > "001001011000" and
								analogIn < "010101111000" else	-- button 2 pressed
					  "010" when analogIn > "010101111000" and
								analogIn < "100010011000" else	-- button 3 pressed
					  "011" when analogIn > "100010011000" and 
								analogIn < "101110111000" else	-- button 4 pressed
					  "100" when analogIn > "101110111000" and
								analogIn < "111011011000" else	-- button 5 pressed
					  "101"; -- nothing pressed
	
end behavior;