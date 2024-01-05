library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity replication is
    generic(fir_ord : natural := 20;
            input_data_width : natural := 24;
            output_data_width : natural := 25;
            number_of_replication : natural := 5);
    Port ( clk_i : in STD_LOGIC;
           we_i  : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           coef_addr_i : STD_LOGIC_VECTOR(log2c(fir_ord+1) - 1 downto 0);
           coef_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
           data_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
           data_outt  : out STD_LOGIC_VECTOR (output_data_width - 2 downto 0));
end replication;

architecture Behavioral of replication is
    -- Pomocni signali za prosledjivanje podataka u MUXeve i iz MUXeva 
    type output_type is array (0 to number_of_replication-1) of STD_LOGIC_VECTOR(output_data_width-1 downto 0);
    signal data_to_mux  : output_type:=(others=>(others=>'0'));
    signal data_from_mux_1 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0);
    signal data_from_mux_2 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0);

    -- Pomocni signali za odlucivanje koji podatak da se prosledi kroz MUX
    signal sel_data_1 : STD_LOGIC_VECTOR (log2c(number_of_replication)-1 downto 0) := std_logic_vector(to_unsigned(0, log2c(number_of_replication)));
    signal sel_data_2 : STD_LOGIC_VECTOR (log2c(number_of_replication)-1 downto 0) := std_logic_vector(to_unsigned(1, log2c(number_of_replication)));
    
    -- Pomocni signali za prosledjivanje errora svakog pojedinacnog bloka 
    signal error_from_comparator : STD_LOGIC := '0';
    
    -- Pomocni signal kojim ce se redukovati koji selekcioni sigal treba da se promeni
    signal counter : unsigned (log2c(number_of_replication) - 1 downto 0) := (to_unsigned(2, log2c(number_of_replication)));
    
    signal data_outt_s  : STD_LOGIC_VECTOR (output_data_width - 2 downto 0);   
begin
    
    replication_of_fir: 
    for i in 0 to number_of_replication-1 generate
        replication:
        entity work.two_fir_with_compare
            generic map(fir_ord => fir_ord, input_data_width => input_data_width, output_data_width => output_data_width-1)
            port map( clk_in => clk_i,
                      we_in  => we_i,
                      coef_addr_in => coef_addr_i,
                      coef_in => coef_i,
                      data_in => data_i,
                      data_out =>  data_to_mux(i)(output_data_width-1 downto 1),
                      error_out => data_to_mux(i)(0));
    end generate;
    
    process(error_from_comparator, data_from_mux_1(0),data_from_mux_2(0))
    begin
        --if(rising_edge(clk_i)) then
            --if(error_from_comparator = '1' or data_from_mux_1(0) = '1') then
            if((rising_edge(error_from_comparator) or rising_edge(data_from_mux_1(0))) and sel_data_1 /= std_logic_vector(counter)) then  
                sel_data_1 <= std_logic_vector(counter);
                counter <= counter + 1;
            elsif((rising_edge(error_from_comparator) or rising_edge(data_from_mux_2(0))) and sel_data_2 /= std_logic_vector(counter)) then  
                sel_data_2 <= std_logic_vector(counter); 
                counter <= counter + 1;     
            else
                counter <= counter;    
            end if;
        --end if;
    end process;          
          
    process(sel_data_1, sel_data_2,data_to_mux)
    begin
        data_from_mux_1 <= data_to_mux(to_integer(unsigned(sel_data_1)));
        data_from_mux_2 <= data_to_mux(to_integer(unsigned(sel_data_2)));
    end process;
    
    process(data_from_mux_1,data_from_mux_2) 
    begin
        if(data_from_mux_1(output_data_width-1 downto 1) /= data_from_mux_2(output_data_width-1 downto 1)) then
            error_from_comparator <= '1';    
        --else
            --error_from_comparator <= '0';
        end if; 
    end process;
    
    process(clk_i)
    begin
        if(rising_edge(clk_i))then
            if we_i = '1' then
                data_outt_s <= data_from_mux_1(output_data_width-1 downto 1);    
            else
                data_outt_s <= (others => '0');
            end if;
        end if;
    end process;

    data_outt <= data_outt_s;
    
end Behavioral;