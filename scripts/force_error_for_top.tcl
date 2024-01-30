############################################################################
#    U zavisnosti od broja modula, otkomentarisati n-1 liniju u skripti    #
############################################################################
 add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(0)\/replication/first_data_o_s[10]} -radix hex {1 82500ns} -cancel_after 400ms
 add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(1)\/replication/first_data_o_s[10]} -radix hex {1 100000ns} -cancel_after 400ms
 add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(2)\/replication/first_data_o_s[10]} -radix hex {1 110000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(3)\/replication/first_data_o_s[10]} -radix hex {1 120000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(4)\/replication/first_data_o_s[10]} -radix hex {1 130000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(5)\/replication/first_data_o_s[10]} -radix hex {1 140000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(6)\/replication/first_data_o_s[10]} -radix hex {1 150000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(7)\/replication/first_data_o_s[10]} -radix hex {1 160000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(8)\/replication/first_data_o_s[10]} -radix hex {1 170000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/pair_and_spare_FIR/\replication_of_fir(9)\/replication/first_data_o_s[10]} -radix hex {1 175000ns} -cancel_after 400ms