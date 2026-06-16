module lvds_tx_cru(
    input       logic                               tx_word_ctrl_idle,
    input       logic                               axis_data_vld,
    input       logic                               switch_clk_req,
    output      logic                               calib_clk,
    output      logic                               calib_rstn,
    input       logic                               cfg_auto_calib_en,
    input                                           scan_mode,
    input                                           bclk_raw,
    input                                           rstn_raw,
    input                                           axis_clk_raw,
    input                                           lvds_ctrl_tx_en,
    input                                           auto_sleep_en,
    input                                           send_stop_req,
    input                                           send_restart_req,
    input                                           a_wfifo_empty,
    output                                          axis_rstn,
    output                                          axis_clk,
    output                                          bclk,
    output                                          brstn,
    output                                          wclk,
    output                                          wrstn,
    output      logic                               wclk_tick

    );

logic   [1:0]                                   div_cnt_bclk;
logic   [7:0]                                   idle_cnt;
logic                                           a_wfifo_empty_syn;
logic                                           idle_cnt_inc_en;
logic                                           sleep_time_hit;
logic                                           in_sleep_st;
logic                                           auto_sleep_en_syn;
logic                                           in_sleep_st_set;
logic                                           in_sleep_st_clr;
logic                                           in_sleep_st_dis;
logic   [2:0]                                   in_sleep_st_wakeup;
logic                                           bclk_en;
logic                                           bclk_g;
logic                                           bclk_div8;
logic                                           tx_word_ctrl_idle_syn;
logic                                           send_stop_req_syn;
logic                                           send_restart_req_syn;
logic                                           send_stop_req_syn_r;
logic                                           send_restart_req_syn_r;
logic                                           send_stop_pos;
logic                                           send_restart_pos;

macro_sync2r u_syn_auto_sleep_en(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( auto_sleep_en               ),
    .o                                  ( auto_sleep_en_syn           )
    );

macro_sync2r u_syn_a_wfifo_empty(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( a_wfifo_empty               ),
    .o                                  ( a_wfifo_empty_syn           )
    );

macro_sync2r u_syn_tx_word_ctrl_idle(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( tx_word_ctrl_idle           ),
    .o                                  ( tx_word_ctrl_idle_syn       )
    );


macro_sync2r u_tx_flow_ctrl_syn[1:0](  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( {send_stop_req,send_restart_req}),
    .o                                  ( {send_stop_req_syn,send_restart_req_syn})
    );

assign idle_cnt_inc_en                     = a_wfifo_empty_syn & auto_sleep_en_syn & tx_word_ctrl_idle_syn & ~axis_data_vld & ~in_sleep_st & ~send_stop_pos & ~send_restart_pos;
assign sleep_time_hit                      = &idle_cnt;
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        idle_cnt                            <= 'h0;
        send_stop_req_syn_r    <= 0;
        send_restart_req_syn_r <= 0;
    end
    else begin

        if(idle_cnt_inc_en) begin
            if(~sleep_time_hit)
                idle_cnt                            <= idle_cnt + 1;
        end
        else begin
            idle_cnt                            <= 'h0;
        end

        send_stop_req_syn_r    <= send_stop_req_syn;
        send_restart_req_syn_r <= send_restart_req_syn & ~send_stop_req_syn;
    end

assign send_stop_pos                       = ~send_stop_req_syn_r & send_stop_req_syn;
assign send_restart_pos                    = ~send_restart_req_syn_r & send_restart_req_syn & ~send_stop_req_syn;
assign in_sleep_st_set                     = idle_cnt_inc_en & sleep_time_hit;
assign in_sleep_st_dis                     = ~auto_sleep_en_syn;
assign in_sleep_st_wakeup[0]               = axis_data_vld & in_sleep_st;
assign in_sleep_st_wakeup[1]               = send_stop_pos & in_sleep_st;
assign in_sleep_st_wakeup[2]               = send_restart_pos & in_sleep_st;
assign in_sleep_st_clr                     = in_sleep_st_dis | (|in_sleep_st_wakeup);
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        in_sleep_st                         <= 'h0;
    end
    else if(in_sleep_st_clr)
        in_sleep_st                         <= 'h0;
    else if(in_sleep_st_set)
        in_sleep_st                         <= 'h1;

macro_reset_sync2 u_rstn_syn_bclk(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( bclk_raw                    ),
    .reset_sync_n                       ( brstn                       )
    );

macro_reset_sync2 u_rstn_syn_aclk(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( axis_clk_raw                ),
    .reset_sync_n                       ( axis_rstn                   )
    );

