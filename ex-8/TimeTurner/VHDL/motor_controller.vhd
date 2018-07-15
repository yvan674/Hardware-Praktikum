-- Copyright 2013: Jan Burchard, Universitt Freiburg
-- motor_controller: create pwm signal to control a motor

-- This file is only for hardware lab exercise 8 and the "final challenge"!
-- It must not be uploaded, distributet or otherwise made available to any third party!

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity motor_controller is port(
clk_50 : in std_logic;

speed : in std_logic_vector(9 downto 0);	
direction : in std_logic;

motor_signal1 : out std_logic;
motor_signal2 : out std_logic
);
end motor_controller;

architecture behavior of motor_controller is	signal pc : natural;constant nc : natural := 1022;
signal c : std_logic := '0';signal cc: std_logic_vector(4 downto 0) := "00000";
begin process(clk_50)begin if rising_edge(clk_50) then cc <= cc + 1;if cc = 0 then c <= not c;end if;end if;end process;
process(c)begin if rising_edge(c) then pc <= pc + 1;if pc = nc then pc <= 0;end if;end if;end process;
motor_signal1 <= '1' when direction = '1' and pc < speed else '0';
motor_signal2 <= '1' when direction = '0' and pc < speed else '0';
end behavior;