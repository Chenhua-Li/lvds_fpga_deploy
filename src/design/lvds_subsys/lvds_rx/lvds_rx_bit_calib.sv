
module lvds_rx_bit_calib(
    input                                           clk,
    input                                           rstn,
    input                                           clk_div2_flag,
    input                                           man_read_req,
    output      logic                               man_read_ack,
    output      logic [59:0]                        man_read_data,
    input       logic                               cal_en_pos,
    input                                           scan_mode,
    input       [ 9:0]                              lvds_rx_bits,
    output      logic                               cal_done,
    output      logic                               cal_up_req,
    output      logic [7:0]                         cal_up_val,
    output      logic [4:0]                         cal_lane_num,
    input       logic                               cal_up_ack
    );

logic                                           calib_sl_done;
logic                                           cal_sl_start;
logic                                           cal_dly_2start;
logic                                           cal_dly_2idle;
logic                                           cal_dly_en;
logic   [2:0]                                   cal_dly_cnt;
logic                                           lane_num_set;
logic                                           lane_num_inc;

logic   [1:0]                                   check_bit_w;
logic   [1:0]                                   check_bit_mux;
logic   [4:0]                                   lane_num;
logic                                           rstn_syn_div_clk2;
logic                                           man_read_req_syn;
logic                                           man_read_req_syn_r;
logic                                           man_read_req_pos;
logic   [4:0]                                   man_read_req_pos_r;

typedef enum logic [1:0] {
    ST_CAL_IDLE,
    ST_CAL_START,
    ST_CAL_BUSY,
    ST_CAL_DLY
} rx_cal_st_type;
rx_cal_st_type                                  cal_cur_st;
rx_cal_st_type                                  cal_next_st;

always_comb begin
    check_bit_mux                       = 2'b0;
    for(int unsigned i = 0;i<5;i++) begin
        if(5'(i) == lane_num)
            check_bit_mux                       = lvds_rx_bits[i*2+:2];
    end
end

assign man_read_req_pos                    = ~man_read_req_syn_r & man_read_req_syn;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        cal_done                            <= 1'b0;
        man_read_req_syn_r                  <= 1'b0;
        man_read_req_pos_r                  <= 'h0;
        man_read_data                       <= 'h0;
        man_read_ack                        <= 'h0;
    end 
    else begin
        man_read_req_syn_r                  <= man_read_req_syn;
        man_read_req_pos_r                  <= {man_read_req_pos_r[3:0],man_read_req_pos};

        if(man_read_req_pos_r[4])
            man_read_ack                        <= 'h1;
        else if(~man_read_req_syn & man_read_ack)
            man_read_ack                        <= 'h0;

        if(man_read_req_pos)
            man_read_data[ 0+:10]               <= lvds_rx_bits;
        if(man_read_req_pos_r[0])
            man_read_data[10+:10]               <= lvds_rx_bits;
        if(man_read_req_pos_r[1])
            man_read_data[20+:10]               <= lvds_rx_bits;
        if(man_read_req_pos_r[2])
            man_read_data[30+:10]               <= lvds_rx_bits;
        if(man_read_req_pos_r[3])
            man_read_data[40+:10]               <= lvds_rx_bits;
        if(man_read_req_pos_r[4])
            man_read_data[50+:10]               <= lvds_rx_bits;

        if(cal_en_pos)
            cal_done                            <= 1'b0;
        else if(cal_dly_2idle)
            cal_done                            <= 1'b1;
    end

macro_sync2r u_man_read_req_syn(  
    .ck                                 ( clk                         ),
    .clb                                ( rstn                        ),
    .d                                  ( man_read_req                ),
    .o                                  ( man_read_req_syn            )
    );

assign cal_lane_num                        = lane_num;
assign lane_num_inc                        = calib_sl_done;
assign lane_num_set                        = cal_en_pos;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        lane_num                            <= 5'h0;
    end
    else begin
        if(lane_num_set)
            lane_num                            <= 5'h0;
        else if(lane_num_inc)
            lane_num                            <= lane_num + 1;
    end

assign check_bit_w                         = check_bit_mux;

always_ff @(posedge clk or negedge rstn)
    if(~rstn)
        cal_cur_st                          <= ST_CAL_IDLE;
    else
        cal_cur_st                          <= cal_next_st;

always_ff @(posedge clk or negedge rstn)
    if(~rstn)
        cal_dly_cnt                         <= 3'h0;
    else if(cal_dly_2start | cal_en_pos | cal_dly_en)
        cal_dly_cnt                         <= 3'h0;
    else if((cal_cur_st == ST_CAL_DLY) | (cal_cur_st == ST_CAL_START))
        cal_dly_cnt                         <= cal_dly_cnt + 1;


assign cal_dly_en                          = (cal_cur_st == ST_CAL_BUSY) & calib_sl_done;
assign cal_dly_2idle                       = (cal_cur_st == ST_CAL_DLY) & (&cal_dly_cnt) & (lane_num == 5'd5);
assign cal_dly_2start                      = (cal_cur_st == ST_CAL_DLY) & (&cal_dly_cnt) & (lane_num != 5'd5);
assign cal_start_2busy                     = (cal_cur_st == ST_CAL_START) & (&cal_dly_cnt);
always_comb begin
    cal_next_st                         = ST_CAL_IDLE;
    case(cal_cur_st)
        ST_CAL_IDLE:
            if(cal_en_pos)
                cal_next_st                         = ST_CAL_START;
            else
                cal_next_st                         = ST_CAL_IDLE;
        ST_CAL_START:
            if(cal_start_2busy)
                cal_next_st                         = ST_CAL_BUSY;
            else
                cal_next_st                         = ST_CAL_START;
        ST_CAL_BUSY:
            if(cal_dly_en)
                cal_next_st                         = ST_CAL_DLY;
            else
                cal_next_st                         = ST_CAL_BUSY;
        ST_CAL_DLY:
            if(cal_dly_2idle)
                cal_next_st                         = ST_CAL_IDLE;
            else if(cal_dly_2start)
                cal_next_st                         = ST_CAL_START;
            else
                cal_next_st                         = ST_CAL_DLY;
    endcase
end


assign cal_sl_start                        = cal_start_2busy;
lvds_rx_bit_calib_sl u_lvds_rx_bit_calib_sl(
    .clk                                ( clk                         ),
    .rstn                               ( rstn                        ),
    .clk_div2_flag                      ( clk_div2_flag               ),
    .check_bit                          ( check_bit_w                 ),
    .start                              ( cal_sl_start                ),
    .done                               ( calib_sl_done               ),
    .up_req                             ( cal_up_req                  ),
    .up_val                             ( cal_up_val                  ),
    .up_ack                             ( cal_up_ack                  )
    );

endmodule



