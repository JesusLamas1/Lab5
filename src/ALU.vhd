----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    signal A, B : signed(7 downto 0);
    signal result : signed(7 downto 0);
    signal carry : std_logic := '0';
    signal overflow : std_logic := '0';

begin
 process(i_A, i_B, i_op)
   begin
       A <= signed(i_A);
       B <= signed(i_B);
       carry <= '0';
       overflow <= '0';

       case i_op is
           when "000" => -- add
               result <= A + B;
               if (A(7) = B(7)) and (result(7) /= A(7)) then
                   overflow <= '1';
               end if;
               if unsigned(i_A) + unsigned(i_B) > 255 then
                   carry <= '1';
               end if;

           when "001" => -- sub
               result <= A - B;
               if (A(7) /= B(7)) and (result(7) /= A(7)) then
                   overflow <= '1';
               end if;

           when "010" => -- and
               result <= A and B;

           when "011" => -- or
               result <= A or B;

           when others =>
               result <= (others => '0');
       end case;

       o_result <= std_logic_vector(result);

       
       o_flags(3) <= overflow;
       o_flags(2) <= result(7);
       o_flags(1) <= carry;

   end process;

end Behavioral;
