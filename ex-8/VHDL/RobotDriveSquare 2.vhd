-- RobotDriveSquare: makes the robot drive in a square shape

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RobotDriveSquare IS PORT(
	CLK : IN std_logic;	-- 50 MHz clock
	
	heading : IN std_logic_vector (8 DOWNTO 0); -- input signal from microcontroller
		
	-- heading output
	target_heading_out : OUT std_logic_vector (8 DOWNTO 0);
	
	-- motor a
	motor_A_speed : OUT std_logic_vector (9 DOWNTO 0) := "0000000000";
	motor_A_direction: OUT std_logic;
	
	-- motor b
	motor_B_speed : OUT std_logic_vector (9 DOWNTO 0) := "0000000000";
	motor_B_direction: OUT std_logic
	);
END RobotDriveSquare;


ARCHITECTURE behavior OF RobotDriveSquare IS
	-- state machine variables
	TYPE state_type IS (s0, s1);
	SIGNAL state : state_type := s0;
	
	-- counter
	SIGNAL counter : NATURAL := 0;
	
	-- heading signal
	SIGNAL target_heading_int : NATURAL;
	SIGNAL target_heading_int_mem : NATURAL;
	SIGNAL heading_int : NATURAL;
	

BEGIN
	-- convert heading to natural
	heading_int <= to_integer(unsigned(heading));

	-- target_heading buffer
	target_heading_int <= (heading_int + 90) MOD 360 WHEN state = s0 ELSE
								 target_heading_int;

	-- target_heading out
	target_heading_out <= std_logic_vector(to_unsigned(target_heading_int, 9));

	PROCESS(CLK)
	BEGIN
		IF (CLK'EVENT AND CLK = '1') THEN
			-- counter
			IF counter /= 200000001 THEN
				counter <= counter + 1;
			ELSIF counter = 200000001 THEN
				counter <= 0;
			END IF;
			CASE state IS
				when s0 =>
					-- stay in state for 4 seconds
					IF counter = 200000000 THEN
						state <= s1;
					ELSE
						state <= s0;
					END IF;
				
				when s1 =>
					-- stay in state until heading >= target heading
					IF to_integer(signed(heading)) >= target_heading_int THEN
						state <= s0;
					ELSE
						state <= s1;
					END IF;
			END CASE;
		ELSE
			counter <= counter;
		END IF;
	END PROCESS;
	
	PROCESS(state)
	BEGIN
		CASE state IS
			when s0 =>
				-- drive motor forwards
				motor_A_speed <= "0111111111";
				motor_A_direction <= '0';
				motor_B_speed <= "0111111111";
				motor_B_direction <= '1';
			when s1 =>
				-- drive motor to turn, send out target heading
				motor_A_speed <= "0111111111";
				motor_A_direction <= '1';
				motor_B_speed <= "0111111111";
				motor_B_direction <= '1';
		END CASE;
	END PROCESS;
END behavior;