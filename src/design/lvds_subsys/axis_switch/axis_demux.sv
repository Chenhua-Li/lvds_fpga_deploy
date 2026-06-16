
module axis_demux #(
    // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
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
    // output tdest signal width
    parameter M_DEST_WIDTH = 8,
    // input tdest signal width
    parameter S_DEST_WIDTH = M_DEST_WIDTH+$clog2(M_COUNT),
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // route via tdest
    parameter TDEST_ROUTE = 0
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
    input       logic [S_DEST_WIDTH-1:0]            s_axis_tdest,
    input       logic [USER_WIDTH-1:0]              s_axis_tuser,

    output      logic [M_COUNT*DATA_WIDTH-1:0]      m_axis_tdata,
    output      logic [M_COUNT*KEEP_WIDTH-1:0]      m_axis_tkeep,
    output      logic [M_COUNT-1:0]                 m_axis_tvalid,
    input       logic [M_COUNT-1:0]                 m_axis_tready,
    output      logic [M_COUNT-1:0]                 m_axis_tlast,
    output      logic [M_COUNT*ID_WIDTH-1:0]        m_axis_tid,
    output      logic [M_COUNT*M_DEST_WIDTH-1:0]    m_axis_tdest,
    output      logic [M_COUNT*USER_WIDTH-1:0]      m_axis_tuser,

    input       logic                               enable,
    input       logic                               drop,
    input       logic [$clog2(M_COUNT)-1:0]         select
    );

parameter CL_M_COUNT = $clog2(M_COUNT);
parameter M_DEST_WIDTH_INT = M_DEST_WIDTH > 0 ? M_DEST_WIDTH : 1;

// check configuration
initial begin
    if (TDEST_ROUTE) begin
        if (!DEST_ENABLE) begin
            $error("Error: TDEST_ROUTE set requires DEST_ENABLE set (instance %m)");
            $finish;
        end

        if (S_DEST_WIDTH < CL_M_COUNT) begin
            $error("Error: S_DEST_WIDTH too small for port count (instance %m)");
            $finish;
        end
    end
end

logic   [CL_M_COUNT-1:0]                        select_r;
logic   [CL_M_COUNT-1:0]                        select_ctl;
logic   [CL_M_COUNT-1:0]                        select_next;
logic                                           drop_r;
logic                                           drop_ctl;
logic                                           drop_next;
logic                                           frame_r;
logic                                           frame_ctl;
logic                                           frame_next;
logic                                           s_axis_tready_r;
logic                                           s_axis_tready_next;
logic   [DATA_WIDTH-1:0]                        m_axis_tdata_int;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_int;
logic   [M_COUNT-1:0]                           m_axis_tvalid_int;
logic                                           m_axis_tready_int_r;
logic                                           m_axis_tlast_int;
logic   [ID_WIDTH-1:0]                          m_axis_tid_int;
logic   [M_DEST_WIDTH-1:0]                      m_axis_tdest_int;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_int;
logic                                           m_axis_tready_int_early;
logic                                           store_axis_temp_to_output;
logic                                           store_axis_int_to_temp;
logic                                           store_axis_int_to_output;
logic   [USER_WIDTH-1:0]                        temp_m_axis_tuser_r;
logic   [M_DEST_WIDTH-1:0]                      temp_m_axis_tdest_r;
logic   [ID_WIDTH-1:0]                          temp_m_axis_tid_r;
logic                                           temp_m_axis_tlast_r;
logic   [M_COUNT-1:0]                           temp_m_axis_tvalid_next;
logic   [M_COUNT-1:0]                           temp_m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        temp_m_axis_tkeep_r;
logic   [DATA_WIDTH-1:0]                        temp_m_axis_tdata_r;
logic   [USER_WIDTH-1:0]                        m_axis_tuser_r;
logic   [M_DEST_WIDTH-1:0]                      m_axis_tdest_r;
logic   [ID_WIDTH-1:0]                          m_axis_tid_r;
logic                                           m_axis_tlast_r;
logic   [M_COUNT-1:0]                           m_axis_tvalid_next;
logic   [M_COUNT-1:0]                           m_axis_tvalid_r;
logic   [KEEP_WIDTH-1:0]                        m_axis_tkeep_r;
logic   [DATA_WIDTH-1:0]                        m_axis_tdata_r;


assign s_axis_tready                       = s_axis_tready_r && enable;

