library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity replication is
    generic(fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 24;
            number_of_replication : natural := 5);
    Port ( clk_i : in STD_LOGIC;
           we_i  : in STD_LOGIC;
           coef_addr_i : STD_LOGIC_VECTOR(log2c(fir_ord+1) - 1 downto 0);
           coef_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
           data_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
           data_o  : out STD_LOGIC_VECTOR (output_data_width - 1 downto 0));
end replication;

architecture Behavioral of replication is
    -- Pomocni signali za prosledjivanje 'data_o' svakog pojedinacnog bloka     
    signal data_o_s  : STD_LOGIC_VECTOR (output_data_width - 1 downto 0);
    
    -- Pomocni signali za prosledjivanje podataka u MUXeve i iz MUXeva 
    type output_type is array (0 to number_of_replication-1) of STD_LOGIC_VECTOR(output_data_width - 1 downto 0);
    signal data_to_mux  : output_type;
    --signal data_in_mux_2  : output_type;
    signal data_out_mux_1 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0);
    signal data_out_mux_2 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0);
   
    -- Pomocni signali za odlucivanje koji podatak da se prosledi kroz MUX
    signal sel_data_o_1 : STD_LOGIC_VECTOR (number_of_replication - 1 downto 0);
    signal sel_data_o_2 : STD_LOGIC_VECTOR (number_of_replication - 1 downto 0);
    
    -- Pomocni signali za prosledjivanje errora svakog pojedinacnog bloka 
    signal error_o_s : STD_LOGIC_VECTOR (number_of_replication - 1 downto 0);
    signal error_from_comparator : STD_LOGIC_VECTOR (number_of_replication - 1 downto 0);
   
begin
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
                      data_o =>  data_to_mux(i),
                      error_o => error_o_s(i));
    end generate;           
    
    sel_data_o_1 <= error_o_s and error_from_comparator;
    sel_data_o_2 <= error_o_s and error_from_comparator;
    
    process(data_to_mux)
    begin
        if(rising_edge(clk_i)) then
        data_out_mux_1 <= data_to_mux(to_integer(unsigned(sel_data_o_1)));
        data_out_mux_2 <= data_to_mux(to_integer(unsigned(sel_data_o_2)));
        end if;
    end process;
    
    process(clk_i, data_out_mux_1,data_out_mux_2) 
    begin
        if(rising_edge(clk_i)) then
            if(data_out_mux_1 /= data_out_mux_1) then
                error_from_comparator <= (others => '1');    
            else
                error_from_comparator <= (others => '0');
            end if;
        end if; 
    end process;
    
    process(clk_i, data_o_s) 
    begin
        if(rising_edge(clk_i)) then
            data_o <= data_out_mux_1;
        end if;
    end process;
    
end Behavioral;