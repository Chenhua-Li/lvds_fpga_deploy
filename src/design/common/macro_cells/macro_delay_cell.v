`timescale 1ps/1fs

module macro_delay_cell (
  input     ctrl        ,
  input     left_in     ,
  input     right_in    ,
  output    right_out   ,
  output    left_out
);

wire middle_out;
wire ctrl_n;

wire right_out_tmp;
wire left_out_tmp;

macro_inv u_dtc_inv_ctrl(
    .a ( ctrl           ),
    .o ( ctrl_n         )
);

macro_nand2 u_dtc_nand_ur(
    .a ( ctrl           ),
    .b ( left_in        ),
    .o ( right_out_tmp  )
);

macro_nand2 u_dtc_nand_m(
    .a ( left_in        ),
    .b ( ctrl_n         ),
    .o ( middle_out     )
);

macro_nand2 u_dtc_nand_dl(
    .a ( right_in       ),
    .b ( middle_out     ),
    .o ( left_out_tmp   )
);

assign #24  right_out = right_out_tmp;
assign #24  left_out  = left_out_tmp;

endmodule
