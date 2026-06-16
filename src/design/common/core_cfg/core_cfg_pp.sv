
module core_cfg_pp
#(parameter EXTRA_PP = 0,
  parameter USED_IN_X_DIRECTION = 0
    )
(
    input                                           clk,
    input                                           rstn,
    input       [1:0]                               CORE_ID,      //core_id in X/Y direction

    //pre level
    output      logic [31:0]                        dout_pre,     //data returned to upstream core_unit
    output      logic                               dout_pre_vld, //qualifier of data returned to upstream core_unit
    input       logic [32:0]                        din_pre,      //cfg_data from upstream core_unit
    input       logic                               din_pre_vld,  //qualifier of cfg_data from upstream core_unit

    //next level//
    input       logic [31:0]                        dout_next,    //data returned from downstream core_unit
    input       logic                               dout_next_vld,//qualifier of data returned from downstream core_unit
    output      logic [32:0]                        din_next,     //cfg_data to downstream core_unit
    output      logic                               din_next_vld, //qualifier of cfg_data to downstream core_unit

    //cur level
    input       logic [31:0]                        dout_cur,     //data returned from current core_unit
    input       logic                               dout_cur_vld, //qualifier of data returned from current core_unit
    output      logic [32:0]                        din_cur,      //cfg_data to current core_unit
    output      logic                               din_cur_vld   //qualifier of cfg_data to current core_unit

    );

logic   [1:0]                                   din_pre_vld_dly;
logic   [1:0]                                   dout_next_vld_dly;
logic                                           din_pre_lat;
logic                                           dout_next_lat;
logic                                           dout_cur_lat;
logic   [32:0]                                  din_pre_r;
logic   [31:0]                                  dout_pre_r;
logic                                           dout_pre_r_vld;
logic                                           din_r_vld_cur;
logic                                           din_r_vld_next;
logic   [1:0]                                   wait_data_cur;
logic   [1:0]                                   wait_data_cur_set;
logic                                           wait_data_cur_clr;
logic   [2:0]                                   din_r_vld_cur_set;
logic   [3:0]                                   din_r_vld_next_set;
logic                                           data_is_addr;
logic                                           op_is_write;
logic                                           id_hit;
logic                                           burst_hit;

assign din_pre_lat                         = din_pre_vld_dly[1];
assign dout_next_lat                       = dout_next_vld_dly[1];
assign dout_cur_lat                        = dout_cur_vld;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        din_pre_vld_dly                     <= '0;
        dout_next_vld_dly                   <= '0;
    end
    else begin
        din_pre_vld_dly                     <= {din_pre_vld_dly[0],  din_pre_vld};
        dout_next_vld_dly                   <= {dout_next_vld_dly[0],dout_next_vld};
    end

generate if(USED_IN_X_DIRECTION)
    assign id_hit                              = ~burst_hit & (din_pre[26+:2] == CORE_ID[1:0]);
else //in Y_direction
    assign id_hit                              = ~burst_hit & (din_pre[28+:2] == CORE_ID[1:0]);
endgenerate

assign data_is_addr                        = din_pre[32];
assign op_is_write                         = din_pre[25];
assign burst_hit                           = din_pre[31];

assign wait_data_cur_set[0]                = din_pre_lat & data_is_addr & ~burst_hit & id_hit & op_is_write;
assign wait_data_cur_set[1]                = din_pre_lat & data_is_addr & burst_hit & op_is_write;
assign wait_data_cur_clr                   = din_pre_lat & ~data_is_addr & wait_data_cur[0];
assign din_r_vld_cur_set[0]                = din_pre_lat & data_is_addr & ~burst_hit & id_hit;
assign din_r_vld_cur_set[1]                = din_pre_lat & data_is_addr & burst_hit & op_is_write;
assign din_r_vld_cur_set[2]                = din_pre_lat & ~data_is_addr & wait_data_cur[0];
assign din_r_vld_next_set[0]               = din_pre_lat & data_is_addr & ~burst_hit & ~id_hit;
assign din_r_vld_next_set[1]               = din_pre_lat & data_is_addr & burst_hit & op_is_write;
assign din_r_vld_next_set[2]               = din_pre_lat & ~data_is_addr & ~wait_data_cur[0] & ~wait_data_cur[1];
assign din_r_vld_next_set[3]               = din_pre_lat & ~data_is_addr & wait_data_cur[1];

always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        wait_data_cur                       <= '0;
        dout_pre_r_vld                      <= '0;
        din_r_vld_cur                       <= '0;
        din_r_vld_next                      <= '0;
        din_pre_r                           <= '0;
        dout_pre_r                          <= '0;
    end
    else begin
        dout_pre_r_vld                      <= dout_next_lat | dout_cur_lat;

        if(wait_data_cur_clr)
            wait_data_cur                       <= '0;
        else if(wait_data_cur_set[0])
            wait_data_cur                       <= 2'b01;
        else if(wait_data_cur_set[1])
            wait_data_cur                       <= 2'b11;

        if(|din_r_vld_cur_set)
            din_r_vld_cur                       <= 1'b1;
        else
            din_r_vld_cur                       <= '0;

        if(|din_r_vld_next_set)
            din_r_vld_next                      <= 1'b1;
        else
            din_r_vld_next                      <= '0;

        if(din_pre_lat)
            din_pre_r                           <= din_pre;

        if(dout_next_lat)
            dout_pre_r                          <= dout_next;
        else if(dout_cur_lat)
            dout_pre_r                          <= dout_cur;
    end

assign dout_pre                            = dout_pre_r;
assign dout_pre_vld                        = dout_pre_r_vld;
assign din_cur                             = din_pre_r;
assign din_cur_vld                         = din_r_vld_cur;

generate if(EXTRA_PP) begin:ADD_EXTRA_PP
logic   [32:0]                                  din_next_r;

    always_ff @(posedge clk or negedge rstn)
        if(~rstn) begin
            din_next_r                          <= '0;
        end
        else begin
            if(din_pre_lat)
                din_next_r                          <= din_pre;
        end

    assign din_next = din_next_r;
    assign din_next_vld = din_r_vld_next;
end 
else begin:NO_EXTRA_PP

    assign din_next = din_pre_r;
    assign din_next_vld = din_r_vld_next;

end 
endgenerate


endmodule
