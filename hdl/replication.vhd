library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity replication is
    generic ( fir_ord : natural := 5;
              input_data_width : natural := 24;
              output_data_width : natural := 25;
              number_of_replication : natural := 5);
      
        Port( clk_i : in STD_LOGIC;
              we_i  : in STD_LOGIC;
              rst_i : in STD_LOGIC;
              coef_addr_i : in STD_LOGIC_VECTOR(log2c(fir_ord+1) - 1 downto 0);
              coef_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
              data_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
              data_outt  : out STD_LOGIC_VECTOR (output_data_width - 2 downto 0); -- 23 downto 0
              fir_ready  : out std_logic);
end replication;

architecture Behavioral of replication is
    -- Pomocni signali za prosledjivanje podataka u MUXeve i iz MUXeva 
    type output_type is array (0 to number_of_replication-1) of STD_LOGIC_VECTOR(output_data_width-1 downto 0);
    type help_type   is array (0 to number_of_replication-1) of STD_LOGIC_VECTOR(output_data_width-1 downto 0);
    
    signal data_to_mux  : output_type:=(others=>(others=>'0'));
    
    signal data_to_mux_1  : help_type :=(others=>(others=>'0'));
    signal data_to_mux_2  : help_type :=(others=>(others=>'0'));
    
    signal data_from_mux_1 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0) := (others=>'0') ;
    signal data_from_mux_2 : STD_LOGIC_VECTOR (output_data_width - 1 downto 0) := (others=>'0') ;

    -- Pomocni signali za odlucivanje koji podatak da se prosledi kroz MUX
    signal sel_data_1 : STD_LOGIC_VECTOR (log2c(number_of_replication)-1 downto 0) := std_logic_vector(to_unsigned(0, log2c(number_of_replication)));
    signal sel_data_2 : STD_LOGIC_VECTOR (log2c(number_of_replication)-1 downto 0) := std_logic_vector(to_unsigned(0, log2c(number_of_replication)));
    
    -- Pomocni signali za prosledjivanje errora svakog pojedinacnog bloka 
    signal error_from_comparator : STD_LOGIC := '0';
    
    -- Pomocni signal kojim ce se redukovati koji selekcioni sigal treba da se promeni
    signal counter : unsigned (log2c(number_of_replication) - 1 downto 0) := (to_unsigned(1, log2c(number_of_replication)));
    signal checker : unsigned (log2c(number_of_replication) - 1 downto 0) := (to_unsigned(number_of_replication, log2c(number_of_replication)));
    
    signal data_outt_s : STD_LOGIC_VECTOR (output_data_width - 2 downto 0) := (others => '0');  
    signal fir_ready_s : std_logic := '0'; 
    
    -------------------------------------------------------------
    attribute dont_touch : string;                  
    attribute dont_touch of data_to_mux : signal is "true";                  
    attribute dont_touch of data_to_mux_1 : signal is "true";
    attribute dont_touch of data_to_mux_2 : signal is "true";
    attribute dont_touch of sel_data_1 : signal is "true"; 
    attribute dont_touch of sel_data_2 : signal is "true";
    -------------------------------------------------------------
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
    
    -- Prvi MUX prima izlaze svih modula, osim izlaz od drugog modula(1,3,4,5...)
    data_to_mux_1(0) <=  data_to_mux(0);
    assigning_value_for_mux1: 
    for i in 1 to number_of_replication-2 generate
        data_to_mux_1(i) <=  data_to_mux(i+1);
    end generate;
    
    -- Drugi MUX prima izlaze svih modula, osim izlaz od prvog modula(2,3,4,5...)
    assigning_value_for_mux2: 
    for i in 0 to number_of_replication-2 generate
        data_to_mux_2(i) <=  data_to_mux(i+1);
    end generate;
    
    process(clk_i,error_from_comparator, data_from_mux_1(0),data_from_mux_2(0),sel_data_1,sel_data_2,counter)
    begin
        if(rising_edge(clk_i)) then
            if((error_from_comparator = '1' and data_from_mux_1(0) = '1') and sel_data_1 /= std_logic_vector(counter)) then  
                sel_data_1 <= std_logic_vector(counter);
                counter <= counter + 1;
            elsif((error_from_comparator = '1' and data_from_mux_2(0) = '1') and sel_data_2 /= std_logic_vector(counter)) then  
                sel_data_2 <= std_logic_vector(counter); 
                counter <= counter + 1;    
            else
                counter <= counter;
            end if;
        end if;                   
    end process;          
    
    -- MUX 1    
    data_from_mux_1 <= data_to_mux_1(to_integer(unsigned(sel_data_1(log2c(number_of_replication)-1 downto 0))));
    
    -- MUX 2
    data_from_mux_2 <= data_to_mux_2(to_integer(unsigned(sel_data_2(log2c(number_of_replication)-1 downto 0))));
    
    -- detektovanje greske
    process(clk_i,data_from_mux_1(output_data_width-1 downto 1),data_from_mux_2(output_data_width-1 downto 1)) 
    begin
        if(rising_edge(clk_i)) then
            if(data_from_mux_1(output_data_width-1 downto 1) /= data_from_mux_2(output_data_width-1 downto 1)) then
                error_from_comparator <= '1';    
            else
                error_from_comparator <= '0';
            end if; 
        end if;
    end process;
    
    -- kada counter dostigne maksimalan dozvoljen broj gresaka izlaz postaje NULA
    process(clk_i,counter,checker,data_from_mux_1(output_data_width-1 downto 1)) 
    begin
        if(rising_edge(clk_i)) then
            if(counter = checker) then
                data_outt_s <= (others => '0'); 
                --fir_ready_s <= '0';
            else
                data_outt_s <= data_from_mux_1(output_data_width-1 downto 1);
                fir_ready_s <= '1';
            end if;
        end if;
    end process;
    
    data_outt <= data_outt_s; 
    fir_ready <= fir_ready_s;

end Behavioral;