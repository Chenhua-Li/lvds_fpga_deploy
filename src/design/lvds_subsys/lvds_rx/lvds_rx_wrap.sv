
module lvds_rx_wrap
import lvds_if_pkg::*;
(

//axis
    input                                           rstn_raw,
    input                                           scan_mode,
    input                                           lvds_rx_ctrl_en,
    input                                           cfg_ecc_correct,
    input                                           rx_bit_clk_inv_sel,
    input       [6*8-1:0]                           delay_chain_ctrl,

    output                                          test_axis_rstn,
    input                                           axis_clk_raw,
    input                                           tready,
    output      [AXIS_DATA_WIDTH-1:0]               tdata,
    output                                          tlast,
    output                                          tvalid,
//dbg
    input       logic                               dbg_rx_en,
    output      logic [10:0]                        dbg_rx_pkt_cnt,
    output      logic                               dbg_rx_pkt_equ,
    output      logic [AXIS_DATA_WIDTH-1:0]         dbg_rx_data,
    output      logic                               prbs_done,
    output      logic                               prbs_pass,


//calib
    input                                           man_read_req,
    output                                          man_read_ack,
    output      [59:0]                              man_read_data,
    input                                           auto_cal_start,
    input                                           cal_mode_en,
    output                                          cal_done,
    output                                          cal_up_req,
    output      [7:0]                               cal_up_val,
    output      [4:0]                               cal_lane_num,
    input                                           cal_up_ack,
    output      logic                               rec_p_calib_req,
    input       logic                               rec_p_calib_ack,

//err report
    output      lvds_rx_err_type                    rx_err_o,
    input       lvds_rx_err_type                    rx_err_ack,

//fc
    output                                          send_restart_req,
    output                                          send_stop_req,
    output                                          fc_stop_tx,
    input       [4:0]                               lvds_rx_data_wr_wm,
    input       [4:0]                               lvds_rx_data_rd_wm,

//pad ctrl
    input                                           lvds_pad_inv_cp,
    input                                           lvds_pad_bias_en,
    input                                           lvds_pad_rterm_en,
    input       [2:0]                               lvds_pad_rterm_val,
    input                                           lvds_pad_rxcm_en,
//lvds pads
    inout                                           LVDS_CLK_N,
    inout                                           LVDS_CLK_P,
    inout                                           LVDS_DAT0_N,
    inout                                           LVDS_DAT0_P,
    inout                                           LVDS_DAT1_N,
    inout                                           LVDS_DAT1_P,
    inout                                           LVDS_DAT2_N,
    inout                                           LVDS_DAT2_P,
    inout                                           LVDS_DAT3_N,
    inout                                           LVDS_DAT3_P,
    inout                                           LVDS_DAT4_N,
    inout       LVDS_DAT4_P

    );

logic                                           lvds_pad_ddr_en;
logic                                           lvds_pad_rxen;
logic                                           lvds_pad_txen;
logic                                           lvds_pad_sync_en;
logic                                           lvds_pad_tx_cm;
logic   [3:0]                                   lvds_pad_txdrv;
logic                                           rx_bit_clk_lvds;
logic   [ 9:0]                                  rx_bits_lvds;
logic   [LVDS_PAD_NUM-1:0]                      lvds_rx_drv_clk;
logic   [LVDS_PAD_NUM-1:0]                      lvds_rx_drv_rstn;

assign lvds_pad_ddr_en                     = 1'b1;
assign lvds_pad_rxen                       = 1'b1;
assign lvds_pad_txen                       = 1'b0;
assign lvds_pad_sync_en                    = 1'b1;
assign lvds_pad_tx_cm                      = 1'b0;
assign lvds_pad_txdrv                      = 4'h5;



