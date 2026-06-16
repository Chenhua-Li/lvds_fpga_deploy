module lvds_tx_ctrl
import lvds_if_pkg::*;
(
    input                                           scan_mode,
    input                                           auto_sleep_en,
    input                                           axis_clk_raw,
    input                                           bclk_raw,
    input                                           rstn_raw,
    input       [AXIS_DATA_WIDTH-1:0]               tdata,
    input                                           tlast,
    input                                           tvalid,
    output                                          tready,

//dbg
    input       logic                               dbg_tx_start,
    input       logic                               dbg_tx_en,
    input       logic [10:0]                        dbg_tx_num,
    input       logic [31:0]                        dbg_tx_dat,
    output      logic                               dbg_tx_done,
    input       logic                               dbg_ser_en,
    input       logic                               dbg_der_en,
    input       logic                               cfg_prbs_tx_en,

    //calib
    input       logic                               cfg_auto_calib_en,
    input       logic [7:0]                         cfg_start_calib_dly,
    input       logic [15:0]                        cfg_calib_extra_dly,
    input                                           cal_mode_en,
    input       [ 9:0]                              cal_mode_pat,

    //ctrl_if
    input       logic                               rec_p_calib_req,
    output      logic                               rec_p_calib_ack,
    output      logic                               auto_start_calib,
    input       logic                               lane_calib_done,
    output      logic                               auto_cal_done,
    input                                           send_stop_req,
    input                                           send_restart_req,
    input                                           lvds_ctrl_tx_en,
    input                                           fc_stop_tx,
    output                                          enc_err,

    //to_lvds
    output                                          lvds_bclk_lvds,
    output      [ 9:0]                              lvds_tx_bits_lvds

    );

logic   [35:0]                                  pre_enc_data;
logic                                           lvds_wf_pop_en;
lvds_tx_wf_data_type                            lvds_wf_pop_data;
logic                                           lvds_wf_afifo_empty;
logic                                           brstn;
logic                                           wclk;
logic                                           wrstn;
logic                                           wclk_tick;
logic                                           axis_clk;
logic                                           axis_rstn;
logic                                           bclk;
logic                                           tready_w;
logic   [ 9:0]                                  lvds_tx_bits;
logic                                           lvds_bclk_dly_gated;
logic                                           tx_calib_busy;
logic                                           switch_clk_req;
logic                                           calib_clk;
logic                                           calib_rstn;
logic                                           tx_word_ctrl_idle;
logic                                           axis_data_vld;
logic                                           auto_tx_bit_sel;


lvds_tx_cru u_lvds_tx_cru(
    .switch_clk_req                     ( switch_clk_req              ),
    .calib_clk                          ( calib_clk                   ),
    .calib_rstn                         ( calib_rstn                  ),
    .tx_word_ctrl_idle                  ( tx_word_ctrl_idle           ),
    .axis_data_vld                      ( axis_data_vld               ),
    .send_stop_req                      ( send_stop_req               ),
    .send_restart_req                   ( send_restart_req            ),

    .cfg_auto_calib_en                  ( cfg_auto_calib_en           ),
    .a_wfifo_empty                      ( lvds_wf_afifo_empty         ),
    .auto_sleep_en                      ( auto_sleep_en               ),
    .scan_mode                          ( scan_mode                   ),
    .bclk_raw                           ( bclk_raw                    ),
    .rstn_raw                           ( rstn_raw                    ),
    .axis_clk_raw                       ( axis_clk_raw                ),
    .lvds_ctrl_tx_en                    ( lvds_ctrl_tx_en             ),
    .axis_rstn                          ( axis_rstn                   ),
    .axis_clk                           ( axis_clk                    ),
    .bclk                               ( bclk                        ),
    .brstn                              ( brstn                       ),
    .wclk                               ( wclk                        ),
    .wrstn                              ( wrstn                       ),
    .wclk_tick                          ( wclk_tick                   )
    );

