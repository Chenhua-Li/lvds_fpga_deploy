module macro_or2 (a, b, o);

input  a, b;
output o;

`ifdef UMC28HPCP
    SVQ_OR2_2 u_preserved_gate (
        .A1   ( a         ),
        .A2   ( b         ),
        .X    ( o         )
    );

`else
    assign o = a | b;

`endif

endmodule
