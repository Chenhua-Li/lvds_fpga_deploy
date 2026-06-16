
module axis_fifo #(
    // FIFO depth in words
    // KEEP_WIDTH words per cycle if KEEP_ENABLE set
    // Rounded up to nearest power of 2 cycles
    parameter DEPTH = 4096,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    // If disabled, tkeep assumed to be 1'b1
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // number of output pipeline registers
    parameter PIPELINE_OUTPUT = 2,
    // Frame FIFO mode - operate on frames instead of cycles
    // When set, m_axis_tvalid will not be deasserted within a frame
    // Requires LAST_ENABLE set
    parameter FRAME_FIFO = 0,
    // tuser value for bad frame marker
    parameter USER_BAD_FRAME_VALUE = 1'b1,
    // tuser mask for bad frame marker
    parameter USER_BAD_FRAME_MASK = 1'b1,
    // Drop frames larger than FIFO
    // Requires FRAME_FIFO set
    parameter DROP_OVERSIZE_FRAME = FRAME_FIFO,
    // Drop frames marked bad
    // Requires FRAME_FIFO and DROP_OVERSIZE_FRAME set
    parameter DROP_BAD_FRAME = 0,
    // Drop incoming frames when full
    // When set, s_axis_tready is always asserted
    // Requires FRAME_FIFO and DROP_OVERSIZE_FRAME set
    parameter DROP_WHEN_FULL = 0
    )
(
    input       logic                               clk,
    input       logic                               rstn,

    input       logic [DATA_WIDTH-1:0]              s_axis_tdata,
    input       logic [KEEP_WIDTH-1:0]              s_axis_tkeep,
    input       logic                               s_axis_tvalid,
    output      logic                               s_axis_tready,
    input       logic                               s_axis_tlast,
    input       logic [ID_WIDTH-1:0]                s_axis_tid,
    input       logic [DEST_WIDTH-1:0]              s_axis_tdest,
    input       logic [USER_WIDTH-1:0]              s_axis_tuser,

    output      logic [DATA_WIDTH-1:0]              m_axis_tdata,
    output      logic [KEEP_WIDTH-1:0]              m_axis_tkeep,
    output      logic                               m_axis_tvalid,
    input       logic                               m_axis_tready,
    output      logic                               m_axis_tlast,
    output      logic [ID_WIDTH-1:0]                m_axis_tid,
    output      logic [DEST_WIDTH-1:0]              m_axis_tdest,
    output      logic [USER_WIDTH-1:0]              m_axis_tuser,

    output      logic                               status_overflow,
    output      logic                               status_bad_frame,
    output      logic                               status_good_frame
    );

parameter ADDR_WIDTH = (KEEP_ENABLE && KEEP_WIDTH > 1) ? $clog2(DEPTH/KEEP_WIDTH) : $clog2(DEPTH);

