# ===================================================================================
# Definisanje direktorijuma u kojem ce biti projekat
# ===================================================================================
cd ..
set root_dir [pwd]
cd scripts
set resultDir ../vivado_project

file mkdir $resultDir

create_project Fault_Tolerant_FIR $resultDir -part xc7z020clg400-1
set_property board_part digilentinc.com:zybo-z7-20:part0:1.1 [current_project]

# ===================================================================================
# Ukljucivanje svih izvornih i simulacionih fajlova u projekat
# ===================================================================================
add_files -norecurse ../hdl/util_pkg.vhd
add_files -norecurse ../hdl/txt_util.vhd
add_files -norecurse ../hdl/mac.vhd
add_files -norecurse ../hdl/fir_param.vhd
add_files -norecurse ../hdl/two_fir_with_compare.vhd
add_files -norecurse ../hdl/replication.vhd
add_files -norecurse ../hdl/bram.vhd
add_files -norecurse ../hdl/top.vhd

update_compile_order -fileset sources_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
#add_files -fileset sim_1 -norecurse ../tb/tb.vhd
#add_files -fileset sim_1 -norecurse ../tb/two_fir_with_compare_tb.vhd
#add_files -fileset sim_1 -norecurse ../tb/replication_tb.vhd
add_files -fileset sim_1 -norecurse ../tb/top_tb.vhd
add_files -fileset constrs_1 -norecurse ../constraint/clock_constraint.xdc
add_files -fileset sim_1 -norecurse ../waveform_tb_behav.wcfg

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
