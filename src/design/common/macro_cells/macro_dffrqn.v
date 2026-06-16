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
