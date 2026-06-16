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

`else
    reg en_reg;

    always @(ck or en) begin
        if (ck==1'b0)
            en_reg <= en;    
    end

    assign ckg = en_reg & ck ;

`endif

endmodule

