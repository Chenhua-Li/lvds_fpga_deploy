module generic_afifo_ctrl
#(
    parameter FIFO_ADDR_WIDTH = 2,
    parameter FIFO_DEPTH      = {1'b1,{FIFO_ADDR_WIDTH{1'b0}}},
    parameter FIFO_WM_WIDTH   = 2,
    parameter FIFO_DATA_WIDTH = 32
)
(
    input                               push_clk,
    input                               push_rstn,
    input                               push_en,
    input       [FIFO_DATA_WIDTH-1:0]   push_data,
    output      logic                   fifo_full,
    input                               pop_clk,
    input                               pop_rstn,
    input                               pop_en,
    output      logic                   fifo_empty,
    input       [FIFO_WM_WIDTH-1:0]     wr_wm,
    input       [FIFO_WM_WIDTH-1:0]     rd_wm,
    output      logic                   fifo_almost_full,
    output      logic                   fifo_almost_empty,

    //ram_if
    output                              wr_en,
    output      [FIFO_ADDR_WIDTH-1:0]   wr_addr,
    output      [FIFO_DATA_WIDTH-1:0]   wr_data,
    output                              rd_en,
    output      [FIFO_ADDR_WIDTH-1:0]   rd_addr

);

parameter ADDR_OFFSET = {1'b1,{FIFO_ADDR_WIDTH{1'b0}}} - FIFO_DEPTH;

logic   [FIFO_ADDR_WIDTH:0]wr_ptr;
logic   [FIFO_ADDR_WIDTH:0]wr_ptr_gray_r;
logic   [FIFO_ADDR_WIDTH:0]wr_ptr_gray_w;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr_gray_syn1;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr_gray_r;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr_gray_w;
logic   [FIFO_ADDR_WIDTH:0]wr_ptr_gray_syn1;
logic                   empty_w;
logic   [FIFO_ADDR_WIDTH:0]wr_ptr_bin_2pop;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr_inc;
logic                   full_w;
logic   [FIFO_ADDR_WIDTH:0]rd_ptr_bin_2push;
logic   [FIFO_ADDR_WIDTH:0]wr_ptr_inc;
logic   [FIFO_ADDR_WIDTH-1:0]wr_diff;
logic   [FIFO_ADDR_WIDTH-1:0]rd_diff;
logic                   fifo_almost_empty_w;
logic                   fifo_almost_full_w;

