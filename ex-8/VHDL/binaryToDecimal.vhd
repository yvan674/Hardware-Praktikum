-- Copyright 2012: Jan Burchard, Universität Freiburg
-- binaryToDecimal
-- converts a 12 bit binary into 4 decimal digits: d3 d2 d1 d0
-- this is done by counting the 1000's, the 100's, the 10's and the 1's (-> 40 clock circles needed per conversion, but no division!)


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity binaryToDecimal is port(
	clk: in std_logic;

	binaryIn: in std_logic_vector(11 downto 0);
	
	d3 : out std_logic_vector(3 downto 0);
	d2 : out std_logic_vector(3 downto 0);
	d1 : out std_logic_vector(3 downto 0);
	d0 : out std_logic_vector(3 downto 0)
);
end binaryToDecimal;


architecture behavior of binaryToDecimal is
	type state_type is (s0, s1, s2, s3, s4, s5);
	
	signal state : state_type := s0;
	
	signal number : std_logic_vector(11 downto 0);
	
	signal digit_int_3 : std_logic_vector(3 downto 0);
	signal digit_int_2 : std_logic_vector(3 downto 0);
	signal digit_int_1 : std_logic_vector(3 downto 0);
	signal digit_int_0 : std_logic_vector(3 downto 0);
	
	signal digit_out_3 : std_logic_vector(3 downto 0);
	signal digit_out_2 : std_logic_vector(3 downto 0);
	signal digit_out_1 : std_logic_vector(3 downto 0);
	signal digit_out_0 : std_logic_vector(3 downto 0);
begin
	process(clk)
	begin
		if clk'event and clk = '1' then
			-- state s0 : reset internal counters, store input
			if state = s0 then
				number <= binaryIn;
				digit_int_3 <= (others => '0');
				digit_int_2 <= (others => '0');
				digit_int_1	<= (others => '0');
				digit_int_0 <= (others => '0');
				
				state <= s1;
				
			-- state s1 : how often 1000 can be substracted from the input
			elsif state = s1 then
				if number >= 1000 then
					number <= number - 1000;
					digit_int_3 <= digit_int_3 + 1;
				else
					state <= s2;
				end if;
		
			-- state s2 : how often 100 can be substracted from the input
			elsif state = s2 then
				if number >= 100 then
					number <= number - 100;
					digit_int_2 <= digit_int_2 + 1;
				else
					state <= s3;
				end if;
			
			-- state s3 : how often 10 can be substracted from the input
			elsif state = s3 then
				if number >= 10 then
					number <= number - 10;
					digit_int_1 <= digit_int_1 + 1;
				else
					state <= s4;
				end if;
			
			-- state s4 : now the number is smaller than 10, this is the last digit
			elsif state = s4 then
--				if number >= 1 then
--					number <= number - 1;
--					digit_int_0 <= digit_int_0 + 1;
--				else
--					state <= s5;
--				end if;
--				
				digit_int_0 <= number(3 downto 0);
				state <= s5;
			
			-- state s5: write the result to the output, start from the beginning
			elsif state = s5 then
				digit_out_3 <= digit_int_3;
				digit_out_2 <= digit_int_2;
				digit_out_1 <= digit_int_1;
				digit_out_0 <= digit_int_0;
				state <= s0;
			end if;
		
		
		end if;
	end process;

	d3 <= digit_out_3;
	d2	<= digit_out_2;
	d1 <= digit_out_1;
	d0 <= digit_out_0;

end behavior;