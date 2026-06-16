module macro_pinmux2 #(parameter INLEVEL = 1'b0) (
    input          pad_sel ,

    input          p0_oe   ,
    input          p0_ie   ,
    input          p0_i    ,
    output         p0_c    ,
 
    input          p1_oe   ,
    input          p1_ie   ,
    input          p1_i    ,
    output         p1_c    ,
   
    output         pad_ie  ,
    output         pad_oe  , 
    output         pad_i   ,
    input          pad_c    
);

//pad_i  = pad_sel ? p1_i : p0_i
macro_mux2 u_mux_i (
    .d0   (  p0_i     ), 
    .d1   (  p1_i     ), 
    .s    (  pad_sel  ), 
    .o    (  pad_i    )
);

//p0_c =  pad_sel ? 1'b0 : pad_c 
macro_mux2 u_p0_c (
    .d0   (  pad_c    ), 
    .d1   (  INLEVEL  ), 
    .s    (  pad_sel  ), 
    .o    (  p0_c     )
);
 
//p1_c =  pad_sel ? pad_c: 1'b0
macro_mux2 u_p1_c (
    .d0   (  INLEVEL  ), 
    .d1   (  pad_c    ), 
    .s    (  pad_sel  ), 
    .o    (  p1_c     )
);
 
//pad_ie = pad_sel ? p1_ie : p0_ie
macro_mux2 u_mux_ie (
    .d0   (  p0_ie    ), 
    .d1   (  p1_ie    ), 
    .s    (  pad_sel  ), 
    .o    (  pad_ie   )
);

//pad_oe = pad_sel ? p1_oe : p0_oe 
macro_mux2 u_mux_oe (
    .d0   (  p0_oe    ), 
    .d1   (  p1_oe    ), 
    .s    (  pad_sel  ), 
    .o    (  pad_oe   )
);

endmodule

