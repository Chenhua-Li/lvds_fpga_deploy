
module cross_event_gen(
    input                               clk_a,
    input                               rstn_a,
    input                               event_a,
    input                               clk_b,
    input                               rstn_b,
    output      logic                   cross_event_o
    );

logic                   event_a_flag;
logic                   event_a_flag_syn2b;
logic                   event_in_b_r;
logic                   cross_event_w;
logic                   event_a_flag_clr;
logic                   event_a_flag_set;
logic                   event_a_flag_ack;

assign event_a_flag_clr        = event_a_flag & event_a_flag_ack;
assign event_a_flag_set        = ~event_a_flag & event_a;
always @(posedge clk_a or negedge rstn_a)
    if(~rstn_a)
        event_a_flag            <= 1'b0;
    else if(event_a_flag_set)
        event_a_flag            <= 1'b1;
    else if(event_a_flag_clr)
        event_a_flag            <= 1'b0;

macro_sync2r u_flag_a_syn(
    .ck                                 ( clk_b                              ),
    .clb                                ( rstn_b                             ),
    .d                                  ( event_a_flag                       ),
    .o                                  ( event_a_flag_syn2b                 )
    );

macro_sync2r u_flag_a_ack_syn(
    .ck                                 ( clk_a                              ),
    .clb                                ( rstn_a                             ),
    .d                                  ( event_a_flag_syn2b                 ),
    .o                                  ( event_a_flag_ack                   )
    );


always @(posedge clk_b or negedge rstn_b)
    if(~rstn_b)
        event_in_b_r            <= 1'b0;
    else
        event_in_b_r            <= event_a_flag_syn2b;

assign cross_event_w           = event_a_flag_syn2b & ~event_in_b_r;
always @(posedge clk_b or negedge rstn_b)
    if(~rstn_b)
        cross_event_o           <= 1'b0;
    else
        cross_event_o           <= cross_event_w;

endmodule
