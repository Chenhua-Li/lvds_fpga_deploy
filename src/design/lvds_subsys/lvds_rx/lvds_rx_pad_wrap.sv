module lvds_rx_pad_wrap
import lvds_if_pkg::*;
(
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
    inout                                           LVDS_DAT4_P,
    
    output                                          lvds_rx_bit_clk_raw,
    output      [ 9:0]                              lvds_rx_bits,
    input       [LVDS_PAD_NUM-1:0]                  lvds_drv_clk,
    input       [LVDS_PAD_NUM-1:0]                  lvds_drv_rstn,

    input                                           lvds_pad_ddr_en,
    input                                           lvds_pad_inv_cp,
    input                                           lvds_pad_rxen,
    input                                           lvds_pad_tx_cm,
    input       [3:0]                               lvds_pad_txdrv,
    input                                           lvds_pad_txen,
    input                                           lvds_pad_bias_en,
    input                                           lvds_pad_rterm_en,
    input       [2:0]                               lvds_pad_rterm_val,
    input                                           lvds_pad_rxcm_en,
    input       lvds_pad_sync_en

    );


// Define inst wires here
logic                                           lvds_ck_rterm_en;
logic   [2:0]                                   lvds_ck_rterm_val;
logic   [3:0]                                   lvds_ck_txdrv;
logic                                           lvds_ck_rxen;
logic                                           lvds_ck_tx_cm;
logic                                           lvds_ck_txen;
logic                                           lvds_ck_bias_en;
logic                                           lvds_ck_rxcm_en;
logic                                           lvds_d0_ddr_en;
logic                                           lvds_d0_inv_cp;
logic                                           lvds_d0_rxen;
logic                                           lvds_d0_tx_cm;
logic   [1:0]                                   lvds_d0_txda;
logic   [3:0]                                   lvds_d0_txdrv;
logic                                           lvds_d0_txen;
logic                                           lvds_d0_bias_en;
logic                                           lvds_d0_rterm_en;
logic   [2:0]                                   lvds_d0_rterm_val;
logic                                           lvds_d0_rxcm_en;
logic                                           lvds_d0_sync_en;
logic                                           lvds_d1_ddr_en;
logic                                           lvds_d1_inv_cp;
logic                                           lvds_d1_rxen;
logic                                           lvds_d1_tx_cm;
logic   [1:0]                                   lvds_d1_txda;
logic   [3:0]                                   lvds_d1_txdrv;
logic                                           lvds_d1_txen;
logic                                           lvds_d2_ddr_en;
logic                                           lvds_d2_inv_cp;
logic                                           lvds_d2_rxen;
logic                                           lvds_d2_tx_cm;
logic   [1:0]                                   lvds_d2_txda;
logic   [3:0]                                   lvds_d2_txdrv;
logic                                           lvds_d2_txen;
logic                                           lvds_d3_ddr_en;
logic                                           lvds_d3_inv_cp;
logic                                           lvds_d3_rxen;
logic                                           lvds_d3_tx_cm;
logic   [1:0]                                   lvds_d3_txda;
logic   [3:0]                                   lvds_d3_txdrv;
logic                                           lvds_d3_txen;
logic                                           lvds_d4_ddr_en;
logic                                           lvds_d4_inv_cp;
logic                                           lvds_d4_rxen;
logic                                           lvds_d4_tx_cm;
logic   [1:0]                                   lvds_d4_txda;
logic   [3:0]                                   lvds_d4_txdrv;
logic                                           lvds_d4_txen;
logic                                           lvds_d1_bias_en;
logic                                           lvds_d1_rterm_en;
logic   [2:0]                                   lvds_d1_rterm_val;
logic                                           lvds_d1_rxcm_en;
logic                                           lvds_d1_sync_en;
logic                                           lvds_d2_bias_en;
logic                                           lvds_d2_rterm_en;
logic   [2:0]                                   lvds_d2_rterm_val;
logic                                           lvds_d2_rxcm_en;
logic                                           lvds_d2_sync_en;
logic                                           lvds_d3_bias_en;
logic                                           lvds_d3_rterm_en;
logic   [2:0]                                   lvds_d3_rterm_val;
logic                                           lvds_d3_rxcm_en;
logic                                           lvds_d3_sync_en;
logic                                           lvds_d4_bias_en;
logic                                           lvds_d4_rterm_en;
logic   [2:0]                                   lvds_d4_rterm_val;
logic                                           lvds_d4_rxcm_en;
logic                                           lvds_d4_sync_en;
logic   [1:0]                                   lvds_d0_rxda_s;
logic   [1:0]                                   lvds_d1_rxda_s;
logic   [1:0]                                   lvds_d2_rxda_s;
logic   [1:0]                                   lvds_d3_rxda_s;
logic   [1:0]                                   lvds_d4_rxda_s;

