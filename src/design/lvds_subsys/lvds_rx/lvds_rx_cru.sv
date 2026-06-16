
module lvds_rx_cru
import lvds_if_pkg::*;
(
    input                                           rstn_raw,
    input                                           axis_clk_raw,
    input                                           scan_mode,
    input                                           lvds_rx_ctrl_en,
    input       [6*8-1:0]                           delay_chain_ctrl,

    input                                           rx_bit_clk_inv_sel,
    input                                           rx_bit_clk_lvds,
    input       [ 9:0]                              rx_bits_lvds,

    input                                           cal_mode_en,
    input                                           auto_cal_start,
    output      logic                               rx_cal_mode_en_pos,
    output      logic                               lvds_rx_calib_clk,
    output      logic                               lvds_rx_calib_rstn,
    output      logic                               lvds_rx_calib_clk_div2,
    output      logic                               cal_mode_mask,

    output                                          lvds_rx_bit_clk,
    output      logic [ 9:0]                        lvds_rx_bits,
    output      logic                               lvds_rx_bit_rstn,
    output      logic                               axis_rstn,
    output      logic                               axis_clk,
    output      logic                               wclk,
    output      logic                               wrstn,
    output      logic                               wclk_tick,
    output      logic [LVDS_PAD_NUM-1:0]            lvds_rx_drv_clk,
    output      logic [LVDS_PAD_NUM-1:0]            lvds_rx_drv_rstn

    );

logic                                           calib_div_clk2;
logic                                           lvds_rx_ctrl_en_syn_axis;
logic   [ 9:0]                                  lvds_rx_bits_mux;
logic                                           lvds_rx_bit_clk_mux;
logic                                           lvds_rx_bit_clk_tmp_inv;
logic                                           lvds_rx_bit_clk_tmp;
logic                                           lvds_rx_ctrl_en_syn;
logic   [1:0]                                   wclk_bit_cnt;
logic                                           lvds_rx_bit_clk_dly;
logic                                           cal_mode_en_syn;
logic                                           auto_cal_start_syn;
logic   [1:0]                                   lvds_rx_calib_clk_en;
logic                                           cal_en_r;
logic                                           cal_en_w;

macro_inv u_lvds_rx_bit_clk_tmp_inv(.a(lvds_rx_bit_clk_tmp),.o(lvds_rx_bit_clk_tmp_inv));
macro_mux2 u_clk1_mux(.d0(lvds_rx_bit_clk_tmp), .d1(lvds_rx_bit_clk_tmp_inv), .s(rx_bit_clk_inv_sel), .o(lvds_rx_bit_clk_mux));
assign lvds_rx_bit_clk_tmp                 = rx_bit_clk_lvds;
assign lvds_rx_bits_mux                    = rx_bits_lvds;

generate
    for(genvar i= 0;i<LVDS_PAD_NUM ;i++) begin:INSTER_RX_BIT_DLY_CHAIN
        macro_delay_block u_rx_drv_clk_dly_chain(
    .scan_mode                          ( scan_mode                   ),
    .delay_ctrl                         ( delay_chain_ctrl[8*i+:8]    ),
    .delay_sig                          ( lvds_rx_bit_clk_mux         ),
    .delayed_out                        ( lvds_rx_drv_clk[i]          )
    );

        //lvds drv rstn
        macro_reset_sync2 u_lvds_drv_rstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( lvds_rx_drv_clk[i]          ),
    .reset_sync_n                       ( lvds_rx_drv_rstn[i]         )
    );

    end
endgenerate

macro_delay_block u_rx_clk_dly_chain(
    .scan_mode                          ( scan_mode                   ),
    .delay_ctrl                         ( delay_chain_ctrl[5*8+:8]    ),
    .delay_sig                          ( lvds_rx_bit_clk_mux         ),
    .delayed_out                        ( lvds_rx_bit_clk_dly         )
    );

//axis clk
macro_reset_sync2 u_rstn_syn_aclk(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( axis_clk_raw                ),
    .reset_sync_n                       ( axis_rstn                   )
    );

macro_sync2r u_lvds_rx_en_syn_aclk(  
    .ck                                 ( axis_clk_raw                ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( lvds_rx_ctrl_en             ),
    .o                                  ( lvds_rx_ctrl_en_syn_axis    )
    );

macro_preicg u_axis_clk_icg(  
    .te                                 ( scan_mode                   ),
    .ck                                 ( axis_clk_raw                ),
    .en                                 ( lvds_rx_ctrl_en_syn_axis    ),
    .ckg                                ( axis_clk                    )
    );

//lvds calib clk
macro_reset_sync2 u_lvds_rx_bit_rstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( lvds_rx_bit_clk_dly         ),
    .reset_sync_n                       ( lvds_rx_bit_rstn            )
    );

