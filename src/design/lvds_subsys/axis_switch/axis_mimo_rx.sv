

module axis_mimo_rx #(
     // Number of AXI stream inputs
    parameter S_COUNT = 3,
     // Number of AXI stream outputs
    parameter M_COUNT = 4,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 96,
    // Width of DATA + SELECT
    parameter DATA_SEL_WIDTH = DATA_WIDTH+$clog2(M_COUNT),
    // fifo depth
    parameter FIFO_DEPTH = 4,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = 0,
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    //parameter ID_WIDTH = 8,
    parameter S_ID_WIDTH = 1,
    // output tid signal width
    parameter M_ID_WIDTH = S_ID_WIDTH+$clog2(S_COUNT),
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // output tdest signal width
    parameter M_DEST_WIDTH = 1,
    // input tdest signal width
    parameter S_DEST_WIDTH = M_DEST_WIDTH+$clog2(M_COUNT),
    // Propagate tuser signal
    parameter USER_ENABLE = 0,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Asynchronus input formm
    parameter ASYNC = 0
    )
(
    input       logic                               clk,
    input       logic                               rst_n,

    input       logic [S_COUNT-1:0]                 s_clk,
    input       logic [S_COUNT-1:0]                 s_rst_n,

    input       logic [S_COUNT*DATA_WIDTH-1:0]      s_axis_tdata,
    input       logic [S_COUNT-1:0]                 s_axis_tvalid,
    output      logic [S_COUNT-1:0]                 s_axis_tready,
    input       logic [S_COUNT-1:0]                 s_axis_tlast,
    input       logic [S_COUNT*KEEP_WIDTH-1:0]      s_axis_tkeep,
    input       logic [S_COUNT*S_ID_WIDTH-1:0]      s_axis_tid,
    input       logic [S_COUNT*S_DEST_WIDTH-1:0]    s_axis_tdest,
    input       logic [S_COUNT*USER_WIDTH-1:0]      s_axis_tuser,

    output      logic [M_COUNT*DATA_WIDTH-1:0]      m_axis_tdata,
    output      logic [M_COUNT-1:0]                 m_axis_tvalid,
    input       logic [M_COUNT-1:0]                 m_axis_tready,
    output      logic [M_COUNT-1:0]                 m_axis_tlast,
    output      logic [M_COUNT*KEEP_WIDTH-1:0]      m_axis_tkeep,
    output      logic [M_COUNT*M_ID_WIDTH-1:0]      m_axis_tid,
    output      logic [M_COUNT*M_DEST_WIDTH-1:0]    m_axis_tdest,
    output      logic [M_COUNT*USER_WIDTH-1:0]      m_axis_tuser,
    
    input       logic                               enable,
    input       logic [S_COUNT*$clog2(M_COUNT)-1:0] select
    );

logic   [S_COUNT*DATA_SEL_WIDTH-1:0]            s_axis_tdata_sel_line;
logic   [S_COUNT*DATA_SEL_WIDTH-1:0]            s_axis_tdata_sel_link;
logic   [S_COUNT*DATA_WIDTH-1:0]                s_axis_tdata_link;
logic   [S_COUNT*$clog2(M_COUNT)-1:0]           select_link;
logic   [S_COUNT-1:0]                           s_axis_tvalid_link;
logic   [S_COUNT-1:0]                           s_axis_tready_link;
logic   [S_COUNT-1:0]                           s_axis_tlast_link;
logic   [S_COUNT*KEEP_WIDTH-1:0]                s_axis_tkeep_link;
logic   [S_COUNT*S_ID_WIDTH-1:0]                s_axis_tid_link;
logic   [S_COUNT*S_DEST_WIDTH-1:0]              s_axis_tdest_link;
logic   [S_COUNT*USER_WIDTH-1:0]                s_axis_tuser_link;
logic   [M_COUNT*DATA_WIDTH-1:0]                s_axis_tdata_line[S_COUNT-1:0];
logic   [M_COUNT-1:0]                           s_axis_tvalid_line[S_COUNT-1:0];
logic   [M_COUNT-1:0]                           s_axis_tready_line[S_COUNT-1:0];
logic   [M_COUNT-1:0]                           s_axis_tlast_line[S_COUNT-1:0];
logic   [M_COUNT*KEEP_WIDTH-1:0]                s_axis_tkeep_line[S_COUNT-1:0];
logic   [M_COUNT*S_ID_WIDTH-1:0]                s_axis_tid_line[S_COUNT-1:0];
logic   [M_COUNT*M_DEST_WIDTH-1:0]              s_axis_tdest_line[S_COUNT-1:0];
logic   [M_COUNT*USER_WIDTH-1:0]                s_axis_tuser_line[S_COUNT-1:0];
logic   [S_COUNT*DATA_WIDTH-1:0]                s_axis_tdata_merge[M_COUNT-1:0];
logic   [S_COUNT*KEEP_WIDTH-1:0]                s_axis_tkeep_merge[M_COUNT-1:0];
logic   [S_COUNT-1:0]                           s_axis_tvalid_merge[M_COUNT-1:0];
logic   [S_COUNT-1:0]                           s_axis_tready_merge[M_COUNT-1:0];
logic   [S_COUNT-1:0]                           s_axis_tlast_merge[M_COUNT-1:0];
logic   [S_COUNT*S_ID_WIDTH-1:0]                s_axis_tid_merge[M_COUNT-1:0];
logic   [S_COUNT*M_DEST_WIDTH-1:0]              s_axis_tdest_merge[M_COUNT-1:0];
logic   [S_COUNT*USER_WIDTH-1:0]                s_axis_tuser_merge[M_COUNT-1:0];

