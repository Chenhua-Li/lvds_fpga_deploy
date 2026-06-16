module macro_nand2 (a, b, o);

input  a, b;
output o;

`ifdef FPGA 
    
    assign o = ~ (a & b);

`else

SVQ_ND2_S_1 u_preserved_nand2(
    .X  (o),
    .A1 (a),
    .A2 (b)
);


`endif

endmodule
