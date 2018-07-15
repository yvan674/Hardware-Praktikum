-- checker
-- checks if the key if correct yet or not


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity checker is port(
	clk_50 : in std_logic;
	decryptedIn : in std_logic_vector(31 downto 0);
	
	correctKey : out std_logic
);
end checker;


architecture behavior of checker is
	SIGNAL decrypted : boolean := false;
	CONSTANT checkedTo : std_logic_vector(31 DOWNTO 0) :=
		"11111111000000001111111100000000";

begin
PROCESS(clk_50)
BEGIN
	IF (clk_50'EVENT and clk_50 = '1') THEN
		IF decryptedIn = checkedTo THEN
			decrypted <= true;
		ELSIF decryptedIn /= checkedTo and decrypted = true then
			decrypted <= true;
		ELSE
			decrypted <= false;
		END IF;
	END IF;
	
END PROCESS;

PROCESS(clk_50)
BEGIN
	IF decrypted THEN
		correctKey <= '1';
	ELSE
		correctKey <= '0';
	END IF;
END PROCESS;

end behavior;