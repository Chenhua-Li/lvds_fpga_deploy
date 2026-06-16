
module axis_arb_mux #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // input tid signal width
    parameter S_ID_WIDTH = 8,
    // output tid signal width
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(S_COUNT),
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Propagate tlast signal
    parameter LAST_ENABLE = 1,
    // Update tid with routing information
    parameter UPDATE_TID = 0,
    // select round robin arbitration
    parameter ARB_TYPE_ROUND_ROBIN = 0,
    // LSB priority selection
    parameter ARB_LSB_HIGH_PRIORITY = 1
    )
(
    input       logic                               clk,
    input       logic                               rstn,

    // * AXI Stream inputs
    input       logic [S_COUNT*DATA_WIDTH-1:0]      s_axis_tdata,
    input       logic [S_COUNT*KEEP_WIDTH-1:0]      s_axis_tkeep,
    input       logic [S_COUNT-1:0]                 s_axis_tvalid,
    output      logic [S_COUNT-1:0]                 s_axis_tready,
    input       logic [S_COUNT-1:0]                 s_axis_tlast,
    input       logic [S_COUNT*S_ID_WIDTH-1:0]      s_axis_tid,
    input       logic [S_COUNT*DEST_WIDTH-1:0]      s_axis_tdest,
    input       logic [S_COUNT*USER_WIDTH-1:0]      s_axis_tuser,

    // * AXI Stream output
    output      logic [DATA_WIDTH-1:0]              m_axis_tdata,
    output      logic [KEEP_WIDTH-1:0]              m_axis_tkeep,
    output      logic                               m_axis_tvalid,
    input       logic                               m_axis_tready,
    output      logic                               m_axis_tlast,
    output      logic [M_ID_WIDTH-1:0]              m_axis_tid,
    output      logic [DEST_WIDTH-1:0]              m_axis_tdest,
    output      logic [USER_WIDTH-1:0]              m_axis_tuser
    );

parameter CL_S_COUNT = $clog2(S_COUNT);

parameter S_ID_WIDTH_INT = S_ID_WIDTH > 0 ? S_ID_WIDTH : 1;

// check configuration
initial begin
    if (UPDATE_TID) begin
        if (!ID_ENABLE) begin
            $error("Error: UPDATE_TID set requires ID_ENABLE set (instance %m)");
            $finish;
        end

        if (M_ID_WIDTH < CL_S_COUNT) begin
            $error("Error: M_ID_WIDTH too small for port count (instance %m)");
            $finish;
        end
    end
end

logic   [S_COUNT-1:0]                           request;
logic   [S_COUNT-1:0]                           acknowledge;
logic   [S_COUNT-1:0]                           grant;
logic                                           grant_valid;
logic   [CL_S_COUNT-1:0]                        grant_encoded;
logic   [S_COUNT*DATA_WIDTH-1:0]                s_axis_tdata_r;
logic   [S_COUNT*KEEP_WIDTH-1:0]                s_axis_tkeep_r;
logic   [S_COUNT-1:0]                           s_axis_tvalid_r;
logic   [S_COUNT-1:0]                           s_axis_tlast_r;
logic   [S_COUNT*S_ID_WIDTH-1:0]                s_axis_tid_r;
logic   [S_COUNT*DEST_WIDTH-1:0]                s_axis_tdest_r;
logic   [S_COUNT*USER_WIDTH-1:0]                s_axis_tuser_r;
logic   [DATA_WIDTH-1:0]                        m_axis_tdata_int;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_int;
logic                                           m_axis_tvalid_int;
logic                                           m_axis_tready_int_r;
logic                                           m_axis_tlast_int;
logic   [M_ID_WIDTH-1:0]                        m_axis_tid_int;
logic   [DEST_WIDTH-1:0]                        m_axis_tdest_int;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_int;
logic                                           m_axis_tready_int_early;
logic                                           store_axis_temp_to_output;
logic                                           store_axis_int_to_temp;
logic                                           store_axis_int_to_output;
logic   [USER_WIDTH-1:0]                        temp_m_axis_tuser_r;
logic   [DEST_WIDTH-1:0]                        temp_m_axis_tdest_r;
logic   [M_ID_WIDTH-1:0]                        temp_m_axis_tid_r;
logic                                           temp_m_axis_tlast_r;
logic                                           temp_m_axis_tvalid_next;
logic                                           temp_m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        temp_m_axis_tkeep_r;
logic   [DATA_WIDTH-1:0]                        temp_m_axis_tdata_r;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_r;
logic   [DEST_WIDTH-1:0]                        m_axis_tdest_r;
logic   [M_ID_WIDTH-1:0]                        m_axis_tid_r;
logic                                           m_axis_tlast_r;
logic                                           m_axis_tvalid_next;
logic                                           m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_r;
logic   [DATA_WIDTH-1:0]                        m_axis_tdata_r;
logic   [USER_WIDTH-1:0]                        current_s_tuser;
logic   [DEST_WIDTH-1:0]                        current_s_tdest;
logic   [S_ID_WIDTH-1:0]                        current_s_tid;
logic                                           current_s_tlast;
logic                                           current_s_tready;
logic                                           current_s_tvalid;
logic   [KEEP_WIDTH-1:0]                        current_s_tkeep;
logic   [DATA_WIDTH-1:0]                        current_s_tdata;

