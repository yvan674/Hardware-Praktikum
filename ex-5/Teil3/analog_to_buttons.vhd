-- analog_to_buttons
-- converts the reading of the adc into the corresponding button


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity analog_to_buttons is port(
	analogIn : in std_logic_vector(11 downto 0);
	
	button1pressed : out std_logic;
	button3pressed : out std_logic
);
end analog_to_buttons;


architecture behavior of analog_to_buttons is
begin

	button1pressed <= '1' when analogIn < "001001011000" else	-- button 1 pressed
							'0';
	button3pressed <= '1' when analogIn > "010101111000" and
										analogIn < "100010011000" else	-- button 3 pressed
							'0';

end behavior;