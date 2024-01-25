library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity top is
    generic( RAM_WIDTH : integer := 24;
             RAM_DEPTH : integer := 4096;
             ADDR_SIZE : integer := 12;
             
             fir_ord : natural := 5;
             input_data_width : natural := 24;
             output_data_width : natural := 24;
             number_of_replication : natural := 5);
       
       port( clk : in std_logic;
             en  : in std_logic;
             we  : in std_logic;
             rst : in std_logic;
             
             addr_read  : in std_logic_vector(ADDR_SIZE-1  downto 0);
             addr_write : in std_logic_vector(ADDR_SIZE-1  downto 0);
             data_in    : in std_logic_vector(RAM_WIDTH - 1 downto 0);
             
             coef_addr_i : in STD_LOGIC_VECTOR(log2c(fir_ord+1) - 1 downto 0);
             coef_i      : in STD_LOGIC_VECTOR(input_data_width - 1 downto 0);
             
             data_out : out std_logic_vector(RAM_WIDTH - 1 downto 0);
             
             start : in std_logic;
             ready : out std_logic);
end top;

architecture Behavioral of top is
 
signal data_from_input_bram : std_logic_vector(RAM_WIDTH - 1 downto 0);
signal data_to_output_bram : std_logic_vector(RAM_WIDTH - 1 downto 0);    

signal address_input_bram  : std_logic_vector(ADDR_SIZE-1  downto 0) := (others => '0');
signal address_input_bram_s  : std_logic_vector(ADDR_SIZE-1  downto 0) := (others => '0');

signal addr_read_s : std_logic_vector(ADDR_SIZE  downto 0) := (others => '0');

signal address_output_bram  : std_logic_vector(ADDR_SIZE-1  downto 0) := (others => '0');
signal address_output_bram_s  : std_logic_vector(ADDR_SIZE-1  downto 0) := (others => '0');  

signal fir_ready_s : std_logic;
signal ready_s : std_logic := '0';
begin
    --Kada se postavi start na jedinicu pocinju da se citaju podaci iz ulaznog BRAMa
    process(clk, start)
    begin
        if(rising_edge(clk)) then
            if( start = '1' and address_input_bram <= std_logic_vector(to_unsigned(RAM_DEPTH-1,ADDR_SIZE))) then
                address_input_bram <= std_logic_vector(unsigned(address_input_bram) + to_unsigned(1,ADDR_SIZE));        
            else
                address_input_bram <= address_input_bram ;
            end if; 
        end if;
    end process;

    INPUT_bram : entity work.bram(Behavioral)
    generic map(RAM_WIDTH=> RAM_WIDTH, RAM_DEPTH=>RAM_DEPTH, ADDR_SIZE=>ADDR_SIZE)    
    port map( clk => clk,
              en  => en, 
              we  => we,
              addr_read  => address_input_bram, 
              addr_write => addr_write,
              data_in  => data_in,
              data_out => data_from_input_bram);

    pair_and_spare_FIR:
    entity work.replication(Behavioral)
    generic map(fir_ord => fir_ord, input_data_width => input_data_width , output_data_width => output_data_width+1 , number_of_replication => number_of_replication)
    port map(
            clk_i => clk,
            we_i  => we,
            rst_i => rst,
            coef_addr_i => coef_addr_i,
            coef_i  => coef_i,
            data_i  => data_from_input_bram,
            data_outt  => data_to_output_bram,
            fir_ready => fir_ready_s );
    
    -- Kad se pojavi 'fir_ready_s' na jedinicu, upisuju se podaci iz FIR filtra u izlazni bram
    process(clk,fir_ready_s, address_output_bram)
    begin
        if(rising_edge(clk)) then
            if(start = '1' and fir_ready_s = '1') then
                address_output_bram   <= std_logic_vector(unsigned(address_output_bram) + to_unsigned(1,ADDR_SIZE));
            else
                address_output_bram <= address_output_bram;
            end if;
        end if;         
    end process;        

    OUTPUT_bram: 
    entity work.bram(Behavioral)
    generic map(RAM_WIDTH=> RAM_WIDTH, RAM_DEPTH=>RAM_DEPTH, ADDR_SIZE=>ADDR_SIZE)
    port map( clk => clk,
              en  => en, 
              we  => we,
              addr_read  => addr_read, 
              addr_write => address_output_bram,
              data_in  => data_to_output_bram,
              data_out => data_out);
            
    process(clk, addr_read)
    begin
        if(addr_read = std_logic_vector(to_unsigned(RAM_DEPTH - 1,ADDR_SIZE))) then
            addr_read_s <= std_logic_vector(to_unsigned(RAM_DEPTH,ADDR_SIZE+1));
        else     
            addr_read_s <= std_logic_vector(to_unsigned(0,ADDR_SIZE+1));
        end if;
    end process;
    
    -- generisanje READY signala na jedinicu kad se obradi N odbiraka           
    process(clk,address_output_bram)
    begin
        if(address_output_bram = std_logic_vector(to_unsigned(RAM_DEPTH - 1,ADDR_SIZE)) and addr_read_s < std_logic_vector(to_unsigned(RAM_DEPTH,ADDR_SIZE+1))) then
            ready_s <= '1';
        else
            ready_s <= '0';
        end if;
    end process;    
    
    ready <= ready_s;
            
end Behavioral;
