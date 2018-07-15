-- Copyright 2012: Jan Burchard, Universität Freiburg
-- lcd_driver2
-- connects to the lcd, allows easy writing to position (x, y) of lcd
-- version 2 creates some new chars on startup, allowing the display of "bars"


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity lcd_driver2 is port(
  clk : in std_logic;
  rst_n : in std_logic;
  
  -- to write data to the display, wait till it is ready, than pull down write_n
  dataIn: in std_logic_vector(7 downto 0);
  posX: in std_logic_vector(4 downto 0);  
  posY : in std_logic_vector(1 downto 0);
  write_n: in std_logic;  -- write data to position
  clear_n : in std_logic;  -- clears the display
  
  rs : out std_logic;
  rw : out std_logic;
  e : out std_logic;
  
  rdy : out std_logic;
  
  dataOut : out std_logic_vector(7 downto 0)
);
end lcd_driver2;


architecture behavior of lcd_driver2 is
	-- the states for the state machine
	type state_type is (init0, init1, init2, init3, init4, init5, init6, init7, createChar1, createChar2, createChar3, createChar4, createChar5, ready, sendingAddress, sendingData);
	-- states:
	-- init0: wait for display to initialize (100ms)
	-- init1: send 0011xxxx (10ms)
	-- init2: send 0011xxxx (1ms)
	-- init3: send 0011xxxx (100µs)
	-- init4: send 001111xx (100µs) (set display to 8 bit interface, 2 line, and font)
	-- init5: send 00001100 (100µs) (set display to on, cursor to off)
	
	-- createChari : create custom char i in cg ram
	
	-- init6: send 00000001 (10ms) (clear display)
	-- init7: send 00000100 (100µs) (entry mode set)
	
	-- ready: wait for data to be send
	-- sendingAddress: send adress to display 
	-- sendingData: send data to display

	signal state : state_type := init0;
	signal charCreationCounter : natural := 0;

	signal counter : natural := 0;
	
	
	-- store the input data for writing
	signal dataStorage: std_logic_vector(7 downto 0) := "01100110";
	signal addressStorage: std_logic_vector(6 downto 0) := "0000000";
