##############################################################################
# Configurations
##############################################################################
set top_dir       "../.."
set apr_dir       ".."
set enc_dir       "$apr_dir/enc"
set ibm13_dir     "/afs/umich.edu/class/eecs627/ibm13/artisan/current/aci/sc-x"
set top           "pulpino_mem"


##############################################################################
# Source files
##############################################################################
source ${apr_dir}/globals_mem.tcl


##############################################################################
# Processes
##############################################################################

proc get_multithread_lic { } {
    setMultiCpuUsage -acquireLicense 4
}

proc connect_std_cells_to_power { } {
    globalNetConnect VDD -type tiehi -inst * -verbose
    globalNetConnect VSS -type tielo -inst * -verbose
    globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
    globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
}


##############################################################################
# Initalization
##############################################################################

# Initalize design
init_design
clearGlobalNets

## Connet Global Net
globalNetConnect VDD -type pgpin -pin VDD* -instanceBasename *
globalNetConnect VDD -type tiehi -pin VDD* -instanceBasename *
globalNetConnect VDD -type net -net VDD*
globalNetConnect VSS -type pgpin -pin VSS* -instanceBasename *
globalNetConnect VSS -type tielo -pin VSS* -instanceBasename *
globalNetConnect VSS -type net -net VSS*


##############################################################################
# Floorplanning
##############################################################################

# Floorplan
set fp_width  2400
set fp_height 1200
set fp_offset 20
floorPlan -site IBM13SITE -s $fp_width $fp_height $fp_offset $fp_offset $fp_offset $fp_offset
loadIoFile "$apr_dir/pulpino_mem.io"

# Place instruction memory
set instr_mem "instr_mem/sp_ram_wrap_i_sp_ram_i"
setObjFPlanBox Instance $instr_mem\_genblk2_1__genblk1_0__RA1SHD_i [expr 150+270*0] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_1__genblk1_1__RA1SHD_i [expr 150+270*1] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_1__genblk1_2__RA1SHD_i [expr 150+270*2] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_1__genblk1_3__RA1SHD_i [expr 150+270*3] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_0__genblk1_0__RA1SHD_i [expr 150+270*4] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_0__genblk1_1__RA1SHD_i [expr 150+270*5] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_0__genblk1_2__RA1SHD_i [expr 150+270*6] 680 9999 9999
setObjFPlanBox Instance $instr_mem\_genblk2_0__genblk1_3__RA1SHD_i [expr 150+270*7] 680 9999 9999

# Place data memory
set data_mem "data_mem/sp_ram_i"
setObjFPlanBox Instance $data_mem\_genblk2_1__genblk1_0__RA1SHD_i [expr 150+270*0] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_1__genblk1_1__RA1SHD_i [expr 150+270*1] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_1__genblk1_2__RA1SHD_i [expr 150+270*2] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_1__genblk1_3__RA1SHD_i [expr 150+270*3] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_0__genblk1_0__RA1SHD_i [expr 150+270*4] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_0__genblk1_1__RA1SHD_i [expr 150+270*5] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_0__genblk1_2__RA1SHD_i [expr 150+270*6] 135 9999 9999
setObjFPlanBox Instance $data_mem\_genblk2_0__genblk1_3__RA1SHD_i [expr 150+270*7] 135 9999 9999

# Add power ring
setAddRingMode \
    -ring_target default \
    -extend_over_row 0 \
    -ignore_rows 0 \
    -avoid_short 0 \
    -skip_crossing_trunks none \
    -stacked_via_top_layer LM \
    -stacked_via_bottom_layer M1 \
    -via_using_exact_crossover_size 1 \
    -orthogonal_only true \
    -skip_via_on_pin { standardcell } \
    -skip_via_on_wire_shape { noshape }
addRing \
    -nets {VDD VSS} \
    -type core_rings \
    -follow core \
    -layer {top M3 bottom M3 left M4 right M4} \
    -width {top 2 bottom 2 left 2 right 2} \
    -spacing {top 1 bottom 1 left 1 right 1} \
    -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} \
    -center 0 \
    -threshold 0 \
    -jog_distance 0 \
    -snap_wire_center_to_grid None \
    -use_wire_group 1 \
    -use_wire_group_bits 3 \
    -use_interleaving_wire_group 1

# Add core ring
setAddRingMode \
    -ring_target core_ring \
    -extend_over_row 1 \
    -ignore_rows 0 \
    -avoid_short 0 \
    -skip_crossing_trunks none \
    -stacked_via_top_layer LM \
    -stacked_via_bottom_layer M1 \
    -via_using_exact_crossover_size 1 \
    -orthogonal_only true \
    -skip_via_on_pin {  standardcell } \
    -skip_via_on_wire_shape { noshape }
addRing \
    -nets {VDD VSS} \
    -type block_rings \
    -around each_block \
    -layer {top M3 bottom M3 left M4 right M4} \
    -width {top 2 bottom 2 left 2 right 2} \
    -spacing {top 1 bottom 1 left 1 right 1} \
    -offset {top 3 bottom 3 left 3 right 3} \
    -center 0 \
    -extend_corner {lt rt tl bl lb rb br tr } \
    -threshold 0 \
    -jog_distance 0 \
    -snap_wire_center_to_grid None

