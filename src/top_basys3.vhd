--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
component ALU
            port (
                i_A      : in  std_logic_vector(7 downto 0);
                i_B      : in  std_logic_vector(7 downto 0);
                i_op     : in  std_logic_vector(2 downto 0);
                o_result : out std_logic_vector(7 downto 0);
                o_flags  : out std_logic_vector(3 downto 0)
            );
        end component;
    
        component controller_fsm
            port (
                i_reset  : in std_logic;
                i_adv    : in std_logic;
                o_cycle  : out std_logic_vector(3 downto 0)
            );
        end component;
    
 -- Signals
           signal operand_A : std_logic_vector(7 downto 0);
           signal operand_B : std_logic_vector(7 downto 0);
           signal opcode    : std_logic_vector(2 downto 0);
           signal result    : std_logic_vector(7 downto 0);
           signal flags     : std_logic_vector(3 downto 0);
           signal state     : std_logic_vector(3 downto 0);
           signal display   : std_logic_vector(7 downto 0);

  
begin
	-- PORT MAPS ----------------------------------------
 operand_A <= sw;    
       operand_B <= sw;
       opcode    <= sw(2 downto 0); 
   
       -- Instantiate controller FSM
       FSM_U : controller_fsm
           port map (
               i_reset => btnU,
               i_adv   => btnC,
               o_cycle => state
           );
   
       -- Instantiate ALU
       ALU_U : ALU
           port map (
               i_A      => operand_A,
               i_B      => operand_B,
               i_op     => opcode,
               o_result => result,
               o_flags  => flags
           );
   
      
       process(state)
       begin
           case state is
               when "0001" => display <= (others => '0');       -- blank
               when "0010" => display <= operand_A;             -- show A
               when "0100" => display <= operand_B;             -- show B
               when "1000" => display <= result;                -- show result
               when others => display <= (others => '0');
           end case;
       end process;
   
       -- Output LEDs
       led(7 downto 0)  <= display;
       led(15 downto 8) <= "0000" & flags;
   
 
       process(display)
       begin
           case display(3 downto 0) is
               when "0000" => seg <= "1000000"; -- 0
               when "0001" => seg <= "1111001"; -- 1
               when "0010" => seg <= "0100100"; -- 2
               when "0011" => seg <= "0110000"; -- 3
               when "0100" => seg <= "0011001"; -- 4
               when "0101" => seg <= "0010010"; -- 5
               when "0110" => seg <= "0000010"; -- 6
               when "0111" => seg <= "1111000"; -- 7
               when "1000" => seg <= "0000000"; -- 8
               when "1001" => seg <= "0010000"; -- 9
               when "1010" => seg <= "0001000"; -- A
               when "1011" => seg <= "0000011"; -- b
               when "1100" => seg <= "1000110"; -- C
               when "1101" => seg <= "0100001"; -- d
               when "1110" => seg <= "0000110"; -- E
               when "1111" => seg <= "0001110"; -- F
               when others => seg <= "1111111"; -- blank
           end case;
       end process;
   
       an <= "1110";

	
	
	-- CONCURRENT STATEMENTS ----------------------------
	
	
	
end top_basys3_arch;
