
module lvds_tx_rx_wrap
import lvds_if_pkg::*;
(
    input                                           tx_bclk,
    input                                           tx_rstn_raw,
    input                                           scan_mode,
    input                                           cfg_tx_auto_sleep_en,
    input                                           cfg_tx_lvds_ctrl_en,
    input                                           cfg_ecc_correct,

    input                                           tx_axis_clk,
    input       [AXIS_DATA_WIDTH-1:0]               tx_axis_tdata,
    input                                           tx_axis_tlast,
    input                                           tx_axis_tvalid,
    output                                          tx_axis_tready,

//dbg
    input       logic                               cfg_prbs_tx_en,
    output      logic                               prbs_done,
    output      logic                               prbs_pass,
    input       logic                               cfg_dbg_rx_en,
    output      logic [10:0]                        cfg_dbg_rx_pkt_cnt,
    output      logic                               cfg_dbg_rx_pkt_equ,
    output      logic [AXIS_DATA_WIDTH-1:0]         cfg_dbg_rx_data,

    input       logic                               cfg_dbg_tx_start,
    input       logic                               cfg_dbg_tx_en,
    input       logic [10:0]                        cfg_dbg_tx_num,
    input       logic [31:0]                        cfg_dbg_tx_dat,
    output      logic                               cfg_dbg_tx_done,
    input       logic                               cfg_dbg_ser_en,
    input       logic                               cfg_dbg_der_en,

    //lvds_pad_cfg
    input                                           cfg_tx_lvds_pad_inv_cp,
    input                                           cfg_tx_lvds_pad_tx_cm,
    input       [3:0]                               cfg_tx_lvds_pad_txdrv,
    input                                           cfg_tx_lvds_pad_bias_en,

    //lvds
    inout                                           TX_LVDS_CLK_N,
    inout                                           TX_LVDS_CLK_P,
    inout                                           TX_LVDS_DAT0_N,
    inout                                           TX_LVDS_DAT0_P,
    inout                                           TX_LVDS_DAT1_N,
    inout                                           TX_LVDS_DAT1_P,
    inout                                           TX_LVDS_DAT2_N,
    inout                                           TX_LVDS_DAT2_P,
    inout                                           TX_LVDS_DAT3_N,
    inout                                           TX_LVDS_DAT3_P,
    inout                                           TX_LVDS_DAT4_N,
    inout                                           TX_LVDS_DAT4_P,

    //calib
    input       logic                               cfg_auto_calib_en,
    input       logic [7:0]                         cfg_start_calib_dly,
    input       logic [15:0]                        cfg_calib_extra_dly,

    input                                           cfg_rx_man_read_req,
    output                                          cfg_rx_man_read_ack,
    output      [59:0]                              cfg_rx_man_read_data,
    input       [ 9:0]                              cfg_tx_cal_mode_pat,
    input                                           cfg_rx_cal_mode_en,
    input                                           cfg_tx_cal_mode_en,
    output                                          cfg_rx_cal_done,
    output                                          cfg_rx_cal_up_req,
    output      [7:0]                               cfg_rx_cal_up_val,
    output      [4:0]                               cfg_rx_cal_lane_num,
    input                                           cfg_rx_cal_up_ack,
//axis
    input                                           rx_rstn_raw,
    input                                           rx_axis_clk,
    output                                          test_rx_axis_rstn,
    input                                           rx_axis_tready,
    output      [AXIS_DATA_WIDTH-1:0]               rx_axis_tdata,
    output                                          rx_axis_tlast,
    output                                          rx_axis_tvalid,

//err report
    output      lvds_rx_err_type                    rx_err_o,
    input       lvds_rx_err_type                    rx_err_ack,

    input       [6*8-1:0]                           cfg_rx_delay_chain_ctrl,
    input                                           cfg_rx_lvds_ctrl_en,
    input                                           cfg_rx_bit_clk_inv_sel,
    input       [4:0]                               cfg_rx_lvds_data_wr_wm,
    input       [4:0]                               cfg_rx_lvds_data_rd_wm,

//pad ctrl
    input                                           cfg_rx_lvds_pad_inv_cp,
    input                                           cfg_rx_lvds_pad_bias_en,
    input                                           cfg_rx_lvds_pad_rterm_en,
    input       [2:0]                               cfg_rx_lvds_pad_rterm_val,
    input                                           cfg_rx_lvds_pad_rxcm_en,
//lvds pads
    inout                                           RX_LVDS_CLK_N,
    inout                                           RX_LVDS_CLK_P,
    inout                                           RX_LVDS_DAT0_N,
    inout                                           RX_LVDS_DAT0_P,
    inout                                           RX_LVDS_DAT1_N,
    inout                                           RX_LVDS_DAT1_P,
    inout                                           RX_LVDS_DAT2_N,
    inout                                           RX_LVDS_DAT2_P,
    inout                                           RX_LVDS_DAT3_N,
    inout                                           RX_LVDS_DAT3_P,
    inout                                           RX_LVDS_DAT4_N,
    inout       RX_LVDS_DAT4_P


    );

