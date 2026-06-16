
module lvds_tx_calib
    import lvds_if_pkg::*;
(
    input       logic                               clk,
    input       logic                               rstn,
    input       logic                               cfg_man_tx_calib_en,
    input       logic                               cfg_auto_calib_en,
    input       logic [7:0]                         cfg_start_calib_dly,
    input       logic [15:0]                        cfg_calib_extra_dly,
    input       logic                               rec_p_calib_req,
    output      logic                               rec_p_calib_ack,
    output      logic                               auto_start_calib,
    output      logic                               auto_tx_bit_sel,
    input       logic                               lane_calib_done,
    output      logic                               auto_cal_done,
    output      logic                               tx_calib_busy,
    output      logic                               switch_clk_req

    );

typedef enum logic [2:0] {
    IDLE,
    WAIT_REQ,
    SEND_REQ,
    SWITCH_CLK,
    START_CALIB_DLY,
    IN_CALIB,
    CALIB_EXTRA_DLY

} tx_calib_st_type;

tx_calib_st_type                                calib_cur_st;
tx_calib_st_type                                calib_next_st;
logic                                           first_ini;
logic                                           send_req_dly_done;
logic                                           start_calib_dly_done;
logic                                           extra_dly_done;
logic   [15:0]                                  calib_st_dly_cnt;
logic                                           calib_st_dly_cnt_inc;
logic                                           calib_st_dly_cnt_clr;
logic   [1:0]                                   tx_calib_busy_clr;
logic                                           switch_clk_req_clr;
logic                                           rec_p_calib_req_syn;
logic                                           auto_calib_en_syn;
logic                                           lane_calib_done_syn;
logic                                           to_wait_req_en;
logic                                           to_send_req_en;
logic                                           to_switch_clk_en;
logic                                           to_start_calib_dly_en;
logic                                           to_in_calib_en;
logic                                           to_calib_extra_dly_en;
logic                                           to_id_st_en;
logic                                           cfg_man_tx_calib_en_syn;
logic                                           auto_tx_bit_sel_clr;

macro_sync2r u_tx_calib_syn[3:0](
    .ck                                 ( clk                         ),
    .clb                                ( rstn                        ),
    .d                                  ( {cfg_man_tx_calib_en,cfg_auto_calib_en,rec_p_calib_req,lane_calib_done}),
    .o                                  ( {cfg_man_tx_calib_en_syn,auto_calib_en_syn,rec_p_calib_req_syn,lane_calib_done_syn})
    );
assign rec_p_calib_ack                     = rec_p_calib_req_syn;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        calib_cur_st                        <= IDLE;
    end
    else begin
        calib_cur_st                        <= calib_next_st;
    end

assign to_wait_req_en                      = first_ini & auto_calib_en_syn & (calib_cur_st == IDLE);
assign to_send_req_en                      = rec_p_calib_req_syn & (calib_cur_st == WAIT_REQ);
assign to_switch_clk_en                    = send_req_dly_done & (calib_cur_st == SEND_REQ);
assign to_start_calib_dly_en               = switch_clk_req & (calib_cur_st == SWITCH_CLK);
assign to_in_calib_en                      = start_calib_dly_done & (calib_cur_st == START_CALIB_DLY);
assign to_calib_extra_dly_en               = lane_calib_done_syn & (calib_cur_st == IN_CALIB);
assign to_id_st_en                         = extra_dly_done & (calib_cur_st == CALIB_EXTRA_DLY);