assign s_axis_tready                       = ~s_axis_tvalid_r | ({S_COUNT{m_axis_tready_int_r}} & grant);

// mux for incoming packet
assign current_s_tdata                     = s_axis_tdata_r[grant_encoded*DATA_WIDTH +: DATA_WIDTH];
assign current_s_tkeep                     = s_axis_tkeep_r[grant_encoded*KEEP_WIDTH +: KEEP_WIDTH];
assign current_s_tvalid                    = s_axis_tvalid_r[grant_encoded];
assign current_s_tready                    = s_axis_tready[grant_encoded];
assign current_s_tlast                     = s_axis_tlast_r[grant_encoded];
assign current_s_tid                       = s_axis_tid_r[grant_encoded*S_ID_WIDTH +: S_ID_WIDTH_INT];
assign current_s_tdest                     = s_axis_tdest_r[grant_encoded*DEST_WIDTH +: DEST_WIDTH];
assign current_s_tuser                     = USER_ENABLE ? s_axis_tuser_r[grant_encoded*USER_WIDTH +: USER_WIDTH] : '0;

// arbiter instance
arbiter #(
    .PORTS                              ( S_COUNT                     ),
    .ARB_TYPE_ROUND_ROBIN               ( ARB_TYPE_ROUND_ROBIN        ),
    .ARB_BLOCK                          ( 1                           ),
    .ARB_BLOCK_ACK                      ( 1                           ),
    .ARB_LSB_HIGH_PRIORITY              ( ARB_LSB_HIGH_PRIORITY       )
    )
arb_inst (
    .clk                                ( clk                         ),
    .rstn                               ( rstn                        ),
    .request                            ( request                     ),
    .acknowledge                        ( acknowledge                 ),
    .grant                              ( grant                       ),
    .grant_valid                        ( grant_valid                 ),
    .grant_encoded                      ( grant_encoded               )
    );

