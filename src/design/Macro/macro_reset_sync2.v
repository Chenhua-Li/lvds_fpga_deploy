// 2 Stage Reset Synchronizer
// - assume asynchronous, active-low reset_n input
// - assume ck  is running during reset
// - reset_sync_n output is asynchronously asserted, synchronously deasserted
// - reset_sync_n forced to orignal reset_n when test_en high 

module macro_reset_sync2 (test_en, reset_n, ck, reset_sync_n);

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

    SVQ_MUX2_2 u_preserved_rst_mux (
        .D0    ( d2             ),
        .D1    ( reset_n        ),
        .S     ( test_en        ),
        .X     ( reset_sync_n   )
    );

`else
    reg d1, d2;

    always @(posedge ck or negedge reset_n) begin
        if (~reset_n)
            {d2, d1} <= 2'b0;
        else
            {d2, d1} <= {d1, 1'b1}; 
    end 

    assign reset_sync_n = test_en ? reset_n : d2;

`endif

endmodule