// check configuration
initial begin
    if (PIPELINE_OUTPUT < 1) begin
        $error("Error: PIPELINE_OUTPUT must be at least 1 (instance %m)");
        $finish;
    end

    if (FRAME_FIFO && !LAST_ENABLE) begin
        $error("Error: FRAME_FIFO set requires LAST_ENABLE set (instance %m)");
        $finish;
    end

    if (DROP_OVERSIZE_FRAME && !FRAME_FIFO) begin
        $error("Error: DROP_OVERSIZE_FRAME set requires FRAME_FIFO set (instance %m)");
        $finish;
    end

    if (DROP_BAD_FRAME && !(FRAME_FIFO && DROP_OVERSIZE_FRAME)) begin
        $error("Error: DROP_BAD_FRAME set requires FRAME_FIFO and DROP_OVERSIZE_FRAME set (instance %m)");
        $finish;
    end

    if (DROP_WHEN_FULL && !(FRAME_FIFO && DROP_OVERSIZE_FRAME)) begin
        $error("Error: DROP_WHEN_FULL set requires FRAME_FIFO and DROP_OVERSIZE_FRAME set (instance %m)");
        $finish;
    end

    if (DROP_BAD_FRAME && (USER_BAD_FRAME_MASK & {USER_WIDTH{1'b1}}) == 0) begin
        $error("Error: Invalid USER_BAD_FRAME_MASK value (instance %m)");
        $finish;
    end
end

localparam KEEP_OFFSET = DATA_WIDTH;
localparam LAST_OFFSET = KEEP_OFFSET + (KEEP_ENABLE ? KEEP_WIDTH : 0);
localparam ID_OFFSET   = LAST_OFFSET + (LAST_ENABLE ? 1          : 0);
localparam DEST_OFFSET = ID_OFFSET   + (ID_ENABLE   ? ID_WIDTH   : 0);
localparam USER_OFFSET = DEST_OFFSET + (DEST_ENABLE ? DEST_WIDTH : 0);
localparam WIDTH       = USER_OFFSET + (USER_ENABLE ? USER_WIDTH : 0);

logic                                           good_frame_r;
logic                                           bad_frame_r;
logic                                           overflow_r;
logic                                           send_frame_r;
logic                                           drop_frame_r;
logic                                           full_wr;
logic                                           empty;
logic                                           full_cur;
logic                                           full;
logic   [PIPELINE_OUTPUT-1:0]                   m_axis_tvalid_pipe_r;
logic   [PIPELINE_OUTPUT-1:0][WIDTH-1:0]        m_axis_pipe_r;
logic   [WIDTH-1:0]                             s_axis;
logic                                           mem_read_data_valid_r;
logic   [WIDTH-1:0]                             mem_read_data_r;
logic   [WIDTH-1:0]                             mem[(2**ADDR_WIDTH)-1:0];
logic   [ADDR_WIDTH:0]                          rd_ptr_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_cur_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_r;


// full when first MSB different but rest same
assign full                                = wr_ptr_r == (rd_ptr_r ^ {1'b1, {ADDR_WIDTH{1'b0}}});
assign full_cur                            = wr_ptr_cur_r == (rd_ptr_r ^ {1'b1, {ADDR_WIDTH{1'b0}}});
// empty when pointers match exactly
assign empty                               = wr_ptr_r == rd_ptr_r;
// overflow within packet
assign full_wr                             = wr_ptr_r == (wr_ptr_cur_r ^ {1'b1, {ADDR_WIDTH{1'b0}}});


assign s_axis_tready                       = FRAME_FIFO ? (!full_cur || (full_wr && DROP_OVERSIZE_FRAME) || DROP_WHEN_FULL) : !full;

generate
    assign s_axis[DATA_WIDTH-1:0] = s_axis_tdata;
    if (KEEP_ENABLE) assign s_axis[KEEP_OFFSET +: KEEP_WIDTH] = s_axis_tkeep;
    if (LAST_ENABLE) assign s_axis[LAST_OFFSET]               = s_axis_tlast;
    if (ID_ENABLE)   assign s_axis[ID_OFFSET   +: ID_WIDTH]   = s_axis_tid;
    if (DEST_ENABLE) assign s_axis[DEST_OFFSET +: DEST_WIDTH] = s_axis_tdest;
    if (USER_ENABLE) assign s_axis[USER_OFFSET +: USER_WIDTH] = s_axis_tuser;
endgenerate