always_comb begin
    if(~auto_calib_en_syn) begin
        calib_next_st                       = IDLE;
    end
    else begin
        calib_next_st                       = IDLE;
        case(calib_cur_st)
            IDLE:
                if(to_wait_req_en)
                    calib_next_st                       = WAIT_REQ;
                else
                    calib_next_st                       = IDLE;
            WAIT_REQ:
                if(to_send_req_en)
                    calib_next_st                       = SEND_REQ;
                else
                    calib_next_st                       = WAIT_REQ;
                
            SEND_REQ:
                if(to_switch_clk_en)
                    calib_next_st                       = SWITCH_CLK;
                else
                    calib_next_st                       = SEND_REQ;

            SWITCH_CLK:
                if(to_start_calib_dly_en)
                    calib_next_st                       = START_CALIB_DLY;
                else
                    calib_next_st                       = SWITCH_CLK;

            START_CALIB_DLY:
                if(to_in_calib_en)
                    calib_next_st                       = IN_CALIB;
                else
                    calib_next_st                       = START_CALIB_DLY;

            IN_CALIB:
                if(to_calib_extra_dly_en)
                    calib_next_st                       = CALIB_EXTRA_DLY;
                else
                    calib_next_st                       = IN_CALIB;

            CALIB_EXTRA_DLY:
                if(to_id_st_en)
                    calib_next_st                       = IDLE;
                else
                    calib_next_st                       = CALIB_EXTRA_DLY;
        endcase
    end
end

assign send_req_dly_done                   = (calib_st_dly_cnt[4:0] == 5'd31) & (calib_cur_st == SEND_REQ);
assign start_calib_dly_done                = (calib_st_dly_cnt[7:0] == cfg_start_calib_dly) & (calib_cur_st == START_CALIB_DLY);
assign extra_dly_done                      = (calib_st_dly_cnt[15:0] == cfg_calib_extra_dly) & (calib_cur_st == CALIB_EXTRA_DLY);
assign calib_st_dly_cnt_clr                = to_send_req_en | send_req_dly_done | start_calib_dly_done | extra_dly_done;
assign calib_st_dly_cnt_inc                = 
            (calib_cur_st == SEND_REQ) |
            (calib_cur_st == START_CALIB_DLY) |
            (calib_cur_st == CALIB_EXTRA_DLY);

assign tx_calib_busy_clr[0]                = tx_calib_busy & ~auto_calib_en_syn;
assign tx_calib_busy_clr[1]                = to_id_st_en;
assign switch_clk_req_clr                  = ~auto_calib_en_syn & switch_clk_req;
assign auto_tx_bit_sel_clr                 = (calib_cur_st == IDLE) & ~cfg_man_tx_calib_en_syn & auto_tx_bit_sel;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        first_ini                           <= 1'b1;
        auto_start_calib                    <= '0;
        auto_tx_bit_sel                     <= '0;
        tx_calib_busy                       <= '0;
        auto_cal_done                       <= '0;
        switch_clk_req                      <= '0;
        calib_st_dly_cnt                    <= 'h0;
    end
    else begin

        if(~auto_calib_en_syn & auto_cal_done)
            auto_cal_done                       <= 1'b0;
        else if(to_id_st_en)
            auto_cal_done                       <= 1'b1;

        if(calib_cur_st == WAIT_REQ)
            first_ini                           <= 1'b0;

        if(to_in_calib_en)
            auto_start_calib                    <= 1'b1;
        else if(to_calib_extra_dly_en)
            auto_start_calib                    <= 1'b0;

        if(to_start_calib_dly_en | cfg_man_tx_calib_en_syn)
            auto_tx_bit_sel                     <= '1;
        else if(auto_tx_bit_sel_clr)
            auto_tx_bit_sel                     <= '0;

        if(|tx_calib_busy_clr)
            tx_calib_busy                       <= 1'b0;
        else if(to_wait_req_en)
            tx_calib_busy                       <= 1'b1;

        if(switch_clk_req_clr)
            switch_clk_req                      <= '0;
        else if(to_switch_clk_en)
            switch_clk_req                      <= '1;

        if(calib_st_dly_cnt_clr)
            calib_st_dly_cnt                    <= 'h0;
        else if(calib_st_dly_cnt_inc)
            calib_st_dly_cnt                    <= calib_st_dly_cnt + 1;

    end

endmodule

