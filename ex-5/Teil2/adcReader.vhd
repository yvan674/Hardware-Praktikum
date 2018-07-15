-- Copyright 2012: Jan Burchard
-- adc reader
-- reads data from ADC128S022 via 4 wire SPI

library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;


entity adcReader is
port(
	clk_50 : in std_logic;  
	reset_n : in std_logic;  -- reset 

	Data0   : out std_logic_vector(11 downto 0);
	Data1   : out std_logic_vector(11 downto 0);
	Data2   : out std_logic_vector(11 downto 0);
	Data3   : out std_logic_vector(11 downto 0);
	Data4   : out std_logic_vector(11 downto 0);
	Data5   : out std_logic_vector(11 downto 0);
	Data6   : out std_logic_vector(11 downto 0);
	Data7   : out std_logic_vector(11 downto 0);
	
	-- spi connections:
	DIN				:	out		std_logic;
	CS_n				:	out		std_logic;
	SCLK				:	out		std_logic;
	DOUT				:	 in		std_logic
);
end adcReader;


architecture behavior of adcReader is
	signal clk_spi : std_logic;
	signal clk_spi_count : std_logic_vector(3 downto 0); -- divide the clk by 2^4 * 2 = 16*2 = 32, resulting in a 1.56 mhz spi clock

   -- the spi interface uses 16 states
	signal count : std_logic_vector(3 downto 0);
	
	-- rotate through all 8 adc channels
	signal channel : std_logic_vector (2 downto 0);
	
	-- stores if the adc is active
	signal active2 : std_logic := '0';
	
	-- stores the read data
	signal data : std_logic_vector(11 downto 0);
	
begin
	-- generate the spi_clk
	process(clk_50)
	begin
		if clk_50'event and clk_50 = '1' then
			clk_spi_count <= clk_spi_count + 1;
			
			if clk_spi_count = 0 then
				clk_spi <= not clk_spi;
			end if;
		end if;
	end process;

	-- chip activation, reset, ...
	process(clk_spi, reset_n)
	begin
		if reset_n = '0' then
			-- pull chip select high -> adc disabled
			active2 <= '0';
		
		elsif clk_spi'event and clk_spi= '1' then
			-- activate active on rising clock flank
			active2 <= '1';
		end if;	
	end process;
	
	
	-- read / write data
	process(clk_spi, active2)
	begin
		if active2 = '0' then
			data <= (others => '0');
			channel <= "000";
			count <= "0000";
			
		elsif active2 = '1' then
			if clk_spi'event and clk_spi = '0' then
				-- write on falling edge
				if count = "0010" then
					DIN <= channel(2);
				elsif count = "0011" then
					DIN <= channel(1);
				elsif count = "0100" then
					DIN <= channel(0);
				else
					DIN <= '0';
				end if;
				
				
			elsif clk_spi'event and clk_spi = '1' then
				-- read on rising edge
				if count = "0000" then
				
					if channel = "000" then
						Data6 <= data;
					elsif channel = "001" then
						Data7 <= data;
					elsif channel = "010" then
						Data0 <= data;
					elsif channel = "011" then
						Data1 <= data;
					elsif channel = "100" then
						Data2 <= data;
					elsif channel = "101" then
						Data3 <= data;
					elsif channel = "110" then
						Data4 <= data;
					elsif channel = "111" then
						Data5 <= data;
					end if;
					
					data <= (others => '0');
				elsif count = "0100" then
					data(11) <= DOUT;
				elsif count = "0101" then
					data(10) <= DOUT;
				elsif count = "0110" then
					data(9) <= DOUT;
				elsif count = "0111" then
					data(8) <= DOUT;
				elsif count = "1000" then
					data(7) <= DOUT;
				elsif count = "1001" then
					data(6) <= DOUT;
				elsif count = "1010" then
					data(5) <= DOUT;
				elsif count = "1011" then
					data(4) <= DOUT;
				elsif count = "1100" then
					data(3) <= DOUT;
				elsif count = "1101" then
					data(2) <= DOUT;
				elsif count = "1110" then
					data(1) <= DOUT;
				elsif count = "1111" then
					data(0) <= DOUT;
					channel <= channel + 1;
				end if;
				
				count <= count + 1;
			end if;
		end if;
	end process;

	SCLK <= clk_spi WHEN active2 = '1' ELSE '1';
	CS_n <= '0' WHEN active2 = '1' ELSE '1';
end behavior;
