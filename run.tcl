##########################################################################################
# Lab 1 - Reading RTL
# Script: run.tcl
##########################################################################################

#settings libraries
source -echo ./setup.tcl

#creating design libraries
create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBRARY router1x3.dlib

#reading RTL
analyze -format verilog [glob rtl/*.v]
elaborate router_top
set_top_module router_top

#reading tlu
#read_parasitic_tech -layermap ../ref/tech/saed32nm_tf_itf_tluplus.map -tlup ../ref/tech/saed32nm_1p9m_Cmax.lv.nxtgrd -name maxTLU
#read_parasitic_tech -layermap ../ref/tech/saed32nm_tf_itf_tluplus.map -tlup ../ref/tech/saed32nm_1p9m_Cmin.lv.nxtgrd -name minTLU

read_parasitic_tech -layermap ../ref/tech/saed32nm_tf_itf_tluplus.map -tlup ../ref/tech/saed32nm_1p9m_Cmax.lv.nxtgrd -name maxTLU
read_parasitic_tech -layermap ../ref/tech/saed32nm_tf_itf_tluplus.map -tlup ../ref/tech/saed32nm_1p9m_Cmin.lv.nxtgrd -name minTLU


#upf
load_upf ./design_data/router_core.upf
commit_upf


#MCMM
source -echo ./design_data/mcmm_router_core.tcl

#Read SDCf-
read_sdc ./Constraints/router.sdc


#missing scandef
set_app_options -list {place.coarse.continue_on_missing_scandef {true}}

#COMPILE FLOW STAGES
compile_fusion
#or
compile_fusion -from initial_map -to initial_map
compile_fusion -from logic_opto -to logic_opto

#floorplaning
initialize_floorplan -boundary {{124.857 101.342} {124.857 5.035} {135.558 5.035} {135.558 -5.665} {220.018 -5.665} {220.018 144.909} {193.266 144.909} {193.266 93.698} {169.189 93.698} {169.189 144.909} {112.628 144.909} {112.628 123.508} {145.494 123.508} {145.494 101.342}} -core_offset {2}
set_app_options -name place.coarse.fix_hard_macros -value false
set_app_options -name plan.place.auto_create_blockages -value auto
create_placement -floorplan

#save_block -hierarchical router1x3.dlib:router_top

#placement
place_pins -self
check_design -checks pre_placement_stage
place_opt

#save_block -hierarchical router1x3.dlib:router_top


report_power 

check_pg_drc
check_pg_connectivity
check_pg_missing_vias
check_pg_nets



