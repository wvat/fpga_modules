
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name vga_controller -dir "/home/fred/Projects/fpga_projects/vga_controller/planAhead_run_3" -part xc3s100ecp132-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/fred/Projects/fpga_projects/vga_controller/top_module.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/fred/Projects/fpga_projects/vga_controller} }
set_property target_constrs_file "top_module.ucf" [current_fileset -constrset]
add_files [list {top_module.ucf}] -fileset [get_property constrset [current_run]]
link_design
