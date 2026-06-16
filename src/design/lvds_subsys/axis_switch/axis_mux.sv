

module axis_mux #
(
    // Number of AXI stream inputs
    parameter S_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Width of DATA + SELECT
    parameter DATA_SEL_WIDTH = DATA_WIDTH+$clog2(S_COUNT),
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
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
    parameter USER_WIDTH = 1
    )
(
    input       logic                               clk,
    input       logic                               rst_n,

    input       logic [S_COUNT*DATA_WIDTH-1:0]      s_axis_tdata,
    input       logic [S_COUNT*KEEP_WIDTH-1:0]      s_axis_tkeep,
    input       logic [S_COUNT-1:0]                 s_axis_tvalid,
    output      logic [S_COUNT-1:0]                 s_axis_tready,
    input       logic [S_COUNT-1:0]                 s_axis_tlast,
    input       logic [S_COUNT*ID_WIDTH-1:0]        s_axis_tid,
    input       logic [S_COUNT*DEST_WIDTH-1:0]      s_axis_tdest,
    input       logic [S_COUNT*USER_WIDTH-1:0]      s_axis_tuser,

    output      logic [DATA_WIDTH-1:0]              m_axis_tdata,
    output      logic [KEEP_WIDTH-1:0]              m_axis_tkeep,
    output      logic                               m_axis_tvalid,
    input       logic                               m_axis_tready,
    output      logic                               m_axis_tlast,
    output      logic [ID_WIDTH-1:0]                m_axis_tid,
    output      logic [DEST_WIDTH-1:0]              m_axis_tdest,
    output      logic [USER_WIDTH-1:0]              m_axis_tuser,

    input       logic [$clog2(S_COUNT):0]           select_input,
    output      logic [$clog2(S_COUNT)-1:0]         m_select
    );

localparam CL_S_COUNT = $clog2(S_COUNT);

logic                                           enable;
logic   [$clog2(S_COUNT)-1:0]                   select;
logic   [S_COUNT*DATA_SEL_WIDTH-1:0]            s_axis_tdata_line;
logic   [CL_S_COUNT-1:0]                        select_r;
logic   [CL_S_COUNT-1:0]                        select_next;
logic   [S_COUNT-1 : 0]                         s_axis_tready_r;
logic   [S_COUNT-1 : 0]                         s_axis_tready_next;
logic                                           frame_r;
logic                                           frame_next;
logic                                           store_axis_temp_to_output;
logic                                           store_axis_int_to_temp;
logic                                           store_axis_int_to_output;
logic   [USER_WIDTH-1:0]                        temp_m_axis_tuser_r;
logic   [DEST_WIDTH-1:0]                        temp_m_axis_tdest_r;
logic   [ID_WIDTH-1:0]                          temp_m_axis_tid_r;
logic                                           temp_m_axis_tlast_r;
logic                                           temp_m_axis_tvalid_next;
logic                                           temp_m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        temp_m_axis_tkeep_r;
logic   [DATA_SEL_WIDTH-1:0]                    temp_m_axis_tdata_r;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_r;
logic   [DEST_WIDTH-1:0]                        m_axis_tdest_r;
logic   [ID_WIDTH-1:0]                          m_axis_tid_r;
logic                                           m_axis_tlast_r;
logic                                           m_axis_tvalid_next;
logic                                           m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_r;
logic   [DATA_SEL_WIDTH-1:0]                    m_axis_tdata_r;
logic   [USER_WIDTH-1:0]                        current_s_tuser;
logic   [DEST_WIDTH-1:0]                        current_s_tdest;
logic   [ID_WIDTH-1:0]                          current_s_tid;
logic                                           current_s_tlast;
logic                                           current_s_tready;
logic                                           current_s_tvalid;
logic   [KEEP_WIDTH-1:0]                        current_s_tkeep;
logic   [DATA_SEL_WIDTH-1:0]                    current_s_tdata;
logic                                           m_axis_tready_int_early;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_int;
logic   [DEST_WIDTH-1:0]                        m_axis_tdest_int;
logic   [ID_WIDTH-1:0]                          m_axis_tid_int;
logic                                           m_axis_tlast_int;
logic                                           m_axis_tready_int_r;
logic                                           m_axis_tvalid_int;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_int;
logic   [DATA_SEL_WIDTH-1:0]                    m_axis_tdata_int;

assign enable                              = select_input > 0 ? 1 : 0;
assign select                              = select_input > 0 ? select_input-1 : 0;

generate 
for (genvar p = 0; p < S_COUNT; p=p+1) begin
    assign s_axis_tdata_line[p*DATA_SEL_WIDTH +: DATA_SEL_WIDTH] = {select_r,{s_axis_tdata[p*DATA_WIDTH +: DATA_WIDTH]}};
end
endgenerate

assign s_axis_tready                       = s_axis_tready_r;
// mux for incoming packet
assign current_s_tdata                     = s_axis_tdata_line[select_r*DATA_SEL_WIDTH +: DATA_SEL_WIDTH];
assign current_s_tkeep                     = s_axis_tkeep[select_r*KEEP_WIDTH +: KEEP_WIDTH];
assign current_s_tvalid                    = s_axis_tvalid[select_r];
assign current_s_tready                    = s_axis_tready[select_r];
assign current_s_tlast                     = s_axis_tlast[select_r];
assign current_s_tid                       = s_axis_tid[select_r*ID_WIDTH +: ID_WIDTH];
assign current_s_tdest                     = s_axis_tdest[select_r*DEST_WIDTH +: DEST_WIDTH];
assign current_s_tuser                     = s_axis_tuser[select_r*USER_WIDTH +: USER_WIDTH];

