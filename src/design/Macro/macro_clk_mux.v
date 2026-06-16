// 2-input Clock MUX
module macro_clk_mux (d0, d1, s, o);

input  d0, d1, s;
output o;

`ifdef UMC28HPCP
    SVQ_MUX2_S_2 u_preserved_gate (
        .D0   ( d0        ),
        .D1   ( d1        ),
        .S    ( s         ),
        .X    ( o         )
    );
`elsif FPGA
    BUFGMUX #(
        .CLK_SEL_TYPE("ASYNC")  // ASYNC, SYNC
    )
    BUFGMUX_inst (
        .O(o),   // 1-bit output: Clock output
        .I0(d0), // 1-bit input: Clock input (S=0)
        .I1(d1), // 1-bit input: Clock input (S=1)
        .S(s)    // 1-bit input: Clock select
    );
`else
    assign o = s ? d1: d0;

`endif

endmodule
