-- Copyright 2012 - 2014: Jan Burchard, Universität Freiburg
-- dataToLcd
-- display different information on the lcd

library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dataToLcd is port(
	clk: in std_logic;
	
	accX: in std_logic_vector (12 downto 0);
	accY: in std_logic_vector (12 downto 0);
	accZ: in std_logic_vector (12 downto 0);
	
	
	-- connection to lcd module
	lcd_ready: in std_logic;
	lcd_data: out std_logic_vector(7 downto 0);
	lcd_posX: out std_logic_vector(4 downto 0);
	lcd_posY: out std_logic_vector(1 downto 0);
	lcd_write_n: out std_logic;
	lcd_clear_n: out std_logic
);
end dataToLcd;


architecture behavior of dataToLcd is
	-- binary to decimal converter (used for acc -> display)
	component binaryToDecimal
		port(clk: in std_logic;
			binaryIn: in std_logic_vector(12 downto 0);			
			d3 : out std_logic_vector(3 downto 0);
			d2 : out std_logic_vector(3 downto 0);
			d1 : out std_logic_vector(3 downto 0);
			d0 : out std_logic_vector(3 downto 0)
		);
	end component;
	
	-- constants:
	constant nameDisplayTime : natural := 50000000; -- 1sec


	-- define states for internal state machine:
	type state_type is (init, update, pause);
	
	signal state : state_type := init;
	signal next_state: state_type;
	-- init: wait for lcd to init, then clear the screen
	-- update: update the lines
	-- pause: wait for 500ms (to reduce screen flickering)
	
	-- define state of display (to show different information
	type display_state_type is (start, showData);
	signal display_state : display_state_type := start;
	signal display_counter : natural := 0;
	
	-- the current character and line that is written
	signal lineCount : std_logic_vector (1 downto 0);
	signal charCount : std_logic_vector (4 downto 0);
	
	-- clock counter used for internal timing
	signal counter : natural := 0; 
		
	
	-- for acc values:
	signal acc_X_d3 : std_logic_vector(3 downto 0);
	signal acc_X_d2 : std_logic_vector(3 downto 0);
	signal acc_X_d1 : std_logic_vector(3 downto 0);
	signal acc_X_d0 : std_logic_vector(3 downto 0);
	
	signal acc_Y_d3 : std_logic_vector(3 downto 0);
	signal acc_Y_d2 : std_logic_vector(3 downto 0);
	signal acc_Y_d1 : std_logic_vector(3 downto 0);
	signal acc_Y_d0 : std_logic_vector(3 downto 0);
	
	signal acc_Z_d3 : std_logic_vector(3 downto 0);
	signal acc_Z_d2 : std_logic_vector(3 downto 0);
	signal acc_Z_d1 : std_logic_vector(3 downto 0);
	signal acc_Z_d0 : std_logic_vector(3 downto 0);
	
	signal accX_v : std_logic_vector(12 downto 0);
	signal accY_v : std_logic_vector(12 downto 0);
	signal accZ_v : std_logic_vector(12 downto 0);
	
	
begin

	-- convert binary acc values into decimal digits
	converterX: binaryToDecimal port map (clk => clk, binaryIn => accX_v, d3 => acc_X_d3, d2 => acc_X_d2, d1 => acc_X_d1, d0 => acc_X_d0);
	converterY: binaryToDecimal port map (clk => clk, binaryIn => accY_v, d3 => acc_Y_d3, d2 => acc_Y_d2, d1 => acc_Y_d1, d0 => acc_Y_d0);
	converterZ: binaryToDecimal port map (clk => clk, binaryIn => accZ_v, d3 => acc_Z_d3, d2 => acc_Z_d2, d1 => acc_Z_d1, d0 => acc_Z_d0);
	

	process(clk)
	begin
		if clk'event and clk = '1' then
			counter <= counter + 1;
			
			-- initialize values
			if state = init and lcd_ready = '1' then
				state <= update;
				counter <= 0;
				display_counter <= 0;
				charCount <= (others => '0');
				lineCount <= (others => '0');
				
				
			elsif state = update then
				-- every char was updated, wait for 100ms
				if charCount = 20 and lineCount = 3 then
					state <= pause;
					
				-- line end reached, goto next line
				elsif charCount = 20 then
					lineCount <= lineCount + 1;
					charCount <= (others => '0');
					counter <= 0;
				
				-- char successfully written to lcd -> goto next char
				elsif counter > 10 and lcd_ready = '1' then
					charCount <= charCount + 1;
					counter <= 0;
				end if;
					
			-- wait for 500ms
			elsif state = pause and counter = 25000000 then   -- sleep for 100ms (to increase screen readability)
				state <= update;
				charCount <= (others => '0');
				lineCount <= (others => '0');
				counter <= 0;				
				-- store the current value
				accX_v <= accX;
				accY_v <= accY;
				accZ_v <= accZ;
			end if;
			
			-- update the display state:			
			if display_counter < nameDisplayTime then  -- how long the names are shown on the screen
				display_counter <= display_counter + 1;
				display_state <= start;
			else	
				display_counter <= 500000000;
				display_state <= showData;
			end if;
			
			
			
		end if;
	end process;

	
	process(clk)  -- do the display updating
	begin
		if clk'event and clk = '1' then
			lcd_posX <= charCount;
			lcd_posY <= lineCount;
			
			-- update all lines
			
			
			if display_state = start then
				if lineCount = 0 then
					-- write "Hardwarepraktikum"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('H'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('d'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('w'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 8 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('e'),8);
					elsif charCount = 9 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);
					elsif charCount = 10 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('P'),8);
					elsif charCount = 11 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 12 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 13 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('k'),8);
					elsif charCount = 14 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('t'),8);
					elsif charCount = 15 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('i'),8);
					elsif charCount = 16 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('k'),8);
					elsif charCount = 17 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('u'),8);
					elsif charCount = 18 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('m'),8);
					elsif charCount = 19 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
					
				elsif lineCount = 1 then
					-- write "IRA, Uni Freiburg"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('I'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('R'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('A'),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('U'),8);
					elsif charCount = 8 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('n'),8);
					elsif charCount = 9 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('i'),8);
					elsif charCount = 10 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);
					elsif charCount = 11 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('F'),8);
					elsif charCount = 12 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 13 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('e'),8);
					elsif charCount = 14 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('i'),8);
					elsif charCount = 15 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('b'),8);
					elsif charCount = 16 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('u'),8);
					elsif charCount = 17 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 18 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('g'),8);
					elsif charCount = 19 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
				elsif lineCount = 2 then
					-- write "J. Burchard,"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('J'),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('.'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('B'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('u'),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('h'),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 8 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 9 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('d'),8);
					elsif charCount = 10 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(','),8);
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
				elsif lineCount = 3 then
					-- write "T.Schuber, B.Becker"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('T'),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('.'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('S'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('h'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('u'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('b'),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('e'),8);
					elsif charCount = 8 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 9 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('t'),8);
					elsif charCount = 10 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(','),8);
					elsif charCount = 11 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('B'),8);
					elsif charCount = 12 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('.'),8);
					elsif charCount = 13 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('B'),8);
					elsif charCount = 14 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('e'),8);
					elsif charCount = 15 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 16 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('k'),8);
					elsif charCount = 17 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('e'),8);
					elsif charCount = 18 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('r'),8);
					elsif charCount = 19 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;	
					
				end if;
			else -- display_state = showData -> display status of adc's and buttons
				
				-----
				-- line 0
				-----
				if lineCount = 0 then				
					-- write "acc X  :xxxx"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
						
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('X'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(':'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 8 then
						if accX_v(12)= '1' then
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);						
						else
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
						end if;
					elsif charCount = 9 then
						lcd_data <= acc_X_d3 + "00110000";
					elsif charCount = 10 then
						lcd_data <= acc_X_d2 + "00110000";
					elsif charCount = 11 then
						lcd_data <= acc_X_d1 + "00110000";
					elsif charCount = 12 then
						lcd_data <= acc_X_d0 + "00110000";
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
				
				----
				-- line 1
				----
				elsif lineCount = 1 then
					-- write "acc Y  :xxxx"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('Y'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(':'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 8 then
						if accY_v(12)= '1' then
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);						
						else
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
						end if;
					
					elsif charCount = 9 then
						lcd_data <= acc_Y_d3 + "00110000";
					elsif charCount = 10 then
						lcd_data <= acc_Y_d2 + "00110000";
					elsif charCount = 11 then
						lcd_data <= acc_Y_d1 + "00110000";
					elsif charCount = 12 then
						lcd_data <= acc_Y_d0 + "00110000";
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
				----
				-- line 2
				----	
				elsif lineCount = 2 then		
					-- write "acc Z  :xxxx"
					if charCount = 0 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('a'),8);
					elsif charCount = 1 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 2 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('c'),8);
					elsif charCount = 3 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 4 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('Z'),8);
					elsif charCount = 5 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(':'),8);
					elsif charCount = 6 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 7 then
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					elsif charCount = 8 then
						if accZ_v(12)= '1' then
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos('-'),8);						
						else
							lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
						end if;
					
					elsif charCount = 9 then
						lcd_data <= acc_Z_d3 + "00110000";
					elsif charCount = 10 then
						lcd_data <= acc_Z_d2 + "00110000";
					elsif charCount = 11 then
						lcd_data <= acc_Z_d1 + "00110000";
					elsif charCount = 12 then
						lcd_data <= acc_Z_d0 + "00110000";
					else 
						lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
					end if;
					
				----
				-- line 3
				----	
				elsif lineCount = 3 then	
					lcd_data <= CONV_STD_LOGIC_VECTOR(character'pos(' '),8);
				end if;
				
				
			
			--	lcd_posY <= "00";
			--	lcd_data <= "00000000";
			end if;
			
			-- generate the write signal for the lcd
			if counter > 2 and counter < 10 and state /= pause then 
				lcd_write_n <= '0';
			else
				lcd_write_n <= '1';
			end if;
		end if;	
	end process;

	-- never clear the lcd
	lcd_clear_n <= '1';
end behavior;