-- UARTreceiver: receives the serial information from the microcontroller

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY UARTreceiver IS PORT(
	clk_50: IN std_logic;	-- 50 MHz clock
	
	serial : IN std_logic; -- input signal from microcontroller
		
	-- data output
	dataReady : OUT std_logic;
	data : OUT std_logic_vector(7 DOWNTO 0)
);
END UARTreceiver;


ARCHITECTURE behavior OF UARTreceiver IS
	-- state enumeration and declaration
	TYPE state_type IS (idle_pre, idle, start_bit, d7, d6, d5, d4, d3, d2, d1, d0, stop_bit);
	SIGNAL state : state_type := idle_pre;
	SIGNAL next_state : state_type := start_bit;
	
	-- time counter
	SIGNAL counter_26us: natural := 0; -- 26 us = 1300 cycles
	
	-- running variable
	SIGNAL running : BIT := '0';
	SIGNAL running_mem : BIT;
	
	-- data_ready buffer
	SIGNAL data_ready_int : std_logic;
	
	-- data buffer
	SIGNAL data_int : std_logic_vector (7 DOWNTO 0);
	signal data_int_mem : std_logic_vector (7 DOWNTO 0);
	
BEGIN
	
	-- setup counter
	counter_26us <= counter_26us + 1 WHEN RISING_EDGE(clk_50) AND running = '1' AND counter_26us /= 1300 ELSE
						 0 WHEN RISING_EDGE(clk_50) AND counter_26us = 1300 ELSE
						 0 WHEN RISING_EDGE(clk_50) AND running = '0' ELSE
						 counter_26us;
	
	-- data ready signal
	data_ready_int <= '1' WHEN state = stop_bit ELSE
							'0' WHEN state /= stop_bit ELSE
							data_ready_int;
	
	dataReady <= data_ready_int;
	
	
	-- data_int value assignment
	data_int(0) <= serial WHEN state = d0 AND (counter_26us > 600 AND counter_26us < 699) ELSE
					   'U' WHEN state = idle_pre ELSE
						data_int_mem(0);
	
	data_int(1) <= serial WHEN state = d1 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(1);
						
	data_int(2) <= serial WHEN state = d2 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(2);
						
	data_int(3) <= serial WHEN state = d3 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(3);
						
	data_int(4) <= serial WHEN state = d4 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(4);
						
	data_int(5) <= serial WHEN state = d5 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(5);
						
	data_int(6) <= serial WHEN state = d6 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(6);
						
	data_int(7) <= serial WHEN state = d7 AND (counter_26us > 600 AND counter_26us < 699)  ELSE
						'U' WHEN state = idle_pre ELSE
						data_int_mem(7);
		
	data_int_mem <= data_int;
	
	data <= data_int;
	
	running <= '0' WHEN state = idle_pre ELSE
				  '1' WHEN state = start_bit ELSE
				  running_mem;
	
	running_mem <= running;
						 
	PROCESS (clk_50, serial, counter_26us)
	BEGIN
		IF (clk_50'EVENT AND clk_50 = '1') THEN
			CASE state IS
				WHEN idle_pre =>
					-- idle for before starting
					IF serial = '0' THEN
							state <= start_bit;
					ELSE
						state <= idle_pre;
					END IF;
				
				WHEN idle =>
					-- idle for during running
					IF counter_26us = 1299 THEN
							state <= next_state;
					ELSE
						state <= idle;
					END IF;
				
				WHEN start_bit => 
					IF counter_26us = 700 THEN
						next_state <= d0;
						state <= idle;
					ELSE
						state <= start_bit;
					END IF; 
				
				WHEN d0 =>
					-- changes back to idle after reading
					IF counter_26us = 700 THEN
						next_state <= d1;
						state <= idle;
					ELSE
						state <= d0;
					END IF;
				
				WHEN d1 =>
					IF counter_26us = 700 THEN
						next_state <= d2;
						state <= idle;
					ELSE
						state <= d1;
					END IF;
				
				WHEN d2 =>
					IF counter_26us = 700 THEN
						next_state <= d3;
						state <= idle;
					ELSE
						state <= d2;
					END IF;
				
				WHEN d3 =>
					IF counter_26us = 700 THEN
						next_state <= d4;
						state <= idle;
					ELSE
						state <= d3;
					END IF;
				
				WHEN d4 =>
					IF counter_26us = 700 THEN
						next_state <= d5;
						state <= idle;
					ELSE
						state <= d4;
					END IF;
				
				WHEN d5 =>
					IF counter_26us = 700 THEN
						next_state <= d6;
						state <= idle;
					ELSE
						state <= d5;
					END IF;
				
				WHEN d6 =>
					IF counter_26us = 700 THEN
						next_state <= d7;
						state <= idle;
					ELSE
						state <= d6;
					END IF;
				
				WHEN d7 =>
					IF counter_26us = 700 THEN
						next_state <= stop_bit;
						state <= idle;
					ELSE
						state <= d7;
					END IF;
				
				WHEN stop_bit =>
					IF counter_26us = 1299 THEN
						next_state <= start_bit;
						state <= idle_pre;
					ELSE
						state <= stop_bit;
					END IF;
			END CASE;
		END IF;
	END PROCESs;
	
	PROCESS (state)
	BEGIN
		CASE state IS
			WHEN idle_pre =>
--				running <= '0';
--				data <= "ZZZZZZZZ";
			
			WHEN idle =>
--				data <= "ZZZZZZZZ";
			
			WHEN d0 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(0) <= serial;
--				ELSE
--					data(0) <= 'Z';
--				END IF;
				
			WHEN d1 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(1) <= serial;
--				ELSE
--					data(1) <= 'Z';
--				END IF;
			
			WHEN d2 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(2) <= serial;
--				ELSE
--					data(2) <= 'Z';
--				END IF;
				
			WHEN d3 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(3) <= serial;
--				ELSE
--					data(3) <= 'Z';
--				END IF;
				
			WHEN d4 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(4) <= serial;
--				ELSE
--					data(4) <= 'Z';
--				END IF;
				
			WHEN d5 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(5) <= serial;
--				ELSE
--					data(5) <= 'Z';
--				END IF;
				
			WHEN d6 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(6) <= serial;
--				ELSE
--					data(6) <= 'Z';
--				END IF;
				
			WHEN d7 =>
--				IF (counter_26us >= 600 and counter_26us < 700) THEN
--					data(7) <= serial;
--				ELSE
--					data(7) <= 'Z';
--				END IF;
			
			WHEN start_bit =>
--				running <= '1';
			
			WHEN stop_bit =>
				-- do nothing
		END CASE;
	END PROCESS;
	
END behavior;