assign lvds_d0_txda[1:0]                   = 2'b0;
assign lvds_d1_txda[1:0]                   = 2'b0;
assign lvds_d2_txda[1:0]                   = 2'b0;
assign lvds_d3_txda[1:0]                   = 2'b0;
assign lvds_d4_txda[1:0]                   = 2'b0;

assign lvds_ck_rterm_en                    = lvds_pad_rterm_en;
assign lvds_ck_rterm_val                   = lvds_pad_rterm_val;
assign lvds_ck_txdrv                       = lvds_pad_txdrv;
assign lvds_ck_rxen                        = lvds_pad_rxen;
assign lvds_ck_tx_cm                       = lvds_pad_tx_cm;
assign lvds_ck_txen                        = lvds_pad_txen;
assign lvds_ck_bias_en                     = lvds_pad_bias_en;
assign lvds_ck_rxcm_en                     = lvds_pad_rxcm_en;

assign lvds_d0_ddr_en                      = lvds_pad_ddr_en;
assign lvds_d0_inv_cp                      = lvds_pad_inv_cp;
assign lvds_d0_rxen                        = lvds_pad_rxen;
assign lvds_d0_tx_cm                       = lvds_pad_tx_cm;
assign lvds_d0_txdrv                       = lvds_pad_txdrv;
assign lvds_d0_txen                        = lvds_pad_txen;
assign lvds_d0_bias_en                     = lvds_pad_bias_en;
assign lvds_d0_rterm_en                    = lvds_pad_rterm_en;
assign lvds_d0_rterm_val                   = lvds_pad_rterm_val;
assign lvds_d0_rxcm_en                     = lvds_pad_rxcm_en;
assign lvds_d0_sync_en                     = lvds_pad_sync_en;

assign lvds_d1_ddr_en                      = lvds_pad_ddr_en;
assign lvds_d1_inv_cp                      = lvds_pad_inv_cp;
assign lvds_d1_rxen                        = lvds_pad_rxen;
assign lvds_d1_tx_cm                       = lvds_pad_tx_cm;
assign lvds_d1_txdrv                       = lvds_pad_txdrv;
assign lvds_d1_txen                        = lvds_pad_txen;
assign lvds_d1_bias_en                     = lvds_pad_bias_en;
assign lvds_d1_rterm_en                    = lvds_pad_rterm_en;
assign lvds_d1_rterm_val                   = lvds_pad_rterm_val;
assign lvds_d1_rxcm_en                     = lvds_pad_rxcm_en;
assign lvds_d1_sync_en                     = lvds_pad_sync_en;

assign lvds_d2_ddr_en                      = lvds_pad_ddr_en;
assign lvds_d2_inv_cp                      = lvds_pad_inv_cp;
assign lvds_d2_rxen                        = lvds_pad_rxen;
assign lvds_d2_tx_cm                       = lvds_pad_tx_cm;
assign lvds_d2_txdrv                       = lvds_pad_txdrv;
assign lvds_d2_txen                        = lvds_pad_txen;
assign lvds_d2_bias_en                     = lvds_pad_bias_en;
assign lvds_d2_rterm_en                    = lvds_pad_rterm_en;
assign lvds_d2_rterm_val                   = lvds_pad_rterm_val;
assign lvds_d2_rxcm_en                     = lvds_pad_rxcm_en;
assign lvds_d2_sync_en                     = lvds_pad_sync_en;