assign request                             = (s_axis_tvalid_r & ~grant) | (s_axis_tvalid & grant);
assign acknowledge                         = grant & s_axis_tvalid_r & {S_COUNT{m_axis_tready_int_r}} & (LAST_ENABLE ? s_axis_tlast_r : {S_COUNT{1'b1}});

always_comb begin
    // pass through selected packet data
    m_axis_tdata_int                    = current_s_tdata;
    m_axis_tkeep_int                    = current_s_tkeep;
    m_axis_tvalid_int                   = current_s_tvalid && m_axis_tready_int_r && grant_valid;
    m_axis_tlast_int                    = current_s_tlast;
    m_axis_tid_int                      = current_s_tid;
    if (UPDATE_TID && S_COUNT > 1) begin
        m_axis_tid_int[M_ID_WIDTH-1:M_ID_WIDTH-CL_S_COUNT]= grant_encoded;
    end
    m_axis_tdest_int                    = current_s_tdest;
    m_axis_tuser_int                    = current_s_tuser;
end


always_ff @(posedge clk or negedge rstn)
    if (~rstn) begin
        s_axis_tvalid_r                   <= 0;
        s_axis_tdata_r <= '0;
        s_axis_tkeep_r <= '0;
        s_axis_tlast_r <= '0;
        s_axis_tid_r <= '0;
        s_axis_tdest_r <= '0;
        s_axis_tuser_r <= '0;
    end
    else begin
        // register inputs
        for (int unsigned i = 0; i < S_COUNT; i = i + 1) begin
            if (s_axis_tready[i]) begin
                s_axis_tdata_r[i*DATA_WIDTH +: DATA_WIDTH]<= s_axis_tdata[i*DATA_WIDTH +: DATA_WIDTH];
                s_axis_tkeep_r[i*KEEP_WIDTH +: KEEP_WIDTH]<= s_axis_tkeep[i*KEEP_WIDTH +: KEEP_WIDTH];
                s_axis_tvalid_r[i]                <= s_axis_tvalid[i];
                s_axis_tlast_r[i]                 <= s_axis_tlast[i];
                s_axis_tid_r[i*S_ID_WIDTH +: S_ID_WIDTH_INT]<= s_axis_tid[i*S_ID_WIDTH +: S_ID_WIDTH_INT];
                s_axis_tdest_r[i*DEST_WIDTH +: DEST_WIDTH]<= s_axis_tdest[i*DEST_WIDTH +: DEST_WIDTH];
                s_axis_tuser_r[i*USER_WIDTH +: USER_WIDTH]<= USER_ENABLE ? s_axis_tuser[i*USER_WIDTH +: USER_WIDTH] : '0;
            end
        end
    end

assign m_axis_tdata                        = m_axis_tdata_r;
assign m_axis_tkeep                        = KEEP_ENABLE ? m_axis_tkeep_r : '1;
assign m_axis_tvalid                       = m_axis_tvalid_r;
assign m_axis_tlast                        = LAST_ENABLE ? m_axis_tlast_r : 1'b1;
assign m_axis_tid                          = ID_ENABLE   ? m_axis_tid_r   : '0;
assign m_axis_tdest                        = DEST_ENABLE ? m_axis_tdest_r : '0;
assign m_axis_tuser                        = USER_ENABLE ? m_axis_tuser_r : '0;

// enable ready input next cycle if output is ready or if both output registers are empty
assign m_axis_tready_int_early             = m_axis_tready || (!temp_m_axis_tvalid_r && !m_axis_tvalid_r);

always_comb begin
    // transfer sink ready state to source
    m_axis_tvalid_next                  = m_axis_tvalid_r;
    temp_m_axis_tvalid_next             = temp_m_axis_tvalid_r;

    store_axis_int_to_output            = 1'b0;
    store_axis_int_to_temp              = 1'b0;
    store_axis_temp_to_output           = 1'b0;

    if (m_axis_tready_int_r) begin
        // input is ready
        if (m_axis_tready || !m_axis_tvalid_r) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next                  = m_axis_tvalid_int;
            store_axis_int_to_output            = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next             = m_axis_tvalid_int;
            store_axis_int_to_temp              = 1'b1;
        end
    end else if (m_axis_tready) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next                  = temp_m_axis_tvalid_r;
        temp_m_axis_tvalid_next             = 1'b0;
        store_axis_temp_to_output           = 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        m_axis_tvalid_r                   <= 1'b0;
        m_axis_tready_int_r               <= 1'b0;
        temp_m_axis_tvalid_r              <= 1'b0;

        temp_m_axis_tdata_r               <= '0;
        temp_m_axis_tkeep_r               <= '0;
        temp_m_axis_tlast_r               <= '0;
        temp_m_axis_tid_r                 <= '0;
        temp_m_axis_tdest_r               <= '0;
        temp_m_axis_tuser_r               <= '0;

        m_axis_tdata_r                    <= '0;
        m_axis_tkeep_r                    <= '0;
        m_axis_tlast_r                    <= '0;
        m_axis_tid_r                      <= '0;
        m_axis_tdest_r                    <= '0;
        m_axis_tuser_r                    <= '0;

    end
    else begin
        m_axis_tvalid_r                   <= m_axis_tvalid_next;
        m_axis_tready_int_r               <= m_axis_tready_int_early;
        temp_m_axis_tvalid_r              <= temp_m_axis_tvalid_next;

        // datapath
        if (store_axis_int_to_output) begin
            m_axis_tdata_r                    <= m_axis_tdata_int;
            m_axis_tkeep_r                    <= m_axis_tkeep_int;
            m_axis_tlast_r                    <= m_axis_tlast_int;
            m_axis_tid_r                      <= m_axis_tid_int;
            m_axis_tdest_r                    <= m_axis_tdest_int;
            m_axis_tuser_r                    <= m_axis_tuser_int;
        end else if (store_axis_temp_to_output) begin
            m_axis_tdata_r                    <= temp_m_axis_tdata_r;
            m_axis_tkeep_r                    <= temp_m_axis_tkeep_r;
            m_axis_tlast_r                    <= temp_m_axis_tlast_r;
            m_axis_tid_r                      <= temp_m_axis_tid_r;
            m_axis_tdest_r                    <= temp_m_axis_tdest_r;
            m_axis_tuser_r                    <= temp_m_axis_tuser_r;
        end

        if (store_axis_int_to_temp) begin
            temp_m_axis_tdata_r               <= m_axis_tdata_int;
            temp_m_axis_tkeep_r               <= m_axis_tkeep_int;
            temp_m_axis_tlast_r               <= m_axis_tlast_int;
            temp_m_axis_tid_r                 <= m_axis_tid_int;
            temp_m_axis_tdest_r               <= m_axis_tdest_int;
            temp_m_axis_tuser_r               <= m_axis_tuser_int;
        end
    end

endmodule

