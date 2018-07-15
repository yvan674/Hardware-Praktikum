-------------------------------------------------------
--Halbaddierer in VHDL
--Jedes Design in VHDL besteht aus einer "entity", welche
-- das Interface definiert, sowie mindestens einer dazu-
--gehoerigen "architecutre", welche die Implementierung
--enthaelt.
-------------------------------------------------------

-- In einer Librar ysind viele Standardfunktionen definiert
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--entity eines Halbaddierers
entity Halfadder_V is port(
	a, b: in std_logic;						-- Input-Ports
	sum_bit,carry_bit: out std_logic);	-- Output-Ports
end Halfadder_V;

--architecture eines Halbaddierers
architecture behavior of Halfadder_V is
begin
	sum_bit <= a xor b;				-- Berechnung des Summen-Bits
	carry_bit <= a and b;			-- Berechnung des Carry-Bits
end behavior;