assign lvds_d3_ddr_en                      = lvds_pad_ddr_en;
assign lvds_d3_inv_cp                      = lvds_pad_inv_cp;
assign lvds_d3_rxen                        = lvds_pad_rxen;
assign lvds_d3_tx_cm                       = lvds_pad_tx_cm;
assign lvds_d3_txdrv                       = lvds_pad_txdrv;
assign lvds_d3_txen                        = lvds_pad_txen;
assign lvds_d3_bias_en                     = lvds_pad_bias_en;
assign lvds_d3_rterm_en                    = lvds_pad_rterm_en;
assign lvds_d3_rterm_val                   = lvds_pad_rterm_val;
assign lvds_d3_rxcm_en                     = lvds_pad_rxcm_en;
assign lvds_d3_sync_en                     = lvds_pad_sync_en;

assign lvds_d4_ddr_en                      = lvds_pad_ddr_en;
assign lvds_d4_inv_cp                      = lvds_pad_inv_cp;
assign lvds_d4_rxen                        = lvds_pad_rxen;
assign lvds_d4_tx_cm                       = lvds_pad_tx_cm;
assign lvds_d4_txdrv                       = lvds_pad_txdrv;
assign lvds_d4_txen                        = lvds_pad_txen;
assign lvds_d4_bias_en                     = lvds_pad_bias_en;
assign lvds_d4_rterm_en                    = lvds_pad_rterm_en;
assign lvds_d4_rterm_val                   = lvds_pad_rterm_val;
assign lvds_d4_rxcm_en                     = lvds_pad_rxcm_en;
assign lvds_d4_sync_en                     = lvds_pad_sync_en;
assign lvds_rx_bits                        = {
    lvds_d4_rxda_s,
    lvds_d3_rxda_s,
    lvds_d2_rxda_s,
    lvds_d1_rxda_s,
    lvds_d0_rxda_s
    };

