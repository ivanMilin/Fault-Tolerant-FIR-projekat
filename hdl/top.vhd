library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;

entity top is
    generic( RAM_WIDTH : integer := 24;
             RAM_DEPTH : integer := 110033;
             ADDR_SIZE : integer := 17;
             fir_ord : natural := 20;
             input_data_width : natural := 24;
             output_data_width : natural := 25;
             number_of_replication : natural := 5);
    port( clk : in std_logic;
          en  : in std_logic;
          we  : in std_logic;
          start : in std_logic;
          addr_read1 : in std_logic_vector(ADDR_SIZE-1  downto 0);
          addr_write : in std_logic_vector(ADDR_SIZE-1  downto 0);
          data_in : in std_logic_vector(RAM_WIDTH - 1 downto 0);
          data_out1 : out std_logic_vector(RAM_WIDTH - 1 downto 0);
          ready : out std_logic;
        
          clk_i : in STD_LOGIC;
          we_i  : in STD_LOGIC;
          rst_i : in STD_LOGIC;
          coef_addr_i : STD_LOGIC_VECTOR(log2c(fir_ord+1) - 1 downto 0);
          coef_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
          data_i  : in  STD_LOGIC_VECTOR (input_data_width - 1 downto 0);
          data_outt  : out STD_LOGIC_VECTOR (output_data_width - 2 downto 0));
end top;

architecture Behavioral of top is

--  POTREBNO JE DODATI SIGNALE I POVEZATI bram SA replication
--  POTREBNO JE DODATI SIGNALE I POVEZATI bram SA replication
--  POTREBNO JE DODATI SIGNALE I POVEZATI bram SA replication
begin

    bram_in : entity work.bram(Behavioral)
    generic map( RAM_WIDTH => RAM_WIDTH,
                 RAM_DEPTH => RAM_DEPTH,
                 ADDR_SIZE => ADDR_SIZE)
    port map(   clk => clk,                                       
                en  => en,                                        
                we  => we,                                        
                addr_read1 => addr_read1,  
                addr_write => addr_write ,  
                data_in    => data_in,   
                data_out1  => data_out1);

end Behavioral;
