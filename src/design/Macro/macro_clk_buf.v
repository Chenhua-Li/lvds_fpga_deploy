// Clock Buffer
module macro_clk_buf (a, o);

input  a;
output o;

`ifdef UMC28HPCP
    SVQ_BUF_S_2 u_preserved_gate (
        .A    ( a         ),
        .X    ( o         )
    );
`elsif FPGA
    BUFG BUFG_inst (
        .O(o), // 1-bit output: Clock output.
        .I(a)  // 1-bit input: Clock input.
    );
`else
    assign o = a;

`endif

endmodule