lvds_tx_axis_if u_lvds_tx_axis_if(
                  // Outputs
    .tready                             ( tready_w                    ),
    .lvds_wf_pop_data                   ( lvds_wf_pop_data            ),
    .lvds_wf_afifo_empty                ( lvds_wf_afifo_empty         ),
    .lvds_wf_afifo_full                 (                             ),
    .axis_data_vld                      ( axis_data_vld               ),

    .dbg_tx_start                       ( dbg_tx_start                ),
    .dbg_tx_en                          ( dbg_tx_en                   ),
    .dbg_tx_num                         ( dbg_tx_num                  ),
    .dbg_tx_dat                         ( dbg_tx_dat                  ),
    .dbg_tx_done                        ( dbg_tx_done                 ),

                  // Inputs
    .axis_clk                           ( axis_clk                    ),
    .axis_rstn                          ( axis_rstn                   ),
    .tdata                              ( tdata                       ),
    .tlast                              ( tlast                       ),
    .tvalid                             ( tvalid                      ),
    .lvds_wf_pop_clk                    ( wclk                        ),
    .lvds_wf_pop_rstn                   ( wrstn                       ),
    .lvds_wf_pop_en                     ( lvds_wf_pop_en              )
    );

lvds_tx_word_ctrl u_lvds_tx_word_ctrl(
                      // Outputs
    .wf_pop_en                          ( lvds_wf_pop_en              ),
    .pre_enc_data                       ( pre_enc_data                ),
    .tx_word_ctrl_idle                  ( tx_word_ctrl_idle           ),
                      // Inputs
    .dbg_ser_en                         ( dbg_ser_en                  ),
    .dbg_der_en                         ( dbg_der_en                  ),

    .tx_calib_busy                      ( tx_calib_busy               ),
    .wclk                               ( wclk                        ),
    .wrstn                              ( wrstn                       ),
    .lvds_ctrl_tx_en                    ( lvds_ctrl_tx_en             ),
    .wf_pop_data                        ( lvds_wf_pop_data            ),
    .wf_fifo_empty                      ( lvds_wf_afifo_empty         ),
    .send_stop_req                      ( send_stop_req               ),
    .send_restart_req                   ( send_restart_req            ),
    .fc_stop_tx                         ( fc_stop_tx                  )
    );

lvds_tx_bit_ctrl u_lvds_tx_bit_ctrl(
                    // Outputs
    .lvds_tx_bits                       ( lvds_tx_bits[9:0]           ),
    .enc_err                            ( enc_err                     ),
                    // Inputs
    .prbs_tx_en                         ( cfg_prbs_tx_en              ),
    .bclk                               ( bclk                        ),
    .brstn                              ( brstn                       ),
    .wclk_tick                          ( wclk_tick                   ),
    .auto_cal_start                     ( auto_tx_bit_sel             ),
    .cal_mode_pat                       ( cal_mode_pat                ),
    .pre_enc_data                       ( pre_enc_data                )
    );

lvds_tx_calib u_lvds_tx_calib(
    .clk                                ( calib_clk                   ),
    .rstn                               ( calib_rstn                  ),
    .cfg_man_tx_calib_en                ( cal_mode_en                 ),
    .cfg_auto_calib_en                  ( cfg_auto_calib_en           ),
    .cfg_start_calib_dly                ( cfg_start_calib_dly         ),
    .cfg_calib_extra_dly                ( cfg_calib_extra_dly         ),
    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .auto_start_calib                   ( auto_start_calib            ),
    .auto_tx_bit_sel                    ( auto_tx_bit_sel             ),
    .lane_calib_done                    ( lane_calib_done             ),
    .auto_cal_done                      ( auto_cal_done               ),
    .tx_calib_busy                      ( tx_calib_busy               ),
    .switch_clk_req                     ( switch_clk_req              )

    );

assign lvds_bclk_dly_gated                 = bclk;

assign lvds_bclk_lvds                      = lvds_bclk_dly_gated;
assign lvds_tx_bits_lvds                   = lvds_tx_bits;
assign tready                              = lvds_ctrl_tx_en ? tready_w : 1'b0;
endmodule
