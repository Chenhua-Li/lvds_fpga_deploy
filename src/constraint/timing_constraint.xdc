#create_clock -period 5.000 -name Sys_Clk [get_ports Sys_Clk]

#create_generated_clock -name apb_pclk_clk_wiz_0 \
#    -source [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKIN1] \
#    -divide_by 10 \
#    [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKOUT0]
    
#create_generated_clock -name axis_brg_clk \
#    -source [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKIN1] \
#    -multiply_by 1 \
#    [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKOUT1]

#create_generated_clock -name lvds_tx_bclk \
#    -source [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKIN1] \
#    -multiply_by 2 \
#    [get_pins clk_gen_0/inst/mmcme4_adv_inst/CLKOUT2]

set_clock_groups -name asyn_grp -asynchronous -group [get_clocks apb_pclk_clk_wiz_0] -group [get_clocks axis_brg_clk_clk_wiz_0] -group [get_clocks lvds_tx_bclk_clk_wiz_0]

