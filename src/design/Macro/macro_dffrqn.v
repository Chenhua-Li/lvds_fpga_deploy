// DFF with async low reset, inverted output
module macro_dffrqn (ck, clb, d, qn);

input  ck, clb, d;
output qn;

`ifdef UMC28HPCP
    SVQ_FSDPRBQ_D_2 u_preserved_dff (
        .D     ( d              ),
        .CK    ( ck             ),
        .RD    ( clb            ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( q              )
    );

    SVQ_INV_2 u_preserved_inv (
        .A     ( q              ),
        .X     ( qn             )
    );
`elsif FPGA
    FDCE #(
        .INIT(1'b1),            // Initial value of register, 1'b0, 1'b1
        // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
        .IS_CLR_INVERTED(1'b1), // Optional inversion for CLR
        .IS_C_INVERTED(1'b0),   // Optional inversion for C
        .IS_D_INVERTED(1'b0)    // Optional inversion for D
    )
    FDCE_inst (
        .Q(qn),     // 1-bit output: Data
        .C(ck),     // 1-bit input: Clock
        .CE(1'b1),   // 1-bit input: Clock enable
        .CLR(clb), // 1-bit input: Asynchronous clear
        .D(~d)      // 1-bit input: Data
    );
`else
    reg d1;

    always @(posedge ck or negedge clb) begin
        if (~clb)
            d1 <= 1'b0;
        else
            d1 <= d; 
    end 

    assign qn = ~d1;

`endif

endmodule
