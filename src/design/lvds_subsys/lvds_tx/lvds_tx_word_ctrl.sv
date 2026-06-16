
module lvds_tx_word_ctrl
    import lvds_if_pkg::*;
(
    input                                           wclk,
    input                                           wrstn,
    input                                           lvds_ctrl_tx_en,
    input                                           tx_calib_busy,
    output      logic                               tx_word_ctrl_idle,

    //dbg
    input       logic                               dbg_ser_en,
    input       logic                               dbg_der_en,
    
    //wf_if
    output                                          wf_pop_en,
    input       lvds_tx_wf_data_type                wf_pop_data,
    input       logic                               wf_fifo_empty,
    //fc_if
    input                                           send_stop_req,
    input                                           send_restart_req,
    input                                           fc_stop_tx,
    output      logic [35:0]                        pre_enc_data

    );

typedef enum logic [3:0] {
    TX_IDLE,    
    TX_W0_DATA0,
    TX_W0_DATA1,
    TX_W0_DATA2,
    TX_W1_DATA0,
    TX_W1_DATA1,
    TX_W1_DATA2,
    TX_W2_DATA0,
    TX_W2_DATA1,
    TX_W2_DATA2,
    TX_W2_EOP
} lvds_tx_w_st_type;

logic                                           send_stop_req_syn;
logic                                           send_restart_req_syn;
logic                                           send_stop_req_syn_r;
logic                                           send_restart_req_syn_r;
logic                                           send_stop_pos;
logic                                           send_restart_pos;
logic                                           fc_stop_tx_syn;
logic   [35:0]                                  pre_enc_data_w;
logic                                           send_restart_vld_clr;
logic                                           send_stop_vld_clr;
logic                                           send_restart_vld;
logic                                           send_stop_vld;
logic                                           wf_data_vld;
logic   [7:0]                                   wf_pop_en_w;
logic   [15:0]                                  wf_data_rem;
logic                                           tx_calib_busy_syn;
logic   [95:0]                                  wf_pop_data_r;
logic   [95:0]                                  wf_pop_data_mux;
logic                                           wf_pop_sop_r;
logic                                           idle_to_w0_w0_en;
logic                                           data_to_w0_d1_en;
logic                                           data_to_w0_d2_en;
logic                                           data_w0_to_idle_en;
logic                                           data_to_w1_d0_en;
logic                                           data_to_w1_d1_en;
logic                                           data_to_w1_d2_en;
logic                                           data_w1_to_idle_en;
logic                                           data_to_w2_d0_en;
logic                                           data_to_w2_d1_en;
logic                                           data_to_w2_d2_en;
logic                                           data_w2_to_idle_en;
logic                                           data_w2_to_eop_en;
logic   [7:0]                                   ecc_r;
logic   [7:0]                                   ecc_w;
logic                                           rx_need_wait_flag;
lvds_tx_w_st_type                               tx_w_cur_st;
lvds_tx_w_st_type                               tx_w_next_st;
logic   [6:0]                                   wf_pop_w0_lat;
logic   [5:0]                                   wf_pop_w1_lat;
logic   [5:0]                                   wf_pop_w2_lat;
logic   [1:0]                                   wf_data_vld_dly;
logic                                           dbg_ser_en_syn;
logic                                           dbg_der_en_syn;


//--------------send_stop/restart if
macro_sync2r u_tx_flow_ctrl_syn[5:0](  
    .ck                                 ( wclk                        ),
    .clb                                ( wrstn                       ),
    .d                                  ( {dbg_ser_en,dbg_der_en,fc_stop_tx,send_stop_req,send_restart_req,tx_calib_busy}),
    .o                                  ( {dbg_ser_en_syn,dbg_der_en_syn,fc_stop_tx_syn,send_stop_req_syn,send_restart_req_syn,tx_calib_busy_syn})
    );

