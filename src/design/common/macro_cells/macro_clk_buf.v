// Clock Buffer
module macro_clk_buf (a, o);

input  a;
output o;

`ifdef UMC28HPCP
    SVQ_BUF_S_2 u_preserved_gate (
        .A    ( a         ),
        .X    ( o         )
    );

`else
    assign o = a;

`endif

endmodule
