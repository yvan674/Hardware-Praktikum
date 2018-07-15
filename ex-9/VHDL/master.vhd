-- master
-- determines what does what


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity master is port(
	clk_50 : in std_logic;
	
	decoderDone : in std_logic;
	decoderAddr : in std_logic_vector(4 downto 0);
	decoderData : in std_logic_vector(31 downto 0);
	decoderWe : in std_logic;
	
	decryptorDone : in std_logic;
	decryptorAddr : in std_logic_vector(4 downto 0);
	decryptorData : in std_logic_vector(31 downto 0);
	decryptorWe : in std_logic;
	
	serialAddr : in std_logic_vector(4 downto 0);
	
	
	ramq : in std_logic_vector(31 downto 0);
	
	
	decryptorq : out std_logic_vector(31 downto 0);
	decryptorE : out std_logic;
	serialq : out std_logic_vector(31 downto 0);
	serialE : out std_logic;
	
	ramAddr : out std_logic_vector(4 downto 0);
	ramData : out std_logic_vector(31 downto 0);
	ramWe : out std_logic
);
end master;


architecture behavior of master is
	

begin
PROCESS(clk_50)
BEGIN
	IF (decoderDone = '0' AND decryptorDone = '0') THEN
		-- decoder's not done
		ramAddr <= decoderAddr;
		ramData <= decoderData;
		ramWe <= decoderWe;
		decryptorE <= '0';
		serialE <= '0';
		
		decryptorq <= (0 to 31 => '0');
		serialq <= (0 to 31 => '0');
		
	ELSIF (decoderDone = '1' AND decryptorDone = '0') THEN
		-- decoder's done, decryptor's not done
		ramAddr <= decryptorAddr;
		ramData <= decryptorData;
		ramWe <= decryptorWe;
		decryptorq <= ramq;
		decryptorE <= '1';
		serialE <= '0';
		
		serialq <= (0 to 31 => '0');
		
		
	ELSIF (decoderDone = '1' AND decryptorDone = '1') THEN
		-- both done, serial does work
		ramAddr <= serialAddr;
		serialq <= ramq;
		serialE <= '1';
		decryptorE <= '0';
		
		decryptorq <= (0 to 31 => '0');
		ramData <= (0 to 31 =>'U');
		ramWe <= '0';
		
	ELSE
		-- broken, reset everything to 0
		decryptorq <= (0 to 31 => '0');
		decryptorE <= '0';
		serialq <= (0 to 31 => '0');
		serialE <= '0';
		ramAddr <= (0 to 4 => '0');
		ramData <= (0 to 31 => '0');
		ramWe <= '0';
	END IF;
		
END PROCESS;
	
end behavior;