begin

	-- the main state machine
   process (clk, rst_n, write_n, clear_n)
	begin

		if clk'event and clk = '1' then
			-- reset
			if rst_n = '0' then
				state <= init0;
				counter <= 0;
				addressStorage <= (others =>'0');
				dataStorage <= (others =>'0');
	
			-- write signal received, if display is ready, write data
			elsif write_n = '0' and state = ready then
				-- calculate address and store data
				if posY = "00" then
					addressStorage <= "00" & posX;
				elsif posY = "01" then
					addressStorage <= ("00" & posX) + "1000000";  -- (posX + 0x40)
				elsif posY = "10" then
					addressStorage <= ("00" & posX) + "0010100"; -- (posX + 0x14)
				else
					addressStorage <= ("00" & posX) + "1010100";  -- (posX + 0x54)
				end if;
				
				dataStorage <= dataIn;
				
				state <= sendingAddress;
				
				counter <= 0;
		
			-- clear signal received
			elsif clear_n = '0' and state = ready then
				state <= init6;  -- clear the screen, this is done in init6
				counter <= 0;
				addressStorage <= (others =>'0');
				dataStorage <= (others =>'0');
				
			-- normal operation
			else
				counter <= counter + 1;
				
				if state = init0 and counter = 5000000 then  -- goto init1 after 100ms
					state <= init1;
					counter <= 0;
				elsif state = init1 and counter = 500000 then -- goto init2 after 10ms
					state <= init2;
					counter <= 0;
				elsif state = init2 and counter = 50000 then -- goto init3 after 1ms
					state <= init3;
					counter <= 0;
				elsif state = init3 and counter = 5000 then -- goto init4 after 100µs
					state <= init4;
					counter <= 0;
				elsif state = init4 and counter = 5000 then -- goto init5 after 100µs
					state <= init5;
					counter <= 0;
				elsif state = init5 and counter = 5000 then -- goto init6 after 100µs
					state <= createChar1;
					counter <= 0;
					charCreationCounter <= 0;
				elsif state = createChar1 and counter = 5000 then 
					charCreationCounter <= charCreationCounter + 1;
					counter <= 0;
					
					if charCreationCounter = 8 then
						state <= createChar2;
						charCreationCounter <= 0;
					end if;
				elsif state = createChar2 and counter = 5000 then 
					charCreationCounter <= charCreationCounter + 1;
					counter <= 0;
					
					if charCreationCounter = 8 then
						state <= createChar3;
						charCreationCounter <= 0;
					end if;
				elsif state = createChar3 and counter = 5000 then 
					charCreationCounter <= charCreationCounter + 1;
					counter <= 0;
					
					if charCreationCounter = 8 then
						state <= createChar4;
						charCreationCounter <= 0;
					end if;
				elsif state = createChar4 and counter = 5000 then 
					charCreationCounter <= charCreationCounter + 1;
					counter <= 0;
					
					if charCreationCounter = 8 then
						state <= createChar5;
						charCreationCounter <= 0;
					end if;
				elsif state = createChar5 and counter = 5000 then 
					charCreationCounter <= charCreationCounter + 1;
					counter <= 0;
					
					if charCreationCounter = 8 then
						state <= init6;
						charCreationCounter <= 0;
					end if;
					
				elsif state = init6 and counter = 500000 then -- goto init 7 after 10ms
					state <= init7;
					counter <= 0;
				elsif state = init7 and counter = 5000 then -- goto ready after 100µs
					state <= ready;
					counter <= 0;

				
				-- writing data to display, this takes 200µs in total
				elsif state = sendingAddress and counter = 5000 then -- goto sendingData after 100µs
					state <= sendingData;
					counter <= 0;
				elsif state = sendingData and counter = 5000 then  -- goto ready after 100µs
					state <= ready;
					counter <= 0;
				end if;
			end if;
		end if;	
	end process;
	

	-- create the signals for the lcd
	process (state, counter, addressStorage, dataStorage, charCreationCounter)
	begin
		-- the write signal is active in the beginning of each state only
		if counter > 5 and counter < 50 and state /= ready then -- first 1µs of each state (when state = ready, no data has to be send)
			e <= '1';
		else
			e <= '0';
		end if;
	
	
		-- rs and rw is always 0 while initializing and while sending the address
		if state = init0 or state = init1 or state = init2 or state = init3 or state = init4 or state = init5 or state = init6 or state = init7 
			or state = sendingAddress or ( (state = createChar1 or state = createChar2 or state = createChar3 or state = createChar4 or state = createChar5) and charCreationCounter = 0) then
			
			rs <= '0';
			rw <= '0';
		-- while waiting for data to be written
		--elsif state = sendingData or state = ready then
		else	
			rs <= '1';
			rw <= '0';
		end if;
		
		-- init
		if state = init0 then
			dataOut <= "00000000";
		elsif state = init1 then
			dataOut <= "00111100";
		elsif state = init2 then
			dataOut <= "00111100";
		elsif state = init3 then
			dataOut <= "00111100";
		elsif state = init4 then
			dataOut <= "00111100";
		elsif state = init5 then
			dataOut <= "00001100";
		elsif state = init6 then
			dataOut <= "00000001";		
		elsif state = init7 then
			dataOut <= "00000110";

		-- createChar1
		elsif state = createChar1 and charCreationCounter = 0 then
			dataOut <= "01000000"; -- address 0
		elsif state = createChar1 and charCreationCounter > 0 then
			dataOut <= "00010000"; -- data : 1 line
		-- createChar2
		elsif state = createChar2 and charCreationCounter = 0 then
			dataOut <= "01001000"; -- address 1
		elsif state = createChar2 and charCreationCounter > 0 then
			dataOut <= "00011000"; --  data : 2 line
		-- createChar3
		elsif state = createChar3 and charCreationCounter = 0 then
			dataOut <= "01010000"; -- address 0
		elsif state = createChar3 and charCreationCounter > 0 then
			dataOut <= "00011100"; -- data : 3 line
		-- createChar4
		elsif state = createChar4 and charCreationCounter = 0 then
			dataOut <= "01011000"; -- address 0
		elsif state = createChar4 and charCreationCounter > 0 then
			dataOut <= "00011110"; --  data : 4 line
		-- createChar5
		elsif state = createChar5 and charCreationCounter = 0 then
			dataOut <= "01100000"; -- address 0
		elsif state = createChar5 and charCreationCounter > 0 then
			dataOut <= "00011111"; --  data : 5 line
		
		
			
			-- normal modes:
		elsif state = sendingAddress then
			dataOut <= '1' & addressStorage;
		elsif state = sendingData then
			dataOut <= dataStorage;
		else -- mode ready
			dataOut <= "00000000";
		end if;

	end process;
	
	rdy <= '1' when state = ready else '0';
end behavior;
  
  