############################################################################
#    U zavisnosti od broja modula, otkomentarisati n-1 liniju u skripti    #
############################################################################
add_force {/tb/uut_fir_filter/\replication_of_fir(0)\/replication/first_data_o_s[10]} -radix hex {1 2000ns} -cancel_after 400ms
add_force {/tb/uut_fir_filter/\replication_of_fir(1)\/replication/first_data_o_s[10]} -radix hex {1 5000ns} -cancel_after 400ms
add_force {/tb/uut_fir_filter/\replication_of_fir(2)\/replication/first_data_o_s[10]} -radix hex {1 10000ns} -cancel_after 400ms
add_force {/tb/uut_fir_filter/\replication_of_fir(3)\/replication/first_data_o_s[10]} -radix hex {1 15000ns} -cancel_after 400ms
add_force {/tb/uut_fir_filter/\replication_of_fir(4)\/replication/first_data_o_s[10]} -radix hex {1 23000ns} -cancel_after 400ms
add_force {/tb/uut_fir_filter/\replication_of_fir(5)\/replication/first_data_o_s[10]} -radix hex {1 33000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/\replication_of_fir(6)\/replication/first_data_o_s[10]} -radix hex {1 36000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/\replication_of_fir(7)\/replication/first_data_o_s[10]} -radix hex {1 38000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/\replication_of_fir(8)\/replication/first_data_o_s[10]} -radix hex {1 41000ns} -cancel_after 400ms
#add_force {/tb/uut_fir_filter/\replication_of_fir(9)\/replication/first_data_o_s[10]} -radix hex {1 53000ns} -cancel_after 400ms
