// 3 Stage Synchronizer, with asynchronous set high 
module macro_sync3s (
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
    SVQ_FSDPSBQ_V2_2 u_preserved_gate1 (
        .D    ( d         ),
        .CK   ( ck        ),
        .SD   ( clb       ),
        .SE   ( 1'b0      ),
        .SI   ( 1'b0      ),
        .Q    ( d1        )
    );

    SVQ_FSDPSBQ_V2_2 u_preserved_gate2 (
        .D    ( d1        ),
        .CK   ( ck        ),
        .SD   ( clb       ),
        .SE   ( 1'b0      ),
        .SI   ( 1'b0      ),
        .Q    ( d2        )
    );

    SVQ_FSDPSBQ_V2_2 u_preserved_gate3 (
        .D    ( d2        ),
        .CK   ( ck        ),
        .SD   ( clb       ),
        .SE   ( 1'b0      ),
        .SI   ( 1'b0      ),
        .Q    ( o         )
    );
    
`else
    reg d1, d2, d3;

    always @(posedge ck or negedge clb) begin
        if (~clb)
            {d3, d2, d1} <= 3'b111;
        else
            {d3, d2, d1} <= {d2, d1, d}; 
    end 

    assign o = d3;

`endif


endmodule
