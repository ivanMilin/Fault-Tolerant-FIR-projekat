library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use work.txt_util.all;
use work.util_pkg.all;

entity tb is
    generic(RAM_WIDTH : integer := 24;
            RAM_DEPTH : integer := 4096;
            ADDR_SIZE : integer := 12;
            fir_ord : natural := 5;
            in_out_data_width : natural := 24;
            number_of_replication : natural := 5); 
--  Port ( );
end tb;

architecture Behavioral of tb is
    constant period : time := 20 ns;
    signal clk_i_s : std_logic;
    file output_check_vector : text open read_mode is "..\..\..\..\..\data\expected_top.txt";
    file input_test_vector : text open read_mode is "..\..\..\..\..\data\input.txt";
    file input_coef : text open read_mode is "..\..\..\..\..\data\coef.txt";
    signal data_i_s : std_logic_vector(in_out_data_width-1 downto 0);
    signal data_o_s : std_logic_vector(in_out_data_width-1 downto 0);
    signal coef_addr_i_s : std_logic_vector(log2c(fir_ord)-1 downto 0);
    signal coef_i_s : std_logic_vector(in_out_data_width-1 downto 0);
    signal we_i_s, en_i_s : std_logic;
    signal rst_i_s : std_logic;
    signal start_check : std_logic := '0';
    signal addr_read_i_s,addr_write_i_s : std_logic_vector(ADDR_SIZE-1  downto 0);
    signal start_i_s : std_logic := '0'; 
    signal ready_i_s : std_logic ;
    signal iterration : natural := 0;

begin

    uut_fir_filter:
    entity work.top(behavioral)
    generic map(fir_ord=>fir_ord,
                RAM_WIDTH => RAM_WIDTH,
                RAM_DEPTH => RAM_DEPTH,
                ADDR_SIZE => ADDR_SIZE,
                input_data_width=>in_out_data_width,
                output_data_width=>in_out_data_width,
                number_of_replication => number_of_replication)
    port map(clk  => clk_i_s,
             rst  => rst_i_s,
             we   => we_i_s,
             en   => en_i_s,
             coef_i =>coef_i_s,
             coef_addr_i=>coef_addr_i_s,
             addr_read  => addr_read_i_s,
             addr_write => addr_write_i_s,
             data_in=>data_i_s,      
             data_out=>data_o_s,
             start => start_i_s,
             ready => ready_i_s);

    clk_process:
    process
    begin
        clk_i_s <= '0';
        wait for period/2;
        clk_i_s <= '1';
        wait for period/2;
    end process;
    
    stim_process:
    process
        variable tv : line;
    begin
        rst_i_s <= '1';
        we_i_s <= '0';
        en_i_s <= '0';
        start_i_s <= '0';
        addr_read_i_s <= (others => '0');
        
        wait until rising_edge(clk_i_s);
        rst_i_s <= '0';
        en_i_s <= '1';
        
        --upis koeficijenata
        data_i_s <= (others=>'0');
        wait until rising_edge(clk_i_s);
        
        for i in 0 to fir_ord loop
            we_i_s <= '1';
            coef_addr_i_s <= std_logic_vector(to_unsigned(i,log2c(fir_ord)));
            readline(input_coef,tv);
            coef_i_s <= to_std_logic_vector(string(tv));
            wait until rising_edge(clk_i_s);
        end loop;
        
        --ulaz za filtriranje
        --while not endfile(input_test_vector) loop
        for i in 0 to RAM_DEPTH-1 loop
            readline(input_test_vector,tv);
            data_i_s <= to_std_logic_vector(string(tv));
            addr_write_i_s <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
            wait until rising_edge(clk_i_s);
            start_check <= '1';
            iterration <= iterration + 1 ;
        end loop;
        
        wait until rising_edge(clk_i_s);
        start_i_s <= '1';
        wait until rising_edge(clk_i_s);
        
        wait until rising_edge(ready_i_s);
        start_i_s <= '0';
        for i in 0 to RAM_DEPTH-1 loop
            addr_read_i_s <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
            wait until rising_edge(clk_i_s);
        end loop;
        
        for i in 0 to RAM_DEPTH-1 loop
            wait until rising_edge(clk_i_s);
        end loop;
        start_check <= '0';
        report "verification done!" severity failure;
    end process;
    
    check_process:
    process
        variable check_v : line;
        variable tmp : std_logic_vector(in_out_data_width-1 downto 0);
    begin
        wait until rising_edge(clk_i_s);
        while(ready_i_s = '1')loop
            readline(output_check_vector,check_v);
            tmp := to_std_logic_vector(string(check_v));
            if(abs(signed(tmp) - signed(data_o_s)) > "000000000000000000000111")then
                report "result mismatch!" severity failure;
            end if;
            wait until rising_edge(clk_i_s);
        end loop;
    end process;
end Behavioral;