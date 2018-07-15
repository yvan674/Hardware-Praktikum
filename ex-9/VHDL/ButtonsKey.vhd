-- ButtonsKey
-- converts the reading of the adc into the corresponding button
-- adapted form analogToButtons


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ButtonsKey is port(
	clk_50 : in std_logic;
	analogIn : in std_logic_vector(11 downto 0);
	
	button : out std_logic_vector(1 downto 0)
);
end ButtonsKey;


architecture behavior of ButtonsKey is
	-- counter signal
	SIGNAL counter : natural := 0;
	CONSTANT limit : integer := 5000000;
	SIGNAL within_parameters : boolean;

begin


	-- correct buttons being pressed
	within_parameters <= true when (analogIn < "001001011000") or 				   			-- button 1 being pressed
								(analogIn > "010101111000" and analogIn < "100010011000") or 	-- button 3 being pressed
								(analogIn > "100010011000" and analogIn < "101110111000") else -- button 4 being pressed
								false; 																				-- anything else being pressed
		   

	-- button Ouptut when 100ms have gone by
	button <= "01" when analogIn < "001001011000" and counter = 4999999 else											-- button 1 pressed Up Value
             "10" when analogIn > "010101111000" and analogIn < "100010011000" and counter = 4999999 else	-- button 3 pressed Right Posit.
	          "11" when analogIn > "100010011000" and analogIn < "101110111000" and counter = 4999999 else	-- button 4 pressed Down Value
	          "00"; 																														-- nothing pressed

	process(clk_50)
	begin
		
		-- clock to count to 50ms 
		if(clk_50'event and clk_50 = '1') then				-- if clk_50 rising edge, increase of reset counter
			
			if within_parameters then							-- one of the "correct" buttons is being pressed
				
				if counter = limit - 1 then					-- if counted up to 50ms reset timer
					counter <= 0;
				
				else
					counter <= counter + 1;						-- else increase timer by one
				end if;
			
			else
				counter <= 0;										-- no or incorrect button pressed, reset
			end if;
		end if;
	end process;
end behavior;