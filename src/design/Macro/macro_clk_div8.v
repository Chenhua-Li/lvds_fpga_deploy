// Clock Divider, can generate 1/2, 1/4, 1/8 clocks
module macro_clk_div8 #(
    parameter SYNC_EN = 0 
)(
    input       test_en    ,
    input       rst_n      ,
    output      rst_n_sync ,
    input       clk_in     ,
    output      clk_out0   ,  //div2
    output      clk_out1   ,  //div4
    output      clk_out2      //div8
);

if (SYNC_EN > 0) begin : sync 
    macro_reset_sync2 u_rst_sync(
        .test_en        (test_en       ),
        .reset_n        (rst_n          ),
        .ck             (clk_in         ),
        .reset_sync_n   (rst_n_sync     )
    );
end else begin
    assign rst_n_sync = rst_n;
end 

// internal state
reg [2:0]  div8_cnt;

always @(posedge clk_in or negedge rst_n_sync) begin
    if (~rst_n_sync)
        div8_cnt <= 3'b0;
    else
        div8_cnt <= div8_cnt + 1'b1;
end

// add anchor to apply sdc
macro_clk_buf u_clk_buf2(
    .a            (  div8_cnt[0]   ),
    .o            (  clk_out0      )
);

macro_clk_buf u_clk_buf4(
    .a            (  div8_cnt[1]   ),
    .o            (  clk_out1      )
);

macro_clk_buf u_clk_buf8(
    .a            (  div8_cnt[2]   ),
    .o            (  clk_out2      )
);

endmodule
