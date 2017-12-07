library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity Final_BH_4 is
	port (
		reset, clk_50MHz : in std_logic;
		addMoney, address0, address1, address2, address3, purchase : in std_logic; -- address0 is MSB; address3 is LSB
		checkQty, checkPrice : in std_logic;
		f : out std_logic;
		waiting : out std_logic;
		error : out std_logic;
		dig0 : out std_logic;
		dig1 : out std_logic;
		dig2 : out std_logic;
		dig3 : out std_logic;
		dig4 : out std_logic;
		dig5 : out std_logic;
		dig6 : out std_logic;
		dig0_MSB :  out std_logic;
		dig1_MSB :  out std_logic;
		dig2_MSB :  out std_logic;
		dig3_MSB :  out std_logic;
		dig4_MSB :  out std_logic;
		dig5_MSB :  out std_logic;
		dig6_MSB :  out std_logic);	
end Final_BH_4;

architecture beh of Final_BH_4 is
	type INT_ARRAY is array (0 to 15) of integer;
	type state_type is (STATE_A, STATE_B, STATE_C, STATE_D, STATE_E, STATE_F);
	
	signal state : state_type := STATE_A;
	signal timeOut : std_logic;
	signal waitingForVend : std_logic;
	signal waitingForTimeout : std_logic;
	signal allowIncrement : std_logic;
	signal countIncrement : std_logic;
	signal firstTime : std_logic := '0';
	signal vend : std_logic;
	signal waitingForCompletion : std_logic;
	signal complete : std_logic;
	
	shared variable counter : integer range 0 to 750000000 := 0; 
	shared variable totalMoney : integer range 0 to 99 := 0;
	shared variable totalMoneyLSB : integer;
	shared variable totalMoneyMSB : integer;
	shared variable address : integer;
	shared variable qtyArray : INT_ARRAY;
	shared variable priceArray : INT_ARRAY;