assign m_axis_tvalid                       = m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-1];
assign m_axis_tdata                        = m_axis_pipe_r[PIPELINE_OUTPUT-1][DATA_WIDTH-1:0];
assign m_axis_tkeep                        = KEEP_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][KEEP_OFFSET +: KEEP_WIDTH] : {KEEP_WIDTH{1'b1}};
assign m_axis_tlast                        = LAST_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][LAST_OFFSET]               : 1'b1;
assign m_axis_tid                          = ID_ENABLE   ? m_axis_pipe_r[PIPELINE_OUTPUT-1][ID_OFFSET   +: ID_WIDTH]   : {ID_WIDTH{1'b0}};
assign m_axis_tdest                        = DEST_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][DEST_OFFSET +: DEST_WIDTH] : {DEST_WIDTH{1'b0}};
assign m_axis_tuser                        = USER_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][USER_OFFSET +: USER_WIDTH] : {USER_WIDTH{1'b0}};
assign status_overflow                     = overflow_r;
assign status_bad_frame                    = bad_frame_r;
assign status_good_frame                   = good_frame_r;

//mem
always_ff @(posedge clk)
    if (s_axis_tready && s_axis_tvalid) begin
        if (!FRAME_FIFO) begin
        // normal FIFO mode
            mem[wr_ptr_r[ADDR_WIDTH-1:0]]     <= s_axis;
        end else begin
        // store it
            mem[wr_ptr_cur_r[ADDR_WIDTH-1:0]] <= s_axis;
        end
    end 

// Write logic
always_ff @(posedge clk or negedge rstn)
    if (~rstn) begin
        wr_ptr_r                          <= '0;
        wr_ptr_cur_r                      <= '0;
        drop_frame_r                      <= 1'b0;
        send_frame_r                      <= 1'b0;
        overflow_r                        <= 1'b0;
        bad_frame_r                       <= 1'b0;
        good_frame_r                      <= 1'b0;
    end
    else begin

        if (s_axis_tready && s_axis_tvalid) begin
            // transfer in
            if (!FRAME_FIFO) begin
                // normal FIFO mode
                wr_ptr_r                          <= wr_ptr_r + 1;
                wr_ptr_cur_r                      <= '0;
                drop_frame_r                      <= 1'b0;
                send_frame_r                      <= 1'b0;
                overflow_r                        <= 1'b0;
                bad_frame_r                       <= 1'b0;
                good_frame_r                      <= 1'b0;
            end else if ((full_cur && DROP_WHEN_FULL) || (full_wr && DROP_OVERSIZE_FRAME) || drop_frame_r) begin
                // full, packet overflow, or currently dropping frame
                // drop frame
                drop_frame_r                      <= 1'b1;
                if (s_axis_tlast) begin
                    // end of frame, reset write pointer
                    wr_ptr_cur_r                      <= wr_ptr_r;
                    drop_frame_r                      <= 1'b0;
                    overflow_r                        <= 1'b1;
                end
            end else begin
                // store it
                if (s_axis_tlast || (!DROP_OVERSIZE_FRAME && (full_wr || send_frame_r))) begin
                    // end of frame or send frame
                    send_frame_r                      <= !s_axis_tlast;
                    if (s_axis_tlast && DROP_BAD_FRAME && USER_BAD_FRAME_MASK & ~(s_axis_tuser ^ USER_BAD_FRAME_VALUE)) begin
                        // bad packet, reset write pointer
                        wr_ptr_cur_r                      <= wr_ptr_r;
                        bad_frame_r                       <= 1'b1;
                    end else begin
                        // good packet or packet overflow, update write pointer
                        wr_ptr_r                          <= wr_ptr_cur_r + 1;
                        good_frame_r                      <= s_axis_tlast;
                    end
                end
                else begin
                    wr_ptr_cur_r                      <= wr_ptr_cur_r + 1;
                end
            end
        end else if (s_axis_tvalid && full_wr && FRAME_FIFO && !DROP_OVERSIZE_FRAME) begin
            // data valid with packet overflow
            // update write pointer
            send_frame_r                      <= 1'b1;
            wr_ptr_r                          <= wr_ptr_cur_r;
        end

end

// Read logic

always_ff @(posedge clk or negedge rstn)
    if (~rstn) begin
        rd_ptr_r                          <= '0;
        m_axis_tvalid_pipe_r              <= '0;
        m_axis_pipe_r                     <= '0;
    end
    else begin
        if (m_axis_tready) begin
            // output ready; invalidate stage
            m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-1]<= 1'b0;
        end

        for (int unsigned j = PIPELINE_OUTPUT-1; j > 0; j = j - 1) begin
            if (m_axis_tready | (~m_axis_tvalid_pipe_r[j])) begin
                // output ready or bubble in pipeline; transfer down pipeline
                m_axis_tvalid_pipe_r[j]           <= m_axis_tvalid_pipe_r[j-1];
                m_axis_pipe_r[j]                  <= m_axis_pipe_r[j-1];
                m_axis_tvalid_pipe_r[j-1]         <= 1'b0;
            end
        end

        if (m_axis_tready | ~(|m_axis_tvalid_pipe_r)) begin
            // output ready or bubble in pipeline; read new data from FIFO
            m_axis_tvalid_pipe_r[0]           <= 1'b0;
            m_axis_pipe_r[0]                  <= mem[rd_ptr_r[ADDR_WIDTH-1:0]];
            if (!empty) begin
                // not empty, increment pointer
                m_axis_tvalid_pipe_r[0]           <= 1'b1;
                rd_ptr_r                          <= rd_ptr_r + 1;
            end
        end

end

endmodule

