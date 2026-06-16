module lvds_generic_afifo_regfile #(
    parameter ADDR_WIDTH = 2,
    parameter DATA_WIDTH = 16
)
(
    input                           clk,
    input                           wr_en,
    input   [ADDR_WIDTH-1:0]        wr_addr,
    input   [DATA_WIDTH-1:0]        data_in,
    input   [ADDR_WIDTH-1:0]        rd_addr,
    output  [DATA_WIDTH-1:0]        data_out
);

localparam FIFO_DEPTH = 2**ADDR_WIDTH;

reg  [DATA_WIDTH-1:0] mem_reg [0:FIFO_DEPTH-1];

always @(posedge clk) begin
    if(wr_en)
        mem_reg[wr_addr]  <= data_in;
end

assign data_out  = mem_reg[rd_addr];

endmodule
