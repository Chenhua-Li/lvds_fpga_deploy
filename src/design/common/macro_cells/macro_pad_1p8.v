module macro_pad_1p8 (
    inout         PORE   ,
    inout         PAD    ,
    input         I      ,
    output        C      , 
    input         OE     , 
    input         IE     ,
    input  [5:0]  CFG     
);

`ifdef UMC28HPCP
    // CFG[5] is unused but reserved at first
    wire   PIN2 = CFG[4]   ; 
    wire   PIN1 = CFG[3]   ; 
    wire   SMT  = CFG[2]   ; 
    wire   PU   = CFG[1]   ; 
    wire   PD   = CFG[0]   ; 
    
    SUMBFSX U_PAD(
    `ifdef PG_SIM_MODE
        .VDD     (  1'b1        ), 
        .VDDIO   (  1'b1        ), 
        .VSS     (  1'b0        ), 
        .VSSIO   (  1'b0        ), 
    `endif
        .PORE    (  PORE        ), 
        .IDDQ    (  1'b0        ), //leave for DFT
        .PAD     (  PAD         ), 
        .IE      (  IE          ), 
        .OE      (  OE          ), 
        .DI      (  C           ), 
        .DO      (  I           ), 
        .PIN2    (  PIN2        ), //cfg 4 Drive Strength 
        .PIN1    (  PIN1        ), //cfg 3 Drive Strength 
        .SMT     (  SMT         ), //cfg 2 Schimitt Trigger 
        .PU      (  PU          ), //cfg 1 
        .PD      (  PD          )  //cfg 0 
    );
    
`else
    GENERIC_PAD U_PAD(
        .PAD     (  PAD         ),
        .Y       (  I           ), 
        .OE      (  OE          ),
        .IE      (  IE          ), 
        .A       (  C           )
    );

`endif

endmodule


module macro_spoc_1p8 (
    output        PORE   
);

`ifdef UMC28HPCP
    SPOCX U_SPOC(
    `ifdef PG_SIM_MODE
        .VDD     (  1'b1        ), 
        .VDDIO   (  1'b1        ), 
        .VSS     (  1'b0        ), 
        .VSSIO   (  1'b0        ), 
    `endif
        .PORE    (  PORE        )
    );
    
`else
    assign PORE = 1'b0;

`endif

endmodule
