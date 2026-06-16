module lvds_rx_bit_calib_sl(
    input                                           clk,
    input                                           rstn,
    input                                           clk_div2_flag,
    input       [1:0]                               check_bit,
    input                                           start,
    output      logic                               done,
    output      logic                               up_req,
    output      logic [7:0]                         up_val,
    input       logic                               up_ack
    );


typedef enum logic [3:0] {
    ST_IDLE,
    ST_LEFT_UNSTABLE1,
    ST_LEFT_UNSTABLE2,
    ST_LEFT,
    ST_RIGHT,
    ST_RIGHT_UNSTABLE1,
    ST_RIGHT_UNSTABLE2,
    ST_LEFT2,
    ST_LEFT2_UNSTABLE1,
    ST_LEFT2_UNSTABLE2,
    ST_DONE
} calib_sl_st_type;

calib_sl_st_type                                cur_st;
calib_sl_st_type                                next_st;
logic                                           st_to_done_en;
logic                                           up_req_clr;
logic                                           up_req_set;
logic   [2:0]                                   up_req_set_right;
logic   [5:0]                                   up_req_set_left;
logic   [8:0]                                   final_up_val;
logic   [7:0]                                   val_left;
logic   [1:0]                                   ref_bit_val;
logic   [1:0]                                   st_to_right_en;
logic                                           st_to_idle_en;
logic                                           up_req_set_done;
logic   [1:0][1:0]                              check_bit_r;
logic   [1:0]                                   bit_stable;
logic                                           st_to_right_unstable1_en;
logic                                           st_to_right_unstable2_en;
logic                                           st_to_left_en;
logic   [1:0]                                   st_to_left_unstable2_en;
logic                                           st_idle_to_left;
logic                                           st_idle_to_left_unstable;
logic                                           up_ack_syn;
logic                                           up_ack_syn_r;
logic                                           st_to_left2_unstable1_en;
logic                                           st_to_left2_unstable2_en;
logic                                           st_to_left2_en;

macro_sync2r u_up_ack_syn(  
    .ck                                 ( clk                         ),
    .clb                                ( rstn                        ),
    .d                                  ( up_ack                      ),
    .o                                  ( up_ack_syn                  )
    );

