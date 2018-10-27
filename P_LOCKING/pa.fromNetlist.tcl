
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name P_LOCKING -dir "F:/Users/sed7/Desktop/P_LOCKING/planAhead_run_1" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "F:/Users/sed7/Desktop/P_LOCKING/P1.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {F:/Users/sed7/Desktop/P_LOCKING} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
