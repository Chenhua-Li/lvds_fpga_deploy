
module lvds_rx_ctrl
import lvds_if_pkg::*;
(
    input       [4:0]                               wr_wm,
    input       [4:0]                               rd_wm,

    input                                           rstn_raw,
    input                                           axis_clk_raw,
    output                                          test_axis_rstn,
    input                                           scan_mode,
    input                                           lvds_rx_ctrl_en,
    input                                           cfg_ecc_correct,
    input                                           rx_bit_clk_inv_sel,
    input       [6*8-1:0]                           delay_chain_ctrl,

    //dbg
    output      logic                               prbs_done,
    output      logic                               prbs_pass,
    input       logic                               dbg_rx_en,
    output      logic [10:0]                        dbg_rx_pkt_cnt,
    output      logic                               dbg_rx_pkt_equ,
    output      logic [AXIS_DATA_WIDTH-1:0]         dbg_rx_data,


    input                                           rx_bit_clk_lvds,
    input       [ 9:0]                              rx_bits_lvds,
    output      [LVDS_PAD_NUM-1:0]                  lvds_rx_drv_clk,
    output      [LVDS_PAD_NUM-1:0]                  lvds_rx_drv_rstn,
    //calib
    input                                           man_read_req,
    output                                          man_read_ack,
    output      [59:0]                              man_read_data,
    input                                           cal_mode_en,
    input                                           auto_cal_start,
    output                                          cal_done,
    output                                          cal_up_req,
    output      [7:0]                               cal_up_val,
    output      [4:0]                               cal_lane_num,
    input                                           cal_up_ack,
    output      logic                               rec_p_calib_req,
    input       logic                               rec_p_calib_ack,


    input                                           tready,
    output      [AXIS_DATA_WIDTH-1:0]               tdata,
    output                                          tlast,
    output                                          tvalid,

//err
    output      lvds_rx_err_type                    rx_err_o,
    input       lvds_rx_err_type                    rx_err_ack,
    output                                          fc_stop_tx,
    output                                          send_restart_req,
    output      send_stop_req

    );

logic                                           dec_err;
logic                                           wclk_tick;
logic                                           wclk;
logic                                           wrstn;
logic                                           eop_i;
logic                                           sop_i;
logic   [31:0]                                  wdata_i;
logic                                           wdata_vld_i;
logic                                           lvds_rx_bit_clk;
logic   [ 9:0]                                  lvds_rx_bits;
logic                                           lvds_rx_bit_rstn;
logic                                           axis_rstn;
logic                                           axis_clk;
logic                                           lvds_rx_calib_clk;
logic                                           lvds_rx_calib_rstn;
logic                                           lvds_rx_df_push_en;
lvds_rx_wf_data_type                            lvds_rx_df_push_data;
logic                                           lvds_rx_calib_clk_div2_flag;
logic                                           dbg_rx_en_syn;
logic                                           rx_cal_mode_en_pos;
logic                                           cal_mode_mask;

assign test_axis_rstn                      = axis_rstn;

macro_sync2r u_syn_dbg_rx_en(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( dbg_rx_en                   ),
    .o                                  ( dbg_rx_en_syn               )
    );

lvds_rx_cru u_lvds_rx_cru(
    .rstn_raw                           ( rstn_raw                    ),
    .axis_clk_raw                       ( axis_clk_raw                ),
    .scan_mode                          ( scan_mode                   ),
    .lvds_rx_ctrl_en                    ( lvds_rx_ctrl_en             ),
    .rx_bit_clk_inv_sel                 ( rx_bit_clk_inv_sel          ),
    .delay_chain_ctrl                   ( delay_chain_ctrl            ),
    .rx_bit_clk_lvds                    ( rx_bit_clk_lvds             ),
    .rx_bits_lvds                       ( rx_bits_lvds                ),
    .cal_mode_mask                      ( cal_mode_mask               ),
    .cal_mode_en                        ( cal_mode_en                 ),
    .auto_cal_start                     ( auto_cal_start              ),
    .rx_cal_mode_en_pos                 ( rx_cal_mode_en_pos          ),
    .lvds_rx_calib_clk                  ( lvds_rx_calib_clk           ),
    .lvds_rx_calib_rstn                 ( lvds_rx_calib_rstn          ),
    .lvds_rx_calib_clk_div2             ( lvds_rx_calib_clk_div2_flag ),
    .lvds_rx_bit_clk                    ( lvds_rx_bit_clk             ),
    .lvds_rx_bits                       ( lvds_rx_bits                ),
    .lvds_rx_bit_rstn                   ( lvds_rx_bit_rstn            ),
    .axis_rstn                          ( axis_rstn                   ),
    .axis_clk                           ( axis_clk                    ),
    .wclk                               ( wclk                        ),
    .wrstn                              ( wrstn                       ),
    .wclk_tick                          ( wclk_tick                   ),
    .lvds_rx_drv_clk                    ( lvds_rx_drv_clk             ),
    .lvds_rx_drv_rstn                   ( lvds_rx_drv_rstn            )

    );

