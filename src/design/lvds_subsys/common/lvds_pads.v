module lvds_pads #(
    parameter TX_SIDE = 1,
    parameter LVDS_PAD_NUM = 5
    )
( 
    //pad
    inout                               LVDS_CLK_N,
    inout                               LVDS_CLK_P,
    inout                               LVDS_DAT0_N,
    inout                               LVDS_DAT0_P,
    inout                               LVDS_DAT1_N,
    inout                               LVDS_DAT1_P,
    inout                               LVDS_DAT2_N,
    inout                               LVDS_DAT2_P,
    inout                               LVDS_DAT3_N,
    inout                               LVDS_DAT3_P,
    inout                               LVDS_DAT4_N,
    inout                               LVDS_DAT4_P,

    //misc interface
    input       [LVDS_PAD_NUM-1:0]      lvds_drv_clk,
    input       [LVDS_PAD_NUM-1:0]      lvds_drv_rstn,
    input       [1:0]                   lvds_d0_txda,
    input       [1:0]                   lvds_d1_txda,
    input       [1:0]                   lvds_d2_txda,
    input       [1:0]                   lvds_d3_txda,
    input       [1:0]                   lvds_d4_txda,
    input                               lvds_ck_txen,
    input                               lvds_ck_rxen,
    input                               lvds_d0_txen,
    input                               lvds_d0_rxen,
    input                               lvds_d1_txen,
    input                               lvds_d1_rxen,
    input                               lvds_d2_txen,
    input                               lvds_d2_rxen,
    input                               lvds_d3_txen,
    input                               lvds_d3_rxen,
    input                               lvds_d4_txen,
    input                               lvds_d4_rxen,

    //software config interface
    input                               lvds_ck_bias_en,
    input                               lvds_ck_rterm_en,
    input       [2:0]                   lvds_ck_rterm_val,
    input                               lvds_ck_rxcm_en,
    input       [3:0]                   lvds_ck_txdrv,
    input                               lvds_ck_tx_cm,

    input                               lvds_d0_bias_en,
    input                               lvds_d0_ddr_en,
    input                               lvds_d0_inv_cp,
    input                               lvds_d0_rterm_en,
    input       [2:0]                   lvds_d0_rterm_val,
    input                               lvds_d0_rxcm_en,
    input                               lvds_d0_sync_en,
    input       [3:0]                   lvds_d0_txdrv,
    input                               lvds_d0_tx_cm,

    input                               lvds_d1_bias_en,
    input                               lvds_d1_ddr_en,
    input                               lvds_d1_inv_cp,
    input                               lvds_d1_rterm_en,
    input       [2:0]                   lvds_d1_rterm_val,
    input                               lvds_d1_rxcm_en,
    input                               lvds_d1_sync_en,
    input       [3:0]                   lvds_d1_txdrv,
    input                               lvds_d1_tx_cm,

    input                               lvds_d2_bias_en,
    input                               lvds_d2_ddr_en,
    input                               lvds_d2_inv_cp,
    input                               lvds_d2_rterm_en,
    input       [2:0]                   lvds_d2_rterm_val,
    input                               lvds_d2_rxcm_en,
    input                               lvds_d2_sync_en,
    input       [3:0]                   lvds_d2_txdrv,
    input                               lvds_d2_tx_cm,

    input                               lvds_d3_bias_en,
    input                               lvds_d3_ddr_en,
    input                               lvds_d3_inv_cp,
    input                               lvds_d3_rterm_en,
    input       [2:0]                   lvds_d3_rterm_val,
    input                               lvds_d3_rxcm_en,
    input                               lvds_d3_sync_en,
    input       [3:0]                   lvds_d3_txdrv,
    input                               lvds_d3_tx_cm,

    input                               lvds_d4_bias_en,
    input                               lvds_d4_ddr_en,
    input                               lvds_d4_inv_cp,
    input                               lvds_d4_rterm_en,
    input       [2:0]                   lvds_d4_rterm_val,
    input                               lvds_d4_rxcm_en,
    input                               lvds_d4_sync_en,
    input       [3:0]                   lvds_d4_txdrv,
    input                               lvds_d4_tx_cm,

    output                              lvds_ck_rxda,
    output      [1:0]                   lvds_ck_rxda_s,
    output                              lvds_d0_rxda,
    output      [1:0]                   lvds_d0_rxda_s,
    output                              lvds_d1_rxda,
    output      [1:0]                   lvds_d1_rxda_s,
    output                              lvds_d2_rxda,
    output      [1:0]                   lvds_d2_rxda_s,
    output                              lvds_d3_rxda,
    output      [1:0]                   lvds_d3_rxda_s,
    output                              lvds_d4_rxda,
    output      [1:0]                   lvds_d4_rxda_s

);