always_comb begin

    select_next                         = select_r;
    frame_next                          = frame_r;

    s_axis_tready_next                  = 0;

    if (current_s_tvalid & current_s_tready) begin
        // end of frame detection
        if(current_s_tlast)begin
            frame_next                          = 1'b0;
            // select_next = 0;
        end  
    end
        
    if (!frame_r && enable && (|(s_axis_tvalid & (1 << select)))) begin
            // start of frame, grab select value
            frame_next                          = 1'b1;
            select_next                         = select;
        end
    

    s_axis_tready_next                  = (m_axis_tready_int_early && frame_next) << select_next;

    // pass through selected packet data
    m_axis_tdata_int                    = current_s_tdata;
    m_axis_tkeep_int                    = current_s_tkeep;
    m_axis_tvalid_int                   = current_s_tvalid && current_s_tready && frame_r;
    m_axis_tlast_int                    = current_s_tlast;
    m_axis_tid_int                      = current_s_tid;
    m_axis_tdest_int                    = current_s_tdest;
    m_axis_tuser_int                    = current_s_tuser;
end

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
        select_r                            <= 0;
        frame_r                             <= 0;
        s_axis_tready_r                     <= 0;
    end 
    else begin
        select_r                            <= select_next;
        frame_r                             <= frame_next;
        s_axis_tready_r                     <= s_axis_tready_next;
    end

end

assign m_select                            = m_axis_tdata_r[DATA_WIDTH +: $clog2(S_COUNT)];
assign m_axis_tdata                        = m_axis_tdata_r[0 +: DATA_WIDTH];
assign m_axis_tkeep                        = KEEP_ENABLE ? m_axis_tkeep_r : {KEEP_WIDTH{1'b1}};
assign m_axis_tvalid                       = m_axis_tvalid_r;
assign m_axis_tlast                        = m_axis_tlast_r;
assign m_axis_tid                          = ID_ENABLE   ? m_axis_tid_r   : {ID_WIDTH{1'b0}};
assign m_axis_tdest                        = DEST_ENABLE ? m_axis_tdest_r : {DEST_WIDTH{1'b0}};
assign m_axis_tuser                        = USER_ENABLE ? m_axis_tuser_r : {USER_WIDTH{1'b0}};

// enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output logic empty or no input)
assign m_axis_tready_int_early             = m_axis_tready || (!temp_m_axis_tvalid_r && (!m_axis_tvalid_r || !m_axis_tvalid_int));

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

always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        m_axis_tvalid_r                     <= 1'b0;
        m_axis_tready_int_r                 <= 1'b0;
        temp_m_axis_tvalid_r                <= 1'b0;

        m_axis_tdata_r                      <= {DATA_SEL_WIDTH{1'b0}};
        m_axis_tkeep_r                      <= {KEEP_WIDTH{1'b0}};
        m_axis_tlast_r                      <= 1'b0;
        m_axis_tid_r                        <= {ID_WIDTH{1'b0}};
        m_axis_tdest_r                      <= {DEST_WIDTH{1'b0}};
        m_axis_tuser_r                      <= {USER_WIDTH{1'b0}};

        temp_m_axis_tdata_r                 <= {DATA_SEL_WIDTH{1'b0}};
        temp_m_axis_tkeep_r                 <= {KEEP_WIDTH{1'b0}};
        temp_m_axis_tlast_r                 <= 1'b0;
        temp_m_axis_tid_r                   <= {ID_WIDTH{1'b0}};
        temp_m_axis_tdest_r                 <= {DEST_WIDTH{1'b0}};
        temp_m_axis_tuser_r                 <= {USER_WIDTH{1'b0}};
    end
    else begin
        m_axis_tvalid_r                     <= m_axis_tvalid_next;
        m_axis_tready_int_r                 <= m_axis_tready_int_early;
        temp_m_axis_tvalid_r                <= temp_m_axis_tvalid_next;

        // datapath
        if (store_axis_int_to_output) begin
            m_axis_tdata_r                      <= m_axis_tdata_int;
            m_axis_tkeep_r                      <= m_axis_tkeep_int;
            m_axis_tlast_r                      <= m_axis_tlast_int;
            m_axis_tid_r                        <= m_axis_tid_int;
            m_axis_tdest_r                      <= m_axis_tdest_int;
            m_axis_tuser_r                      <= m_axis_tuser_int;
        end else if (store_axis_temp_to_output) begin
            m_axis_tdata_r                      <= temp_m_axis_tdata_r;
            m_axis_tkeep_r                      <= temp_m_axis_tkeep_r;
            m_axis_tlast_r                      <= temp_m_axis_tlast_r;
            m_axis_tid_r                        <= temp_m_axis_tid_r;
            m_axis_tdest_r                      <= temp_m_axis_tdest_r;
            m_axis_tuser_r                      <= temp_m_axis_tuser_r;
        end

        if (store_axis_int_to_temp) begin
            temp_m_axis_tdata_r                 <= m_axis_tdata_int;
            temp_m_axis_tkeep_r                 <= m_axis_tkeep_int;
            temp_m_axis_tlast_r                 <= m_axis_tlast_int;
            temp_m_axis_tid_r                   <= m_axis_tid_int;
            temp_m_axis_tdest_r                 <= m_axis_tdest_int;
            temp_m_axis_tuser_r                 <= m_axis_tuser_int;
        end
    end
end

endmodule
