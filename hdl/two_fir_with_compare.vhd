library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity two_fir_with_compare is
    generic(fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 24);
    Port ( clk_i : in STD_LOGIC;
           we_i : in STD_LOGIC;
           coef_addr_i : std_logic_vector(log2c(fir_ord+1)-1 downto 0);
           coef_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_i : in STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_o : out STD_LOGIC_VECTOR (output_data_width-1 downto 0);
           error_o : out STD_LOGIC);
end two_fir_with_compare;

architecture Behavioral of two_fir_with_compare is
    signal first_data_o_s  : STD_LOGIC_VECTOR (output_data_width-1 downto 0) ;
    signal second_data_o_s : STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    signal data_o_s :  STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    --signal enable : STD_LOGIC;
begin
    first_module : 
    entity work.fir_param(Behavioral)
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width =>output_data_width)
    port map( clk_i => clk_i,
              we_i => we_i,
              coef_addr_i => coef_addr_i,
              coef_i => coef_i,
              data_i => data_i,
              data_o => first_data_o_s);
            
    second_module : 
    entity work.fir_param(Behavioral)
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width =>output_data_width)
    port map (
            clk_i => clk_i,
            we_i => we_i,
            coef_addr_i => coef_addr_i,
            coef_i => coef_i,
            data_i => data_i,
            data_o => second_data_o_s); 
          
    error_detection:
    process(clk_i, first_data_o_s,second_data_o_s) 
    begin    
        if( first_data_o_s /= second_data_o_s) then
            data_o_s <= first_data_o_s;
            error_o <= '1';
        else
            error_o <= '0';
            data_o_s <= first_data_o_s;
        end if;
    end process;          
end Behavioral;
