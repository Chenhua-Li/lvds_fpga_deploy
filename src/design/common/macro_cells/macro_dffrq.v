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
