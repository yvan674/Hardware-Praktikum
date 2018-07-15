-- analogToButtons
-- converts the reading of the adc into the corresponding button


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity analogToButtons is port(
	analogIn : in std_logic_vector(11 downto 0);
	
	Led: out std_logic_vector(5 downto 0)
);
end analogToButtons;


architecture behavior of analogToButtons is
begin
	-- TODO: add your code here
	-- if no button
	Led <= "000001" when analogIn < "001001011000" else	-- button 1 pressed
			 "000010" when analogIn > "001001011000" and
								analogIn < "010101111000" else	-- button 2 pressed
			 "000100" when analogIn > "010101111000" and
								analogIn < "100010011000" else	-- button 3 pressed
			 "001000" when analogIn > "100010011000" and 
								analogIn < "101110111000" else	-- button 4 pressed
			 "010000" when analogIn > "101110111000" and
								analogIn < "111011011000" else	-- button 5 pressed
			 "100000"; -- nothing pressed
	
end behavior;