module macro_delay_block (
    input               scan_mode    ,
    input  [7:0]        delay_ctrl   ,
    input               delay_sig    ,
    output              delayed_out
);

wire [127:0] thermo_ctrl;
wire         invert_ctrl;

assign invert_ctrl = delay_ctrl[7];

`ifndef FPGA
    macro_hex2thermo u_hex2thermo(
        .hex            (  delay_ctrl[6:0]     ), 
        .thermo         (  thermo_ctrl         )  
    );
    macro_delay_chain u_delay_chain(
        .invert_ctrl    (  invert_ctrl         ), 
        .delay_ctrl     (  thermo_ctrl         ), 
        .delay_sig      (  delay_sig           ), 
        .delayed_out    (  delayed_out         )  
    );
`else
    wire     casc_out_0;
    wire     casc_out_1;

    wire     casc_return_1;
    wire     casc_return_2;

    wire     delayed_sig_mux;
    wire     delayed_sig;
    wire     delayed_sig_inv;

    IDELAYE3 #(
      .CASCADE("MASTER"),               // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
      .DELAY_FORMAT("COUNT"),          // Units of the DELAY_VALUE (COUNT, TIME)
      .DELAY_SRC("DATAIN"),          // Delay input (DATAIN, IDATAIN)
      .DELAY_TYPE("VAR_LOAD"),           // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
      .DELAY_VALUE(0),                // Input delay value setting
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .REFCLK_FREQUENCY(500.0),       // IDELAYCTRL clock input frequency in MHz (200.0-800.0)
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
      .UPDATE_MODE("ASYNC")           // Determines when updates to the delay will take effect (ASYNC, MANUAL,
                                      // SYNC)
   )
   IDELAYE3_inst_0 (
      .CASC_OUT(casc_out_0),       // 1-bit output: Cascade delay output to ODELAY input cascade
      .CNTVALUEOUT(), // 9-bit output: Counter value output
      .DATAOUT(delayed_sig),         // 1-bit output: Delayed data output
      .CASC_IN(),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
      .CASC_RETURN(casc_return_1), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
      .CE(1'b0),                   // 1-bit input: Active-High enable increment/decrement input
      .CLK(delay_sig),                 // 1-bit input: Clock input
      .CNTVALUEIN({delay_ctrl[6:0], 2'b00}),   // 9-bit input: Counter value input
      .DATAIN(delay_sig),           // 1-bit input: Data input from the logic
      .EN_VTC(1'b0),           // 1-bit input: Keep delay constant over VT
      .IDATAIN(),         // 1-bit input: Data input from the IOBUF
      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
      .LOAD(1'b1),               // 1-bit input: Load DELAY_VALUE input
      .RST(1'b0)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );
   
   ODELAYE3 #(
      .CASCADE("SLAVE_MIDDLE"),               // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
      .DELAY_FORMAT("COUNT"),          // (COUNT, TIME)
      .DELAY_TYPE("VAR_LOAD"),           // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
      .DELAY_VALUE(0),                // Output delay tap setting
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .REFCLK_FREQUENCY(500.0),       // IDELAYCTRL clock input frequency in MHz (200.0-800.0).
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
      .UPDATE_MODE("ASYNC")           // Determines when updates to the delay will take effect (ASYNC, MANUAL,
                                      // SYNC)
   )
   ODELAYE3_inst_1 (
      .CASC_OUT(casc_out_1),       // 1-bit output: Cascade delay output to IDELAY input cascade
      .CNTVALUEOUT(), // 9-bit output: Counter value output
      .DATAOUT(casc_return_1),         // 1-bit output: Delayed data from ODATAIN input port
      .CASC_IN(casc_out_0),         // 1-bit input: Cascade delay input from slave IDELAY CASCADE_OUT
      .CASC_RETURN(casc_return_2), // 1-bit input: Cascade delay returning from slave IDELAY DATAOUT
      .CE(1'b0),                   // 1-bit input: Active-High enable increment/decrement input
      .CLK(delay_sig),                 // 1-bit input: Clock input
      .CNTVALUEIN({delay_ctrl[6:0], 2'b00}),   // 9-bit input: Counter value input
      .EN_VTC(1'b0),           // 1-bit input: Keep delay constant over VT
      .INC(1'b0),                 // 1-bit input: Increment/Decrement tap delay input
      .LOAD(1'b1),               // 1-bit input: Load DELAY_VALUE input
      .ODATAIN(),         // 1-bit input: Data input
      .RST(1'b0)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );
   
   IDELAYE3 #(
      .CASCADE("SLAVE_END"),               // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
      .DELAY_FORMAT("COUNT"),          // Units of the DELAY_VALUE (COUNT, TIME)
      .DELAY_SRC("DATAIN"),          // Delay input (DATAIN, IDATAIN)
      .DELAY_TYPE("VAR_LOAD"),           // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
      .DELAY_VALUE(0),                // Input delay value setting
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .REFCLK_FREQUENCY(500.0),       // IDELAYCTRL clock input frequency in MHz (200.0-800.0)
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
      .UPDATE_MODE("ASYNC")           // Determines when updates to the delay will take effect (ASYNC, MANUAL,
                                      // SYNC)
   )
   IDELAYE3_inst_2 (
      .CASC_OUT(),       // 1-bit output: Cascade delay output to ODELAY input cascade
      .CNTVALUEOUT(), // 9-bit output: Counter value output
      .DATAOUT(casc_return_2),         // 1-bit output: Delayed data output
      .CASC_IN(casc_out_1),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
      .CASC_RETURN(), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
      .CE(1'b0),                   // 1-bit input: Active-High enable increment/decrement input
      .CLK(delay_sig),                 // 1-bit input: Clock input
      .CNTVALUEIN({delay_ctrl[6:0], 2'b00}),   // 9-bit input: Counter value input
      .DATAIN(),           // 1-bit input: Data input from the logic
      .EN_VTC(1'b0),           // 1-bit input: Keep delay constant over VT
      .IDATAIN(),         // 1-bit input: Data input from the IOBUF
      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
      .LOAD(1'b1),               // 1-bit input: Load DELAY_VALUE input
      .RST(1'b0)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );

    macro_mux2 u_delay_clkmux(
        .d0             (  delay_sig            ), 
        .d1             (  delayed_sig          ), 
        .s              (  | delay_ctrl[6:0]    ), 
        .o              (  delayed_sig_mux      ) 
    );

    macro_inv u_drv_clkinv(
        .a              (  delayed_sig_mux      ), 
        .o              (  delayed_sig_inv      ) 
    );

    macro_mux2 u_inv_clkmux(
        .d0             (  delayed_sig_mux      ), 
        .d1             (  delayed_sig_inv      ), 
        .s              (  invert_ctrl          ), 
        .o              (  delayed_out          ) 
    );
`endif
// macro_mux2 u_bypass_mux(
//     .d0             (  delayed_sig         ),
//     .d1             (  delay_sig           ),
//     .s              (  scan_mode           ),
//     .o              (  delayed_out         )
// );

endmodule

