module macro_delay_block (
    input               scan_mode    ,
    input  [7:0]        delay_ctrl   ,
    input               delay_sig    ,
    output              delayed_out
);

wire [127:0] thermo_ctrl;
wire         invert_ctrl;
wire         delayed_sig;

assign invert_ctrl = delay_ctrl[7];

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

// macro_mux2 u_bypass_mux(
//     .d0             (  delayed_sig         ),
//     .d1             (  delay_sig           ),
//     .s              (  scan_mode           ),
//     .o              (  delayed_out         )
// );

endmodule

