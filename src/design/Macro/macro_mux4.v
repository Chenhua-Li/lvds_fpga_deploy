// 4-input MUX
module macro_mux4 (
    input        d0,  
    input        d1,  
    input        d2,  
    input        d3,  
    input [1:0]  s,
    output       o
);

macro_mux2 u_mux2_00(
    .d0   ( d0          ), 
    .d1   ( d1          ), 
    .s    ( s[0]        ), 
    .o    ( out_00      ) 
);

macro_mux2 u_mux2_01(
    .d0   ( d2          ), 
    .d1   ( d3          ), 
    .s    ( s[0]        ), 
    .o    ( out_01      ) 
);

macro_mux2 u_mux2_10(
    .d0   ( out_00      ), 
    .d1   ( out_01      ), 
    .s    ( s[1]        ), 
    .o    ( o           ) 
);

endmodule