always_ff@(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        tx_word_ctrl_idle                   <= '0;
        send_stop_req_syn_r                 <= 1'b0;
        send_restart_req_syn_r              <= 1'b0;
    end
    else begin
        tx_word_ctrl_idle                   <= (tx_w_cur_st == TX_IDLE) & ~tx_calib_busy_syn;
        send_stop_req_syn_r                 <= send_stop_req_syn;
        send_restart_req_syn_r              <= send_restart_req_syn & ~send_stop_req_syn & rx_need_wait_flag;
    end

assign send_stop_pos                       = ~send_stop_req_syn_r & send_stop_req_syn;
assign send_restart_pos                    = ~send_restart_req_syn_r & send_restart_req_syn & ~send_stop_req_syn & rx_need_wait_flag;
assign send_stop_vld_clr                   = send_stop_vld;
assign send_restart_vld_clr                = send_restart_vld;

always_ff@(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        send_stop_vld                       <= 1'b0;
        send_restart_vld                    <= 1'b0;
        rx_need_wait_flag                   <= 1'b0;
    end
    else begin
        if(send_stop_pos)
            send_stop_vld                       <= 1'b1;
        else if(send_stop_vld_clr)
            send_stop_vld                       <= 1'b0;

        if(send_restart_pos)
            send_restart_vld                    <= 1'b1;
        else if(send_restart_vld_clr)
            send_restart_vld                    <= 1'b0;

        if(send_stop_vld)
            rx_need_wait_flag                   <= 1'b1;
        else if(send_restart_vld)
            rx_need_wait_flag                   <= 1'b0;
    end

//--------------wfifo

assign wf_pop_en                           = |wf_pop_en_w;
generate if(TX_WF_INPUT_PIPELINE_EN) begin
    assign wf_pop_en_w[0]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & ~fc_stop_tx_syn & ~wf_fifo_empty & ~wf_data_vld & (tx_w_cur_st == TX_IDLE);
    assign wf_pop_en_w[1]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & ~fc_stop_tx_syn & ~wf_fifo_empty & (tx_w_cur_st != TX_W2_DATA1) & ~send_stop_vld & ~send_restart_vld;
    assign wf_pop_en_w[2]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & wf_data_vld & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_IDLE);
    assign wf_pop_en_w[3]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & wf_data_vld & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_W0_DATA2);
    assign wf_pop_en_w[4]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & wf_data_vld & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_W1_DATA2);
    assign wf_pop_en_w[5]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_W0_DATA0);
    assign wf_pop_en_w[6]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_W1_DATA0);
    assign wf_pop_en_w[7]     = ~tx_calib_busy_syn & lvds_ctrl_tx_en & fc_stop_tx_syn & ~wf_fifo_empty & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st == TX_W2_DATA0);

    assign wf_pop_w0_lat[0] = wf_pop_en_w[0];
    assign wf_pop_w0_lat[1] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W0_DATA1);
    assign wf_pop_w0_lat[2] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W0_DATA2) & ~wf_data_vld;
    assign wf_pop_w0_lat[3] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W1_DATA1);
    assign wf_pop_w0_lat[4] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W1_DATA2) & ~wf_data_vld;
    assign wf_pop_w0_lat[5] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W2_DATA2);
    assign wf_pop_w0_lat[6] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W2_EOP);

    assign wf_pop_w1_lat[0] = wf_pop_en_w[1] & wf_data_vld & (tx_w_cur_st == TX_IDLE);
    assign wf_pop_w1_lat[1] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W0_DATA2) & wf_data_vld;
    assign wf_pop_w1_lat[2] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W1_DATA2) & wf_data_vld;
    assign wf_pop_w1_lat[3] = wf_pop_en_w[2];
    assign wf_pop_w1_lat[4] = wf_pop_en_w[3];
    assign wf_pop_w1_lat[5] = wf_pop_en_w[4];

    assign wf_pop_w2_lat[0] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W0_DATA0);
    assign wf_pop_w2_lat[1] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W1_DATA0);
    assign wf_pop_w2_lat[2] = wf_pop_en_w[1] & (tx_w_cur_st == TX_W2_DATA0);
    assign wf_pop_w2_lat[3] = wf_pop_en_w[5];
    assign wf_pop_w2_lat[4] = wf_pop_en_w[6];
    assign wf_pop_w2_lat[5] = wf_pop_en_w[7];

    assign wf_data_vld_dly[0] = wf_data_vld & send_stop_vld;
    assign wf_data_vld_dly[1] = wf_data_vld & send_restart_vld;

    always_ff@(posedge wclk or negedge wrstn)
        if(~wrstn) begin
            wf_pop_data_r                       <= 'h0;
            wf_pop_sop_r                        <= '0;
            wf_data_vld                         <= 'h0;
        end
        else begin
            if(wf_pop_en) begin
                wf_data_vld                         <= 1'b1;
                wf_pop_sop_r                        <= wf_pop_data.sop;
            end
            else begin 
                wf_data_vld                         <= |wf_data_vld_dly;
            end

            if(|wf_pop_w0_lat)
                wf_pop_data_r[64+:32]               <= wf_pop_data.data;

            if(|wf_pop_w1_lat)
                wf_pop_data_r[32+:32]               <= wf_pop_data.data;

            if(|wf_pop_w2_lat)
                wf_pop_data_r[0+:32]                <= wf_pop_data.data;

        end