CS_UMC28_BIDIR_LVDSH U_LVDS_CK(  
    // Outputs
    .RXDA                   ( lvds_ck_rxda                          ),
    .RXDA_S                 ( lvds_ck_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_CLK_P                            ),
    .PAD_N                  ( LVDS_CLK_N                            ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[0]                      ),
    .SYNC_EN                ( 1'b0                                  ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_ck_txdrv[3:0]                    ),
    .DDR_EN                 ( 1'b0                                  ),
    .TXEN                   ( lvds_ck_txen                          ),
    .TXDA                   ( {1'b0,{TX_SIDE ? lvds_drv_clk[0] : 1'b0}}),
    .CP                     ( 1'b0                                  ),
    .INV_CP                 ( 1'b0                                  ),
    .RXEN                   ( lvds_ck_rxen                          ),
    .RTERM_EN               ( lvds_ck_rterm_en                      ),
    .RTERM_VAL              ( lvds_ck_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_ck_rxcm_en                       ),
    .BIAS_EN                ( lvds_ck_bias_en                       ),
    .TX_CM                  ( lvds_ck_tx_cm                         )
);

CS_UMC28_BIDIR_LVDSH U_LVDS_D0(  
    // Outputs
    .RXDA                   ( lvds_d0_rxda                          ),
    .RXDA_S                 ( lvds_d0_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_DAT0_P                           ),
    .PAD_N                  ( LVDS_DAT0_N                           ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[0]                      ),
    .SYNC_EN                ( lvds_d0_sync_en                       ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_d0_txdrv[3:0]                    ),
    .DDR_EN                 ( lvds_d0_ddr_en                        ),
    .TXEN                   ( lvds_d0_txen                          ),
    .TXDA                   ( lvds_d0_txda[1:0]                     ),
    .CP                     ( lvds_drv_clk[0]                       ),
    .INV_CP                 ( lvds_d0_inv_cp                        ),
    .RXEN                   ( lvds_d0_rxen                          ),
    .RTERM_EN               ( lvds_d0_rterm_en                      ),
    .RTERM_VAL              ( lvds_d0_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_d0_rxcm_en                       ),
    .BIAS_EN                ( lvds_d0_bias_en                       ),
    .TX_CM                  ( lvds_d0_tx_cm                         )
);


CS_UMC28_BIDIR_LVDSH U_LVDS_D1(  
    // Outputs
    .RXDA                   ( lvds_d1_rxda                          ),
    .RXDA_S                 ( lvds_d1_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_DAT1_P                           ),
    .PAD_N                  ( LVDS_DAT1_N                           ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[1]                      ),
    .SYNC_EN                ( lvds_d1_sync_en                       ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_d1_txdrv[3:0]                    ),
    .DDR_EN                 ( lvds_d1_ddr_en                        ),
    .TXEN                   ( lvds_d1_txen                          ),
    .TXDA                   ( lvds_d1_txda[1:0]                     ),
    .CP                     ( lvds_drv_clk[1]                       ),
    .INV_CP                 ( lvds_d1_inv_cp                        ),
    .RXEN                   ( lvds_d1_rxen                          ),
    .RTERM_EN               ( lvds_d1_rterm_en                      ),
    .RTERM_VAL              ( lvds_d1_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_d1_rxcm_en                       ),
    .BIAS_EN                ( lvds_d1_bias_en                       ),
    .TX_CM                  ( lvds_d1_tx_cm                         )
);


CS_UMC28_BIDIR_LVDSH U_LVDS_D2(  
    // Outputs
    .RXDA                   ( lvds_d2_rxda                          ),
    .RXDA_S                 ( lvds_d2_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_DAT2_P                           ),
    .PAD_N                  ( LVDS_DAT2_N                           ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[2]                      ),
    .SYNC_EN                ( lvds_d2_sync_en                       ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_d2_txdrv[3:0]                    ),
    .DDR_EN                 ( lvds_d2_ddr_en                        ),
    .TXEN                   ( lvds_d2_txen                          ),
    .TXDA                   ( lvds_d2_txda[1:0]                     ),
    .CP                     ( lvds_drv_clk[2]                       ),
    .INV_CP                 ( lvds_d2_inv_cp                        ),
    .RXEN                   ( lvds_d2_rxen                          ),
    .RTERM_EN               ( lvds_d2_rterm_en                      ),
    .RTERM_VAL              ( lvds_d2_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_d2_rxcm_en                       ),
    .BIAS_EN                ( lvds_d2_bias_en                       ),
    .TX_CM                  ( lvds_d2_tx_cm                         )
);

CS_UMC28_BIDIR_LVDSH U_LVDS_D3(  
    // Outputs
    .RXDA                   ( lvds_d3_rxda                          ),
    .RXDA_S                 ( lvds_d3_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_DAT3_P                           ),
    .PAD_N                  ( LVDS_DAT3_N                           ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[3]                      ),
    .SYNC_EN                ( lvds_d3_sync_en                       ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_d3_txdrv[3:0]                    ),
    .DDR_EN                 ( lvds_d3_ddr_en                        ),
    .TXEN                   ( lvds_d3_txen                          ),
    .TXDA                   ( lvds_d3_txda[1:0]                     ),
    .CP                     ( lvds_drv_clk[3]                       ),
    .INV_CP                 ( lvds_d3_inv_cp                        ),
    .RXEN                   ( lvds_d3_rxen                          ),
    .RTERM_EN               ( lvds_d3_rterm_en                      ),
    .RTERM_VAL              ( lvds_d3_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_d3_rxcm_en                       ),
    .BIAS_EN                ( lvds_d3_bias_en                       ),
    .TX_CM                  ( lvds_d3_tx_cm                         )
);


CS_UMC28_BIDIR_LVDSH U_LVDS_D4(  
    // Outputs
    .RXDA                   ( lvds_d4_rxda                          ),
    .RXDA_S                 ( lvds_d4_rxda_s                        ),
    // Inouts
    .PAD_P                  ( LVDS_DAT4_P                           ),
    .PAD_N                  ( LVDS_DAT4_N                           ),
    // Inputs
    .RESET_N                ( lvds_drv_rstn[4]                      ),
    .SYNC_EN                ( lvds_d4_sync_en                       ),
    .VBIAS_SEL              ( 1'b0                                  ),
    .VBIAS_IN               ( 1'b0                                  ),
    .TXDRV                  ( lvds_d4_txdrv[3:0]                    ),
    .DDR_EN                 ( lvds_d4_ddr_en                        ),
    .TXEN                   ( lvds_d4_txen                          ),
    .TXDA                   ( lvds_d4_txda[1:0]                     ),
    .CP                     ( lvds_drv_clk[4]                       ),
    .INV_CP                 ( lvds_d4_inv_cp                        ),
    .RXEN                   ( lvds_d4_rxen                          ),
    .RTERM_EN               ( lvds_d4_rterm_en                      ),
    .RTERM_VAL              ( lvds_d4_rterm_val[2:0]                ),
    .RXCM_EN                ( lvds_d4_rxcm_en                       ),
    .BIAS_EN                ( lvds_d4_bias_en                       ),
    .TX_CM                  ( lvds_d4_tx_cm                         )
);


//enable it when model is ready SANAIOFS U_LVDS_D0_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT0_N));
//enable it when model is ready SANAIOFS U_LVDS_D0_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT0_P));
//enable it when model is ready SANAIOFS U_LVDS_D1_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT1_N));
//enable it when model is ready SANAIOFS U_LVDS_D1_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT1_P));
//enable it when model is ready SANAIOFS U_LVDS_D2_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT2_N));
//enable it when model is ready SANAIOFS U_LVDS_D2_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT2_P));
//enable it when model is ready SANAIOFS U_LVDS_D3_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT3_N));
//enable it when model is ready SANAIOFS U_LVDS_D3_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT3_P));
//enable it when model is ready SANAIOFS U_LVDS_D4_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT4_N));
//enable it when model is ready SANAIOFS U_LVDS_D4_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_DAT4_P));
//enable it when model is ready SANAIOFS U_LVDS_CK_AIO_N ( .AIO050(), .AIO250(), .ANAIO(LVDS_CLK_N ));
//enable it when model is ready SANAIOFS U_LVDS_CK_AIO_P ( .AIO050(), .AIO250(), .ANAIO(LVDS_CLK_P ));

endmodule
