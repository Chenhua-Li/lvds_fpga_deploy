// 2-input MUX
module macro_mux2 (d0, d1, s, o);

input  d0, d1, s;
output o;

`ifdef UMC28HPCP
    SVQ_MUX2_2 u_preserved_gate (
        .D0   ( d0        ),
        .D1   ( d1        ),
        .S    ( s         ),
        .X    ( o         )
    );

`else
    assign o = s ? d1: d0;

`endif

endmodule
