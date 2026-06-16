
// * AXI4-Stream asynchronous FIFO
module axis_async_fifo #
(
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
    input       logic                               s_clk,
    input       logic                               s_rstn,
    input       logic [DATA_WIDTH-1:0]              s_axis_tdata,
    input       logic [KEEP_WIDTH-1:0]              s_axis_tkeep,
    input       logic                               s_axis_tvalid,
    output      logic                               s_axis_tready,
    input       logic                               s_axis_tlast,
    input       logic [ID_WIDTH-1:0]                s_axis_tid,
    input       logic [DEST_WIDTH-1:0]              s_axis_tdest,
    input       logic [USER_WIDTH-1:0]              s_axis_tuser,

    input       logic                               m_clk,
    input       logic                               m_rstn,
    output      logic [DATA_WIDTH-1:0]              m_axis_tdata,
    output      logic [KEEP_WIDTH-1:0]              m_axis_tkeep,
    output      logic                               m_axis_tvalid,
    input       logic                               m_axis_tready,
    output      logic                               m_axis_tlast,
    output      logic [ID_WIDTH-1:0]                m_axis_tid,
    output      logic [DEST_WIDTH-1:0]              m_axis_tdest,
    output      logic [USER_WIDTH-1:0]              m_axis_tuser,

    output      logic                               s_status_overflow,
    output      logic                               s_status_bad_frame,
    output      logic                               s_status_good_frame,
    output      logic                               m_status_overflow,
    output      logic                               m_status_bad_frame,
    output      logic                               m_status_good_frame
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

logic   [ADDR_WIDTH:0]                          wr_ptr_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_cur_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_gray_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_sync_gray_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_cur_gray_r;
logic   [ADDR_WIDTH:0]                          rd_ptr_r;
logic   [ADDR_WIDTH:0]                          rd_ptr_gray_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_gray_sync1_r;
logic   [ADDR_WIDTH:0]                          wr_ptr_gray_sync2_r;
logic   [ADDR_WIDTH:0]                          rd_ptr_gray_sync2_r;
logic                                           wr_ptr_update_valid_r;
logic                                           wr_ptr_update_r;
logic                                           wr_ptr_update_sync2_r;
logic                                           wr_ptr_update_sync3_r;
logic                                           wr_ptr_update_ack_sync1_r;
logic                                           wr_ptr_update_ack_sync2_r;
logic                                           s_rst_sync1_r;
logic                                           s_rst_sync2_r;
logic                                           s_rst_sync3_r;
logic                                           m_rst_sync1_r;
logic                                           m_rst_sync2_r;
logic                                           m_rst_sync3_r;
logic   [WIDTH-1:0]                             mem[(2**ADDR_WIDTH)-1:0];
logic   [WIDTH-1:0]                             mem_read_data_r;
logic                                           mem_read_data_valid_r;
logic   [WIDTH-1:0]                             s_axis;
logic   [PIPELINE_OUTPUT-1:0][WIDTH-1:0]        m_axis_pipe_r;
logic   [PIPELINE_OUTPUT-1:0]                   m_axis_tvalid_pipe_r;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_pipe;
logic   [DEST_WIDTH-1:0]                        m_axis_tdest_pipe;
logic   [ID_WIDTH-1:0]                          m_axis_tid_pipe;
logic                                           m_axis_tlast_pipe;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_pipe;
logic   [DATA_WIDTH-1:0]                        m_axis_tdata_pipe;
logic                                           m_axis_tvalid_pipe;
logic                                           good_frame_sync4_r;
logic                                           good_frame_sync3_r;
logic                                           good_frame_sync1_r;
logic                                           bad_frame_sync4_r;
logic                                           bad_frame_sync3_r;
logic                                           bad_frame_sync1_r;
logic                                           overflow_sync4_r;
logic                                           overflow_sync3_r;
logic                                           overflow_sync1_r;
logic                                           m_terminate_frame_r;
logic                                           m_drop_frame_r;
logic                                           good_frame_r;
logic                                           bad_frame_r;
logic                                           overflow_r;
logic                                           send_frame_r;
logic                                           drop_frame_r;
logic                                           m_frame_r;
logic                                           s_frame_r;
logic                                           store_output;
logic                                           read;
logic                                           write;
logic                                           full_wr;
logic                                           empty;
logic                                           full_cur;
logic                                           full;


// full when first TWO MSBs do NOT match, but rest matches
// (gray code equivalent of first MSB different but rest same)
assign full                                = wr_ptr_gray_r == (rd_ptr_gray_sync2_r ^ {2'b11, {ADDR_WIDTH-1{1'b0}}});
assign full_cur                            = wr_ptr_cur_gray_r == (rd_ptr_gray_sync2_r ^ {2'b11, {ADDR_WIDTH-1{1'b0}}});
// empty when pointers match exactly
assign empty                               = rd_ptr_gray_r == (FRAME_FIFO ? wr_ptr_gray_sync1_r : wr_ptr_gray_sync2_r);
// overflow within packet
assign full_wr                             = wr_ptr_r == (wr_ptr_cur_r ^ {1'b1, {ADDR_WIDTH{1'b0}}});

