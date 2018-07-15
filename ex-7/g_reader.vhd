-- ADC reader: reads data from ADXL345

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_reader is port (
	clk_50: in std_logic;	-- 50 MHz clock
	
	reset_n : in std_logic; -- reset signal (active low)

	-- SPI interface
	CS_N : out std_logic;   -- connected to chip select of g sensor
	SCLK : out std_logic;   -- spi clock
	SDIO : inout std_logic; -- spi data (bidirectional)
		
	-- data output
	dataX : out std_logic_vector(12 downto 0);
	dataY : out std_logic_vector(12 downto 0);
	dataZ : out std_logic_vector(12 downto 0)
);
end g_reader;


architecture behavior of g_reader is
	
begin

	
end behavior;