assign bit_stable[0]                       = (check_bit_r[0] == check_bit_r[1]) & (check_bit_r[1] == 2'b01);
assign bit_stable[1]                       = (check_bit_r[0] == check_bit_r[1]) & (check_bit_r[1] == 2'b10);
assign st_idle_to_left                     = start & bit_stable[0];
assign st_idle_to_left_unstable            = start & ~bit_stable[0];
assign st_to_right_unstable1_en            = (cur_st == ST_LEFT) & ~up_req & ~up_ack_syn & ~bit_stable[0];
assign st_to_left_unstable2_en[0]          = (cur_st == ST_LEFT_UNSTABLE1) & ~up_req & ~up_ack_syn & bit_stable[0];
assign st_to_left_unstable2_en[1]          = (cur_st == ST_LEFT_UNSTABLE1) & ~up_req & ~up_ack_syn & bit_stable[1];
assign st_to_left_en                       = (cur_st == ST_LEFT_UNSTABLE2) & ~up_ack_syn & up_ack_syn_r & bit_stable[0];
assign st_to_right_unstable2_en            = (cur_st == ST_RIGHT_UNSTABLE1) & ~up_req & ~up_ack_syn & bit_stable[1];
assign st_to_right_en[0]                   = (cur_st == ST_LEFT_UNSTABLE2) & ~up_ack_syn & up_ack_syn_r & bit_stable[1];
assign st_to_right_en[1]                   = (cur_st == ST_RIGHT_UNSTABLE2) & ~up_ack_syn & up_ack_syn_r & bit_stable[1];
assign st_to_left2_unstable1_en            = (cur_st == ST_RIGHT) & ~up_req & ~up_ack_syn & ~bit_stable[1];
assign st_to_left2_unstable2_en            = (cur_st == ST_LEFT2_UNSTABLE1) & ~up_req & ~up_ack_syn & bit_stable[0];
assign st_to_left2_en                      = (cur_st == ST_LEFT2_UNSTABLE2) & ~up_ack_syn & up_ack_syn_r & bit_stable[0];
assign st_to_done_en                       = (cur_st == ST_LEFT2) & ~up_req & ~up_ack_syn & ~bit_stable[0];
assign st_to_idle_en                       = (cur_st == ST_DONE) & up_req & up_ack_syn;

always_ff @(posedge clk or negedge rstn)
    if(~rstn)
        cur_st                              <= ST_IDLE;
    else
        cur_st                              <= next_st;

always_comb begin
    next_st                             = ST_IDLE;
    case(cur_st)
        ST_IDLE:
            if(st_idle_to_left)
                next_st                             = ST_LEFT;
            else if(st_idle_to_left_unstable)
                next_st                             = ST_LEFT_UNSTABLE1;
            else
                next_st                             = ST_IDLE;

        ST_LEFT:
            if(st_to_right_unstable1_en)
                next_st                             = ST_RIGHT_UNSTABLE1;
            else
                next_st                             = ST_LEFT;

        ST_LEFT_UNSTABLE1:
            if(|st_to_left_unstable2_en)
                next_st                             = ST_LEFT_UNSTABLE2;
            else
                next_st                             = ST_LEFT_UNSTABLE1;

        ST_LEFT_UNSTABLE2:
            if(st_to_left_en)
                next_st                             = ST_LEFT;
            else if(st_to_right_en[0])
                next_st                             = ST_RIGHT;
            else
                next_st                             = ST_LEFT_UNSTABLE2;

        ST_RIGHT_UNSTABLE1:
            if(st_to_right_unstable2_en)
                next_st                             = ST_RIGHT_UNSTABLE2;
            else
                next_st                             = ST_RIGHT_UNSTABLE1;

        ST_RIGHT_UNSTABLE2:
            if(st_to_right_en[1])
                next_st                             = ST_RIGHT;
            else
                next_st                             = ST_RIGHT_UNSTABLE2;

        ST_RIGHT:
            if(st_to_left2_unstable1_en)
                next_st                             = ST_LEFT2_UNSTABLE1;
            else
                next_st                             = ST_RIGHT;

        ST_LEFT2_UNSTABLE1:
            if(st_to_left2_unstable2_en)
                next_st                             = ST_LEFT2_UNSTABLE2;
            else
                next_st                             = ST_LEFT2_UNSTABLE1;

        ST_LEFT2_UNSTABLE2:
            if(st_to_left2_en)
                next_st                             = ST_LEFT2;
            else
                next_st                             = ST_LEFT2_UNSTABLE2;

        ST_LEFT2:
            if(st_to_done_en)
                next_st                             = ST_DONE;
            else
                next_st                             = ST_LEFT2;

        ST_DONE:
            if(st_to_idle_en)
                next_st                             = ST_IDLE;
            else
                next_st                             = ST_DONE;
    endcase
end

always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        ref_bit_val                         <= '0;
        check_bit_r                         <= '0;
        val_left                            <= 'h0;
        done                                <= 1'b0;
        up_ack_syn_r                        <= '0;
    end
    else begin 
        if(clk_div2_flag)
            check_bit_r                         <= {check_bit_r[0],check_bit};

        if(start)
            ref_bit_val                         <= check_bit_r[1];
        else if(st_to_left_en | (|st_to_right_en))
            ref_bit_val                         <= check_bit_r[1];

        if(st_to_left2_unstable1_en)
            val_left                            <= up_val;

        done                                <= st_to_idle_en;
        up_ack_syn_r                        <= up_ack_syn;
    end

assign final_up_val                        = up_val + val_left;
always_ff @(posedge clk or negedge rstn)
    if(~rstn)
        up_val                              <= 8'h0;
    else if(start)
        up_val                              <= 8'h0;
    else if((|up_req_set_left) | (|up_req_set_right))
        up_val                              <= up_val + 1;
    else if(st_to_done_en)
        up_val                              <= final_up_val[8:1];

assign up_req_set_left[0]                  = (cur_st == ST_LEFT) & ~up_req & ~up_ack_syn & bit_stable[0];
assign up_req_set_left[1]                  = (cur_st == ST_LEFT_UNSTABLE1) & ~up_req & ~up_ack_syn & ~bit_stable[0] & ~bit_stable[1];
assign up_req_set_left[2]                  = (cur_st == ST_LEFT_UNSTABLE2) & ~up_req & ~up_ack_syn;
assign up_req_set_left[3]                  = (cur_st == ST_LEFT2) & ~up_req & ~up_ack_syn & bit_stable[0];
assign up_req_set_left[4]                  = (cur_st == ST_LEFT2_UNSTABLE1) & ~up_req & ~up_ack_syn & ~bit_stable[0];
assign up_req_set_left[5]                  = (cur_st == ST_LEFT2_UNSTABLE2) & ~up_req & ~up_ack_syn;
assign up_req_set_right[0]                 = (cur_st == ST_RIGHT) & ~up_req & ~up_ack_syn & bit_stable[1];
assign up_req_set_right[1]                 = (cur_st == ST_RIGHT_UNSTABLE1) & ~up_req & ~up_ack_syn & ~bit_stable[1];
assign up_req_set_right[2]                 = (cur_st == ST_RIGHT_UNSTABLE2) & ~up_req & ~up_ack_syn;
assign up_req_set_done                     = (cur_st == ST_DONE) & ~up_req & ~up_ack_syn;
assign up_req_set                          = (|up_req_set_left) | (|up_req_set_right) | up_req_set_done;
assign up_req_clr                          = up_req & up_ack_syn;
always_ff @(posedge clk or negedge rstn)
    if(~rstn)
        up_req                              <= 1'b0;
    else if(up_req_set)
        up_req                              <= 1'b1;
    else if(up_req_clr)
        up_req                              <= 1'b0;

endmodule