logic                                           fc_stop_tx;
logic                                           send_restart_req;
logic                                           send_stop_req;
logic                                           auto_start_calib;
logic                                           rec_p_calib_req;
logic                                           rec_p_calib_ack;
logic                                           lane_calib_done;

lvds_tx_wrap u_lvds_tx_wrap(

    .axis_clk_raw                       ( tx_axis_clk                 ),
    .bclk_raw                           ( tx_bclk                     ),
    .rstn_raw                           ( tx_rstn_raw                 ),
    .scan_mode                          ( scan_mode                   ),
    .auto_sleep_en                      ( cfg_tx_auto_sleep_en        ),

    .cfg_prbs_tx_en                     ( cfg_prbs_tx_en              ),
    .cfg_dbg_tx_start                   ( cfg_dbg_tx_start            ),
    .cfg_dbg_tx_en                      ( cfg_dbg_tx_en               ),
    .cfg_dbg_tx_num                     ( cfg_dbg_tx_num              ),
    .cfg_dbg_tx_dat                     ( cfg_dbg_tx_dat              ),
    .cfg_dbg_tx_done                    ( cfg_dbg_tx_done             ),
    .cfg_dbg_ser_en                     ( cfg_dbg_ser_en              ),
    .cfg_dbg_der_en                     ( cfg_dbg_der_en              ),

    .cfg_auto_calib_en                  ( cfg_auto_calib_en           ),
    .cfg_start_calib_dly                ( cfg_start_calib_dly         ),
    .cfg_calib_extra_dly                ( cfg_calib_extra_dly         ),
    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .auto_start_calib                   ( auto_start_calib            ),
    .lane_calib_done                    ( lane_calib_done             ),
    .auto_cal_done                      ( cfg_rx_cal_done             ),

    .fc_stop_tx                         ( fc_stop_tx                  ),
    .cal_mode_en                        ( cfg_tx_cal_mode_en          ),
    .cal_mode_pat                       ( cfg_tx_cal_mode_pat         ),
    .lvds_ctrl_tx_en                    ( cfg_tx_lvds_ctrl_en         ),
    .send_restart_req                   ( send_restart_req            ),
    .send_stop_req                      ( send_stop_req               ),

    .tdata                              ( tx_axis_tdata               ),
    .tlast                              ( tx_axis_tlast               ),
    .tvalid                             ( tx_axis_tvalid              ),
    .tready                             ( tx_axis_tready              ),
    
    .lvds_pad_inv_cp                    ( cfg_tx_lvds_pad_inv_cp      ),
    .lvds_pad_tx_cm                     ( cfg_tx_lvds_pad_tx_cm       ),
    .lvds_pad_txdrv                     ( cfg_tx_lvds_pad_txdrv       ),
    .lvds_pad_bias_en                   ( cfg_tx_lvds_pad_bias_en     ),

    
    .LVDS_CLK_N                         ( TX_LVDS_CLK_N               ),
    .LVDS_CLK_P                         ( TX_LVDS_CLK_P               ),
    .LVDS_DAT0_N                        ( TX_LVDS_DAT0_N              ),
    .LVDS_DAT0_P                        ( TX_LVDS_DAT0_P              ),
    .LVDS_DAT1_N                        ( TX_LVDS_DAT1_N              ),
    .LVDS_DAT1_P                        ( TX_LVDS_DAT1_P              ),
    .LVDS_DAT2_N                        ( TX_LVDS_DAT2_N              ),
    .LVDS_DAT2_P                        ( TX_LVDS_DAT2_P              ),
    .LVDS_DAT3_N                        ( TX_LVDS_DAT3_N              ),
    .LVDS_DAT3_P                        ( TX_LVDS_DAT3_P              ),
    .LVDS_DAT4_N                        ( TX_LVDS_DAT4_N              ),
    .LVDS_DAT4_P                        ( TX_LVDS_DAT4_P              )

    );

