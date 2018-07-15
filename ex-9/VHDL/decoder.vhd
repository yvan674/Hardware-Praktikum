-- Decoder
-- checks parity bits and correct possible errors


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is port(
	clk_50 : in std_logic;
	decoderAddr: out std_logic_vector(4 downto 0);
	decoderData: out std_logic_vector(31 downto 0);
	decoderWe: out std_logic
		
);
end decoder;


architecture behavior of decoder is
	signal p0 : std_logic; 															-- parity bit 0 calculated value (1-5 analog)		
	signal p1 : std_logic;
	signal p2 : std_logic;
	signal p3 : std_logic;
	signal p4 : std_logic;
	signal p5 : std_logic;														
	signal wrong : integer range 0 to 63 := 0; 								-- bit number that is incorrect
	signal current : std_logic_vector (37 downto 0);						-- current line being "corrected"
	signal correct : std_logic_vector (31 downto 0); 						-- corrected data line withought parity bits
	signal finished_correct: boolean := false;								-- allow for RAM communication 
	
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
		
	TYPE dataElement32 IS ARRAY (0 to 27) OF std_logic_vector(31 downto 0); -- correct data
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
		"00000000000000000000000000000000",
		"00000000000000000000000000000000",
		"00000000000000000000000000000000");
		

begin
	process(clk_50)
	begin
		
		if(clk_50'event and clK_50 = '1') then
			
			-- go through all commands 
			for i in 0 to 27 loop
			
			-- reset the wrong value to zero
				wrong <= 0;
			
			-- store i-th line of array as current line being "corrected"
				current <= dataStorage(27 - i);
				
			-- calculate correct parity bit value
		
				p0 <= current(2) XOR current(4) XOR current(6) XOR current(8) XOR current(10) XOR current(12) XOR		-- calculates the value parity bit 0 should have
						current(14) XOR current(16) XOR current(18) XOR current(20) XOR current(22) XOR current(24) XOR	-- analog for parity bits 1-5
						current(26) XOR current(28) XOR current(30) XOR current(32) XOR current(34) XOR current(36);
				
				p1 <= current(2) XOR current(5) XOR current(6) XOR current(9) XOR current(10) XOR current(13) XOR		
						current(14) XOR current(17) XOR current(18) XOR current(21) XOR current(22) XOR current(25) XOR
						current(26) XOR current(29) XOR current(30) XOR current(33) XOR current(34) XOR current(37);
		
				
				p2 <= current(4) XOR current(5) XOR current(6) XOR current(11) XOR current(12) XOR current(13) XOR
						current(14) XOR current(19) XOR current(20) XOR current(21) XOR current(22) XOR current(27) XOR
						current(28) XOR current(29) XOR current(30) XOR current(35) XOR current(36) XOR current(37);
	
				
				p3 <= current(8) XOR current(9) XOR current(10) XOR current(11) XOR current(12) XOR current(13) XOR
						current(14) XOR current(23) XOR current(24) XOR current(25) XOR current(26) XOR current(27) XOR
						current(28) XOR current(29) XOR current(30);
	
				p4 <= current(16) XOR current(17) XOR current(18) XOR current(19) XOR current(20) XOR current(21) XOR
						current(22) XOR current(23) XOR current(24) XOR current(25) XOR current(26) XOR current(27) XOR
						current(28) XOR current(29) XOR current(30);
	
				p5 <= current(32) XOR current(33) XOR current(34) XOR current(35) XOR current(36) XOR current(37); 
				
				
			-- compare to actual parity bit value, if value is incorrect increase wrong variable by
			-- value of incorrect parity bit binary position
				
				if (p0 /= current(0)) then
					wrong <= wrong + 1;
			
				end if;
				
				if (p1 /= current(1)) then
					wrong <= wrong + 2;
			
				end if;
				
				if (p2 /= current(3)) then
					wrong <= wrong + 4;
			
				end if;
	
				
				if (p3 /= current(7)) then
					wrong <= wrong + 8;
			
				end if;
				
				if (p4 /= current(15)) then
					wrong <= wrong + 16;
			
				end if;
				
				if (p5 /= current(31)) then
					wrong <= wrong + 32;
			
				end if;
		
		
			-- correct possible bit errors
				
				if wrong /= 0 then 					
					-- has mistake at bit index (wrong-1)
					-- store reversed value at index place
					current(wrong - 1) <= NOT current(wrong-1);		
					
				end if;
		
			-- save in output vector
				
				-- save all the data bits into 32 bit variable
				correct(31 downto 26) <= current(37 downto 32); 
				correct(25 downto 11) <= current(30 downto 16);
				correct(10 downto 4) <= current(14 downto 8);
				correct(3 downto 1) <= current(6 downto 4);
				correct(0) <= current (2);	
				
				-- save the 32 bit data into the ouput at the corresponding 
				-- line position
				
				dataCommand(i) <= correct;
	
			end loop;
			-- allow RAM communication process to commence
			finished_correct <= true;
		end if;
	end process;
		
	
	process(clk_50)
	begin
		if (clk_50'event and clk_50 = '1' and finished_correct) then  
			-- tell master it's ready to write into RAM
			decoderWe <= '1';
			
			-- go through all correct commands and store each command 
			-- seperatley in RAM
			for j in 0 to 27 loop

					-- address is the current value of j
					decoderAddr <= std_logic_vector(to_unsigned(j, decoderAddr'length));
					
					-- send out data bits of j-th command
					decoderData <= dataCommand(j);
			end loop;
		end if;
	end process;
end;
