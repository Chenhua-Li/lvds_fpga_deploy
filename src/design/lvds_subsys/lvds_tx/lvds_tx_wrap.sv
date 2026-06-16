
module lvds_tx_wrap
    import lvds_if_pkg::*;
(

    input                                           axis_clk_raw,
    input                                           bclk_raw,
    input                                           rstn_raw,
    input                                           scan_mode,
    input                                           auto_sleep_en,

    input                                           fc_stop_tx,
    input                                           lvds_ctrl_tx_en,
    input                                           cal_mode_en,
    input       [ 9:0]                              cal_mode_pat,
    input                                           send_restart_req,
    input                                           send_stop_req,

    input       logic                               cfg_auto_calib_en,
    input       logic [7:0]                         cfg_start_calib_dly,
    input       logic [15:0]                        cfg_calib_extra_dly,
    input       logic                               rec_p_calib_req,
    output      logic                               rec_p_calib_ack,
    output      logic                               auto_start_calib,
    input       logic                               lane_calib_done,
    output      logic                               auto_cal_done,
//dbg
    input       logic                               cfg_prbs_tx_en,
    input       logic                               cfg_dbg_tx_start,
    input       logic                               cfg_dbg_tx_en,
    input       logic [10:0]                        cfg_dbg_tx_num,
    input       logic [31:0]                        cfg_dbg_tx_dat,
    output      logic                               cfg_dbg_tx_done,
    input       logic                               cfg_dbg_ser_en,
    input       logic                               cfg_dbg_der_en,


    input       [AXIS_DATA_WIDTH-1:0]               tdata,
    input                                           tlast,
    input                                           tvalid,
    output                                          tready,
    //lvds_pad_cfg
    input                                           lvds_pad_inv_cp,
    input                                           lvds_pad_tx_cm,
    input       [3:0]                               lvds_pad_txdrv,
    input                                           lvds_pad_bias_en,

    //lvds
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

logic                                           lvds_bclk;
logic   [ 9:0]                                  lvds_tx_bits;
logic                                           lvds_pad_ddr_en;
logic                                           lvds_pad_rxen;
logic                                           lvds_pad_txen;
logic                                           lvds_pad_sync_en;
logic                                           lvds_pad_rterm_en;
logic   [2:0]                                   lvds_pad_rterm_val;
logic                                           lvds_pad_rxcm_en;

assign lvds_pad_ddr_en                     = 1'b1;
assign lvds_pad_rxen                       = 1'b0;
assign lvds_pad_txen                       = 1'b1;
assign lvds_pad_sync_en                    = 1'b1;
assign lvds_pad_rterm_en                   = 1'b0;
assign lvds_pad_rterm_val                  = 3'b011;
assign lvds_pad_rxcm_en                    = 1'b0;


lvds_tx_ctrl u_lvds_tx_ctrl(
                // Outputs
    .tready                             ( tready                      ),
    .enc_err                            (                             ),
    .lvds_bclk_lvds                     ( lvds_bclk                   ),
    .lvds_tx_bits_lvds                  ( lvds_tx_bits[ 9:0]),

    .dbg_tx_start                       ( cfg_dbg_tx_start            ),
    .dbg_tx_en                          ( cfg_dbg_tx_en               ),
    .dbg_tx_num                         ( cfg_dbg_tx_num              ),
    .dbg_tx_dat                         ( cfg_dbg_tx_dat              ),
    .dbg_tx_done                        ( cfg_dbg_tx_done             ),
    .dbg_ser_en                         ( cfg_dbg_ser_en              ),
    .dbg_der_en                         ( cfg_dbg_der_en              ),

                // Inputs
    .cfg_prbs_tx_en                     ( cfg_prbs_tx_en              ),
    .cfg_auto_calib_en                  ( cfg_auto_calib_en           ),
    .cfg_start_calib_dly                ( cfg_start_calib_dly         ),
    .cfg_calib_extra_dly                ( cfg_calib_extra_dly         ),
    .rec_p_calib_req                    ( rec_p_calib_req             ),
    .rec_p_calib_ack                    ( rec_p_calib_ack             ),
    .auto_start_calib                   ( auto_start_calib            ),
    .lane_calib_done                    ( lane_calib_done             ),
    .auto_cal_done                      ( auto_cal_done               ),

    .auto_sleep_en                      ( auto_sleep_en               ),
    .scan_mode                          ( scan_mode                   ),
    .axis_clk_raw                       ( axis_clk_raw                ),
    .bclk_raw                           ( bclk_raw                    ),
    .rstn_raw                           ( rstn_raw                    ),
    .tdata                              ( tdata                       ),
    .tlast                              ( tlast                       ),
    .tvalid                             ( tvalid                      ),
    .send_stop_req                      ( send_stop_req               ),
    .send_restart_req                   ( send_restart_req            ),
    .lvds_ctrl_tx_en                    ( lvds_ctrl_tx_en             ),
    .cal_mode_en                        ( cal_mode_en                 ),
    .cal_mode_pat                       ( cal_mode_pat                ),
    .fc_stop_tx                         ( fc_stop_tx                  )
    );

lvds_tx_pad_wrap u_lvds_tx_pad_wrap(
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
    .scan_mode                          ( scan_mode                   ),
    .lvds_tx_bit_clk                    ( lvds_bclk                   ),
    .lvds_rstn_raw                      ( rstn_raw                    ),
    .lvds_tx_bits                       ( lvds_tx_bits[ 9:0]),

    .lvds_pad_ddr_en                    ( lvds_pad_ddr_en             ),
    .lvds_pad_inv_cp                    ( lvds_pad_inv_cp             ),
    .lvds_pad_rxen                      ( lvds_pad_rxen               ),
    .lvds_pad_tx_cm                     ( lvds_pad_tx_cm              ),
    .lvds_pad_txdrv                     ( lvds_pad_txdrv              ),
    .lvds_pad_txen                      ( lvds_pad_txen               ),
    .lvds_pad_bias_en                   ( lvds_pad_bias_en            ),
    .lvds_pad_rterm_en                  ( lvds_pad_rterm_en           ),
    .lvds_pad_rterm_val                 ( lvds_pad_rterm_val          ),
    .lvds_pad_rxcm_en                   ( lvds_pad_rxcm_en            ),
    .lvds_pad_sync_en                   ( lvds_pad_sync_en            )

    );

endmodule
