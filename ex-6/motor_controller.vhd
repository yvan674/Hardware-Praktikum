library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity motor_controller is port(
	clk_50: in std_logic;
	
	speed: in std_logic_vector(9 downto 0);
	
	-- direction input signal for motors
	direction: in std_logic;
	
	-- motor signal for motor 1
	motor_signal1: out std_logic;
	
	-- motor signal for motor 2
	motor_signal2: out std_logic
	
);
end motor_controller;



architecture behavior of motor_controller is
	-- value of motor1_signal
	signal motor1 : std_ulogic := '0';
	-- value of motor2_signal
	signal motor2 : std_ulogic := '0';
	-- 1 if the motor should be on 0 if its off in the PWM process
	--signal motorPower: std_ulogic := '0';
	-- counter to alternate between on off for PWM
	--signal counterSpeed: integer range 0 to 333333 := 0;


begin
	process(direction, motor1, motor2) --clk_50, counterSpeed, motorPower, speed)
	begin
	
	
--		if rising_edge(clk_50) then
--			counterSpeed <= counterSpeed + 1;
--		
--		else
--			counterSpeed <= counterSpeed;
--		
--		end if;
--		
--		
--		if counterSpeed = 0 and motorPower = '0' then
--			motorPower <= '1';
--		
--		elsif counterSpeed = 0 and motorPower = '1' then
--			motorPower <= '0';
--		
--		end if;
--		
		-- direction 0 then motor1 is 0 and motor 2 is 1
		if direction = '0' then --and motorPower = '1' then
			motor1 <= '0';
			motor2 <= '1';
			
		
		-- direction 1 then motor1 is 1 and motor 2 is 0
		elsif direction = '1' then --and motorPower = '1' then
			motor1 <= '1'; 
			motor2 <= '0';
			
		else
			motor1 <= '0';
			motor2 <= '0';
			
		end if;
		-- return motor1 and motor2 value to corresponding output
		motor_signal1 <= motor1;
		motor_signal2 <= motor2;
		
	end process;
end behavior; 

