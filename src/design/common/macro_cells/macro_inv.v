// Clock Inverter 
module macro_inv (a, o);

input  a;
output o;

`ifdef UMC28HPCP
    SVQ_INV_S_2 u_preserved_gate (
        .A    ( a         ),
        .X    ( o         )
    );

`else
    assign o = ~a;

`endif

endmodule