generate 
    if(ADDR_OFFSET == 32'h0) begin

        function [FIFO_ADDR_WIDTH:0] bin2gray(
            input       [FIFO_ADDR_WIDTH:0]     bin_val
        );
            logic [FIFO_ADDR_WIDTH:0] bin2gray_temp;
            begin
                bin2gray_temp                = bin_val ^ {1'b0,bin_val[FIFO_ADDR_WIDTH:1]};
                return bin2gray_temp;
            end
        endfunction
        
        function [FIFO_ADDR_WIDTH:0] gray2bin(
            input       [FIFO_ADDR_WIDTH:0]     gray_val
        );
            int i;
            begin
                gray2bin[FIFO_ADDR_WIDTH]= gray_val[FIFO_ADDR_WIDTH];
                for(i= FIFO_ADDR_WIDTH-1;i>=0;i--) begin
                    gray2bin[i]             = gray2bin[i+1] ^ gray_val[i];
                end
            end
        endfunction

        assign wr_ptr_gray_w           = bin2gray(wr_ptr_inc);
        assign rd_ptr_gray_w           = bin2gray(rd_ptr_inc);
        assign rd_ptr_bin_2push        = gray2bin(rd_ptr_gray_syn1);
        assign wr_ptr_bin_2pop         = gray2bin(wr_ptr_gray_syn1);
    end
    else begin

        function [FIFO_ADDR_WIDTH:0] bin2gray(
            input       [FIFO_ADDR_WIDTH:0]     bin_val
        );
            logic   [FIFO_ADDR_WIDTH:0]bin_val_tmp;
            begin
                if(bin_val[FIFO_ADDR_WIDTH]) begin
                    bin_val_tmp             = bin_val + (FIFO_ADDR_WIDTH-1)'(ADDR_OFFSET);
                end
                else begin
                    bin_val_tmp             = bin_val;
                end
                bin2gray                = bin_val_tmp ^ {1'b0,bin_val_tmp[FIFO_ADDR_WIDTH:1]};
            end
        endfunction
        
        function [FIFO_ADDR_WIDTH:0] gray2bin(
            input       [FIFO_ADDR_WIDTH:0]     gray_val
        );
            int i;
            logic [FIFO_ADDR_WIDTH:0]     bin_tmp;
            begin
                bin_tmp[FIFO_ADDR_WIDTH]= gray_val[FIFO_ADDR_WIDTH];
                for(i= FIFO_ADDR_WIDTH-1;i>=0;i--) begin
                    bin_tmp[i]              = bin_tmp[i+1] ^ gray_val[i];
                end
                if(bin_tmp[FIFO_ADDR_WIDTH]) begin
                    gray2bin                = bin_tmp - (FIFO_ADDR_WIDTH-1)'(ADDR_OFFSET);
                end
                else begin
                    gray2bin                = bin_tmp;
                end
            end
        endfunction

        assign wr_ptr_gray_w           = bin2gray(wr_ptr_inc);
        assign rd_ptr_gray_w           = bin2gray(rd_ptr_inc);
        assign rd_ptr_bin_2push        = gray2bin(rd_ptr_gray_syn1);
        assign wr_ptr_bin_2pop         = gray2bin(wr_ptr_gray_syn1);
    end
endgenerate

generate 
    if(ADDR_OFFSET == 32'h0) begin
        assign wr_ptr_inc     = wr_ptr + 1;
        assign rd_ptr_inc     = rd_ptr + 1;
        assign wr_diff        = rd_ptr_bin_2push[FIFO_ADDR_WIDTH-1:0] - wr_ptr[FIFO_ADDR_WIDTH-1:0];
        assign rd_diff        = wr_ptr_bin_2pop[FIFO_ADDR_WIDTH-1:0] - rd_ptr[FIFO_ADDR_WIDTH-1:0];
    end
    else begin
        assign wr_ptr_inc     = (wr_ptr[FIFO_ADDR_WIDTH-1:0] == (FIFO_DEPTH-1)) ? {~wr_ptr[FIFO_ADDR_WIDTH],{FIFO_ADDR_WIDTH{1'b0}}} : (wr_ptr + 1);
        assign rd_ptr_inc     = (rd_ptr[FIFO_ADDR_WIDTH-1:0] == (FIFO_DEPTH-1)) ? {~rd_ptr[FIFO_ADDR_WIDTH],{FIFO_ADDR_WIDTH{1'b0}}} : (rd_ptr + 1);
        assign wr_diff        = (rd_ptr_bin_2push[FIFO_ADDR_WIDTH] == wr_ptr[FIFO_ADDR_WIDTH]) ? 
                                    (rd_ptr_bin_2push[FIFO_ADDR_WIDTH-1:0] - wr_ptr[FIFO_ADDR_WIDTH-1:0] - ADDR_OFFSET) :
                                    (rd_ptr_bin_2push[FIFO_ADDR_WIDTH-1:0] - wr_ptr[FIFO_ADDR_WIDTH-1:0]);
        assign rd_diff        = (wr_ptr_bin_2pop[FIFO_ADDR_WIDTH] == rd_ptr[FIFO_ADDR_WIDTH]) ? 
                                    (wr_ptr_bin_2pop[FIFO_ADDR_WIDTH-1:0] - rd_ptr[FIFO_ADDR_WIDTH-1:0] - ADDR_OFFSET) :
                                    (wr_ptr_bin_2pop[FIFO_ADDR_WIDTH-1:0] - rd_ptr[FIFO_ADDR_WIDTH-1:0]);
    end
endgenerate

//write
//assign wr_ptr_gray_w           = bin2gray(wr_ptr_inc);

always @(posedge push_clk or negedge push_rstn) begin
    if(~push_rstn) begin
        wr_ptr                  <= 'h0;
        wr_ptr_gray_r           <= 'h0;
    end
    else if(push_en & ~fifo_full) begin
        wr_ptr                  <= wr_ptr_inc;
        wr_ptr_gray_r           <= wr_ptr_gray_w;
    end
end

macro_sync2r u_rd_ptr_gray_syn[FIFO_ADDR_WIDTH:0](  
    .ck                     ( push_clk                              ),
    .clb                    ( push_rstn                             ),
    .d                      ( rd_ptr_gray_r                         ),
    .o                      ( rd_ptr_gray_syn1                      )
);

//assign rd_ptr_bin_2push        = gray2bin(rd_ptr_gray_syn1);

assign fifo_almost_full_w      = (
                                    (wr_diff <= {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH-2){1'b0}},wr_wm,2'b00}) & 
                                    (rd_ptr_bin_2push != wr_ptr)
                                 );
assign full_w                  = (
                (wr_ptr_inc[FIFO_ADDR_WIDTH] == ~rd_ptr_bin_2push[FIFO_ADDR_WIDTH]) &
                (wr_ptr_inc[FIFO_ADDR_WIDTH-1:0] == rd_ptr_bin_2push[FIFO_ADDR_WIDTH-1:0]) &
                push_en
                ) | (
                (wr_ptr[FIFO_ADDR_WIDTH] == ~rd_ptr_bin_2push[FIFO_ADDR_WIDTH]) & 
                (wr_ptr[FIFO_ADDR_WIDTH-1:0] == rd_ptr_bin_2push[FIFO_ADDR_WIDTH-1:0])
                );

always @(posedge push_clk or negedge push_rstn) begin
    if(~push_rstn) begin
        fifo_full               <= 1'b0;
        fifo_almost_full        <= 'h0;
    end
    else begin
        fifo_full               <= full_w;
        fifo_almost_full        <= fifo_almost_full_w;
    end
end

//read
//assign rd_ptr_gray_w           = bin2gray(rd_ptr_inc);

always @(posedge pop_clk or negedge pop_rstn) begin
    if(~pop_rstn) begin
        rd_ptr                  <= 'h0;
        rd_ptr_gray_r           <= 'h0;
    end
    else if(pop_en & ~fifo_empty) begin
        rd_ptr                  <= rd_ptr_inc;
        rd_ptr_gray_r           <= rd_ptr_gray_w;
    end
end

macro_sync2r u_wr_ptr_gray_syn[FIFO_ADDR_WIDTH:0](  
    .ck                     ( pop_clk                               ),
    .clb                    ( pop_rstn                              ),
    .d                      ( wr_ptr_gray_r                         ),
    .o                      ( wr_ptr_gray_syn1                      )
);

//assign wr_ptr_bin_2pop         = gray2bin(wr_ptr_gray_syn1);

assign fifo_almost_empty_w     = (
                                    (rd_diff <= {{(FIFO_ADDR_WIDTH-FIFO_WM_WIDTH-2){1'b0}},rd_wm,2'b00}) &
                                    (wr_ptr_bin_2pop != {~rd_ptr[FIFO_ADDR_WIDTH],rd_ptr[FIFO_ADDR_WIDTH-1:0]})
                                 );

assign empty_w                 = (
                (rd_ptr_inc[FIFO_ADDR_WIDTH] == wr_ptr_bin_2pop[FIFO_ADDR_WIDTH]) &
                (rd_ptr_inc[FIFO_ADDR_WIDTH-1:0] == wr_ptr_bin_2pop[FIFO_ADDR_WIDTH-1:0]) &
                pop_en
                ) | (
                (rd_ptr[FIFO_ADDR_WIDTH] == wr_ptr_bin_2pop[FIFO_ADDR_WIDTH]) & 
                (rd_ptr[FIFO_ADDR_WIDTH-1:0] == wr_ptr_bin_2pop[FIFO_ADDR_WIDTH-1:0])
                );

always @(posedge pop_clk or negedge pop_rstn) begin
    if(~pop_rstn) begin
        fifo_empty              <= 1'b1;
        fifo_almost_empty       <= 'h1;
    end
    else begin
        fifo_empty              <= empty_w;
        fifo_almost_empty       <= fifo_almost_empty_w;
    end
end

assign wr_en                   = push_en & ~fifo_full;
assign wr_addr                 = wr_ptr[FIFO_ADDR_WIDTH-1:0];
assign wr_data                 = push_data;
assign rd_en                   = pop_en & ~fifo_empty;
assign rd_addr                 = rd_ptr[FIFO_ADDR_WIDTH-1:0];

endmodule
