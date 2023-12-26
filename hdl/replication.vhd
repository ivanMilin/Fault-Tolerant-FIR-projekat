library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity replication is
    generic(fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 24;
            number_of_replication : natural := 3);
    Port ( clk_i : in STD_LOGIC;
           we_i  : in STD_LOGIC;
           coef_addr_i : STD_LOGIC_VECTOR(log2c(fir_ord+1)-1 downto 0);
           coef_i  : in  STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_i  : in  STD_LOGIC_VECTOR (input_data_width-1 downto 0);
           data_o  : out STD_LOGIC_VECTOR (output_data_width-1 downto 0));
end replication;

architecture Behavioral of replication is
    signal pair_module_s  : STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    signal spare_module_s : STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    
    signal error_signal   : STD_LOGIC_VECTOR (number_of_replication+2-1 downto 0);
    signal error_from_module : STD_LOGIC_VECTOR (number_of_replication+2-1 downto 0);
    signal error_to_switch   : STD_LOGIC_VECTOR (number_of_replication+2-1 downto 0);
    signal enable   : STD_LOGIC_VECTOR (number_of_replication+2-1 downto 0);
    
    signal data_o_1  : STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    signal data_o_2  : STD_LOGIC_VECTOR (output_data_width-1 downto 0);
    
begin

    
    
    pair_module : 
    entity work.two_fir_with_compare
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width => output_data_width)
    port map( clk_i => clk_i,
              we_i  => we_i,
              coef_addr_i => coef_addr_i,
              coef_i => coef_i,
              data_i => data_i,
              data_o =>  pair_module_s,
              error_o => error_from_module(0)
              );
              
   spare_module:       
   entity work.two_fir_with_compare
    generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width => output_data_width)
    port map( clk_i => clk_i,
              we_i  => we_i,
              coef_addr_i => coef_addr_i,
              coef_i => coef_i,
              data_i => data_i,
              data_o =>  spare_module_s,
              error_o => error_from_module(1));         
          
    
    replication_of_fir: 
    for i in 0 to number_of_replication-1 generate
        replication:
        entity work.two_fir_with_compare
            generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width => output_data_width)
            port map( clk_i => clk_i,
                      we_i  => we_i,
                      coef_addr_i => coef_addr_i,
                      coef_i => coef_i,
                      data_i => data_i,
                      data_o =>  spare_module_s,
                      error_o => error_from_module(i+2));
    end generate;           
    
    
    process(clk_i, pair_module_s, spare_module_s) 
    begin
        if(rising_edge(clk_i)) then
            data_o_1 <= pair_module_s;
            data_o_2 <= spare_module_s;
        end if;
    end process;
    
    process(clk_i, pair_module_s, spare_module_s) 
    begin
        if(rising_edge(clk_i)) then
            data_o_1 <= spare_module_s;
            data_o_2 <= pair_module_s;
        end if;
    end process;
    
    process(clk_i,data_o_1, data_o_2)
    begin
        if( data_o_1 /= data_o_2) then
            error_signal <= (others => '1');
        elsif(rising_edge(clk_i)) then
            data_o <= data_o_1;
            error_to_switch <= error_from_module;
        end if;  
    end process;
    
    enable <= error_signal and error_from_module;
    
end Behavioral;