lvds_pads #( .TX_SIDE(0))
    u_lvds_rx_pad(
            // Outputs
    .lvds_ck_rxda                       ( lvds_rx_bit_clk_raw         ),
    .lvds_ck_rxda_s                     (                             ),
    .lvds_d0_rxda                       (                             ),
    .lvds_d0_rxda_s                     ( lvds_d0_rxda_s              ),
    .lvds_d1_rxda                       (                             ),
    .lvds_d1_rxda_s                     ( lvds_d1_rxda_s              ),
    .lvds_d2_rxda                       (                             ),
    .lvds_d2_rxda_s                     ( lvds_d2_rxda_s              ),
    .lvds_d3_rxda                       (                             ),
    .lvds_d3_rxda_s                     ( lvds_d3_rxda_s              ),
    .lvds_d4_rxda                       (                             ),
    .lvds_d4_rxda_s                     ( lvds_d4_rxda_s              ),
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
    .lvds_drv_clk                       ( lvds_drv_clk                ),
    .lvds_drv_rstn                      ( lvds_drv_rstn               ),
    .lvds_d0_txda                       ( lvds_d0_txda[1:0]           ),
    .lvds_d1_txda                       ( lvds_d1_txda[1:0]           ),
    .lvds_d2_txda                       ( lvds_d2_txda[1:0]           ),
    .lvds_d3_txda                       ( lvds_d3_txda[1:0]           ),
    .lvds_d4_txda                       ( lvds_d4_txda[1:0]           ),
    .lvds_ck_txen                       ( lvds_ck_txen                ),
    .lvds_ck_rxen                       ( lvds_ck_rxen                ),
    .lvds_d0_txen                       ( lvds_d0_txen                ),
    .lvds_d0_rxen                       ( lvds_d0_rxen                ),
    .lvds_d1_txen                       ( lvds_d1_txen                ),
    .lvds_d1_rxen                       ( lvds_d1_rxen                ),
    .lvds_d2_txen                       ( lvds_d2_txen                ),
    .lvds_d2_rxen                       ( lvds_d2_rxen                ),
    .lvds_d3_txen                       ( lvds_d3_txen                ),
    .lvds_d3_rxen                       ( lvds_d3_rxen                ),
    .lvds_d4_txen                       ( lvds_d4_txen                ),
    .lvds_d4_rxen                       ( lvds_d4_rxen                ),
    .lvds_ck_bias_en                    ( lvds_ck_bias_en             ),
    .lvds_ck_rterm_en                   ( lvds_ck_rterm_en            ),
    .lvds_ck_rterm_val                  ( lvds_ck_rterm_val[2:0]      ),
    .lvds_ck_rxcm_en                    ( lvds_ck_rxcm_en             ),
    .lvds_ck_txdrv                      ( lvds_ck_txdrv[3:0]          ),
    .lvds_ck_tx_cm                      ( lvds_ck_tx_cm               ),
    .lvds_d0_bias_en                    ( lvds_d0_bias_en             ),
    .lvds_d0_ddr_en                     ( lvds_d0_ddr_en              ),
    .lvds_d0_inv_cp                     ( lvds_d0_inv_cp              ),
    .lvds_d0_rterm_en                   ( lvds_d0_rterm_en            ),
    .lvds_d0_rterm_val                  ( lvds_d0_rterm_val[2:0]      ),
    .lvds_d0_rxcm_en                    ( lvds_d0_rxcm_en             ),
    .lvds_d0_sync_en                    ( lvds_d0_sync_en             ),
    .lvds_d0_txdrv                      ( lvds_d0_txdrv[3:0]          ),
    .lvds_d0_tx_cm                      ( lvds_d0_tx_cm               ),
    .lvds_d1_bias_en                    ( lvds_d1_bias_en             ),
    .lvds_d1_ddr_en                     ( lvds_d1_ddr_en              ),
    .lvds_d1_inv_cp                     ( lvds_d1_inv_cp              ),
    .lvds_d1_rterm_en                   ( lvds_d1_rterm_en            ),
    .lvds_d1_rterm_val                  ( lvds_d1_rterm_val[2:0]      ),
    .lvds_d1_rxcm_en                    ( lvds_d1_rxcm_en             ),
    .lvds_d1_sync_en                    ( lvds_d1_sync_en             ),
    .lvds_d1_txdrv                      ( lvds_d1_txdrv[3:0]          ),
    .lvds_d1_tx_cm                      ( lvds_d1_tx_cm               ),
    .lvds_d2_bias_en                    ( lvds_d2_bias_en             ),
    .lvds_d2_ddr_en                     ( lvds_d2_ddr_en              ),
    .lvds_d2_inv_cp                     ( lvds_d2_inv_cp              ),
    .lvds_d2_rterm_en                   ( lvds_d2_rterm_en            ),
    .lvds_d2_rterm_val                  ( lvds_d2_rterm_val[2:0]      ),
    .lvds_d2_rxcm_en                    ( lvds_d2_rxcm_en             ),
    .lvds_d2_sync_en                    ( lvds_d2_sync_en             ),
    .lvds_d2_txdrv                      ( lvds_d2_txdrv[3:0]          ),
    .lvds_d2_tx_cm                      ( lvds_d2_tx_cm               ),
    .lvds_d3_bias_en                    ( lvds_d3_bias_en             ),
    .lvds_d3_ddr_en                     ( lvds_d3_ddr_en              ),
    .lvds_d3_inv_cp                     ( lvds_d3_inv_cp              ),
    .lvds_d3_rterm_en                   ( lvds_d3_rterm_en            ),
    .lvds_d3_rterm_val                  ( lvds_d3_rterm_val[2:0]      ),
    .lvds_d3_rxcm_en                    ( lvds_d3_rxcm_en             ),
    .lvds_d3_sync_en                    ( lvds_d3_sync_en             ),
    .lvds_d3_txdrv                      ( lvds_d3_txdrv[3:0]          ),
    .lvds_d3_tx_cm                      ( lvds_d3_tx_cm               ),
    .lvds_d4_bias_en                    ( lvds_d4_bias_en             ),
    .lvds_d4_ddr_en                     ( lvds_d4_ddr_en              ),
    .lvds_d4_inv_cp                     ( lvds_d4_inv_cp              ),
    .lvds_d4_rterm_en                   ( lvds_d4_rterm_en            ),
    .lvds_d4_rterm_val                  ( lvds_d4_rterm_val[2:0]      ),
    .lvds_d4_rxcm_en                    ( lvds_d4_rxcm_en             ),
    .lvds_d4_sync_en                    ( lvds_d4_sync_en             ),
    .lvds_d4_txdrv                      ( lvds_d4_txdrv[3:0]          ),
    .lvds_d4_tx_cm                      ( lvds_d4_tx_cm               )
    );

endmodule