macro_sync2r u_syn_cal_en[1:0](  
    .ck                                 ( lvds_rx_bit_clk_dly         ),
    .clb                                ( lvds_rx_bit_rstn            ),
    .d                                  ( {cal_mode_en,auto_cal_start}),
    .o                                  ( {cal_mode_en_syn,auto_cal_start_syn})
    );

macro_sync2r u_syn_lvds_rx_ctrl_en(  
    .ck                                 ( lvds_rx_bit_clk_dly         ),
    .clb                                ( lvds_rx_bit_rstn            ),
    .d                                  ( lvds_rx_ctrl_en             ),
    .o                                  ( lvds_rx_ctrl_en_syn         )
    );

assign cal_mode_mask                       = cal_en_r;
assign cal_en_w                            = cal_mode_en_syn | auto_cal_start_syn;
always_ff @(posedge lvds_rx_bit_clk_dly or negedge lvds_rx_bit_rstn)
    if(~lvds_rx_bit_rstn)
        cal_en_r                            <= 1'b0;
    else
        cal_en_r                            <= cal_en_w;
assign rx_cal_mode_en_pos                  = ~cal_en_r & auto_cal_start_syn;

assign lvds_rx_calib_clk_en[0]             = lvds_rx_ctrl_en_syn & cal_mode_en_syn;
assign lvds_rx_calib_clk_en[1]             = lvds_rx_ctrl_en_syn & auto_cal_start_syn;
macro_preicg u_lvds_rx_calib_clk_icg(  
    .te                                 ( scan_mode                   ),
    .ck                                 ( lvds_rx_bit_clk_dly         ),
    .en                                 ( |lvds_rx_calib_clk_en       ),
    .ckg                                ( lvds_rx_calib_clk           )
    );

assign lvds_rx_calib_rstn                  = lvds_rx_bit_rstn;

//rx bit clk
macro_preicg u_lvds_rx_bit_clk_icg(  
    .te                                 ( scan_mode                   ),
    .ck                                 ( lvds_rx_bit_clk_dly         ),
    .en                                 ( lvds_rx_ctrl_en_syn         ),
    .ckg                                ( lvds_rx_bit_clk             )
    );

macro_reset_sync2 u_rx_wrstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( wclk                        ),
    .reset_sync_n                       ( wrstn                       )
    );

//lvds_rx_bits
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_bit_rstn)
    if(~lvds_rx_bit_rstn) begin
        lvds_rx_bits                        <= 'h0;
        wclk_tick                           <= 1'b0;
    end
    else begin
        lvds_rx_bits                        <= lvds_rx_bits_mux;
        wclk_tick                           <= (wclk_bit_cnt == 2'b0);
    end

`ifdef FOR_SIM_ONLY
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_bit_rstn)
    if(~lvds_rx_bit_rstn) begin
        wclk_bit_cnt                        = 2'b00;
    end
    else begin
        case(wclk_bit_cnt)
            2'b00:
                wclk_bit_cnt                        = 2'b01;
            2'b01:
                wclk_bit_cnt                        = 2'b11;
            2'b11:
                wclk_bit_cnt                        = 2'b10;
            2'b10:
                wclk_bit_cnt                        = 2'b00;
           default: wclk_bit_cnt = 2'b0;
       endcase
    end

`else
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_bit_rstn)
    if(~lvds_rx_bit_rstn) begin
        wclk_bit_cnt                        <= 2'b00;
    end
    else begin
       case(wclk_bit_cnt)
            2'b00:
                wclk_bit_cnt                        <= 2'b01;
            2'b01:
                wclk_bit_cnt                        <= 2'b11;
            2'b11:
                wclk_bit_cnt                        <= 2'b10;
            2'b10:
                wclk_bit_cnt                        <= 2'b00;
           default: wclk_bit_cnt <= 2'b0;
       endcase
    end

`endif

always_ff @(posedge lvds_rx_calib_clk or negedge lvds_rx_calib_rstn)
    if(~lvds_rx_calib_rstn)
        calib_div_clk2                      <= 1'b0;
    else
        calib_div_clk2                      <= ~calib_div_clk2;

assign wclk_bit_tmp                        = wclk_bit_cnt[1];

macro_buf u_wclk_buf( .a( wclk_bit_tmp), .o( wclk) );
assign lvds_rx_calib_clk_div2              = calib_div_clk2;

endmodule

