-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Kryštof Paulík (xpauli08)
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK       : in std_logic;
   RST       : in std_logic;
	DIN       : in std_logic;
	CLK_CNT   : in std_logic_vector(4 downto 0);
	BIT_CNT   : in std_logic_vector(3 downto 0);
	READ_DATA_EN : out std_logic;
	CNT_EN    : out std_logic;
	OUT_VLD  : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type state_t is (WAIT_START_BIT, WAIT_FIRST_BIT, READ_DATA, WAIT_STOP_BIT, OUT_VALID);
signal state : state_t := WAIT_START_BIT;
begin

	READ_DATA_EN <= '1' when state = READ_DATA else '0';
	CNT_EN <= '0' when state = WAIT_START_BIT else '1';
	OUT_VLD <= '1' when state = OUT_VALID else '0';
	
	process (CLK) begin
		
		if rising_edge(CLK) then
			if RST = '1' then
				state <= WAIT_START_BIT;
			else
			   case state is
				when WAIT_START_BIT => if DIN = '0' then
													state <= WAIT_FIRST_BIT;
											  end if;
				when WAIT_FIRST_BIT => if CLK_CNT = "01111" then
													state <= READ_DATA;
											  end if;
				when READ_DATA      => if BIT_CNT = "1000" then
													state <= WAIT_STOP_BIT;
											  end if;
				when WAIT_STOP_BIT  => if CLK_CNT = "10000" then
													state <= OUT_VALID;
											  end if;
				when OUT_VALID      => state <= WAIT_START_BIT;
				when others => null;
				end case;
			end if;
		end if;
	end process;
end behavioral;
