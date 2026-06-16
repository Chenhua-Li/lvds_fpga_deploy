// DFF with async low reset, non-inverted output
module macro_dffrq (ck, clb, d, q);

input  ck, clb, d;
output q;

`ifdef UMC28HPCP
    SVQ_FSDPRBQ_D_2 u_preserved_gate (
        .D     ( d              ),
        .CK    ( ck             ),
        .RD    ( clb            ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( q              )
    );
`elsif FPGA
    FDCE #(
        .INIT(1'b0),            // Initial value of register, 1'b0, 1'b1
        // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_CLR_INVERTED(1'b1), // Optional inversion for CLR
        .IS_C_INVERTED(1'b0),   // Optional inversion for C
        .IS_D_INVERTED(1'b0)    // Optional inversion for D
    )
    FDCE_inst (
        .Q(q),     // 1-bit output: Data
        .C(ck),     // 1-bit input: Clock
        .CE(1'b1),   // 1-bit input: Clock enable
        .CLR(clb), // 1-bit input: Asynchronous clear
        .D(d)      // 1-bit input: Data
    );
`else
    reg d1;

    always @(posedge ck or negedge clb) begin
        if (~clb)
            d1 <= 1'b0;
        else
            d1 <= d; 
    end 

    assign q = d1;

`endif

endmodule
