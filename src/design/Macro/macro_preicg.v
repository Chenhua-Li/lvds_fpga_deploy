// Clock Gating Cell 
module macro_preicg (te, en, ck, ckg);

input  te, en, ck;
output ckg;

`ifdef UMC28HPCP
    SVQ_CKGTPLT_V5_2 u_preserved_preicg (
        .SE    ( te             ),
        .EN    ( en             ),
        .CK    ( ck             ),
        .Q     ( ckg            )
    );
`elsif FPGA
    BUFGCE #(
        .CE_TYPE("SYNC"),               // ASYNC, HARDSYNC, SYNC
        .IS_CE_INVERTED(1'b0),          // Programmable inversion on CE
        .IS_I_INVERTED(1'b0),           // Programmable inversion on I
        .SIM_DEVICE("ULTRASCALE_PLUS")  // ULTRASCALE, ULTRASCALE_PLUS
    )
        BUFGCE_inst (
        .O(ckg),   // 1-bit output: Buffer
        .CE(en), // 1-bit input: Buffer enable
        .I(ck)    // 1-bit input: Buffer
    );
`else
    reg en_reg;

    always @(ck or en) begin
        if (ck==1'b0)
            en_reg <= en;    
    end

    assign ckg = en_reg & ck ;

`endif

endmodule