generate 
for (genvar p = 0; p < S_COUNT; p=p+1) begin
    assign s_axis_tdata_sel_line[p*DATA_SEL_WIDTH +: DATA_SEL_WIDTH] = {select[p*$clog2(M_COUNT) +: $clog2(M_COUNT)],s_axis_tdata[p*DATA_WIDTH +: DATA_WIDTH]};
    assign s_axis_tdata_link[p*DATA_WIDTH +: DATA_WIDTH] = s_axis_tdata_sel_link[p*DATA_SEL_WIDTH +: DATA_WIDTH];
    assign select_link[p*$clog2(M_COUNT) +: $clog2(M_COUNT)] = s_axis_tdata_sel_link[p*DATA_SEL_WIDTH+DATA_WIDTH +: $clog2(M_COUNT)];
end
endgenerate

generate
    for (genvar l= 0; l<S_COUNT; l=l+1) begin : loop_assign1
        for (genvar n= 0; n<M_COUNT; n=n+1) begin : loop_assign2
            assign s_axis_tdata_merge[n][l*DATA_WIDTH +: DATA_WIDTH] = s_axis_tdata_line[l][n*DATA_WIDTH +: DATA_WIDTH];
            assign s_axis_tkeep_merge[n][l*KEEP_WIDTH +: KEEP_WIDTH] = KEEP_ENABLE ? s_axis_tkeep_line[l][n*KEEP_WIDTH +: KEEP_WIDTH] : '0;
            assign s_axis_tvalid_merge[n][l] = s_axis_tvalid_line[l][n];
            assign s_axis_tready_line[l][n] = s_axis_tready_merge[n][l];
            assign s_axis_tlast_merge[n][l] = s_axis_tlast_line[l][n];
            assign s_axis_tid_merge[n][l*S_ID_WIDTH +: S_ID_WIDTH] = ID_ENABLE ? s_axis_tid_line[l][n*S_ID_WIDTH +: S_ID_WIDTH] : '0;
            assign s_axis_tdest_merge[n][l*M_DEST_WIDTH +: M_DEST_WIDTH] = s_axis_tdest_line[l][n*M_DEST_WIDTH +: M_DEST_WIDTH];
            assign s_axis_tuser_merge[n][l*USER_WIDTH +: USER_WIDTH] = USER_ENABLE ? s_axis_tuser_line[l][n*USER_WIDTH +: USER_WIDTH] : '0;
        end
    end
endgenerate

