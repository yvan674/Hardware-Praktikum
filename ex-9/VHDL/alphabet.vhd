-- alphabet
-- changes the input key


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alphabet is port(
	clk_50 : in std_logic;
	button : in std_logic_vector(1 downto 0);
	
	cursorPosition : out std_logic_vector(1 DOWNTO 0);
	key : out std_logic_vector(31 downto 0)
);
end alphabet;


architecture behavior of alphabet is
	type state_type is (zero, one, two, three);
	signal state : state_type := zero;

	SIGNAL key_rep : std_logic_vector(31 downto 0) := "01100001011000010110000101100001";
	SIGNAL last_button : std_logic_vector(1 downto 0) := "00";
	SIGNAL index_0: natural := 97;
	SIGNAL index_1: natural := 97;
	SIGNAL index_2: natural := 97;
	SIGNAL index_3: natural := 97;

begin

	process(clk_50)
	begin

		if (clk_50'event and clk_50 = '1') then

			if state = zero then
				cursorPosition <= "00";

				if (button = "11" and button /= last_button) then			-- button 4 pressed, increase value
					last_button <= "11";
					if (index_0 > 96 AND index_0 < 122) then 										-- within lowercase ASCII lowercase boundary
						index_0 <= index_0 + 1;
					else																	-- reset to lowercase 'a'
						index_0 <= 97;
					end if;

				elsif (button = "10" and button /= last_button) then		-- button 3 pressed, change position to right
					last_button <= "10";
					state <= one;

				elsif (button = "01" and button /= last_button) then		-- button 1 pressed, decrease value
					last_button <= "01";
					if (index_0 > 97 AND index_0 < 123) then 											-- within lowercase ASCII lowercase boundary
						index_0 <= index_0 - 1;
					else																	-- reset to lowercase 'z'
						index_0 <= 122;
					end if;
				else
					last_button <= "00";												-- invalid button pressed

				end if;


			elsif state = one then													-- works analog to state 0
				cursorPosition <= "01";
				
				if (button = "11" and button /= last_button) then
					last_button <= "11";
					if (index_1 > 96 AND index_1 < 122) then
						index_1 <= index_1 + 1;
					else
						index_1 <= 97;
					end if;

				elsif (button = "10" and button /= last_button) then
					last_button <= "10";
					state <= two;

				elsif (button = "01" and button /= last_button) then
					last_button <= "01";
					if (index_1 > 97 AND index_1 < 123) then
						index_1 <= index_1 - 1;
					else
						index_1 <= 122;
					end if;
				else
					last_button <= "00";

				end if;


			elsif state = two then													-- works analog to state 0
				cursorPosition <= "10";
				
				if (button = "11" and button /= last_button)	then
					last_button <= "11";
					if (index_2 > 96 AND index_2 < 122) then
						index_2 <= index_2 + 1;
					else
						index_2 <= 97;
					end if;

				elsif (button = "10" and button /= last_button) then
					last_button <= "10";
					state <= three;

				elsif (button = "01" and button /= last_button)	then
					last_button <= "01";
					if (index_2 > 97 AND index_2 < 123) then
						index_2 <= index_2 - 1;
					else
						index_2 <= 122;
					end if;
				else
					last_button <= "00";

				end if;


			elsif state = three then					-- works analog to state 0
				cursorPosition <= "11";
				
				if (button = "11" and button /= last_button) then
					last_button <= "11";
					if (index_3 > 96 AND index_3 < 122) then
						index_3 <= index_3 + 1;
					else
						index_3 <= 97;
					end if;

				elsif (button = "10" and button /= last_button)	then
					last_button <= "10";
					state <= zero;

				elsif (button = "01" and button /= last_button)	then
					last_button <= "01";
					if (index_3 > 97 AND index_3 < 123) then
						index_3 <= index_3 - 1;
					else
						index_3 <= 122;
					end if;
				else
					last_button <= "00";

				end if;
			end if;

		-- update key with index values 3 to 0
		key_rep(31 downto 24) <= std_logic_vector(to_unsigned(index_0, 8));
		key_rep(23 downto 16) <= std_logic_vector(to_unsigned(index_1, 8));
		key_rep(15 downto 8) <= std_logic_vector(to_unsigned(index_2, 8));
		key_rep(7 downto 0) <= std_logic_vector(to_unsigned(index_3, 8));
		end if;

		key <= key_rep; -- send out binary rep of key
	end process;
end;
