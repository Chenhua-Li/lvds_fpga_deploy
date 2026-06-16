create_clock -name apb_pclk -period 20 [get_ports apb_pclk]
create_clock -name axis_brg_clk  -period 2 [get_ports axis_brg_clk]
create_clock -name lvds_tx_bclk -period 1 [get_ports lvds_tx_bclk]

set_clock_groups -asynchronous -name asyn_grp \
    -group [get_clocks apb_pclk] \
    -group [get_clocks axis_brg_clk] \
    -group [get_clocks lvds_tx_bclk]