end
else begin
    assign wf_pop_en_w                         = lvds_ctrl_tx_en & ~fc_stop_tx_syn & ~wf_fifo_empty & ~send_stop_vld & ~send_restart_vld & (tx_w_cur_st != TX_W0_DATA2);
    assign wf_pop_data_r  = wf_pop_data;
    assign wf_data_vld    = ~wf_fifo_empty;
end
endgenerate

//--------------assemble w_data
always_ff@(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        tx_w_cur_st                         <= TX_IDLE;
        pre_enc_data                        <= '0;
        wf_data_rem                         <= '0;
    end
    else begin
        tx_w_cur_st                         <= tx_w_next_st;
        pre_enc_data                        <= tx_calib_busy_syn ? {4'hf,{4{K_REQ_CALIB}}} : pre_enc_data_w;
        if(data_to_w0_d2_en)
            wf_data_rem[7:0]                    <= wf_pop_data_r[0+:8];
        else if(data_to_w1_d2_en)
            wf_data_rem[15:0]                   <= wf_pop_data_r[0+:16];
    end

assign idle_to_w0_w0_en                    = (tx_w_cur_st == TX_IDLE) & wf_data_vld & ~send_stop_vld & ~send_restart_vld & wf_pop_sop_r;
assign data_to_w0_d1_en                    = (tx_w_cur_st == TX_W0_DATA0) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_to_w0_d2_en                    = (tx_w_cur_st == TX_W0_DATA1) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_w0_to_idle_en                  = (tx_w_cur_st == TX_W0_DATA2) & ~wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_to_w1_d0_en                    = (tx_w_cur_st == TX_W0_DATA2) & wf_data_vld & ~send_stop_vld & ~send_restart_vld & wf_pop_sop_r;
assign data_to_w1_d1_en                    = (tx_w_cur_st == TX_W1_DATA0) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_to_w1_d2_en                    = (tx_w_cur_st == TX_W1_DATA1) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_w1_to_idle_en                  = (tx_w_cur_st == TX_W1_DATA2) & ~wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_to_w2_d0_en                    = (tx_w_cur_st == TX_W1_DATA2) & wf_data_vld & ~send_stop_vld & ~send_restart_vld & wf_pop_sop_r;
assign data_to_w2_d1_en                    = (tx_w_cur_st == TX_W2_DATA0) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_to_w2_d2_en                    = (tx_w_cur_st == TX_W2_DATA1) & wf_data_vld & ~send_stop_vld & ~send_restart_vld;
assign data_w2_to_idle_en                  = (tx_w_cur_st == TX_W2_DATA2) & wf_pop_en_w[1];
//insert eop to help dec in rx side
assign data_w2_to_eop_en                   = (tx_w_cur_st == TX_W2_DATA2) & ~send_stop_vld & ~send_restart_vld;
assign data_eop_to_idle_en                 = (tx_w_cur_st == TX_W2_EOP) & ~send_stop_vld & ~send_restart_vld;

always_comb begin
    tx_w_next_st                        = TX_IDLE;
    case(tx_w_cur_st)
    TX_IDLE:
        if(idle_to_w0_w0_en)
            tx_w_next_st                        = TX_W0_DATA0;
        else
            tx_w_next_st                        = TX_IDLE;

    TX_W0_DATA0:
        if(data_to_w0_d1_en)
            tx_w_next_st                        = TX_W0_DATA1;
        else
            tx_w_next_st                        = TX_W0_DATA0;

    TX_W0_DATA1:
        if(data_to_w0_d2_en)
            tx_w_next_st                        = TX_W0_DATA2;
        else
            tx_w_next_st                        = TX_W0_DATA1;

    TX_W0_DATA2:
        if(data_w0_to_idle_en)
            tx_w_next_st                        = TX_IDLE;
        else if(data_to_w1_d0_en)
            tx_w_next_st                        = TX_W1_DATA0;
        else
            tx_w_next_st                        = TX_W0_DATA2;

    TX_W1_DATA0:
        if(data_to_w1_d1_en)
            tx_w_next_st                        = TX_W1_DATA1;
        else
            tx_w_next_st                        = TX_W1_DATA0;

    TX_W1_DATA1:
        if(data_to_w1_d2_en)
            tx_w_next_st                        = TX_W1_DATA2;
        else
            tx_w_next_st                        = TX_W1_DATA1;

    TX_W1_DATA2:
        if(data_w1_to_idle_en)
            tx_w_next_st                        = TX_IDLE;
        else if(data_to_w2_d0_en)
            tx_w_next_st                        = TX_W2_DATA0;
        else
            tx_w_next_st                        = TX_W1_DATA2;

    TX_W2_DATA0:
        if(data_to_w2_d1_en)
            tx_w_next_st                        = TX_W2_DATA1;
        else
            tx_w_next_st                        = TX_W2_DATA0;

    TX_W2_DATA1:
        if(data_to_w2_d2_en)
            tx_w_next_st                        = TX_W2_DATA2;
        else
            tx_w_next_st                        = TX_W2_DATA1;

    TX_W2_DATA2:
        if(data_w2_to_idle_en)
            tx_w_next_st                        = TX_IDLE;
        else if(data_w2_to_eop_en)
            tx_w_next_st                        = TX_W2_EOP;
        else
            tx_w_next_st                        = TX_W2_DATA2;

    TX_W2_EOP:
        if(data_eop_to_idle_en)
            tx_w_next_st                        = TX_IDLE;
        else
            tx_w_next_st                        = TX_W2_EOP;

    endcase
end

//{sop,w0[95:72]} {w0[71:40]} {w0[39:8]} {ecc,w0[7:0],w1[95:80]}
//{w1[79:48]} {w1[47:16]} {w1[15:0],ecc,w2[95:88]}
//{w2[87:56]} {w2[55:24]} {w2[23:0],ecc} 
//
always_comb begin
    if(send_stop_vld)
        pre_enc_data_w                      = {4'hf,{4{K_WAIT}}};
    else if(send_restart_vld)
        pre_enc_data_w                      = {4'hf,{4{K_RESEND}}};
    else begin
        pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};
        case(tx_w_cur_st)
            TX_IDLE:
                if(idle_to_w0_w0_en)
                    pre_enc_data_w                      = {4'h8,K_SOP,
                    (dbg_ser_en_syn ? {~wf_pop_data_r[AXIS_DATA_WIDTH-1],wf_pop_data_r[AXIS_DATA_WIDTH-2]} :
                     dbg_der_en_syn ? ~wf_pop_data_r[AXIS_DATA_WIDTH-1-:2] : 
                     wf_pop_data_r[AXIS_DATA_WIDTH-1-:2]),//highest two bits
                                                    wf_pop_data_r[AXIS_DATA_WIDTH-32+8+:3*8-2]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W0_DATA0:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*2)+8+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W0_DATA1:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*3)+8+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W0_DATA2:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_data_rem[7:0],ecc_r,wf_pop_data_r[AXIS_DATA_WIDTH-(32*1)+16+:16]};
                else
                    pre_enc_data_w                      = {4'h3,wf_data_rem[7:0],ecc_r,K_EOP,K_EOP};

            TX_W1_DATA0:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*2)+16+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W1_DATA1:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*3)+16+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W1_DATA2:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_data_rem[15:0],ecc_r,wf_pop_data_r[AXIS_DATA_WIDTH-(32*1)+24+:8]};
                else
                    pre_enc_data_w                      = {4'h1,wf_data_rem[15:0],ecc_r,K_EOP};

            TX_W2_DATA0:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*2)+24+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W2_DATA1:
                if(wf_data_vld)
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[AXIS_DATA_WIDTH-(32*3)+24+:32]};
                else
                    pre_enc_data_w                      = {4'hf,{4{K_IDLE}}};

            TX_W2_DATA2:
                    pre_enc_data_w                      = {4'h0,wf_pop_data_r[23:0],ecc_r};

            TX_W2_EOP:
                pre_enc_data_w                      = {4'hf,K_EOP,K_EOP,K_IDLE,K_IDLE};
        endcase
    end
end

//--------------ecc gen
always_ff@(posedge wclk or negedge wrstn)
    if(~wrstn) begin
        ecc_r                               <= 'h0;
    end
    else begin
        if(data_to_w0_d2_en | data_to_w1_d2_en | data_to_w2_d2_en)
            ecc_r                               <= ecc_w;
    end

assign wf_pop_data_mux                     = wf_data_vld & (
    (tx_w_cur_st == TX_W0_DATA1) |
    (tx_w_cur_st == TX_W1_DATA1) |
    (tx_w_cur_st == TX_W2_DATA1) 
    ) ? wf_pop_data_r : '0;

DW_ecc #(
    .width                              ( AXIS_DATA_WIDTH             ),
    .chkbits                            ( 8                           ),
    .synd_sel                           ( 0                           )
    ) u_wr_ecc(
    .gen                                ( 1'b1                        ), // gen tied high for write
    .correct_n                          ( 1'b1                        ), // correct_n not needed (tied high)
    .datain                             ( wf_pop_data_mux             ), // datain from system bus
    .chkin                              ( {8{1'b0}}                   ), // chkin bus not needed (tied low)
    .err_detect                         (                             ), // no error flag for writes
    .err_multpl                         (                             ), // no multi error flag for writes
    .dataout                            (                             ), // no data modification for writes
    .chkout                             ( ecc_w                       ) // check bits written to memory
    );

endmodule

