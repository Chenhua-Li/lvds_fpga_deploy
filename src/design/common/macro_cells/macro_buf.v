// Clock Buffer
module macro_buf (a, o);

input  a;
output o;

`ifdef UMC28HPCP
    SVQ_BUF_2 u_preserved_gate (
        .A    ( a         ),
        .X    ( o         )
    );

`else
    assign o = a;

`endif

endmodule
