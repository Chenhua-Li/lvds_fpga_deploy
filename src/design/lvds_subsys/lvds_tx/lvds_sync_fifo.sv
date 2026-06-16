module lvds_sync_fifo
#(
    parameter FIFO_ADDR_WIDTH = 8,
    parameter FIFO_WM_WIDTH   = 6,
    parameter FIFO_DATA_WIDTH = 32
    )
(
    input                                           clk,
    input                                           rstn,
    input       [FIFO_WM_WIDTH-1:0]                 wr_wm,
    input       [FIFO_WM_WIDTH-1:0]                 rd_wm,
    output      logic                               fifo_almost_full,
    output      logic                               fifo_almost_empty,
    input                                           push_en,
    input       [FIFO_DATA_WIDTH-1:0]               push_data,
    output      logic                               fifo_full,
    input                                           pop_en,
    output      [FIFO_DATA_WIDTH-1:0]               pop_data,
    output      logic                               fifo_empty
    );

logic   [FIFO_ADDR_WIDTH:0]                     wr_ptr;
logic   [FIFO_ADDR_WIDTH:0]                     rd_ptr;
logic   [FIFO_ADDR_WIDTH-1:0]                   wr_diff_pre;
logic   [FIFO_ADDR_WIDTH-1:0]                   wr_diff;
logic   [FIFO_ADDR_WIDTH-1:0]                   rd_diff_pre;
logic   [FIFO_ADDR_WIDTH-1:0]                   rd_diff;
logic                                           empty_w;
logic                                           rd_en;
logic   [FIFO_ADDR_WIDTH:0]                     rd_ptr_inc;
logic                                           full_w;
logic   [FIFO_ADDR_WIDTH:0]                     wr_ptr_inc;
logic                                           wr_en;
logic                                           fifo_almost_empty_w;
logic                                           fifo_almost_full_w;

//write
assign wr_en                               = push_en & ~fifo_full;
assign wr_ptr_inc                          = wr_ptr + 1;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        wr_ptr                              <= 'h0;
    end
    else if(wr_en) begin
        wr_ptr                              <= wr_ptr_inc;
    end
end

assign full_w                              = (
                (wr_ptr_inc[FIFO_ADDR_WIDTH] == ~rd_ptr[FIFO_ADDR_WIDTH]) &
                (wr_ptr_inc[FIFO_ADDR_WIDTH-1:0] == rd_ptr[FIFO_ADDR_WIDTH-1:0]) &
                wr_en
    ) | (
                (wr_ptr[FIFO_ADDR_WIDTH] == ~rd_ptr[FIFO_ADDR_WIDTH]) & 
                (wr_ptr[FIFO_ADDR_WIDTH-1:0] == rd_ptr[FIFO_ADDR_WIDTH-1:0])
    );

always @(posedge clk or negedge rstn) begin
    if(~rstn)
        fifo_full                           <= 1'b0;
    else
        fifo_full                           <= full_w;
end

//read
assign rd_en                               = pop_en & ~fifo_empty;
assign rd_ptr_inc                          = rd_ptr + 1;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        rd_ptr                              <= 'h0;
    end
    else if(rd_en) begin
        rd_ptr                              <= rd_ptr_inc;
    end
end

assign empty_w                             = (
                (rd_ptr_inc[FIFO_ADDR_WIDTH] == wr_ptr[FIFO_ADDR_WIDTH]) &
                (rd_ptr_inc[FIFO_ADDR_WIDTH-1:0] == wr_ptr[FIFO_ADDR_WIDTH-1:0]) &
                rd_en
    ) | (
                (rd_ptr[FIFO_ADDR_WIDTH] == wr_ptr[FIFO_ADDR_WIDTH]) & 
                (rd_ptr[FIFO_ADDR_WIDTH-1:0] == wr_ptr[FIFO_ADDR_WIDTH-1:0])
    );

always @(posedge clk or negedge rstn) begin
    if(~rstn)
        fifo_empty                          <= 1'b1;
    else
        fifo_empty                          <= empty_w;
end

lvds_tx_ram #(
    .ADDR_WIDTH                         ( FIFO_ADDR_WIDTH             ),
    .DATA_WIDTH                         ( FIFO_DATA_WIDTH             )
    ) u_fifo_reg_file(

    .ram_rtsel                          ( 2'b00                       ),
    .ram_wtsel                          ( 2'b00                       ),
    .ram_ptsel                          ( 2'b00                       ),
    .clk                                ( clk                         ),
    .wr_en                              ( wr_en                       ),
    .wr_addr                            ( wr_ptr[FIFO_ADDR_WIDTH-1:0] ),
    .data_in                            ( push_data                   ),
    .rd_en                              ( rd_en                       ),
    .rd_addr                            ( rd_ptr[FIFO_ADDR_WIDTH-1:0] ),
    .data_out                           ( pop_data                    )
    );

assign rd_diff_pre                         = wr_ptr[FIFO_ADDR_WIDTH-1:0] - rd_ptr_inc[FIFO_ADDR_WIDTH-1:0];
assign rd_diff                             = wr_ptr[FIFO_ADDR_WIDTH-1:0] - rd_ptr[FIFO_ADDR_WIDTH-1:0];
assign wr_diff_pre                         = rd_ptr[FIFO_ADDR_WIDTH-1:0] - wr_ptr_inc[FIFO_ADDR_WIDTH-1:0];
assign wr_diff                             = rd_ptr[FIFO_ADDR_WIDTH-1:0] - wr_ptr[FIFO_ADDR_WIDTH-1:0];

assign fifo_almost_empty_w                 = ((rd_diff_pre == {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH){1'b0}},rd_wm}) & rd_en) 
                    |
                (rd_diff < {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH){1'b0}},rd_wm});

assign fifo_almost_full_w                  = ((wr_diff_pre == {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH){1'b0}},wr_wm}) & wr_en) 
                    |
                    (wr_diff < {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH){1'b0}},wr_wm});

always @(posedge clk or negedge rstn)
    if(~rstn) begin
        fifo_almost_full                    <= 'h0;
        fifo_almost_empty                   <= 'h0;
    end
    else begin
        fifo_almost_full                    <= fifo_almost_full_w;
        fifo_almost_empty                   <= fifo_almost_empty_w;
    end

endmodule