assign s_axis_tready                       = (FRAME_FIFO ? (!full_cur || (full_wr && DROP_OVERSIZE_FRAME) || DROP_WHEN_FULL) : !full) && !s_rst_sync3_r;

assign s_axis[DATA_WIDTH-1:0] = s_axis_tdata;

generate

if(KEEP_ENABLE) begin
    assign s_axis[KEEP_OFFSET +: KEEP_WIDTH] = s_axis_tkeep ;
end

if(LAST_ENABLE) begin
    assign s_axis[LAST_OFFSET]               = s_axis_tlast ;
end

if(ID_ENABLE)   begin
    assign s_axis[ID_OFFSET   +: ID_WIDTH]   = s_axis_tid   ;
end

if(DEST_ENABLE) begin
    assign s_axis[DEST_OFFSET +: DEST_WIDTH] = s_axis_tdest ;
end

if(USER_ENABLE) begin
    assign s_axis[USER_OFFSET +: USER_WIDTH] = s_axis_tuser ;
end
endgenerate

assign m_axis_tvalid_pipe                  = m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-1];
assign m_axis_tdata_pipe                   = m_axis_pipe_r[PIPELINE_OUTPUT-1][DATA_WIDTH-1:0];
assign m_axis_tkeep_pipe                   = KEEP_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][KEEP_OFFSET +: KEEP_WIDTH] : {KEEP_WIDTH{1'b1}};
assign m_axis_tlast_pipe                   = LAST_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][LAST_OFFSET] : 1'b1;
assign m_axis_tid_pipe                     = ID_ENABLE   ? m_axis_pipe_r[PIPELINE_OUTPUT-1][ID_OFFSET +: ID_WIDTH] : {ID_WIDTH{1'b0}};
assign m_axis_tdest_pipe                   = DEST_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][DEST_OFFSET +: DEST_WIDTH] : {DEST_WIDTH{1'b0}};
assign m_axis_tuser_pipe                   = USER_ENABLE ? m_axis_pipe_r[PIPELINE_OUTPUT-1][USER_OFFSET +: USER_WIDTH] : {USER_WIDTH{1'b0}};
assign m_axis_tvalid                       = m_axis_tvalid_pipe;
assign m_axis_tdata                        = m_axis_tdata_pipe;
assign m_axis_tkeep                        = m_axis_tkeep_pipe;
assign m_axis_tlast                        = (m_terminate_frame_r ? 1'b1 : m_axis_tlast_pipe);
assign m_axis_tid                          = m_axis_tid_pipe;
assign m_axis_tdest                        = m_axis_tdest_pipe;
assign m_axis_tuser                        = (m_terminate_frame_r ? USER_BAD_FRAME_VALUE : m_axis_tuser_pipe);
assign s_status_overflow                   = overflow_r;
assign s_status_bad_frame                  = bad_frame_r;
assign s_status_good_frame                 = good_frame_r;
assign m_status_overflow                   = overflow_sync3_r ^ overflow_sync4_r;
assign m_status_bad_frame                  = bad_frame_sync3_r ^ bad_frame_sync4_r;
assign m_status_good_frame                 = good_frame_sync3_r ^ good_frame_sync4_r;

// reset synchronization
always_ff @(posedge m_clk or negedge m_rstn)
    if (~m_rstn) begin
        s_rst_sync1_r                     <= 1'b1;
    end 
    else begin
        s_rst_sync1_r                     <= 1'b0;
    end

macro_sync2r inst_macro_sync2r_srst(
    .ck                                 ( s_clk                       ),
    .clb                                ( s_rstn                      ),
    .d                                  ( s_rst_sync1_r             ), 
    .o                                  ( s_rst_sync3_r             )
    );

always_ff @(posedge s_clk or negedge s_rstn)
    if (~s_rstn) begin
        m_rst_sync1_r                     <= 1'b1;
    end else begin
        m_rst_sync1_r                     <= 1'b0;
    end

macro_sync2r inst_macro_sync2r_mrst(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( m_rst_sync1_r             ), 
    .o                                  ( m_rst_sync3_r             )
    );

//mem
always_ff @(posedge s_clk)//or negedge s_rstn)
if (s_axis_tready && s_axis_tvalid) begin
    if (!FRAME_FIFO) begin
        mem[wr_ptr_r[ADDR_WIDTH-1:0]]     <= s_axis;
    end
    else begin
        mem[wr_ptr_cur_r[ADDR_WIDTH-1:0]] <= s_axis;
    end
end




// Write logic
always_ff @(posedge s_clk or negedge s_rstn)
    if (~s_rstn) begin
        wr_ptr_r                          <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_r                      <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_r                     <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_sync_gray_r                <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_gray_r                 <= {ADDR_WIDTH+1{1'b0}};

        wr_ptr_update_valid_r             <= 1'b0;
        wr_ptr_update_r                   <= 1'b0;

        s_frame_r                         <= 1'b0;

        drop_frame_r                      <= 1'b0;
        send_frame_r                      <= 1'b0;
        overflow_r                        <= 1'b0;
        bad_frame_r                       <= 1'b0;
        good_frame_r                      <= 1'b0;
    end
    else begin

    if (FRAME_FIFO && wr_ptr_update_valid_r) begin
        // have updated pointer to sync
        if (wr_ptr_update_r == wr_ptr_update_ack_sync2_r) begin
            // no sync in progress; sync update
            wr_ptr_update_valid_r             <= 1'b0;
            wr_ptr_sync_gray_r                <= wr_ptr_gray_r;
            wr_ptr_update_r                   <= !wr_ptr_update_ack_sync2_r;
        end
    end

    if (s_rst_sync3_r) begin
        wr_ptr_r                          <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_r                      <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_gray_r                     <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_sync_gray_r                <= {ADDR_WIDTH+1{1'b0}};
        wr_ptr_cur_gray_r                 <= {ADDR_WIDTH+1{1'b0}};

        wr_ptr_update_valid_r             <= 1'b0;
        wr_ptr_update_r                   <= 1'b0;
    end
    else begin

        if (s_axis_tready && s_axis_tvalid && LAST_ENABLE) begin
            // track input frame status
            s_frame_r                         <= !s_axis_tlast;
        end

        if (s_rst_sync3_r && LAST_ENABLE) begin
            // if sink side is reset during transfer, drop partial frame
            if (s_frame_r && !(s_axis_tready && s_axis_tvalid && s_axis_tlast)) begin
                drop_frame_r                      <= 1'b1;
            end
            if (s_axis_tready && s_axis_tvalid && !s_axis_tlast) begin
                drop_frame_r                      <= 1'b1;
            end
        end

        if (s_axis_tready && s_axis_tvalid) begin
            // transfer in
            if (!FRAME_FIFO) begin
                overflow_r                        <= 1'b0;
                bad_frame_r                       <= 1'b0;
                good_frame_r                      <= 1'b0;
                // normal FIFO mode
                if (drop_frame_r && LAST_ENABLE) begin
                    // currently dropping frame
                    // (only for frame transfers interrupted by sink reset)
                    if (s_axis_tlast) begin
                        // end of frame, clear drop flag
                        drop_frame_r                      <= 1'b0;
                    end
                end else begin
                    // update pointers
                    wr_ptr_r                          <= (wr_ptr_r + 1);
                    wr_ptr_gray_r                     <= (wr_ptr_r + 1) ^ ((wr_ptr_r + 1) >> 1);
                end
            end else if ((full_cur && DROP_WHEN_FULL) || (full_wr && DROP_OVERSIZE_FRAME) || drop_frame_r) begin
                // full, packet overflow, or currently dropping frame
                // drop frame
                drop_frame_r                      <= 1'b1;
                if (s_axis_tlast) begin
                    // end of frame, reset write pointer
                    wr_ptr_cur_r                      <= wr_ptr_r;
                    wr_ptr_cur_gray_r                 <= wr_ptr_r ^ (wr_ptr_r >> 1);
                    drop_frame_r                      <= 1'b0;
                    overflow_r                        <= 1'b1;
                end
            end else begin
                wr_ptr_cur_r                      <= (wr_ptr_cur_r + 1);
                wr_ptr_cur_gray_r                 <= (wr_ptr_cur_r + 1)^ ((wr_ptr_cur_r + 1)>> 1);
                if (s_axis_tlast || (!DROP_OVERSIZE_FRAME && (full_wr || send_frame_r))) begin
                    // end of frame or send frame
                    send_frame_r                      <= !s_axis_tlast;
                    if (s_axis_tlast && DROP_BAD_FRAME && USER_BAD_FRAME_MASK & ~(s_axis_tuser ^ USER_BAD_FRAME_VALUE)) begin
                        // bad packet, reset write pointer
                        wr_ptr_cur_r                      <= wr_ptr_r;
                        wr_ptr_cur_gray_r                 <= wr_ptr_r ^ (wr_ptr_r>> 1);
                        bad_frame_r                       <= 1'b1;
                    end else begin
                        // good packet or packet overflow, update write pointer
                        wr_ptr_r                          <= (wr_ptr_cur_r + 1);
                        wr_ptr_gray_r                     <= (wr_ptr_cur_r + 1) ^ ((wr_ptr_cur_r + 1)>> 1);

                        if (wr_ptr_update_r == wr_ptr_update_ack_sync2_r) begin
                            // no sync in progress; sync update
                            wr_ptr_update_valid_r             <= 1'b0;
                            wr_ptr_sync_gray_r                <= (wr_ptr_cur_r + 1) ^ ((wr_ptr_cur_r + 1) >> 1);
                            wr_ptr_update_r                   <= !wr_ptr_update_ack_sync2_r;
                        end else begin
                            // sync in progress; flag it for later
                            wr_ptr_update_valid_r             <= 1'b1;
                        end

                        good_frame_r                      <= s_axis_tlast;
                    end
                end
            end
        end else if (s_axis_tvalid && full_wr && FRAME_FIFO && !DROP_OVERSIZE_FRAME) begin
            // data valid with packet overflow
            // update write pointer
            send_frame_r                      <= 1'b1;
            wr_ptr_r                          <= wr_ptr_cur_r;
            wr_ptr_gray_r                     <= wr_ptr_cur_r ^ (wr_ptr_cur_r>> 1);

            if (wr_ptr_update_r == wr_ptr_update_ack_sync2_r) begin
                // no sync in progress; sync update
                wr_ptr_update_valid_r             <= 1'b0;
                wr_ptr_sync_gray_r                <= wr_ptr_cur_r ^ (wr_ptr_cur_r >> 1);
                wr_ptr_update_r                   <= !wr_ptr_update_ack_sync2_r;
            end else begin
                // sync in progress; flag it for later
                wr_ptr_update_valid_r             <= 1'b1;
            end
        end
    end

end

// pointer synchronization
generate
    for (genvar i= 0;i<ADDR_WIDTH+1;i=i+1) begin:rd_ptr_gray_sync_r
        macro_sync2r inst_macro_sync2r_rd_ptr(
    .ck                                 ( s_clk                       ),
    .clb                                ( s_rstn                      ),
    .d                                  ( rd_ptr_gray_r[i]          ), 
    .o                                  ( rd_ptr_gray_sync2_r[i]    )
    );
    end
endgenerate

macro_sync2r inst_macro_sync2r_wr_ptr_up_ack(
    .ck                                 ( s_clk                       ),
    .clb                                ( s_rstn                      ),
    .d                                  ( wr_ptr_update_sync3_r     ), 
    .o                                  ( wr_ptr_update_ack_sync2_r )
    );

always_comb begin
    if (FRAME_FIFO && m_rst_sync3_r) begin
        wr_ptr_gray_sync1_r               = {ADDR_WIDTH+1{1'b0}};
    end else if (!FRAME_FIFO) begin
        wr_ptr_gray_sync1_r               = wr_ptr_gray_r;
    end else if (wr_ptr_update_sync2_r ^ wr_ptr_update_sync3_r) begin
        wr_ptr_gray_sync1_r               = wr_ptr_sync_gray_r;
    end else begin
        wr_ptr_gray_sync1_r               = wr_ptr_gray_sync2_r;
    end
end

generate
    for (genvar i= 0;i<ADDR_WIDTH+1;i=i+1) begin:wr_ptr_gray_sync_r
        macro_sync2r inst_macro_sync2r_wr_ptr(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( wr_ptr_gray_sync1_r[i]    ), 
    .o                                  ( wr_ptr_gray_sync2_r[i]    )
    );
    end
endgenerate

always_ff @(posedge m_clk or negedge m_rstn)
    if (~m_rstn) begin
        wr_ptr_update_sync3_r             <= 1'b0;
    end
    else begin
        wr_ptr_update_sync3_r             <= wr_ptr_update_sync2_r;
    end

macro_sync2r inst_macro_sync2r_wr_ptr_up(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( wr_ptr_update_r           ), 
    .o                                  ( wr_ptr_update_sync2_r     )
    );

// status synchronization
always_ff @(posedge s_clk or negedge s_rstn)
    if (~s_rstn) begin
        overflow_sync1_r                  <= 1'b0;
        bad_frame_sync1_r                 <= 1'b0;
        good_frame_sync1_r                <= 1'b0;
    end
    else begin
        overflow_sync1_r                  <= overflow_sync1_r ^ overflow_r;
        bad_frame_sync1_r                 <= bad_frame_sync1_r ^ bad_frame_r;
        good_frame_sync1_r                <= good_frame_sync1_r ^ good_frame_r;

    end

always_ff @(posedge m_clk or negedge m_rstn)
    if (~m_rstn) begin
        overflow_sync4_r                  <= 1'b0;
        bad_frame_sync4_r                 <= 1'b0;
        good_frame_sync4_r                <= 1'b0;
    end
    else begin
        overflow_sync4_r                  <= overflow_sync3_r;
        bad_frame_sync4_r                 <= bad_frame_sync3_r;
        good_frame_sync4_r                <= good_frame_sync3_r;

    end

macro_sync2r inst_macro_sync2r_overflow(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( overflow_sync1_r          ), 
    .o                                  ( overflow_sync3_r          )
    );

macro_sync2r inst_macro_sync2r_badframe(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( bad_frame_sync1_r         ), 
    .o                                  ( bad_frame_sync3_r         )
    );

macro_sync2r inst_macro_sync2r_goodframe(
    .ck                                 ( m_clk                       ),
    .clb                                ( m_rstn                      ),
    .d                                  ( good_frame_sync1_r        ), 
    .o                                  ( good_frame_sync3_r        )
    );

// Read logic
always_ff @(posedge m_clk or negedge m_rstn)
    if (~m_rstn) begin
        rd_ptr_r                          <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_r                     <= {ADDR_WIDTH+1{1'b0}};
        m_axis_tvalid_pipe_r              <= {PIPELINE_OUTPUT{1'b0}};
        m_frame_r                         <= 1'b0;
        m_drop_frame_r                    <= 1'b0;
        m_terminate_frame_r               <= 1'b0;
        m_axis_pipe_r                     <= '0;
    end
    else begin
    if (m_axis_tready) begin
        // output ready; invalidate stage
        m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-1]<= 1'b0;
        m_terminate_frame_r               <= 1'b0;
    end

    for (int unsigned j = PIPELINE_OUTPUT-1; j > 0; j = j - 1) begin
        if (m_axis_tready || ((~m_axis_tvalid_pipe_r) >> j)) begin
            // output ready or bubble in pipeline; transfer down pipeline
            m_axis_tvalid_pipe_r[j]           <= m_axis_tvalid_pipe_r[j-1];
            m_axis_pipe_r[j]                  <= m_axis_pipe_r[j-1];
            m_axis_tvalid_pipe_r[j-1]         <= 1'b0;
        end
    end

    if (m_axis_tready || ~m_axis_tvalid_pipe_r) begin
        // output ready or bubble in pipeline; read new data from FIFO
        m_axis_tvalid_pipe_r[0]           <= 1'b0;
        m_axis_pipe_r[0]                  <= mem[rd_ptr_r[ADDR_WIDTH-1:0]];
        if (!empty && !m_rst_sync3_r && !m_drop_frame_r) begin
            // not empty, increment pointer
            m_axis_tvalid_pipe_r[0]           <= 1'b1;
            rd_ptr_r                          <= (rd_ptr_r + 1);
            rd_ptr_gray_r                     <= (rd_ptr_r + 1)^ ((rd_ptr_r + 1)>> 1);
        end
    end

    if (m_axis_tvalid && LAST_ENABLE) begin
        // track output frame status
        if (m_axis_tlast && m_axis_tready) begin
            m_frame_r                         <= 1'b0;
        end else begin
            m_frame_r                         <= 1'b1;
        end
    end

    if (m_drop_frame_r && (m_axis_tready || !m_axis_tvalid_pipe) && LAST_ENABLE) begin
        // terminate frame
        // (only for frame transfers interrupted by source reset)
        m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-1]<= 1'b1;
        m_terminate_frame_r               <= 1'b1;
        m_drop_frame_r                    <= 1'b0;
    end

    if (m_rst_sync3_r && LAST_ENABLE) begin
        // if source side is reset during transfer, drop partial frame

        // empty output pipeline, except for last stage
        if (PIPELINE_OUTPUT > 1) begin
            m_axis_tvalid_pipe_r[PIPELINE_OUTPUT-2:0]<= 0;
        end

        if (m_frame_r && (!m_axis_tvalid || (m_axis_tvalid && !m_axis_tlast)) &&
                !(m_drop_frame_r || m_terminate_frame_r)) begin
            // terminate frame
            m_drop_frame_r                    <= 1'b1;
        end
    end

    if (m_rst_sync3_r) begin
        rd_ptr_r                          <= {ADDR_WIDTH+1{1'b0}};
        rd_ptr_gray_r                     <= {ADDR_WIDTH+1{1'b0}};
    end

end

endmodule

