module macro_delay_chain (
    input               invert_ctrl ,
    input  [127:0]      delay_ctrl  ,
    input               delay_sig   ,
    output              delayed_out
);

wire  [127:0]  left_out     ;
wire  [127:0]  right_out    ;
wire           left_out_inv ; 

macro_inv u_dtc_outinv(
    .a              (  left_out[0]        ), 
    .o              (  left_out_inv       ) 
);

macro_mux2 u_dtc_outmux(
    .d0             (  left_out[0]        ), 
    .d1             (  left_out_inv       ), 
    .s              (  invert_ctrl        ), 
    .o              (  delayed_out        ) 
);

macro_delay_cell u_dtc_delay_cell_0(
    .ctrl           (  delay_ctrl[0]      ),
    .left_in        (  delay_sig          ),
    .right_in       (  left_out[1]        ),
    .right_out      (  right_out[0]       ),
    .left_out       (  left_out[0]        )
);

macro_delay_cell u_dtc_delay_cell_1(
    .ctrl           (  delay_ctrl[1]      ),
    .left_in        (  right_out[0]       ),
    .right_in       (  left_out[2]        ),
    .right_out      (  right_out[1]       ),
    .left_out       (  left_out[1]        )
);

genvar i;
generate
for (i=2;i<127;i=i+1) begin
macro_delay_cell u_dtc_delay_cell_n(
    .ctrl           (  delay_ctrl[i]      ),
    .left_in        (  right_out[i-1]     ),
    .right_in       (  left_out[i+1]      ),
    .right_out      (  right_out[i]       ),
    .left_out       (  left_out[i]        )
);
end
endgenerate

//127 stage of delay cell
macro_delay_cell u_dtc_delay_cell_127(
    .ctrl           (  delay_ctrl[127]    ),
    .left_in        (  right_out[126]     ),
    .right_in       (  right_out[127]     ),
    .right_out      (  right_out[127]     ),
    .left_out       (  left_out[127]      )
);

endmodule