// Asynchronus input formm
generate
    if (ASYNC) begin 
        for (genvar k= 0; k<S_COUNT; k=k+1)
        begin: axis_async_fifo
        axis_async_fifo #(
    .DATA_WIDTH                         ( DATA_SEL_WIDTH              ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( S_ID_WIDTH                  ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( S_DEST_WIDTH                ),
    .USER_ENABLE                        ( USER_ENABLE                 ),
    .USER_WIDTH                         ( USER_WIDTH                  ),
    .DEPTH                              ( FIFO_DEPTH                  ),
    .LAST_ENABLE                        ( 1                           ),
    .PIPELINE_OUTPUT                    ( 2                           ),
    .FRAME_FIFO                         ( 0                           ),
    .USER_BAD_FRAME_VALUE               ( 1'b1                        ),
    .USER_BAD_FRAME_MASK                ( 1'b1                        ),
    .DROP_OVERSIZE_FRAME                ( 0                           ),
    .DROP_BAD_FRAME                     ( 0                           ),
    .DROP_WHEN_FULL                     ( 0                           )
    )
        async_fifo (
    .s_status_overflow                  (                             ),
    .s_status_bad_frame                 (                             ),
    .s_status_good_frame                (                             ),
    .m_status_overflow                  (                             ),
    .m_status_bad_frame                 (                             ),
    .m_status_good_frame                (                             ),
    .s_clk                              ( s_clk[k]                    ),
    .s_rstn                             ( s_rst_n[k]                  ),
    .s_axis_tdata                       ( s_axis_tdata_sel_line[k*DATA_SEL_WIDTH +: DATA_SEL_WIDTH]),
    .s_axis_tvalid                      ( s_axis_tvalid[k]            ),
    .s_axis_tlast                       ( s_axis_tlast[k]             ),
    .s_axis_tready                      ( s_axis_tready[k]            ),
    .s_axis_tid                         ( s_axis_tid[k*S_ID_WIDTH +: S_ID_WIDTH]),
    .s_axis_tkeep                       ( s_axis_tkeep[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .s_axis_tdest                       ( s_axis_tdest[k*S_DEST_WIDTH +: S_DEST_WIDTH]),
    .s_axis_tuser                       ( s_axis_tuser[k*USER_WIDTH +: USER_WIDTH]),
    .m_clk                              ( clk                         ),
    .m_rstn                             ( rst_n                       ),
    .m_axis_tdata                       ( s_axis_tdata_sel_link[k*DATA_SEL_WIDTH +: DATA_SEL_WIDTH]),
    .m_axis_tvalid                      ( s_axis_tvalid_link[k]       ),
    .m_axis_tready                      ( s_axis_tready_link[k]       ),
    .m_axis_tlast                       ( s_axis_tlast_link[k]        ),
    .m_axis_tid                         ( s_axis_tid_link[k*S_ID_WIDTH +: S_ID_WIDTH]),
    .m_axis_tdest                       ( s_axis_tdest_link[k*S_DEST_WIDTH +: S_DEST_WIDTH]),
    .m_axis_tkeep                       ( s_axis_tkeep_link[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tuser                       ( s_axis_tuser_link[k*USER_WIDTH +: USER_WIDTH])
    );
        end 
    end else begin  
        for (genvar k= 0; k<S_COUNT; k=k+1)
        begin: axis_fifo
        axis_fifo #(
    .DATA_WIDTH                         ( DATA_SEL_WIDTH              ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( S_ID_WIDTH                  ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( S_DEST_WIDTH                ),
    .USER_ENABLE                        ( USER_ENABLE                 ),
    .USER_WIDTH                         ( USER_WIDTH                  ),
    .DEPTH                              ( FIFO_DEPTH                  ),
    .LAST_ENABLE                        ( 1                           ),
    .PIPELINE_OUTPUT                    ( 2                           ),
    .FRAME_FIFO                         ( 0                           ),
    .USER_BAD_FRAME_VALUE               ( 1'b1                        ),
    .USER_BAD_FRAME_MASK                ( 1'b1                        ),
    .DROP_OVERSIZE_FRAME                ( 0                           ),
    .DROP_BAD_FRAME                     ( 0                           ),
    .DROP_WHEN_FULL                     ( 0                           )
    )
        fifo (
    .clk                                ( clk                         ),
    .rstn                               ( rst_n                       ),
    .s_axis_tdata                       ( s_axis_tdata_sel_line[k*DATA_SEL_WIDTH +: DATA_SEL_WIDTH]),
    .s_axis_tvalid                      ( s_axis_tvalid[k]            ),
    .s_axis_tlast                       ( s_axis_tlast[k]             ),
    .s_axis_tready                      ( s_axis_tready[k]            ),
    .s_axis_tid                         ( s_axis_tid[k*S_ID_WIDTH +: S_ID_WIDTH]),
    .s_axis_tkeep                       ( s_axis_tkeep[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .s_axis_tdest                       ( s_axis_tdest[k*S_DEST_WIDTH +: S_DEST_WIDTH]),
    .s_axis_tuser                       ( s_axis_tuser[k*USER_WIDTH +: USER_WIDTH]),
    .m_axis_tdata                       ( s_axis_tdata_sel_link[k*DATA_SEL_WIDTH +: DATA_SEL_WIDTH]),
    .m_axis_tvalid                      ( s_axis_tvalid_link[k]       ),
    .m_axis_tready                      ( s_axis_tready_link[k]       ),
    .m_axis_tlast                       ( s_axis_tlast_link[k]        ),
    .m_axis_tid                         ( s_axis_tid_link[k*S_ID_WIDTH +: S_ID_WIDTH]),
    .m_axis_tdest                       ( s_axis_tdest_link[k*S_DEST_WIDTH +: S_DEST_WIDTH]),
    .m_axis_tkeep                       ( s_axis_tkeep_link[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tuser                       ( s_axis_tuser_link[k*USER_WIDTH +: USER_WIDTH]),
    .status_overflow                    (                             ),
    .status_bad_frame                   (                             ),
    .status_good_frame                  (                             )
    );
        end 
    end 
endgenerate

generate 
    for (genvar i= 0; i<S_COUNT; i=i+1)
    begin: axis_demux
axis_demux #(
    .M_COUNT                            ( M_COUNT                     ),
    .DATA_WIDTH                         ( DATA_WIDTH                  ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( S_ID_WIDTH                  ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .M_DEST_WIDTH                       ( M_DEST_WIDTH                ),
    .S_DEST_WIDTH                       ( S_DEST_WIDTH                ),
    .USER_ENABLE                        ( USER_ENABLE                 ),
    .USER_WIDTH                         ( USER_WIDTH                  ),
    .TDEST_ROUTE                        ( 0                           )
    )
demux (
    .clk                                ( clk                         ),
    .rstn                               ( rst_n                       ),
    .s_axis_tdata                       ( s_axis_tdata_link[i*DATA_WIDTH +: DATA_WIDTH]),
    .s_axis_tvalid                      ( s_axis_tvalid_link[i]       ),
    .s_axis_tready                      ( s_axis_tready_link[i]       ),
    .s_axis_tlast                       ( s_axis_tlast_link[i]        ),
    .s_axis_tid                         ( s_axis_tid_link[i*S_ID_WIDTH +: S_ID_WIDTH]),
    .s_axis_tkeep                       ( s_axis_tkeep_link[i*KEEP_WIDTH +: KEEP_WIDTH]),
    .s_axis_tdest                       ( s_axis_tdest_link[i*S_DEST_WIDTH +: S_DEST_WIDTH]),
    .s_axis_tuser                       ( s_axis_tuser_link[i*USER_WIDTH +: USER_WIDTH]),
    .m_axis_tdata                       ( s_axis_tdata_line[i]        ),
    .m_axis_tvalid                      ( s_axis_tvalid_line[i]       ),
    .m_axis_tready                      ( s_axis_tready_line[i]       ),
    .m_axis_tlast                       ( s_axis_tlast_line[i]        ),
    .m_axis_tid                         ( s_axis_tid_line[i]          ),
    .m_axis_tdest                       ( s_axis_tdest_line[i]        ),
    .m_axis_tkeep                       ( s_axis_tkeep_line[i]        ),
    .m_axis_tuser                       ( s_axis_tuser_line[i]        ),
    .enable                             ( enable                      ),
    .drop                               ( '0                          ),
    .select                             ( select_link[i*$clog2(M_COUNT) +: $clog2(M_COUNT)])
    );
end         
endgenerate

generate 
    for (genvar j= 0; j<M_COUNT; j=j+1)
    begin: axis_arb_mux
axis_arb_mux #(
    .S_COUNT                            ( S_COUNT                     ),
    .DATA_WIDTH                         ( DATA_WIDTH                  ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .S_ID_WIDTH                         ( S_ID_WIDTH                  ),
    .M_ID_WIDTH                         ( M_ID_WIDTH                  ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( M_DEST_WIDTH                ),
    .USER_ENABLE                        ( USER_ENABLE                 ),
    .USER_WIDTH                         ( USER_WIDTH                  ),
    .LAST_ENABLE                        ( 1                           ),
    .UPDATE_TID                         ( 0                           ),
    .ARB_TYPE_ROUND_ROBIN               ( 0                           ),
    .ARB_LSB_HIGH_PRIORITY              ( 1                           )
    )
axis_arb_mux (
    .clk                                ( clk                         ),
    .rstn                               ( rst_n                       ),
    .s_axis_tdata                       ( s_axis_tdata_merge[j]       ),
    .s_axis_tvalid                      ( s_axis_tvalid_merge[j]      ),
    .s_axis_tready                      ( s_axis_tready_merge[j]      ),
    .s_axis_tlast                       ( s_axis_tlast_merge[j]       ),
    .s_axis_tid                         ( s_axis_tid_merge[j]         ),
    .s_axis_tkeep                       ( s_axis_tkeep_merge[j]       ),
    .s_axis_tdest                       ( s_axis_tdest_merge[j]       ),
    .s_axis_tuser                       ( s_axis_tuser_merge[j]       ),
    .m_axis_tdata                       ( m_axis_tdata[j*DATA_WIDTH +: DATA_WIDTH]),
    .m_axis_tvalid                      ( m_axis_tvalid[j]            ),
    .m_axis_tready                      ( m_axis_tready[j]            ),
    .m_axis_tlast                       ( m_axis_tlast[j]             ),
    .m_axis_tid                         ( m_axis_tid[j*M_ID_WIDTH +: M_ID_WIDTH]),
    .m_axis_tkeep                       ( m_axis_tkeep[j*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tdest                       ( m_axis_tdest[j*M_DEST_WIDTH +: M_DEST_WIDTH]),
    .m_axis_tuser                       ( m_axis_tuser[j*USER_WIDTH +: USER_WIDTH])
    );
end
endgenerate

endmodule
