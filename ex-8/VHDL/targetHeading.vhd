-- targetHeading: makes the robot drive in a square shape

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY targetHeading IS PORT(
	heading : IN std_logic_vector (8 DOWNTO 0); -- input signal from microcontroller
		
	-- heading output
	target_heading_out : OUT std_logic_vector (8 DOWNTO 0)
	
--	-- motor a
--	motor_A_speed : OUT std_logic_vector (9 DOWNTO 0) := "0000000000";
--	motor_A_direction: OUT std_logic;
--	
--	-- motor b
--	motor_B_speed : OUT std_logic_vector (9 DOWNTO 0) := "0000000000";
--	motor_B_direction: OUT std_logic
	);
END targetHeading;


ARCHITECTURE behavior OF targetHeading IS

BEGIN
	target_heading_out <= std_logic_vector(to_unsigned(90, 9));

END behavior;