lvds_rx_axis_if u_lvds_rx_axis_if (

    .wclk                               ( wclk                        ),
    .wrstn                              ( wrstn                       ),
    .wr_wm                              ( wr_wm                       ),
    .rd_wm                              ( rd_wm                       ),
    .lvds_rx_df_push_en                 ( lvds_rx_df_push_en          ),
    .lvds_rx_df_push_data               ( lvds_rx_df_push_data        ),
    .axis_clk                           ( axis_clk                    ),
    .axis_rstn                          ( axis_rstn                   ),
    .tdata                              ( tdata                       ),
    .tlast                              ( tlast                       ),
    .tvalid                             ( tvalid                      ),
    .tready                             ( tready                      ),

    //dbg
    .dbg_rx_en                          ( dbg_rx_en_syn               ),
    .dbg_rx_pkt_cnt                     ( dbg_rx_pkt_cnt              ),
    .dbg_rx_pkt_equ                     ( dbg_rx_pkt_equ              ),
    .dbg_rx_data                        ( dbg_rx_data                 ),
    
    //fc
    .send_stop_req                      ( send_stop_req               ),
    .send_restart_req                   ( send_restart_req            )

    );

lvds_rx_word_ctrl u_lvds_rx_word_ctrl(
    // Outputs
    .lvds_rx_df_push_en                 ( lvds_rx_df_push_en          ),
    .lvds_rx_df_push_data               ( lvds_rx_df_push_data        ),
    // Inputs
    .dbg_rx_en                          ( dbg_rx_en_syn               ),
    .cfg_ecc_correct                    ( cfg_ecc_correct             ),
    .bit_dec_err                        ( dec_err                     ),
    .rx_err_o                           ( rx_err_o                    ),
    .rx_err_ack                         ( rx_err_ack                  ),
    .wclk                               ( wclk                        ),
    .wrstn                              ( wrstn                       ),
    .wdata_i                            ( wdata_i                     ),
    .wdata_vld_i                        ( wdata_vld_i                 ),
    .sop_i                              ( sop_i                       ),
    .eop_i                              ( eop_i                       )
    );

lvds_rx_bit_ctrl u_lvds_rx_bit_ctrl(
                    // Outputs
    .prbs_done                          ( prbs_done                   ),
    .prbs_pass                          ( prbs_pass                   ),
    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .tx_stop_send_en                    ( fc_stop_tx                  ),
    .wdata_o                            ( wdata_i[31:0]               ),
    .wdata_vld_o                        ( wdata_vld_i                 ),
    .sop_o                              ( sop_i                       ),
    .eop_o                              ( eop_i                       ),
                    // Inputs
    .cal_mode_mask                      ( cal_mode_mask               ),
    .wclk_tick                          ( wclk_tick                   ),
    .lvds_rx_bit_clk                    ( lvds_rx_bit_clk             ),
    .lvds_rx_bits                       ( lvds_rx_bits                ),
    .lvds_rx_bit_rstn                   ( lvds_rx_bit_rstn            ),
    .dec_err_o                          ( dec_err                     )
    );

lvds_rx_bit_calib u_lvds_rx_bit_calib(
    .clk                                ( lvds_rx_calib_clk           ),
    .rstn                               ( lvds_rx_calib_rstn          ),
    .clk_div2_flag                      ( lvds_rx_calib_clk_div2_flag ),
    .man_read_req                       ( man_read_req                ),
    .man_read_ack                       ( man_read_ack                ),
    .man_read_data                      ( man_read_data               ),
    .cal_en_pos                         ( rx_cal_mode_en_pos          ),
    .scan_mode                          ( scan_mode                   ),
    .lvds_rx_bits                       ( lvds_rx_bits                ),
    .cal_done                           ( cal_done                    ),
    .cal_up_req                         ( cal_up_req                  ),
    .cal_up_val                         ( cal_up_val                  ),
    .cal_lane_num                       ( cal_lane_num                ),
    .cal_up_ack                         ( cal_up_ack                  )
    );

endmodule


