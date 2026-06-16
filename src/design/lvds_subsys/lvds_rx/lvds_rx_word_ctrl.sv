
module lvds_rx_word_ctrl
import lvds_if_pkg::*;
(
    input                                           wclk,
    input                                           wrstn,
    input       [31:0]                              wdata_i,
    input                                           wdata_vld_i,
    input                                           sop_i,
    input                                           eop_i,
    input                                           cfg_ecc_correct,
    input       logic                               dbg_rx_en,

    input       logic                               bit_dec_err,
    output      lvds_rx_err_type                    rx_err_o,
    input       lvds_rx_err_type                    rx_err_ack,
    output      logic                               lvds_rx_df_push_en,
    output      lvds_rx_wf_data_type                lvds_rx_df_push_data

    );

logic   [31:0]                                  wdata_r;
logic                                           sop_r;
logic                                           eop_r;
logic                                           wdata_vld_r;
logic   [127:0]                                 data_pre;
logic                                           chk_en;
logic   [2:0]                                   chk_en_w;
logic                                           s_err_flag_w;
logic                                           m_err_flag_w;
logic   [AXIS_DATA_WIDTH-1:0]                   data_post_w;
logic   [AXIS_DATA_WIDTH-1:0]                   data_pre_mux;
logic   [7:0]                                   chk_pre_mux;
logic   [AXIS_DATA_WIDTH-1:0]                   data_post;
logic                                           s_err_flag;
logic                                           m_err_flag;
logic                                           idle_to_w0_d0_en;
logic                                           data_to_w0_d1_en;
logic                                           data_to_w0_d2_en;
logic                                           data_to_w1_d0_en;
logic                                           data_w0_to_idle;
logic                                           data_to_w1_d1_en;
logic                                           data_to_w1_d2_en;
logic                                           data_to_w2_d0_en;
logic                                           data_w1_to_idle;
logic                                           data_to_w2_d1_en;
logic                                           data_to_w2_d2_en;
logic                                           data_w2_to_idle_en;
logic                                           push_data_to_d1_en;
logic                                           data_post_vld;

typedef enum logic [1:0] {
    WF_IDLE,
    WF_D1,
    WF_D2
} wf_push_st_type;

wf_push_st_type                                 wf_push_cur_st;
wf_push_st_type                                 wf_push_next_st;

typedef enum logic [3:0] {
    RX_IDLE,
    RX_W0_D0,
    RX_W0_D1,
    RX_W0_D2,
    RX_W1_D0,
    RX_W1_D1,
    RX_W1_D2,
    RX_W2_D0,
    RX_W2_D1,
    RX_W2_D2
} rx_w_st_type;

rx_w_st_type                                    rx_w_cur_st;
rx_w_st_type                                    rx_w_next_st;
lvds_rx_err_type                                rx_err_lat;
lvds_rx_err_type                                rx_err_lat_set;
lvds_rx_err_type                                rx_err_lat_clr;
lvds_rx_err_type                                rx_err_lat_ack;

generate if(RX_WF_INPUT_PIPELINE_EN) begin:wf_input_pipeline
    always_ff @(posedge wclk or negedge wrstn)
        if(~wrstn) begin
            wdata_vld_r                         <= 'h0;
            wdata_r                             <= 'h0;
            sop_r                               <= 'h0;
            eop_r                               <= 'h0;
        end
        else begin
            wdata_vld_r                         <= wdata_vld_i;
            if(wdata_vld_i) begin
                wdata_r                             <= wdata_i;
                sop_r                               <= sop_i;
                eop_r                               <= eop_i;
            end
        end
end
else begin//bypass pipeline
    assign wdata_vld_r = wdata_vld_i;
    assign wdata_r  = wdata_i;
    assign sop_r    = sop_i;
    assign eop_r    = eop_i;
end
endgenerate

