-- decryptor
-- runs the decryption algorithm


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decryptor is port(
	clk_50 : in std_logic;
	keyIn : in std_logic_vector(31 downto 0);
	correctKey : in std_logic;
	addrIn : in std_logic_vector(4 downto 0);

	decryptedOut : out std_logic_vector(31 downto 0);
	addr : out std_logic_vector(4 downto 0)
);
end decryptor;


architecture behavior of decryptor is
	-- data storage arrays
	TYPE dataElement38 IS ARRAY (0 to 27) OF std_logic_vector(37 downto 0); -- command data
	CONSTANT dataStorage : dataElement38 := (
		"11100101110110110111110011111100011000", 
		"00101000110001100001010000010010111010",  
		"10110011101101000101000101000100101111", 
		"10100110011000010101010010011011110110", 
		"10110011101101000110010010000000011110", 
		"10100110011000010001000110011110010010", 
		"10110011101101100111110100001100011010", 
		"10100110011000010001011011100101100000", 
		"10110011101101000110010010010000110110", 
		"10100110011000010110001001110100110101", 
		"10110011101101000001011000100001010101", 
		"01001100110111110101001110000000001001", 
		"00001010110110001110010101000110011110", 
		"10100110011000010111110000010011110111", 
		"10110011101101000101001110110010011100", 
		"01000100011101111111100001100000110100", 
		"00001101011010100110111000100000011111", 
		"00101111000100110000000110010000001101", 
		"11100011101101010110110000100000011111", 
		"00100100000000000000001110010000000100", 
		"00001010001001110110110000100000010100", 
		"00101110100110001100000110010000001111", 
		"01000010100100010110111000100010011111", 
		"01001000010100100111101110000011010101", 
		"01000100000000001111101010010010101101", 
		"10110011101101000110010110101100000110", 
		"11100011000100110110110000100000011100", 
		"11100101100100110000010000111100010100");
		
	TYPE dataElement32 IS ARRAY (0 to 25) OF std_logic_vector(31 downto 0); -- correct data
	SIGNAL dataCommand: dataElement32 := (
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000");
		

		
	-- round keys
	TYPE roundKey IS ARRAY (0 to 3) OF std_logic_vector(31 DOWNTO 0);
	
	SIGNAL newRoundKey : roundKey := (
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000"
	);
	
	
	
	-- flag signals
	SIGNAL doneDecrypting : boolean := false;
	SIGNAL oldKey : std_logic_vector(31 DOWNTO 0) := (0 to 31 => '0');
	SIGNAL current_key: std_logic_vector (31 DOWNTO 0) := (0 to 31 => '0');
	SIGNAL shift_key: std_logic_vector (31 DOWNTO 0) := (0 to 31 => '0');
	
	FUNCTION decode (data38 : std_logic_vector(37 DOWNTO 0)) RETURN std_logic_vector IS
		VARIABLE element : std_logic_vector(37 DOWNTO 0);
		VARIABLE wrong : natural;
		VARIABLE p0 : std_ulogic;
		VARIABLE p1 : std_ulogic;
		VARIABLE p2 : std_ulogic;
		VARIABLE p3 : std_ulogic;
		VARIABLE p4 : std_ulogic;
		VARIABLE p5 : std_ulogic;
		VARIABLE correct : std_logic_vector(31 DOWNTO 0);
	BEGIN
		element := data38;
	-- calculate correct parity bit value

		p0 := element(2) XOR element(4) XOR element(6) XOR element(8) XOR element(10) XOR element(12) XOR		-- calculates the value parity bit 0 should have
				element(14) XOR element(16) XOR element(18) XOR element(20) XOR element(22) XOR element(24) XOR	-- analog for parity bits 1-5
				element(26) XOR element(28) XOR element(30) XOR element(32) XOR element(34) XOR element(36);
		
		p1 := element(2) XOR element(5) XOR element(6) XOR element(9) XOR element(10) XOR element(13) XOR		
				element(14) XOR element(17) XOR element(18) XOR element(21) XOR element(22) XOR element(25) XOR
				element(26) XOR element(29) XOR element(30) XOR element(33) XOR element(34) XOR element(37);

		
		p2 := element(4) XOR element(5) XOR element(6) XOR element(11) XOR element(12) XOR element(13) XOR
				element(14) XOR element(19) XOR element(20) XOR element(21) XOR element(22) XOR element(27) XOR
				element(28) XOR element(29) XOR element(30) XOR element(35) XOR element(36) XOR element(37);

		
		p3 := element(8) XOR element(9) XOR element(10) XOR element(11) XOR element(12) XOR element(13) XOR
				element(14) XOR element(23) XOR element(24) XOR element(25) XOR element(26) XOR element(27) XOR
				element(28) XOR element(29) XOR element(30);

		p4 := element(16) XOR element(17) XOR element(18) XOR element(19) XOR element(20) XOR element(21) XOR
				element(22) XOR element(23) XOR element(24) XOR element(25) XOR element(26) XOR element(27) XOR
				element(28) XOR element(29) XOR element(30);

		p5 := element(32) XOR element(33) XOR element(34) XOR element(35) XOR element(36) XOR element(37); 
		
		
	-- compare to actual parity bit value, if value is incorrect increase wrong variable by
	-- value of incorrect parity bit binary position
		
		if (p0 /= element(0)) then
			wrong := wrong + 1;
		end if;
		
		if (p1 /= element(1)) then
			wrong := wrong + 2;
		end if;
		
		if (p2 /= element(3)) then
			wrong := wrong + 4;
		end if;

		
		if (p3 /= element(7)) then
			wrong := wrong + 8;
		end if;
		
		if (p4 /= element(15)) then
			wrong := wrong + 16;
		end if;
		
		if (p5 /= element(31)) then
			wrong := wrong + 32;
		end if;


	-- correct possible bit errors
		
		if wrong /= 0 then 					
			-- has mistake at bit index (wrong-1)
			-- store reversed value at index place
			element(wrong - 1) := NOT element(wrong - 1);		
			
		end if;

	-- save in output vector
		
		-- save all the data bits into 32 bit variable
		correct(31 downto 26) := element(37 downto 32); 
		correct(25 downto 11) := element(30 downto 16);
		correct(10 downto 4) := element(14 downto 8);
		correct(3 downto 1) := element(6 downto 4);
		correct(0) := element (2);	
		
		-- save the 32 bit data into the ouput at the corresponding 
		-- line position
		
		RETURN correct;
	END decode;
	
	
	FUNCTION substitute (data32 : std_logic_vector(31 DOWNTO 0)) RETURN std_logic_vector IS
		VARIABLE output : std_logic_vector(31 DOWNTO 0);
	BEGIN
		FOR i IN 0 TO 7 LOOP
			IF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0000" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1010";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0001" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1100";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0010" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1000";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0011" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1111";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0100" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1110";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0101" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0110";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0110" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0011";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "0111" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1011";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1000" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0111";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1001" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0101";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1010" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0000";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1011" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0010";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1100" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1001";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1101" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0001";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1110" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "0100";
			ELSIF data32(31 - (i * 4) DOWNTO 28 - (i * 4)) = "1111" THEN
				output(31 - (i * 4) DOWNTO 28 - (i * 4)) := "1101";
			END IF;
		END LOOP;
		
		RETURN output;
	END substitute;
	
	FUNCTION shift (data32 : std_logic_vector(31 DOWNTO 0)) RETURN std_logic_vector IS
		VARIABLE output : std_logic_vector(31 DOWNTO 0);
	BEGIN
		FOR i IN 0 TO 3 LOOP
			IF i = 0 THEN
					output(31 DOWNTO 0) := data32(31 DOWNTO 0);
			ELSIF i = 1 THEN
				output(23 DOWNTO 18) := data32(21 DOWNTO 16);
				output(17 DOWNTO 16) := data32(23 DOWNTO 22);
			ELSIF i = 2 THEN
				output(15 DOWNTO 12) := data32(11 DOWNTO 8);
				output(11 DOWNTO 8) := data32(15 DOWNTO 12);
			ELSIF i = 3 THEN
				output(7 DOWNTO 6) := data32(1 DOWNTO 0);
				output(5 DOWNTO 0) := data32(7 DOWNTO 2);
			END IF; 
		END LOOP;
		RETURN output;
	END shift;
	
	FUNCTION addRoundKey (data32 : std_logic_vector(31 DOWNTO 0); key : std_logic_vector(31 DOWNTO 0)) RETURN std_logic_vector IS
		VARIABLE output : std_logic_vector(31 DOWNTO 0);
	BEGIN
		FOR i IN 0 TO (data32'LENGTH - 1) LOOP
			output(i) := data32(i) XOR key(i);
		END LOOP;
		RETURN output;
	END addRoundKey;
	

	FUNCTION findRoundKey (key : std_logic_vector(31 DOWNTO 0)) RETURN roundKey IS
		VARIABLE roundKeys : roundKey := (
			(0 to 31 => '0'),
			(0 to 31 => '0'),
			(0 to 31 => '0'),
			(0 to 31 => '0')
		);
		
		CONSTANT roundKeyArray : roundKey := (
			"11110111100100011001111001001000",
			"11000110010011001010001101010111",
			"10111001100111111011011111010100",
			"01100111001010110011000011101101"
		);
		
		VARIABLE rotatedKey : std_logic_vector(31 DOWNTO 0);
		BEGIN
			-- round 1
			rotatedKey(31 DOWNTO 8) := key(23 DOWNTO 0);
			rotatedKey(7 DOWNTO 0) := key(31 DOWNTO 24);
			
			FOR i IN 0 TO 31 LOOP
				roundKeys(0)(i) := rotatedKey(i) XOR roundKeyArray(0)(i);
			END LOOP;
			
			-- round 2
			rotatedKey(31 DOWNTO 8) := roundKeys(0)(23 DOWNTO 0);
			rotatedKey(7 DOWNTO 0) := roundKeys(0)(31 DOWNTO 24);
			
			FOR i IN 0 TO 31 LOOP
				roundKeys(1)(i) := rotatedKey(i) XOR roundKeyArray(1)(i);
			END LOOP;
			
			-- round 3
			rotatedKey(31 DOWNTO 8) := roundKeys(1)(23 DOWNTO 0);
			rotatedKey(7 DOWNTO 0) := roundKeys(1)(31 DOWNTO 24);
			
			FOR i IN 0 TO 31 LOOP
				roundKeys(2)(i) := rotatedKey(i) XOR roundKeyArray(2)(i);
			END LOOP;
			
			-- round 4
			rotatedKey(31 DOWNTO 8) := roundKeys(2)(23 DOWNTO 0);
			rotatedKey(7 DOWNTO 0) := roundKeys(2)(31 DOWNTO 24);
			
			FOR i IN 0 TO 31 LOOP
				roundKeys(3)(i) := rotatedKey(i) XOR roundKeyArray(3)(i);
			END LOOP;
			
			-- return statement
			RETURN roundKeys;
	END findRoundKey;		
			
begin

-- process to get round keys
PROCESS(clk_50)
BEGIN
	IF (clk_50'EVENT AND clk_50 = '1') THEN
		IF oldKey /= keyIn THEN
			newRoundKey <= findRoundKey(keyIn);
			oldKey <= keyIn;
		ELSE
			-- do nothing
			oldKey <= keyIn;
		END IF;
	END IF;
END PROCESS;


-- decoding/decrypting process
PROCESS(clk_50, correctKey, oldKey, doneDecrypting)
BEGIN
	IF (clk_50'EVENT and clk_50 = '1') THEN
		IF (oldKey = keyIn AND doneDecrypting = false) THEN		-- if the round keys have been calculated
			IF correctKey = '0' THEN															-- checks with checker if the decrypted is correct or not
				dataCommand(0) <= addRoundKey(shift(substitute(addRoundKey(shift(substitute(addRoundKey(shift(substitute(addRoundKey(shift(substitute(decode(dataStorage(0)))), newRoundKey(0)))), newRoundKey(1)))), newRoundKey(2)))), newRoundKey(3));
				doneDecrypting <= true;
			ELSIF (correctKey = '1') THEN														-- if it is proceeds to decode everything until it's done then does nothing
				FOR i IN 1 TO 26 LOOP
					dataCommand(i - 1) <= addRoundKey(shift(substitute(addRoundKey(shift(substitute(addRoundKey(shift(substitute(addRoundKey(shift(substitute(decode(dataStorage(i)))), newRoundKey(0)))), newRoundKey(1)))), newRoundKey(2)))), newRoundKey(3));
				END LOOP;
				doneDecrypting <= true;
			ELSE
				-- do nothing
			END IF;
		ELSIF (oldKey /= keyIn) THEN
			doneDecrypting <= false;
		END IF;
	END IF;
END PROCESS;


-- sends the commands line by line to the serial driver
PROCESS(clk_50, addrIn)
BEGIN
	IF (clk_50'EVENT and clk_50 = '1') THEN
		IF (doneDecrypting AND correctKey = '1') THEN
			IF addrIn = (0 to 4 => 'U') THEN
				addr <= std_logic_vector(to_unsigned(0, 5));
				decryptedOut <= dataCommand(0);
			ELSIF addrIn = std_logic_vector(to_unsigned(0, 5)) THEN
				addr <= std_logic_vector(to_unsigned(1, 5));
				decryptedOut <= dataCommand(1);
			ELSIF addrIn = std_logic_vector(to_unsigned(1, 5)) THEN
				addr <= std_logic_vector(to_unsigned(2, 5));
				decryptedOut <= dataCommand(2);
			ELSIF addrIn = std_logic_vector(to_unsigned(2, 5)) THEN
				addr <= std_logic_vector(to_unsigned(3, 5));
				decryptedOut <= dataCommand(3);
			ELSIF addrIn = std_logic_vector(to_unsigned(3, 5)) THEN
				addr <= std_logic_vector(to_unsigned(4, 5));
				decryptedOut <= dataCommand(4);
			ELSIF addrIn = std_logic_vector(to_unsigned(4, 5)) THEN
				addr <= std_logic_vector(to_unsigned(5, 5));
				decryptedOut <= dataCommand(5);
			ELSIF addrIn = std_logic_vector(to_unsigned(5, 5)) THEN
				addr <= std_logic_vector(to_unsigned(6, 5));
				decryptedOut <= dataCommand(6);
			ELSIF addrIn = std_logic_vector(to_unsigned(6, 5)) THEN
				addr <= std_logic_vector(to_unsigned(7, 5));
				decryptedOut <= dataCommand(7);
			ELSIF addrIn = std_logic_vector(to_unsigned(7, 5)) THEN
				addr <= std_logic_vector(to_unsigned(8, 5));
				decryptedOut <= dataCommand(8);
			ELSIF addrIn = std_logic_vector(to_unsigned(8, 5)) THEN
				addr <= std_logic_vector(to_unsigned(9, 5));
				decryptedOut <= dataCommand(9);
			ELSIF addrIn = std_logic_vector(to_unsigned(9, 5)) THEN
				addr <= std_logic_vector(to_unsigned(10, 5));
				decryptedOut <= dataCommand(10);
			ELSIF addrIn = std_logic_vector(to_unsigned(10, 5)) THEN
				addr <= std_logic_vector(to_unsigned(11, 5));
				decryptedOut <= dataCommand(11);
			ELSIF addrIn = std_logic_vector(to_unsigned(11, 5)) THEN
				addr <= std_logic_vector(to_unsigned(12, 5));
				decryptedOut <= dataCommand(12);
			ELSIF addrIn = std_logic_vector(to_unsigned(12, 5)) THEN
				addr <= std_logic_vector(to_unsigned(13, 5));
				decryptedOut <= dataCommand(13);
			ELSIF addrIn = std_logic_vector(to_unsigned(13, 5)) THEN
				addr <= std_logic_vector(to_unsigned(14, 5));
				decryptedOut <= dataCommand(14);
			ELSIF addrIn = std_logic_vector(to_unsigned(14, 5)) THEN
				addr <= std_logic_vector(to_unsigned(15, 5));
				decryptedOut <= dataCommand(15);
			ELSIF addrIn = std_logic_vector(to_unsigned(15, 5)) THEN
				addr <= std_logic_vector(to_unsigned(16, 5));
				decryptedOut <= dataCommand(16);
			ELSIF addrIn = std_logic_vector(to_unsigned(16, 5)) THEN
				addr <= std_logic_vector(to_unsigned(17, 5));
				decryptedOut <= dataCommand(17);
			ELSIF addrIn = std_logic_vector(to_unsigned(17, 5)) THEN
				addr <= std_logic_vector(to_unsigned(18, 5));
				decryptedOut <= dataCommand(18);
			ELSIF addrIn = std_logic_vector(to_unsigned(18, 5)) THEN
				addr <= std_logic_vector(to_unsigned(19, 5));
				decryptedOut <= dataCommand(19);
			ELSIF addrIn = std_logic_vector(to_unsigned(19, 5)) THEN
				addr <= std_logic_vector(to_unsigned(20, 5));
				decryptedOut <= dataCommand(20);
			ELSIF addrIn = std_logic_vector(to_unsigned(20, 5)) THEN
				addr <= std_logic_vector(to_unsigned(21, 5));
				decryptedOut <= dataCommand(21);
			ELSIF addrIn = std_logic_vector(to_unsigned(21, 5)) THEN
				addr <= std_logic_vector(to_unsigned(22, 5));
				decryptedOut <= dataCommand(22);
			ELSIF addrIn = std_logic_vector(to_unsigned(22, 5)) THEN
				addr <= std_logic_vector(to_unsigned(23, 5));
				decryptedOut <= dataCommand(23);
			ELSIF addrIn = std_logic_vector(to_unsigned(23, 5)) THEN
				addr <= std_logic_vector(to_unsigned(24, 5));
				decryptedOut <= dataCommand(24);
			ELSIF addrIn = std_logic_vector(to_unsigned(24, 5)) THEN
				addr <= std_logic_vector(to_unsigned(25, 5));
				decryptedOut <= dataCommand(25);
			ELSE
				addr <= (0 to 4 => 'U');
				decryptedOut <= (0 to 31 => 'U');
			END IF;
		ELSIF (correctKey = '0' AND doneDecrypting = true)THEN
			addr <= std_logic_vector(to_unsigned(26, 5));
			decryptedOut <= dataCommand(0);
		ELSE
			addr <= "UUUUU";
			decryptedOut <= (0 to 31 => 'U');
		END IF;
	ELSE
		addr <= "UUUUU";
		decryptedOut <= (0 to 31 => 'U');
	END IF;
END PROCESS;
	

end behavior;
