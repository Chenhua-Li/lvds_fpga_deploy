// Clock Divider, can generate 1/2 clocks
module macro_clk_div2 #(
    parameter SYNC_EN = 0 
)(
    input       test_en    ,
    input       rst_n      ,
    output      rst_n_sync ,
    input       clk_in     ,
    output      clk_out0    
);

// internal state
reg  clk_div_by2;

if (SYNC_EN > 0) begin : sync 
    macro_reset_sync2 u_rst_sync(
        .test_en        (test_en       ),
        .reset_n        (rst_n         ),
        .ck             (clk_in        ),
        .reset_sync_n   (rst_n_sync    )
    );
end else begin
    assign rst_n_sync = rst_n;
end 

// div2
always @(posedge clk_in or negedge rst_n_sync) begin
    if (~rst_n_sync)
        clk_div_by2 <= 1'b0;
    else
        clk_div_by2 <= ~clk_div_by2;
end

// add anchor to apply sdc
macro_clk_buf u_clk_buf2(
    .a            (  clk_div_by2   ),
    .o            (  clk_out0      )
);

endmodule
