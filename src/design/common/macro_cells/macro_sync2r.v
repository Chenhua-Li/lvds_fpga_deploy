// 2 Stage Synchronizer, with asynchronous reset
module macro_sync2r (
    ck,
    d,
    clb,
    o
);

input    ck;
input    d;
input    clb;
output   o;

`ifdef UMC28HPCP
    SVQ_FSDPRBQ_D_2 u_preserved_gate1 (
        .D    ( d         ),
        .CK   ( ck        ),
        .RD   ( clb       ),
        .SE   ( 1'b0      ),
        .SI   ( 1'b0      ),
        .Q    ( d1        )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate2 (
        .D    ( d1        ),
        .CK   ( ck        ),
        .RD   ( clb       ),
        .SE   ( 1'b0      ),
        .SI   ( 1'b0      ),
        .Q    ( o         )
    );
    
`else
    reg d1, d2;

    always @(posedge ck or negedge clb) begin
        if (~clb)
            {d2, d1} <= 2'b0;
        else
            {d2, d1} <= {d1, d}; 
    end 

    assign o = d2;

`endif


endmodule