always_ff @(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        rx_w_cur_st                         <= RX_IDLE;
    end
    else begin
        rx_w_cur_st                         <= rx_w_next_st;
    end

assign idle_to_w0_d0_en                    = (rx_w_cur_st == RX_IDLE) & wdata_vld_r & sop_r;
assign data_to_w0_d1_en                    = (rx_w_cur_st == RX_W0_D0) & wdata_vld_r;
assign data_to_w0_d2_en                    = (rx_w_cur_st == RX_W0_D1) & wdata_vld_r;
assign data_to_w1_d0_en                    = (rx_w_cur_st == RX_W0_D2) & wdata_vld_r & ~eop_r;
assign data_w0_to_idle                     = (rx_w_cur_st == RX_W0_D2) & wdata_vld_r & eop_r;
assign data_to_w1_d1_en                    = (rx_w_cur_st == RX_W1_D0) & wdata_vld_r;
assign data_to_w1_d2_en                    = (rx_w_cur_st == RX_W1_D1) & wdata_vld_r;
assign data_to_w2_d0_en                    = (rx_w_cur_st == RX_W1_D2) & wdata_vld_r & ~eop_r;
assign data_w1_to_idle                     = (rx_w_cur_st == RX_W1_D2) & wdata_vld_r & eop_r;
assign data_to_w2_d1_en                    = (rx_w_cur_st == RX_W2_D0) & wdata_vld_r;
assign data_to_w2_d2_en                    = (rx_w_cur_st == RX_W2_D1) & wdata_vld_r;
assign data_w2_to_idle_en                  = (rx_w_cur_st == RX_W2_D2) & wdata_vld_r;

always_comb begin
    rx_w_next_st                        = RX_IDLE;
    case(rx_w_cur_st)
    RX_IDLE:
        if(idle_to_w0_d0_en)
            rx_w_next_st                        = RX_W0_D0;
        else
            rx_w_next_st                        = RX_IDLE;

    RX_W0_D0:
        if(data_to_w0_d1_en)
            rx_w_next_st                        = RX_W0_D1;
        else
            rx_w_next_st                        = RX_W0_D0;

    RX_W0_D1:
        if(data_to_w0_d2_en)
            rx_w_next_st                        = RX_W0_D2;
        else
            rx_w_next_st                        = RX_W0_D1;

    RX_W0_D2:
        if(data_to_w1_d0_en)
            rx_w_next_st                        = RX_W1_D0;
        else if(data_w0_to_idle)
            rx_w_next_st                        = RX_IDLE;
        else
            rx_w_next_st                        = RX_W0_D2;

    RX_W1_D0:
        if(data_to_w1_d1_en)
            rx_w_next_st                        = RX_W1_D1;
        else
            rx_w_next_st                        = RX_W1_D0;

    RX_W1_D1:
        if(data_to_w1_d2_en)
            rx_w_next_st                        = RX_W1_D2;
        else
            rx_w_next_st                        = RX_W1_D1;

    RX_W1_D2:
        if(data_to_w2_d0_en)
            rx_w_next_st                        = RX_W2_D0;
        else if(data_w1_to_idle)
            rx_w_next_st                        = RX_IDLE;
        else
            rx_w_next_st                        = RX_W1_D2;

    RX_W2_D0:
        if(data_to_w2_d1_en)
            rx_w_next_st                        = RX_W2_D1;
        else
            rx_w_next_st                        = RX_W2_D0;

    RX_W2_D1:
        if(data_to_w2_d2_en)
            rx_w_next_st                        = RX_W2_D2;
        else
            rx_w_next_st                        = RX_W2_D1;

    RX_W2_D2:
        if(data_w2_to_idle_en)
            rx_w_next_st                        = RX_IDLE;
        else
            rx_w_next_st                        = RX_W2_D2;

    endcase

end

//{w0[95-:32]} {w0[63-:32]} {w0[31-:32]} {ecc,w1[95-:24]}
//{w1[71-:32]} {w1[39-:32]} {w1[7:0],ecc,w2[95-:16]}
//{w2[79-:32]} {w2[47-:32]} {w2[15:0],ecc,eop} 

assign chk_en_w[0]                         = wdata_vld_r & (rx_w_cur_st == RX_W0_D2);
assign chk_en_w[1]                         = wdata_vld_r & (rx_w_cur_st == RX_W1_D2);
assign chk_en_w[2]                         = wdata_vld_r & (rx_w_cur_st == RX_W2_D2);

always_ff @(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        data_pre                            <= 'h0;
        chk_en                              <= 'h0;
        data_post                           <= '0;
        data_post_vld                       <= '0;
        s_err_flag                          <= '0;
        m_err_flag                          <= '0;
    end
    else begin

        if(wdata_vld_r & (rx_w_cur_st == RX_W1_D2))
            data_pre[127:0]                     <= {data_pre[0+:32+32+24],wdata_r[31-:16],8'h0,wdata_r[0+:16]};
        else if(wdata_vld_r & (rx_w_cur_st == RX_W2_D2))
            data_pre[127:0]                     <= {data_pre[0+:32+32+16],wdata_r[31-:24],24'h0};
        else if(wdata_vld_r)
            data_pre                            <= {data_pre[0+:96],wdata_r};

        chk_en                              <= |chk_en_w;
        data_post_vld                       <= chk_en;
        if(chk_en) begin
            data_post                           <= data_post_w;
            s_err_flag                          <= s_err_flag_w;
            m_err_flag                          <= m_err_flag_w;
        end

    end

assign data_pre_mux                        = chk_en ? data_pre[127-:96]  : '0;
assign chk_pre_mux                         = chk_en ? data_pre[127-96-:8]: '0;

DW_ecc #(
    .width                              ( AXIS_DATA_WIDTH             ),
    .chkbits                            ( 8                           ),
    .synd_sel                           ( 1                           )
    ) u_rd_ecc(
    .gen                                ( 1'b0                        ), 
    .correct_n                          ( cfg_ecc_correct             ), // correct data, active low
    .datain                             ( data_pre_mux                ), // 
    .chkin                              ( chk_pre_mux                 ), // 
    .err_detect                         ( s_err_flag_w                ), // single err flag
    .err_multpl                         ( m_err_flag_w                ), // multiple err flag
    .dataout                            ( data_post_w                 ), //
    .chkout                             (                             )  //
    );

//wfifo
always_ff @(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        wf_push_cur_st                      <= WF_IDLE;
    end
    else begin

        wf_push_cur_st                      <= wf_push_next_st;
    end

//data will transfert to app side no matter there is err 
//assign push_data_to_d1_en                  = data_post_vld & ((~s_err_flag & ~m_err_flag) | dbg_rx_en);
assign push_data_to_d1_en                  = data_post_vld;
always_comb begin
    wf_push_next_st                     = WF_IDLE;
    case(wf_push_cur_st)
        WF_IDLE:
            if(push_data_to_d1_en)
                wf_push_next_st                     = WF_D1;
            else 
                wf_push_next_st                     = WF_IDLE;

        WF_D1:
            wf_push_next_st                     = WF_D2;

        WF_D2:
            wf_push_next_st                     = WF_IDLE;

    endcase
end

always_comb begin
    lvds_rx_df_push_data                = '0;
    lvds_rx_df_push_en                  = 1'b0;
    case(wf_push_cur_st)
        WF_IDLE: begin
            lvds_rx_df_push_data.data           = data_post[AXIS_DATA_WIDTH-1-:32];
            lvds_rx_df_push_data.sop            = push_data_to_d1_en;
            lvds_rx_df_push_en                  = push_data_to_d1_en;
        end
        WF_D1: begin
            lvds_rx_df_push_data.data = data_post[AXIS_DATA_WIDTH-1-(32*1)-:32];
            lvds_rx_df_push_en                  = 1'b1;
        end
        WF_D2: begin
            lvds_rx_df_push_data.data           = data_post[AXIS_DATA_WIDTH-1-(32*2)-:32];
            lvds_rx_df_push_data.eop            = 1'b1;
            lvds_rx_df_push_en                  = 1'b1;
        end
    endcase
end

//err report
macro_sync2r u_syn_rx_err_ack[2:0](
    .ck                                 ( wclk                        ),
    .clb                                ( wrstn                       ),
    .d                                  ( {
                                            rx_err_ack.dec_err, 
                                            rx_err_ack.pkt_c_err, 
                                            rx_err_ack.pkt_nc_err 
                                            }),
    .o                                  ( {
                                            rx_err_lat_ack.dec_err, 
                                            rx_err_lat_ack.pkt_c_err, 
                                            rx_err_lat_ack.pkt_nc_err 
                                            })
    );

assign rx_err_lat_set.dec_err              = ~rx_err_lat_ack.dec_err & ~rx_err_lat.dec_err & bit_dec_err;
assign rx_err_lat_set.pkt_c_err            = ~rx_err_lat_ack.pkt_c_err & ~rx_err_lat.pkt_c_err & s_err_flag & data_post_vld;
assign rx_err_lat_set.pkt_nc_err           = ~rx_err_lat_ack.pkt_nc_err & ~rx_err_lat.pkt_nc_err & m_err_flag & data_post_vld;
assign rx_err_lat_clr.dec_err              = rx_err_lat_ack.dec_err & rx_err_lat.dec_err;
assign rx_err_lat_clr.pkt_c_err            = rx_err_lat_ack.pkt_c_err & rx_err_lat.pkt_c_err;
assign rx_err_lat_clr.pkt_nc_err           = rx_err_lat_ack.pkt_nc_err & rx_err_lat.pkt_nc_err;
assign rx_err_o                            = rx_err_lat;
always_ff @(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        rx_err_lat                          <= '0;
    end
    else begin

        if(rx_err_lat_clr.dec_err)
            rx_err_lat.dec_err    <= '0;
        else if(rx_err_lat_set.dec_err)
            rx_err_lat.dec_err    <= '1;

        if(rx_err_lat_clr.pkt_c_err)
            rx_err_lat.pkt_c_err  <= '0;
        else if(rx_err_lat_set.pkt_c_err)
            rx_err_lat.pkt_c_err  <= '1;

        if(rx_err_lat_clr.pkt_nc_err)
            rx_err_lat.pkt_nc_err <= '0;
        else if(rx_err_lat_set.pkt_nc_err)
            rx_err_lat.pkt_nc_err <= '1;

    end

endmodule

