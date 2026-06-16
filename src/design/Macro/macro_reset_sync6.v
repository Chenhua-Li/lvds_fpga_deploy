// 6 Stage Reset Synchronizer
// - assume asynchronous, active-low reset_n input
// - assume ck  is running during reset
// - reset_sync_n output is asynchronously asserted, synchronously deasserted
// - reset_sync_n forced to orignal reset_n when test_en high 

module macro_reset_sync6 (test_en, reset_n, ck, reset_sync_n);

input  test_en;
input  reset_n;
input  ck; 
output reset_sync_n;

`ifdef UMC28HPCP
    SVQ_FSDPRBQ_D_2 u_preserved_gate1 (
        .D     ( 1'b1           ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d1             )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate2 (
        .D     ( d1             ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d2             )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate3 (
        .D     ( d2             ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d3             )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate4 (
        .D     ( d3             ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d4             )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate5 (
        .D     ( d4             ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d5             )
    );

    SVQ_FSDPRBQ_D_2 u_preserved_gate6 (
        .D     ( d5             ),
        .CK    ( ck             ),
        .RD    ( reset_n        ),
        .SE    ( 1'b0           ),
        .SI    ( 1'b0           ),
        .Q     ( d6             )
    );

    SVQ_MUX2_2 u_preserved_rst_mux (
        .D0    ( d6             ),
        .D1    ( reset_n        ),
        .S     ( test_en        ),
        .X     ( reset_sync_n   )
    );

`else
    reg d1, d2, d3, d4, d5, d6;

    always @(posedge ck or negedge reset_n) begin
        if (~reset_n)
            {d6, d5, d4, d3, d2, d1} <= 6'b0;
        else
            {d6, d5, d4, d3, d2, d1} <= {d5, d4, d3, d2, d1, 1'b1}; 
    end 

    assign reset_sync_n = test_en ? reset_n : d6;

`endif

endmodule