always_comb begin
    select_next                         = select_r;
    select_ctl                          = select_r;
    drop_next                           = drop_r;
    drop_ctl                            = drop_r;
    frame_next                          = frame_r;
    frame_ctl                           = frame_r;
    s_axis_tready_next                  = 1'b0;

    if (s_axis_tvalid && s_axis_tready) begin
        // end of frame detection
        if (s_axis_tlast) begin
            frame_next                          = 1'b0;
            drop_next                           = 1'b0;
        end
    end

    if (!frame_r && s_axis_tvalid && s_axis_tready) begin
        // start of frame, grab select value
        if (TDEST_ROUTE) begin
            if (M_COUNT > 1) begin
                select_ctl                          = s_axis_tdest[S_DEST_WIDTH-1:S_DEST_WIDTH-CL_M_COUNT];
                drop_ctl                            = s_axis_tdest[S_DEST_WIDTH-1:S_DEST_WIDTH-CL_M_COUNT] >= M_COUNT;
            end else begin
                select_ctl                          = 0;
                drop_ctl                            = 1'b0;
            end
        end else begin
            select_ctl                          = select;
            drop_ctl                            = drop || select >= M_COUNT;
        end
        frame_ctl                           = 1'b1;
        if (!(s_axis_tready && s_axis_tvalid && s_axis_tlast)) begin
            select_next                         = select_ctl;
            drop_next                           = drop_ctl;
            frame_next                          = 1'b1;
        end
    end

    s_axis_tready_next                  = (m_axis_tready_int_early || drop_ctl);

    m_axis_tdata_int                    = s_axis_tdata;
    m_axis_tkeep_int                    = s_axis_tkeep;
    m_axis_tvalid_int                   = (s_axis_tvalid && s_axis_tready && !drop_ctl) << select_ctl;
    m_axis_tlast_int                    = s_axis_tlast;
    m_axis_tid_int                      = s_axis_tid;
    m_axis_tdest_int                    = s_axis_tdest;
    m_axis_tuser_int                    = s_axis_tuser;
end

always_ff @(posedge clk or negedge rstn)
    if (~rstn) begin
        select_r                            <= 2'd0;
        drop_r                              <= 1'b0;
        frame_r                             <= 1'b0;
        s_axis_tready_r                     <= 1'b0;
    end
    else begin
        select_r                            <= select_next;
        drop_r                              <= drop_next;
        frame_r                             <= frame_next;
        s_axis_tready_r                     <= s_axis_tready_next;
    end

assign m_axis_tdata                        = {M_COUNT{m_axis_tdata_r}};
assign m_axis_tkeep                        = KEEP_ENABLE ? {M_COUNT{m_axis_tkeep_r}} : {M_COUNT*KEEP_WIDTH{1'b1}};
assign m_axis_tvalid                       = m_axis_tvalid_r;
assign m_axis_tlast                        = {M_COUNT{m_axis_tlast_r}};
assign m_axis_tid                          = ID_ENABLE   ? {M_COUNT{m_axis_tid_r}}   : '0;
assign m_axis_tdest                        = DEST_ENABLE ? {M_COUNT{m_axis_tdest_r}} : '0;
assign m_axis_tuser                        = USER_ENABLE ? {M_COUNT{m_axis_tuser_r}} : '0;

// enable ready input next cycle if output is ready or if both output registers are empty
assign m_axis_tready_int_early             = (|(m_axis_tready & m_axis_tvalid))  | (!temp_m_axis_tvalid_r && !m_axis_tvalid_r);

always_comb begin
    // transfer sink ready state to source
    m_axis_tvalid_next                  = m_axis_tvalid_r;
    temp_m_axis_tvalid_next             = temp_m_axis_tvalid_r;

    store_axis_int_to_output            = 1'b0;
    store_axis_int_to_temp              = 1'b0;
    store_axis_temp_to_output           = 1'b0;

    if (m_axis_tready_int_r) begin
        // input is ready
        if ((|(m_axis_tready & m_axis_tvalid)) | (&(~m_axis_tvalid))) begin
            // output is ready or currently not valid, transfer data to output
            m_axis_tvalid_next                  = m_axis_tvalid_int;
            store_axis_int_to_output            = 1'b1;
        end else begin
            // output is not ready, store input in temp
            temp_m_axis_tvalid_next             = m_axis_tvalid_int;
            store_axis_int_to_temp              = 1'b1;
        end
    end else if ((|(m_axis_tready & m_axis_tvalid))) begin
        // input is not ready, but output is ready
        m_axis_tvalid_next                  = temp_m_axis_tvalid_r;
        temp_m_axis_tvalid_next             = {M_COUNT{1'b0}};
        store_axis_temp_to_output           = 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn)
    if (~rstn) begin
        m_axis_tvalid_r                     <= {M_COUNT{1'b0}};
        m_axis_tready_int_r                 <= 1'b0;
        m_axis_tdata_r                      <= '0;
        m_axis_tkeep_r                      <= '0;
        m_axis_tlast_r                      <= '0;
        m_axis_tid_r                        <= '0;
        m_axis_tdest_r                      <= '0;
        m_axis_tuser_r                      <= '0;
        temp_m_axis_tvalid_r                <= '0;
        temp_m_axis_tdata_r                 <= '0;
        temp_m_axis_tkeep_r                 <= '0;
        temp_m_axis_tlast_r                 <= '0;
        temp_m_axis_tid_r                   <= '0;
        temp_m_axis_tdest_r                 <= '0;
        temp_m_axis_tuser_r                 <= '0;

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

endmodule