# Special route block pin
sroute \
    -connect { blockPin } \
    -layerChangeRange { M1(1) LM(8) } \
    -blockPinTarget { nearestTarget } \
    -allowJogging 1 \
    -crossoverViaLayerRange { M1(1) LM(8) } \
    -nets { VDD VSS } \
    -allowLayerChange 1 \
    -blockPin useLef \
    -targetViaLayerRange { M1(1) LM(8) }

# Add placement blockage
addHaloToBlock {10 10 10 10} -allBlock

# Add follow pin
setSrouteMode -viaConnectToShape { blockring }
sroute \
    -connect { corePin } \
    -layerChangeRange { M1(1) LM(8) } \
    -blockPinTarget { nearestTarget } \
    -corePinTarget { firstAfterRowEnd } \
    -allowJogging 1 \
    -crossoverViaLayerRange { M1(1) LM(8) } \
    -nets { VDD VSS } \
    -allowLayerChange 1 \
    -targetViaLayerRange { M1(1) LM(8) }

# Add placement blockage
createPlaceBlockage -box 140 135 2290 1200 -type hard


##############################################################################
# Placement
##############################################################################

# Place design
get_multithread_lic
setMultiCpuUsage \
    -localCpu 6 \
    -cpuPerRemoteHost 1 \
    -remoteHost 0 \
    -keepLicense true
setDistributeHost -local
setPlaceMode -fp false
place_design

# Opt design iteration 1
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS


##############################################################################
# Clock tree synthesis
##############################################################################

# Initialize
get_multithread_lic

if {[sizeof_collection [get_clocks -quiet]] == 0} {
    puts "No clocks found... not running CTS."
    return
}

connect_std_cells_to_power

# Create Clock Tree Spec
set_ccopt_mode -cts_opt_priority insertion_delay -cts_opt_type full
set_ccopt_effort -high

create_ccopt_clock_tree_spec -file ${top}.cts

set_ccopt_property target_insertion_delay 600ps
set_ccopt_property target_skew 600ps
set_ccopt_property source_input_max_trans 10ps


# Clock Tree Synthesis
source ${top}.cts

ccopt_design

# Link power pins of any newly added cells to the power nets
connect_std_cells_to_power

saveDesign "${top}.clock.enc"


##############################################################################
# Routing
##############################################################################
# Route
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName ANTENNATR
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeTdrEffort 10
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail -viaOpt -wireOpt

# Set mode for opt design
setDelayCalMode -engine aae -SIAware true
setAnalysisMode -analysisType onChipVariation -cppr both
setOptMode -addInst true -addInstancePrefix POSROT

# Optimize Design
set opt_time 2
for { set a 0 }  { $a < $opt_time } { incr a } {
    optDesign -postRoute
    optDesign -postRoute -hold
}

##############################################################################
# Final
##############################################################################

# Delete placement blockage
deletePlaceBlockage -all
deleteHaloFromBlock -allBlock

# Add filler
addFiller -cell {FILL64TR FILL32TR FILL16TR FILL8TR FILL4TR FILL2TR FILL1TR} -prefix FILLER
ecoRoute -fix_drc
optDesign -postRoute -incr

# Add metal fill
# set floorplan_width  [dbDBUToMicrons [lindex [dbFPlanBox [dbHeadFPlan]] 2]]
# set floorplan_height [dbDBUToMicrons [lindex [dbFPlanBox [dbHeadFPlan]] 3]]
# set window_size 500

# setMetalFill \
#     -layer {1 2 3 4 5} \
#     -minDensity 20 \
#     -preferredDensity 25 \
#     -maxDensity 80 \
#     -maxLength 4 \
#     -maxWidth 1 \
#     -windowSize $window_size $window_size \
#     -windowStep $window_size $window_size

# for {set i 0} { $i < $floorplan_width } {set i [expr $i + $window_size]} {
#     for {set j 0} { $j < $floorplan_height } {set j [expr $j + $window_size]} {
#         puts "($i, $j)"
#         addMetalFill \
#             -layer {1 2 3 4 5} \
#             -onCells \
#             -timingAware sta \
#             -area $i $j [expr min($floorplan_width,$i+$window_size)] [expr min($floorplan_height,$j+$window_size)]
#     }
# }

# trimMetalFill deleteViols
ecoRoute -fix_drc
optDesign -postRoute -incr

# Report timing before metal fill so that sta mode works
report_timing

return
# Run some checks
clearDrc
verifyGeometry -error 1000000 -noRoutingBlkg
verifyConnectivity -type regular -error 1000000 -warning 500000
verifyProcessAntenna -error 1000000

# Output DEF
set dbgLefDefOutVersion 5.5
defOut -floorplan -netlist -routing ${top}.apr.def

# Output LEF
lefout "$top.lef" -stripePin -PGpinLayers 1 2 3 4 5

# Output GDSII
setStreamOutMode -snapToMGrid true
streamOut "$top.gds" -mapFile "./enc2gdsLM.map" -libName ${top} -structureName $top -stripes 1 -mode ALL

# Output Netlist
saveNetlist -excludeLeafCell ${top}.apr.v
saveNetlist -excludeLeafCell -lineLength 10000000 -includePowerGround -includePhysicalInst ${top}.apr.physical.v

# Generate SDF
extractRC -outfile ${top}.cap
rcOut -spef ${top}.spef

# write_sdf appears broken, but delayCal works.
write_sdf -version 3.0 -collapse_internal_pins ${top}.apr.sdf

# Save Final Design
saveDesign "${top}.final.enc"

return
exit
