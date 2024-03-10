----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2021 04:32:31 PM
-- Design Name: 
-- Module Name: Nexys4 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Nexys4 is
Port
 (
 signal clk:in std_logic;
 signal btn:in std_logic_vector(4 downto 0);
 signal sw:in std_logic_vector(15 downto 0);
 signal TMP_INT:in std_logic; -- over-temperature and under temp indicator
 signal TMP_CT:in std_logic; -- critical over-temperature indicator
 signal cat:out std_logic_vector(7 downto 0);
 signal an:out std_logic_vector(7 downto 0);
 signal led:out std_logic_vector(15 downto 0);
 signal TMP_SCL:inout std_logic;
 signal RX:in std_logic;
signal TX:out std_logic;
 signal TMP_SDA:inout std_logic
  );
end Nexys4;

architecture Behavioral of Nexys4 is

signal TSR:std_logic_vector(23 downto 0):=(others=>'0');
signal btn_reset:std_logic;
signal btn_start:std_logic;
signal semnal_read:std_logic;
signal counter:INTEGER:=0;
signal ena:std_logic:='0';

signal rx_8:std_logic_vector(7 downto 0);

signal trimitere_mesaje:std_logic_vector(7 downto 0);

signal start:std_logic;
signal activ:std_logic;
signal done:std_logic;

signal date:std_logic_vector(12 downto 0);
signal afisor:std_logic_vector(31 downto 0);
signal date2 : std_logic_vector(15 downto 0);

begin

buton_reset:entity WORK.mpg port map
(
btn=>btn(1),
clk=>clk,
en=>btn_reset
);

buton_start:entity WORK.mpg port map
(
btn=>btn(0),
clk=>clk,
en=>btn_start
);
senzor:entity WORK.SenzorTemperatura port map
(
TMP_SCL=>TMP_SCL,
		TMP_SDA=>TMP_SDA,
--		TMP_INT : in STD_LOGIC; -- Interrupt line from the ADT7420, not used in this project
--		TMP_CT : in STD_LOGIC;  -- Critical Temperature interrupt line from ADT7420, not used in this project
		
		TEMP_O =>date, --12-bit two's complement temperature with sign bit
		RDY_O =>led(15),	--'1' when there is a valid temperature reading on TEMP_O
		ERR_O =>led(0), --'1' if communication error
		
		CLK_I=>clk,
		SRST_I=>btn_reset
);

b1_rx:entity WORK.UART_rx
generic map
(
g_CLKS_PER_BIT => 10416
)
port map
(
i_Clk=>clk,
i_RX_Serial=>RX,
o_RX_DV=>led(3),
o_RX_Byte=>rx_8
);

b1_tx:entity WORK.UART_tx
generic map
(
g_CLKS_PER_BIT=> 10416
)
port map
(
i_Clk=>clk,
i_TX_DV=>start,
i_TX_Byte=>trimitere_mesaje,
o_TX_Active=>activ,
o_TX_Serial=>TX,
o_TX_Done=>done
);

unitate_cc:entity WORK.UCC
port map
(
clk=>clk,
rst=>btn_reset,
btn_start=>btn_start,
date_intrare => date2,
activ=>activ,
done=>done,
date_iesire=>trimitere_mesaje,
start=>start
);    
--control:entity WORK.I2C_master 
--generic map
--(
--input_clk=>100_000_000,
--bus_clk=>400_000
--)
--port map
--(
--    clk=>clk,                  --system clock
--    reset_n=>btn_reset,                    --active low reset
--    ena=>ena,                  --latch in command
--    addr=>"1001011", --address of target slave -- x4B=> 01001011
--    rw=>'1',                    --'0' is write, '1' is read
--    data_wr=>(others=>'0'), --data to write to slave
--    busy=>led(15),                    --indicates transaction in progress
--    data_rd=>date, --data read from slave
--    ack_error=>led(0),                --flag if improper acknowledge from slave
--    semnal_read=>semnal_read,
--    sda=>TMP_SDA,                   --serial data output of i2c bus
--    scl=>TMP_SCL
--);

--process(clk)
--begin
--    if clk'event and clk='1' then
--        if btn_start='1' then
--            ena<='1';
--        elsif ena='1' and semnal_read='0' then 
--            TSR(7 downto 0)<=date;
--        elsif ena='1' and semnal_read='1' then
--            counter<=counter+1;
--            TSR<=TSR(15 downto 0) & "00000000";
--        end if;
--        if counter=2 then
--            ena<='0';
--        end if;
--    end if;
--end process;
date2 <= "000"& date ;
afisor<="0000000000000000000" & date;
ssd:entity WORK.displ7seg port map
    (
    Clk=>Clk,
           Rst=>btn_reset,
           Data=>afisor,   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
           An=>an,    -- selectia anodului activ
           Seg=>cat
    );
end Behavioral;
