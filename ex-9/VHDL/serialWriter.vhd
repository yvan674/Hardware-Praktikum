-- serialWriter
-- To write to the arduino

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serialWriter is 

generic 
(
	DATA_WIDTH : natural := 32;
	ADDR_WIDTH : natural := 5
);


port(
	clk_50 : in std_logic;
	addr_in: in std_logic_vector(4 downto 0);
	data: in std_logic_vector(31 downto 0);

	serial_out : out std_ulogic := '1';
	addr_out : out std_logic_vector(4 downto 0)
);
end serialWriter;


architecture behavior of serialWriter is

	type state_type is (init, sendingBits, last, idle);
	signal state : state_type := idle;


	-- Taken from the Single Port RAM template 
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t;

	-- Register to hold the address 
	signal addr_reg : natural range 0 to 2**ADDR_WIDTH-1;
	
	signal addr_in_var : std_logic_vector (4 downto 0)	:= "UUUUU";
	
	-- all commands have been stored
	signal stored : boolean:= false;
	
	-- counter signals
	signal count : boolean;
	signal receive_counter : natural:= 0;
	signal count_last : boolean;
	signal counter_last : natural:= 0;
	
	-- misc signals
	signal addr_sending : integer range 0 to 27 := 0;
	signal bitNumb : integer range 0 to 31:= 0;
	
begin

	-- counter that runs for 26us
	PROCESS (clk_50)
	BEGIN
		
	END PROCESS;
	

	-- save incoming data from decoder/decryptor
	process(clk_50)
	begin
	
		if(clk_50'event and clk_50 = '1') then
			
			if (addr_in = "11010" or addr_in = "UUUUU") then
				-- do nothing 
				addr_out <= "UUUUU";
			
			elsif (addr_in >= "00000" and addr_in <= "11001") then
				-- store data in RAM
				ram(to_integer(unsigned(addr_in))) <= data;
				-- send back address to confirm that data for command has been stored
				addr_in_var <= addr_in;
				addr_out <= addr_in_var;
				
				-- if last command has been stored, start sending out data process
				if addr_in_var = "11001" then
					stored <= true;
				end if;
			end if;
		end if;
	end process;
	
	
	-- counter for data bits sending
	PROCESS(clk_50)
	BEGIN
	
		if (clk_50'EVENT and clk_50 = '1') then
			-- check if counter is activated
			if count then 
				if receive_counter < 1300 then
					receive_counter <= receive_counter + 1;
				else
					receive_counter <= 0;
				end if;
			else
				receive_counter <= 0;
			end if;
		end if;
	END PROCESS;
	
	
	-- counter for last bit sending
	PROCESS(clk_50)
	BEGIN
		if (clk_50'EVENT and clk_50 = '1') then
			-- check if counter is activated
			if count_last then 
				if counter_last < 1000000 then
					counter_last <= counter_last + 1;
				else
					counter_last <= 0;
				end if;
			else
				counter_last <= 0;
			end if;
		end if;
	END PROCESS;
	
	
	-- send out data to serial
	process(clk_50)
	begin 
		-- send out all command data bits individually 
		
		if(clk_50'event and clk_50 = '1') then
	
			case state is
			
				WHEN idle =>
					IF stored = false THEN
						state <= idle;
					ELSE
						state <= init;
						
					end if;
			
				-- send out a 0 for 26us
				when init => 
					-- iniate counter
					-- wait until 0 has been sent out for 26 us  
					if receive_counter = 1300 then
						state <= sendingBits;
					ELSE
						state <= init;
					end if;
					
	
				-- send out 32 data bit command
				when sendingBits =>
				
					-- send out each bit for 26 us
					if (receive_counter = 1300 and bitNumb = 31) then				
						state <= last;
					ELSE
						state <= sendingBits;
					END IF;
					
				when last =>
					
					-- send out 1 for 2 milis					
					if (addr_sending < 27) then
						if counter_last = 1000000 then
							state <= init;
						ELSE
							state <= last;
						end if;
					ELSE
						state <= last;
					end if;
			end case;
		end if;
	end process;
	
	PROCESS(state)
	BEGIN
		CASE state IS
			WHEN init =>
				serial_out <= '0';
				count <= true;
				
			WHEN sendingBits =>
				count <= true;
				serial_out <= ram(addr_sending)(bitNumb);
				
				-- if 26 us have passed, send out next bit
				if (receive_counter = 1300 and bitNumb < 31) then
					count <= false;
					bitNumb <= bitNumb + 1;				
				END IF;
				
			WHEN last =>
				count_last <= true;
				serial_out <= '1';
					
				if (addr_sending < 27) then
					if counter_last = 1000000 then
						count_last <= false;
						addr_sending <= addr_sending + 1;
					end if;
				end if;
			
			WHEN idle =>
				-- do nothing
		END CASE;
	END PROCESS;
				
end behavior;
	