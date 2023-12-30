library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity two_fir_with_compare is
    generic(fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 25);
    Port ( clk_in : in STD_LOGIC;
           we_in : in STD_LOGIC;
           coef_addr_in : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           coef_in : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_in : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (output_data_width-1 downto 0));
end two_fir_with_compare;

architecture Behavioral of two_fir_with_compare is
    signal first_data_o_s  : STD_LOGIC_VECTOR (output_data_width-2 downto 0) ;
    signal second_data_o_s : STD_LOGIC_VECTOR (output_data_width-2 downto 0);
    signal error_s : STD_LOGIC;
begin
    first_module : 
    entity work.fir_param(Behavioral)
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width =>output_data_width-1)
    port map( clk_i => clk_in,
              we_i => we_in,
              coef_addr_i => coef_addr_in,
              coef_i => coef_in,
              data_i => data_in,
              data_o => first_data_o_s);
            
    second_module : 
    entity work.fir_param(Behavioral)
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width =>output_data_width-1)
    port map (
            clk_i => clk_in,
            we_i => we_in,
            coef_addr_i => coef_addr_in,
            coef_i => coef_in,
            data_i => data_in,
            data_o => second_data_o_s); 
          
    error_detection:
    process(clk_in, first_data_o_s,second_data_o_s) 
    begin
        if(rising_edge(clk_in)) then    
            if( first_data_o_s/= second_data_o_s) then
                error_s <= '1';
            else
                error_s <= '0';
            end if;
        end if;        
    end process;
    
    data_out <= first_data_o_s & error_s;          
end Behavioral;