begin		
	vending: process (reset, addMoney, purchase, checkQty, checkPrice, clk_50MHz)
	begin	
		if reset = '0' then 
			timeOut <= '0';
			state <= STATE_A;
			totalMoney := 0;
			f <= '0';
			error <= '0';
			firstTime <= '0';
			waitingForVend <= '0';
			waitingForTimeout <= '0';
			waitingForCompletion <= '0';
			allowIncrement <= '0';
			countIncrement <= '0';
			vend <= '0';
			complete <= '0';
			
			counter := 0;
		elsif clk_50MHz'event and clk_50MHz = '1' then -- rising edge
			if address0 = '0' and address1 = '0' and address2 = '0' and address3 = '0' then
				address := 0;
			elsif address0 = '0' and address1 = '0' and address2 = '0' and address3 = '1' then
				address := 1;
			elsif address0 = '0' and address1 = '0' and address2 = '1' and address3 = '0' then
				address := 2;
			elsif address0 = '0' and address1 = '0' and address2 = '1' and address3 = '1' then
				address := 3;
			elsif address0 = '0' and address1 = '1' and address2 = '0' and address3 = '0' then
				address := 4;
			elsif address0 = '0' and address1 = '1' and address2 = '0' and address3 = '1' then
				address := 5;
			elsif address0 = '0' and address1 = '1' and address2 = '1' and address3 = '0' then
				address := 6;
			elsif address0 = '0' and address1 = '1' and address2 = '1' and address3 = '1' then
				address := 7;
			elsif address0 = '1' and address1 = '0' and address2 = '0' and address3 = '0' then
				address := 8;
			elsif address0 = '1' and address1 = '0' and address2 = '0' and address3 = '1' then
				address := 9;
			elsif address0 = '1' and address1 = '0' and address2 = '1' and address3 = '0' then
				address := 10;
			elsif address0 = '1' and address1 = '0' and address2 = '1' and address3 = '1' then
				address := 11;
			elsif address0 = '1' and address1 = '1' and address2 = '0' and address3 = '0' then
				address := 12;
			elsif address0 = '1' and address1 = '1' and address2 = '0' and address3 = '1' then
				address := 13;
			elsif address0 = '1' and address1 = '1' and address2 = '1' and address3 = '0' then
				address := 14;
			elsif address0 = '1' and address1 = '1' and address2 = '1' and address3 = '1' then
				address := 15;
			end if;
			
			counter := counter + 1;
			
			if firstTime = '0' then
				qtyArray := (15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
				priceArray := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16);
				
				state <= STATE_A;
				firstTime <= '1';
			end if;
			
			if addMoney = '0' then
				countIncrement <= '1';
				counter := 0;
			end if;
				
			if waitingForVend = '1' then
				if counter = 125000000 then -- vend after 5s
					vend <= '1';
					waiting <= '0';
					waitingForVend <= '0';
					counter := 0;
				else
					vend <= '0';
					waiting <= '1';
				end if;	
			end if;
			
			if waitingForCompletion = '1' then
				if counter = 125000000 then -- complete after 5s
					counter := 0;
					complete <= '1';
				else
					complete <= '0';
				end if;
			end if;
			
			case state is
			when STATE_A =>
				vend <= '0';
				timeOut <= '0';
				waiting <= '0';
				error <= '0';
				f <= '0';
				waitingForVend <= '0';
				waitingForTimeout <= '1';
				
				if counter = 25000000 and countIncrement = '1' then -- 1s
					totalMoney := totalMoney + 1;
					countIncrement <= '0';
					
					if totalMoney = 99 then
						state <= STATE_C;
					elsif purchase = '0' then
						state <= STATE_F;
					else
						state <= STATE_B;
					end if;
				else
					state <= STATE_A;
				end if;
			when STATE_B =>
				vend <= '0';
				timeOut <= '0';
				waiting <= '0';
				error <= '0';
				f <= '0';
				waitingForVend <= '0';
				waitingForTimeout <= '1';
				
				if counter = 25000000 and countIncrement = '1' then -- 1s
					totalMoney := totalMoney + 1;
					countIncrement <= '0';
				end if;
				
				if totalMoney = 99 then -- maximum money allowed
					state <= STATE_C;
				elsif purchase	= '0' then
					if((qtyArray(15 - address) > 0) AND (priceArray(15 - address) <= totalMoney)) then -- quantity is available
						state <= STATE_D;
					else
						state <= STATE_F;
					end if;
				else
					state <= STATE_B;
				end if;
			when STATE_C =>
				vend <= '0';
				timeOut <= '0';
				waiting <= '0';
				error <= '0';
				f <= '0';
				waitingForVend <= '0';
				waitingForTimeout <= '1';
				
				totalMoney := 99;
				
				if purchase = '0' then
					counter := 0;
					
					if((qtyArray(15 - address) > 0) AND (priceArray(15 - address) <= totalMoney)) then -- quantity is available
						state <= STATE_D;
						waiting <= '1';
						waitingForVend <= '1';
						waitingForTimeout <= '0';
					else
						state <= STATE_F;
					end if;
				else
					state <= STATE_C;
				end if;
			when STATE_D =>
				timeOut <= '0';
				error <= '0';
				waiting <= '1';
				f <= '0';
				
				waitingForVend <= '1';
				waitingForCompletion <= '0';
				waitingForTimeout <= '0';
				
				if vend = '1' then
					vend <= '0';
					state <= STATE_E;
					totalMoney := totalMoney - priceArray(15 - address);
					qtyArray(15 - address) := qtyArray(15 - address) - 1;
				else
					state <= STATE_D;
				end if;
				
			when STATE_E =>
				timeOut <= '0';
				error <= '0';
				waiting <= '0';
				f <= '1';
				
				waitingForVend <= '0';
				waitingForCompletion <= '1';
				waitingForTimeout <= '0';
				
				if complete = '1' then
					complete <= '0';
					f <= '1';
					
					if totalMoney = 99 then
						state <= STATE_C;	
					else
						state <= STATE_B;
					end if;
				end if;
			when STATE_F =>
				timeOut <= '0';
				error <= '1';
				waiting <= '0';
				f <= '0';
				
				waitingForVend <= '0';
				waitingForCompletion <= '0';
				waitingForTimeout <= '0';
			when others => 
				null;
			end case;
		end if;

		-- using totalMoney variables as 3 potential values...
		if checkQty = '1' then -- quantity
			totalMoneyLSB := qtyArray(15 - address) mod 10;
			totalMoneyMSB := qtyArray(15 - address) - totalMoneyLSB;
			totalMoneyMSB := totalMoneyMSB / 10;
		elsif checkPrice = '1' then -- price
			totalMoneyLSB := priceArray(15 - address) mod 10;
			totalMoneyMSB := priceArray(15 - address) - totalMoneyLSB;
			totalMoneyMSB := totalMoneyMSB / 10;
		else -- money that has been inserted by user
			totalMoneyLSB := totalMoney mod 10;
			totalMoneyMSB := totalMoney - totalMoneyLSB;
			totalMoneyMSB := totalMoneyMSB / 10;
		end if;

		if totalMoneyLSB = 0 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '0';
			dig5 <= '0';
			dig6 <= '1';
		elsif totalMoneyLSB = 1 then
			dig0 <= '1';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '1';
			dig4 <= '1';
			dig5 <= '1';
			dig6 <= '1';
		elsif totalMoneyLSB = 2 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '1';
			dig3 <= '0';
			dig4 <= '0';
			dig5 <= '1';
			dig6 <= '0';
		elsif totalMoneyLSB = 3 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '1';
			dig5 <= '1';
			dig6 <= '0';
		elsif totalMoneyLSB = 4 then
			dig0 <= '1';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '1';
			dig4 <= '1';
			dig5 <= '0';
			dig6 <= '0';
		elsif totalMoneyLSB = 5 then
			dig0 <= '0';
			dig1 <= '1';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '1';
			dig5 <= '0';
			dig6 <= '0';
		elsif totalMoneyLSB = 6 then
			dig0 <= '0';
			dig1 <= '1';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '0';
			dig5 <= '0';
			dig6 <= '0';
		elsif totalMoneyLSB = 7 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '1';
			dig4 <= '1';
			dig5 <= '1';
			dig6 <= '1';
		elsif totalMoneyLSB = 8 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '0';
			dig5 <= '0';
			dig6 <= '0';
		elsif totalMoneyLSB = 9 then
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '1';
			dig5 <= '0';
			dig6 <= '0';
		else
			dig0 <= '0';
			dig1 <= '0';
			dig2 <= '0';
			dig3 <= '0';
			dig4 <= '0';
			dig5 <= '0';
			dig6 <= '1';
		end if;
		
		if totalMoneyMSB = 0 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '0';
			dig5_MSB <= '0';
			dig6_MSB <= '1';
		elsif totalMoneyMSB = 1 then
			dig0_MSB <= '1';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '1';
			dig4_MSB <= '1';
			dig5_MSB <= '1';
			dig6_MSB <= '1';
		elsif totalMoneyMSB = 2 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '1';
			dig3_MSB <= '0';
			dig4_MSB <= '0';
			dig5_MSB <= '1';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 3 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '1';
			dig5_MSB <= '1';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 4 then
			dig0_MSB <= '1';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '1';
			dig4_MSB <= '1';
			dig5_MSB <= '0';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 5 then
			dig0_MSB <= '0';
			dig1_MSB <= '1';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '1';
			dig5_MSB <= '0';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 6 then
			dig0_MSB <= '0';
			dig1_MSB <= '1';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '0';
			dig5_MSB <= '0';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 7 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '1';
			dig4_MSB <= '1';
			dig5_MSB <= '1';
			dig6_MSB <= '1';
		elsif totalMoneyMSB = 8 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '0';
			dig5_MSB <= '0';
			dig6_MSB <= '0';
		elsif totalMoneyMSB = 9 then
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '1';
			dig5_MSB <= '0';
			dig6_MSB <= '0';
		else
			dig0_MSB <= '0';
			dig1_MSB <= '0';
			dig2_MSB <= '0';
			dig3_MSB <= '0';
			dig4_MSB <= '0';
			dig5_MSB <= '0';
			dig6_MSB <= '1';
		end if;	
	end process vending;
end beh;