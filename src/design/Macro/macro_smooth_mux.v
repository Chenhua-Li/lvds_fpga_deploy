// Glitch-less Clock MUX;
// When enable = 0,   clkout = clk0
// When enable = 1,   clkout = clk1
// When test_en high, clkout = clk1
// If ASET_EN=1
// When rst_n  = 0,   clkout = clk1 
// If ASET_EN=0
// When rst_n  = 0,   clkout = 0 

module macro_smooth_mux #(
    parameter SYNC_EN = 1, 
    parameter ASET_EN = 1 
)(
    input    rst_n      ,
    input    clk0       ,
    input    clk1       ,
    input    enable     ,
    input    test_en    ,
    output   clkout
);

`ifndef FPGA
    wire clk0_sel_synced;
    wire clk1_sel_synced;

    wire clk0_rst_n;
    wire clk1_rst_n;

    wire clk0_gated;
    wire clk1_gated;
    wire clk_gated_ored;

    wire clk0_sel_synced_delay_b;
    wire clk1_sel_synced_delay_b;

    wire clk0_en_cg = clk0_sel_synced & ~test_en;
    wire clk1_en_cg = clk1_sel_synced |  test_en;

    wire clk0_sel = ~enable & clk1_sel_synced_delay_b;
    wire clk1_sel =  enable & clk0_sel_synced_delay_b;


    if (SYNC_EN > 0) begin : sync 
        //reset sync @clk0
        macro_reset_sync2 u_clk0_resync (
            .test_en      ( test_en                 ), 
            .reset_n      ( rst_n                   ), 
            .ck           ( clk0                    ),  
            .reset_sync_n ( clk0_rst_n              )
        );
        
        //reset sync @clk1
        macro_reset_sync2 u_clk1_resync (
            .test_en      ( test_en                 ), 
            .reset_n      ( rst_n                   ), 
            .ck           ( clk1                    ),  
            .reset_sync_n ( clk1_rst_n              )
        );
    end else begin
        assign clk0_rst_n = rst_n;
        assign clk1_rst_n = rst_n;
    end 

    //below is functional logic   
    if (ASET_EN > 0) begin : aset 
        macro_sync2s u_sync_clk0_en(
            .d            ( clk0_sel                ),
            .ck           ( clk0                    ),
            .clb          ( clk0_rst_n              ),
            .o            ( clk0_sel_synced         )
        );
    end else begin
        macro_sync2r u_sync_clk0_en(
            .d            ( clk0_sel                ),
            .ck           ( clk0                    ),
            .clb          ( clk0_rst_n              ),
            .o            ( clk0_sel_synced         )
        );
    end

    macro_dffrqn u_sync_clk0_en_dly(
        .ck           ( clk0                    ), 
        .clb          ( clk0_rst_n              ), 
        .d            ( clk0_sel_synced         ),
        .qn           ( clk0_sel_synced_delay_b )
    );

    macro_sync2r u_sync_clk1_en(
        .d            ( clk1_sel                ),
        .ck           ( clk1                    ),
        .clb          ( clk1_rst_n              ),
        .o            ( clk1_sel_synced         )
    );

    macro_dffrqn u_sync_clk1_en_dly(
        .ck           ( clk1                    ), 
        .clb          ( clk1_rst_n              ), 
        .d            ( clk1_sel_synced         ),
        .qn           ( clk1_sel_synced_delay_b )
    );

    macro_preicg u_clk0_ckg(
        .te           ( 1'b0                    ),
        .ck           ( clk0                    ),
        .en           ( clk0_en_cg              ),
        .ckg          ( clk0_gated              )
    );

    macro_preicg u_clk1_ckg(        
        .te           ( 1'b0                    ),
        .ck           ( clk1                    ),
        .en           ( clk1_en_cg              ),
        .ckg          ( clk1_gated              )
    );

    macro_or2 u_clk_2or(
        .a            ( clk0_gated              ),
        .b            ( clk1_gated              ),
        .o            ( clk_gated_ored          )
    );
        
    //required by DFT guy  
    macro_clk_mux u_scan_mux(
        .d0           ( clk_gated_ored          ),
        .d1           ( clk1                    ),
        .s            ( test_en                 ),
        .o            ( clkout                  )
    );
`else
    BUFGMUX #(
        .CLK_SEL_TYPE("SYNC")  // ASYNC, SYNC
    )
    SMOOTHMUX_inst (
        .O(clkout),   // 1-bit output: Clock output
        .I0(clk0), // 1-bit input: Clock input (S=0)
        .I1(clk1), // 1-bit input: Clock input (S=1)
        .S(enable)    // 1-bit input: Clock select
    );
`endif

endmodule

