module lvds_generic_afifo
#(
    parameter FIFO_DATA_WIDTH = 9,
    parameter FIFO_ADDR_WIDTH = 6,
    parameter FIFO_WM_WIDTH = 4

)
(
    input                               push_clk,
    input                               push_rstn,
    input                               push_en,
    input       [FIFO_DATA_WIDTH-1:0]   push_data,
    input       [FIFO_WM_WIDTH-1:0]     wr_wm,
    output                              fifo_full,
    output                              fifo_almost_full,
    input                               pop_clk,
    input                               pop_rstn,
    input                               pop_en,
    output      [FIFO_DATA_WIDTH-1:0]   pop_data,
    input       [FIFO_WM_WIDTH-1:0]     rd_wm,
    output                              fifo_empty,
    output      fifo_almost_empty
    
);

logic                   wr_en;
logic   [FIFO_ADDR_WIDTH-1:0]wr_addr;
logic   [FIFO_DATA_WIDTH-1:0]wr_data;
logic                   rd_en;
logic   [FIFO_ADDR_WIDTH-1:0]rd_addr;

localparam FIFO_DEPTH = 2**FIFO_ADDR_WIDTH;
//5KB
generic_afifo_ctrl
#(
    .FIFO_ADDR_WIDTH        ( FIFO_ADDR_WIDTH                       ),
    .FIFO_DEPTH             ( FIFO_DEPTH                            ),
    .FIFO_WM_WIDTH          ( FIFO_WM_WIDTH                         ),
    .FIFO_DATA_WIDTH        ( FIFO_DATA_WIDTH                       )
)
u_afifo_ctrl(
    .push_clk               ( push_clk                              ),
    .push_rstn              ( push_rstn                             ),
    .push_en                ( push_en                               ),
    .push_data              ( push_data                             ),
    .fifo_full              ( fifo_full                             ),
    .pop_clk                ( pop_clk                               ),
    .pop_rstn               ( pop_rstn                              ),
    .pop_en                 ( pop_en                                ),
    .fifo_empty             ( fifo_empty                            ),
    .wr_wm                  ( wr_wm                                 ),
    .rd_wm                  ( rd_wm                                 ),
    .fifo_almost_full       ( fifo_almost_full                      ),
    .fifo_almost_empty      ( fifo_almost_empty                     ),

    //ram_if
    .wr_en                  ( wr_en                                 ),
    .wr_addr                ( wr_addr                               ),
    .wr_data                ( wr_data                               ),
    .rd_en                  ( rd_en                                 ),
    .rd_addr                ( rd_addr                               )

);

lvds_generic_afifo_regfile
#(
    .ADDR_WIDTH             ( FIFO_ADDR_WIDTH                       ),
    .DATA_WIDTH             ( FIFO_DATA_WIDTH                       )
) u_afifo_reg_file(
    .clk                    ( push_clk                              ),
    .wr_en                  ( wr_en                                 ),
    .wr_addr                ( wr_addr                               ),
    .data_in                ( wr_data                               ),
    .rd_addr                ( rd_addr                               ),
    .data_out               ( pop_data                              )
);

endmodule
