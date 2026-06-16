# Set project path
set prj_root       "./vivado_prj"
set prj_name       "lvds_subsys"

# Device part
set dev_part       "xcvu13p-fhgb2104-2-i"

# Set top module
set top_design     "lvds_top"
set top_tb         "tb_lvds_subsys_tx_rx_test"

# Close existing project
if {[file exists $prj_root/$prj_name.xpr]} {
    close_project -quiet
}

# Delete old project
file delete -force $prj_root

# Create new project
create_project -force $prj_name $prj_root -part $dev_part