lvds_rx_wrap u_lvds_rx_wrap(

    .rstn_raw                           ( rx_rstn_raw                 ),
    .scan_mode                          ( scan_mode                   ),
    .lvds_rx_ctrl_en                    ( cfg_rx_lvds_ctrl_en         ),
    .rx_bit_clk_inv_sel                 ( cfg_rx_bit_clk_inv_sel      ),
    .cfg_ecc_correct                    ( cfg_ecc_correct             ),

    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .test_axis_rstn                     ( test_rx_axis_rstn           ),
    .axis_clk_raw                       ( rx_axis_clk                 ),
    .tready                             ( rx_axis_tready              ),
    .tdata                              ( rx_axis_tdata               ),
    .tlast                              ( rx_axis_tlast               ),
    .tvalid                             ( rx_axis_tvalid              ),
    .man_read_req                       ( cfg_rx_man_read_req         ),
    .man_read_ack                       ( cfg_rx_man_read_ack         ),
    .man_read_data                      ( cfg_rx_man_read_data        ),
    .auto_cal_start                     ( auto_start_calib            ),
    .cal_mode_en                        ( cfg_rx_cal_mode_en          ),
    .cal_done                           ( lane_calib_done             ),
    .cal_up_req                         ( cfg_rx_cal_up_req           ),
    .cal_up_val                         ( cfg_rx_cal_up_val           ),
    .cal_lane_num                       ( cfg_rx_cal_lane_num         ),
    .cal_up_ack                         ( cfg_rx_cal_up_ack           ),
    .delay_chain_ctrl                   ( cfg_rx_delay_chain_ctrl     ),

    //dbg
    .prbs_done                          ( prbs_done                   ),
    .prbs_pass                          ( prbs_pass                   ),
    .dbg_rx_en                          ( cfg_dbg_rx_en               ),
    .dbg_rx_pkt_cnt                     ( cfg_dbg_rx_pkt_cnt          ),
    .dbg_rx_pkt_equ                     ( cfg_dbg_rx_pkt_equ          ),
    .dbg_rx_data                        ( cfg_dbg_rx_data             ),

    .rx_err_o                           ( rx_err_o                    ),
    .rx_err_ack                         ( rx_err_ack                  ),
    .send_restart_req                   ( send_restart_req            ),
    .send_stop_req                      ( send_stop_req               ),
    .fc_stop_tx                         ( fc_stop_tx                  ),
    .lvds_rx_data_wr_wm                 ( cfg_rx_lvds_data_wr_wm      ),
    .lvds_rx_data_rd_wm                 ( cfg_rx_lvds_data_rd_wm      ),
    .lvds_pad_inv_cp                    ( cfg_rx_lvds_pad_inv_cp      ),
    .lvds_pad_bias_en                   ( cfg_rx_lvds_pad_bias_en     ),
    .lvds_pad_rterm_en                  ( cfg_rx_lvds_pad_rterm_en    ),
    .lvds_pad_rterm_val                 ( cfg_rx_lvds_pad_rterm_val   ),
    .lvds_pad_rxcm_en                   ( cfg_rx_lvds_pad_rxcm_en     ),
    .LVDS_CLK_N                         ( RX_LVDS_CLK_N               ),
    .LVDS_CLK_P                         ( RX_LVDS_CLK_P               ),
    .LVDS_DAT0_N                        ( RX_LVDS_DAT0_N              ),
    .LVDS_DAT0_P                        ( RX_LVDS_DAT0_P              ),
    .LVDS_DAT1_N                        ( RX_LVDS_DAT1_N              ),
    .LVDS_DAT1_P                        ( RX_LVDS_DAT1_P              ),
    .LVDS_DAT2_N                        ( RX_LVDS_DAT2_N              ),
    .LVDS_DAT2_P                        ( RX_LVDS_DAT2_P              ),
    .LVDS_DAT3_N                        ( RX_LVDS_DAT3_N              ),
    .LVDS_DAT3_P                        ( RX_LVDS_DAT3_P              ),
    .LVDS_DAT4_N                        ( RX_LVDS_DAT4_N              ),
    .LVDS_DAT4_P                        ( RX_LVDS_DAT4_P              )

    );

endmodule