lvds_rx_ctrl u_lvds_rx_ctrl(
                // Outputs
    .test_axis_rstn                     ( test_axis_rstn              ),
    .lvds_rx_drv_clk                    ( lvds_rx_drv_clk             ),
    .lvds_rx_drv_rstn                   ( lvds_rx_drv_rstn            ),
    .tdata                              ( tdata                       ),
    .tlast                              ( tlast                       ),
    .tvalid                             ( tvalid                      ),
    .fc_stop_tx                         ( fc_stop_tx                  ),
    .send_restart_req                   ( send_restart_req            ),
    .send_stop_req                      ( send_stop_req               ),
    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .rx_err_o                           ( rx_err_o                    ),
    .rx_err_ack                         ( rx_err_ack                  ),

    //dbg
    .prbs_done                          ( prbs_done                   ),
    .prbs_pass                          ( prbs_pass                   ),
    .dbg_rx_en                          ( dbg_rx_en                   ),
    .dbg_rx_pkt_cnt                     ( dbg_rx_pkt_cnt              ),
    .dbg_rx_pkt_equ                     ( dbg_rx_pkt_equ              ),
    .dbg_rx_data                        ( dbg_rx_data                 ),

                     // Inputs
    .cfg_ecc_correct                    ( cfg_ecc_correct             ),
    .rstn_raw                           ( rstn_raw                    ),
    .axis_clk_raw                       ( axis_clk_raw                ),
    .scan_mode                          ( scan_mode                   ),
    .lvds_rx_ctrl_en                    ( lvds_rx_ctrl_en             ),
    .rx_bit_clk_inv_sel                 ( rx_bit_clk_inv_sel          ),
    .delay_chain_ctrl                   ( delay_chain_ctrl            ),
    .rx_bit_clk_lvds                    ( rx_bit_clk_lvds             ),
    .rx_bits_lvds                       ( rx_bits_lvds                ),
    .man_read_req                       ( man_read_req                ),
    .man_read_ack                       ( man_read_ack                ),
    .man_read_data                      ( man_read_data               ),
    .auto_cal_start                     ( auto_cal_start              ),
    .cal_mode_en                        ( cal_mode_en                 ),
    .cal_done                           ( cal_done                    ),
    .cal_up_req                         ( cal_up_req                  ),
    .cal_up_val                         ( cal_up_val                  ),
    .cal_lane_num                       ( cal_lane_num                ),
    .cal_up_ack                         ( cal_up_ack                  ),
    .wr_wm                              ( lvds_rx_data_wr_wm          ),
    .rd_wm                              ( lvds_rx_data_rd_wm          ),
    .tready                             ( tready                      )
    );


lvds_rx_pad_wrap u_lvds_rx_pad_wrap(
                    // Outputs
    .lvds_rx_bit_clk_raw                ( rx_bit_clk_lvds             ),
    .lvds_rx_bits                       ( rx_bits_lvds[ 9:0]),
                    // Inouts
    .LVDS_CLK_N                         ( LVDS_CLK_N                  ),
    .LVDS_CLK_P                         ( LVDS_CLK_P                  ),
    .LVDS_DAT0_N                        ( LVDS_DAT0_N                 ),
    .LVDS_DAT0_P                        ( LVDS_DAT0_P                 ),
    .LVDS_DAT1_N                        ( LVDS_DAT1_N                 ),
    .LVDS_DAT1_P                        ( LVDS_DAT1_P                 ),
    .LVDS_DAT2_N                        ( LVDS_DAT2_N                 ),
    .LVDS_DAT2_P                        ( LVDS_DAT2_P                 ),
    .LVDS_DAT3_N                        ( LVDS_DAT3_N                 ),
    .LVDS_DAT3_P                        ( LVDS_DAT3_P                 ),
    .LVDS_DAT4_N                        ( LVDS_DAT4_N                 ),
    .LVDS_DAT4_P                        ( LVDS_DAT4_P                 ),
                    // Inputs

    .lvds_drv_clk                       ( lvds_rx_drv_clk             ),
    .lvds_drv_rstn                      ( lvds_rx_drv_rstn            ),
    .lvds_pad_ddr_en                    ( lvds_pad_ddr_en             ),
    .lvds_pad_inv_cp                    ( lvds_pad_inv_cp             ),
    .lvds_pad_rxen                      ( lvds_pad_rxen               ),
    .lvds_pad_tx_cm                     ( lvds_pad_tx_cm              ),
    .lvds_pad_txdrv                     ( lvds_pad_txdrv[3:0]         ),
    .lvds_pad_txen                      ( lvds_pad_txen               ),
    .lvds_pad_bias_en                   ( lvds_pad_bias_en            ),
    .lvds_pad_rterm_en                  ( lvds_pad_rterm_en           ),
    .lvds_pad_rterm_val                 ( lvds_pad_rterm_val[2:0]     ),
    .lvds_pad_rxcm_en                   ( lvds_pad_rxcm_en            ),
    .lvds_pad_sync_en                   ( lvds_pad_sync_en            )
    );


endmodule