macro_reset_sync2 u_rstn_syn_wclk(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( wclk                        ),
    .reset_sync_n                       ( wrstn                       )
    );

macro_sync2r u_lvds_tx_en_syn_bclk(  
    .ck                                 ( bclk_raw                    ),
    .clb                                ( brstn                       ),
    .d                                  ( lvds_ctrl_tx_en             ),
    .o                                  ( lvds_ctrl_tx_en_syn_bclk    )
    );

macro_sync2r u_lvds_tx_en_syn_aclk(  
    .ck                                 ( axis_clk_raw                ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( lvds_ctrl_tx_en             ),
    .o                                  ( lvds_ctrl_tx_en_syn_aclk    )
    );

macro_sync2r u_syn_in_sleep_st(  
    .ck                                 ( bclk_raw                    ),
    .clb                                ( brstn                       ),
    .d                                  ( in_sleep_st                 ),
    .o                                  ( in_sleep_st_syn_bclk        )
    );

assign bclk_en                             = lvds_ctrl_tx_en_syn_bclk & ~in_sleep_st_syn_bclk;
macro_preicg u_lvds_tx_bclk_icg(  
    .te                                 ( scan_mode                   ),
    .ck                                 ( bclk_raw                    ),
    .en                                 ( bclk_en                     ),
    .ckg                                ( bclk_g                      )
    );

macro_preicg u_lvds_tx_aclk_icg(  
    .te                                 ( scan_mode                   ),
    .ck                                 ( axis_clk_raw                ),
    .en                                 ( lvds_ctrl_tx_en_syn_aclk    ),
    .ckg                                ( axis_clk                    )
    );

macro_clk_div8 u_macro_clk_div8(
    .test_en                            ( scan_mode                   ),
    .rst_n                              ( brstn                       ),
    .rst_n_sync                         (                             ),
    .clk_in                             ( bclk_g                      ),
    .clk_out0                           (                             ),  //div2
    .clk_out1                           (                             ),  //div4
    .clk_out2                           ( bclk_div8                   )   //div8
    );

macro_smooth_mux #(
    .SYNC_EN                            ( 1                           ), 
    .ASET_EN                            ( 0                           ) 
    ) u_bclk_mux(
    .rst_n                              ( rstn_raw                    ) ,
    .clk0                               ( bclk_div8                   ) ,
    .clk1                               ( bclk_g                      ) ,
    .enable                             ( switch_clk_req | ~cfg_auto_calib_en) ,
    .test_en                            ( scan_mode                   ) ,
    .clkout                             ( bclk_mux                    )
    );

macro_buf u_calib_clk_buf(
    .a                                  ( bclk_div8                   ),
    .o                                  ( calib_clk                   )
    );

macro_reset_sync2 u_rstn_syn_bclk_div8(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( calib_clk                   ),
    .reset_sync_n                       ( calib_rstn                  )
    );

always_ff @(posedge bclk_mux or negedge brstn)
    if(~brstn) begin
        wclk_tick                           <= 1'b0;
    end
    else begin
        wclk_tick                           <= div_cnt_bclk == 2'b00;
    end

`ifdef FOR_SIM_ONLY

always_ff @(posedge bclk_mux or negedge brstn)
    if(~brstn) begin
        div_cnt_bclk                        = 2'b0;
    end
    else begin 
        case(div_cnt_bclk)
            2'b00:
                div_cnt_bclk                        = 2'b01;
            2'b01:
                div_cnt_bclk                        = 2'b11;
            2'b11:
                div_cnt_bclk                        = 2'b10;
            2'b10:
                div_cnt_bclk                        = 2'b00;
            default:
                div_cnt_bclk                        = 2'b00;
        endcase
    end

`else//for synthesis

always_ff @(posedge bclk_mux or negedge brstn)
    if(~brstn) begin
        div_cnt_bclk                        <= 2'b0;
    end
    else begin 
        case(div_cnt_bclk)
            2'b00:
                div_cnt_bclk                        <= 2'b01;
            2'b01:
                div_cnt_bclk                        <= 2'b11;
            2'b11:
                div_cnt_bclk                        <= 2'b10;
            2'b10:
                div_cnt_bclk                        <= 2'b00;
            default:
                div_cnt_bclk                        <= 2'b00;
        endcase
    end
`endif

macro_buf u_wclk_buf(
    .a                                  ( div_cnt_bclk[1]             ),
    .o                                  ( wclk                        )
    );

assign bclk                                = bclk_mux;

endmodule

