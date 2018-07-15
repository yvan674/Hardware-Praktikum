-- sixtotwelve
-- converts six bit to twelve bit


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sixtotwelve is port(
	six_bit : in std_logic_vector(5 downto 0);
	
	twelve_bit: out std_logic_vector(11 downto 0)	-- counter output
);
end sixtotwelve;


architecture behavior of sixtotwelve is

begin
	twelve_bit <= std_logic_vector(resize(signed(six_bit), twelve_bit'length));
end behavior;