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
        
            component sevenseg_decoder
                port (
                    i_hex : in std_logic_vector(3 downto 0);
                    o_seg_n : out std_logic_vector(6 downto 0)
                );
            end component;
        
            -- Internal Signals
            signal operand_A      : std_logic_vector(7 downto 0);
            signal operand_B      : std_logic_vector(7 downto 0);
            signal opcode         : std_logic_vector(2 downto 0);
            signal result         : std_logic_vector(7 downto 0);
            signal flags          : std_logic_vector(3 downto 0);
            signal state          : std_logic_vector(3 downto 0);
            signal display        : std_logic_vector(7 downto 0);
            signal w_display_hex  : std_logic_vector(3 downto 0);
            signal w_seg          : std_logic_vector(6 downto 0);


  
begin
	-- PORT MAPS ----------------------------------------
	process (state)
    begin
       if rising_edge(state(1)) then
          operand_A <= sw; 
       end if;
    end process;
    
    process (state)
        begin
           if rising_edge(state(2)) then
              operand_B <= sw; 
           end if;
        end process;

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

               -- Display selection based on FSM state
               process(state)
               begin
                   if state = "0001" then
                       display <= (others => '0');     -- blank
                   elsif state = "0010" then
                       display <= operand_A;
                   elsif state = "0100" then
                       display <= operand_B;
                   elsif state = "1000" then
                       display <= result;
                   else
                       display <= (others => '0');
                   end if;
               end process;
           
               -- Display Decoder
               w_display_hex <= display(3 downto 0);
               
               SEVENSEG_U : sevenseg_decoder
                   port map (
                       i_hex => w_display_hex,
                       o_seg_n => w_seg
                   );
           
               seg <= w_seg;
               an  <= "1110";  -- Rightmost digit enabled
           
               -- LED output
               led(7 downto 0)  <= display;
               led(15 downto 8) <= "0000" & flags;
           
           end top_basys3_arch;    
