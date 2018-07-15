library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ultrasound_controller is port(
	clk_50: in std_logic;
	
	-- enable signal
	enable : in std_logic;
	
	-- trigger, connected to ultrasound sensor
	trigger: inout std_logic;

	-- finished signal - high if system is idle
	finished : out std_logic;
		
	-- distance in cm (maximum = 255)
	distance : out std_logic_vector(7 downto 0)
);
end ultrasound_controller;



architecture behavior of ultrasound_controller is
	-- state signals:
	type state_type is (init, sending, sent, receiving, calculating);
	signal state : state_type := init;
	
	-- counter variables for timers
	signal counterSend : integer range 0 to 501 := 0;
	signal counterWait : integer range 0 to 1500000 := 0;
	signal counterReceive : integer range 0 to 1500000 := 0;
	
	-- variables
	signal tooFar : boolean;
	signal distanceNatural : natural := 0;
	
begin
	process (clk_50, trigger, enable)
		begin
		
		case state is
		
		-- state = init
		when init =>
			finished <= '1';
			if enable = '1' then
				state <= sending;
			end if;
		
		-- state = sending
		when sending =>
			-- reset previous counter
			finished <= '0';
			
			-- counter
			if rising_edge(clk_50) then
				counterSend <= counterSend + 1;
			else
				counterSend <= counterSend;
			end if;
			
			-- triggering for 10 us and switch to next state on finish
			if counterSend = 0 then
				trigger <= '0';
			elsif counterSend = 501 then
				trigger <= '0';
				state <= sent;
			else
				trigger <= '1';
			end if;

		-- state = sent
		when sent =>
			-- reset previous counter
			-- counter
			if rising_edge(clk_50) then
				counterWait <= counterWait + 1;
			else
				counterWait <= counterWait;
			end if;
			
			-- waiting for signal
			if trigger /= '0' and counterWait /= 1500000 then
				counterWait <= 0;
				tooFar <= false;
				state <= receiving;
			elsif counterWait = 1500000 then
				counterWait <= 0;
				state <= calculating;
				tooFar <= true;
			end if;
			
		-- state = receiving
		when receiving =>
			
			-- counter
			if rising_edge(clk_50) then
				counterReceive <= counterReceive + 1;
			else
				counterReceive <= counterReceive;
			end if;
			
			-- when to stop counting
			if trigger = '0' then
				state <= calculating;
			end if;
			
		-- state = calculating
		when calculating =>
			-- two cases: one for too far and other for actual distance
			if tooFar then
				distance <= "11111111";
				state <= init;			
			else
				distanceNatural <= counterReceive / 58;
				if distanceNatural < 14790 then
					distance <= "11111111";
				else
					distance <= std_logic_vector(to_unsigned(distanceNatural, distance'length));
				end if;
			end if;
		end case;
	end process;
end behavior;
