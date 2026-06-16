
module axis_mimo_tx #
(
     // Number of AXI stream inputs
    parameter S_COUNT = 4,
     // Number of AXI stream outputs
    parameter M_COUNT = 3,
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 96,
    // fifo_depth
    parameter FIFO_DEPTH = 4,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = 0,
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 1,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 1,
    // Propagate tuser signal
    parameter USER_ENABLE = 0,
    // tuser signal width
    parameter USER_WIDTH = 1,
    // Asynchronus input formm
    parameter ASYNC = 0
    )
(
    input       logic                               cfg_dis_parallel_tx,
    input       logic                               clk,
    input       logic                               rst_n,

    input       logic [S_COUNT-1:0]                 s_clk,
    input       logic [S_COUNT-1:0]                 s_rst_n,

    input       logic [S_COUNT*DATA_WIDTH-1:0]      s_axis_tdata,
    input       logic [S_COUNT*KEEP_WIDTH-1:0]      s_axis_tkeep,
    input       logic [S_COUNT-1:0]                 s_axis_tvalid,
    output      logic [S_COUNT-1:0]                 s_axis_tready,
    input       logic [S_COUNT-1:0]                 s_axis_tlast,
    input       logic [S_COUNT*ID_WIDTH-1:0]        s_axis_tid,
    input       logic [S_COUNT*DEST_WIDTH-1:0]      s_axis_tdest,
    input       logic [S_COUNT*USER_WIDTH-1:0]      s_axis_tuser,

    output      logic [M_COUNT*DATA_WIDTH-1:0]      m_axis_tdata,
    output      logic [M_COUNT*KEEP_WIDTH-1:0]      m_axis_tkeep,
    output      logic [M_COUNT-1:0]                 m_axis_tvalid,
    input       logic [M_COUNT-1:0]                 m_axis_tready,
    output      logic [M_COUNT-1:0]                 m_axis_tlast,
    output      logic [M_COUNT*ID_WIDTH-1:0]        m_axis_tid,
    output      logic [M_COUNT*DEST_WIDTH-1:0]      m_axis_tdest,
    output      logic [M_COUNT*USER_WIDTH-1:0]      m_axis_tuser,
    
    output      logic [M_COUNT*$clog2(S_COUNT)-1:0] select
    );

logic   [S_COUNT*DATA_WIDTH-1:0]                s_axis_tdata_line;
logic   [S_COUNT*KEEP_WIDTH-1:0]                s_axis_tkeep_line;
logic   [S_COUNT-1:0]                           s_axis_tvalid_line;
logic   [S_COUNT-1:0]                           s_axis_tready_line;
logic   [S_COUNT-1:0]                           s_axis_tlast_line;
logic   [S_COUNT*ID_WIDTH-1:0]                  s_axis_tid_line;
logic   [S_COUNT*DEST_WIDTH-1:0]                s_axis_tdest_line;
logic   [S_COUNT*USER_WIDTH-1:0]                s_axis_tuser_line;
logic   [M_COUNT-1:0][($clog2(S_COUNT)+1)-1:0]  select_line_p0;
logic   [M_COUNT-1:0][($clog2(S_COUNT)+1)-1:0]  select_line;
logic   [1:0]                                   select_line_p1;
logic   [M_COUNT*S_COUNT-1:0]                   s_axis_tready_merge;
logic   [M_COUNT*S_COUNT-1:0]                   s_axis_tready_merge_r;

assign s_axis_tready_line                  = s_axis_tready_merge_r[(M_COUNT-1)*S_COUNT +: S_COUNT];

always_comb begin
    s_axis_tready_merge_r[0 +: S_COUNT] = s_axis_tready_merge[0 +: S_COUNT];
    for (int unsigned i= 1; i<M_COUNT; i=i+1) begin
        s_axis_tready_merge_r[i*S_COUNT +: S_COUNT]= s_axis_tready_merge_r[(i-1)*S_COUNT +: S_COUNT]|s_axis_tready_merge[i*S_COUNT +: S_COUNT];
    end 
end  

// Asynchronus input formm

generate
    if(ASYNC) begin
        for (genvar k= 0; k<S_COUNT; k=k+1)
        begin: axis_async_fifo
    axis_async_fifo #(
    .DATA_WIDTH                         ( DATA_WIDTH                  ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( ID_WIDTH                    ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( DEST_WIDTH                  ),
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
    .s_axis_tdata                       ( s_axis_tdata[k*DATA_WIDTH +: DATA_WIDTH]),
    .s_axis_tvalid                      ( s_axis_tvalid[k]            ),
    .s_axis_tlast                       ( s_axis_tlast[k]             ),
    .s_axis_tready                      ( s_axis_tready[k]            ),
    .s_axis_tid                         ( s_axis_tid[k*ID_WIDTH +: ID_WIDTH]),
    .s_axis_tkeep                       ( s_axis_tkeep[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .s_axis_tdest                       ( s_axis_tdest[k*DEST_WIDTH +: DEST_WIDTH]),
    .s_axis_tuser                       ( s_axis_tuser[k*USER_WIDTH +: USER_WIDTH]),
    .m_clk                              ( clk                         ),
    .m_rstn                             ( rst_n                       ),
    .m_axis_tdata                       ( s_axis_tdata_line[k*DATA_WIDTH +: DATA_WIDTH]),
    .m_axis_tvalid                      ( s_axis_tvalid_line[k]       ),
    .m_axis_tready                      ( s_axis_tready_line[k]       ),
    .m_axis_tlast                       ( s_axis_tlast_line[k]        ),
    .m_axis_tid                         ( s_axis_tid_line[k*ID_WIDTH +: ID_WIDTH]),
    .m_axis_tdest                       ( s_axis_tdest_line[k*DEST_WIDTH +: DEST_WIDTH]),
    .m_axis_tkeep                       ( s_axis_tkeep_line[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tuser                       ( s_axis_tuser_line[k*USER_WIDTH +: USER_WIDTH])
    );
        end  
    end else begin
        for (genvar k= 0; k<S_COUNT; k=k+1)
        begin: axis_fifo
    axis_fifo #(
    .DATA_WIDTH                         ( DATA_WIDTH                  ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( ID_WIDTH                    ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( DEST_WIDTH                  ),
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
    .s_axis_tdata                       ( s_axis_tdata[k*DATA_WIDTH +: DATA_WIDTH]),
    .s_axis_tvalid                      ( s_axis_tvalid[k]            ),
    .s_axis_tlast                       ( s_axis_tlast[k]             ),
    .s_axis_tready                      ( s_axis_tready[k]            ),
    .s_axis_tid                         ( s_axis_tid[k*ID_WIDTH +: ID_WIDTH]),
    .s_axis_tkeep                       ( s_axis_tkeep[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .s_axis_tdest                       ( s_axis_tdest[k*DEST_WIDTH +: DEST_WIDTH]),
    .s_axis_tuser                       ( s_axis_tuser[k*USER_WIDTH +: USER_WIDTH]),
    .m_axis_tdata                       ( s_axis_tdata_line[k*DATA_WIDTH +: DATA_WIDTH]),
    .m_axis_tvalid                      ( s_axis_tvalid_line[k]       ),
    .m_axis_tready                      ( s_axis_tready_line[k]       ),
    .m_axis_tlast                       ( s_axis_tlast_line[k]        ),
    .m_axis_tid                         ( s_axis_tid_line[k*ID_WIDTH +: ID_WIDTH]),
    .m_axis_tdest                       ( s_axis_tdest_line[k*DEST_WIDTH +: DEST_WIDTH]),
    .m_axis_tkeep                       ( s_axis_tkeep_line[k*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tuser                       ( s_axis_tuser_line[k*USER_WIDTH +: USER_WIDTH]),
    .status_overflow                    (                             ),
    .status_bad_frame                   (                             ),
    .status_good_frame                  (                             )
    );
        end  
    end
endgenerate

assign select_line = cfg_dis_parallel_tx ? {
        (select_line_p1[0] ? 3'd3 : 
         select_line_p1[1] ? 3'd4 : 
         3'd0),
        3'd2,3'd1}: select_line_p0;
axis_arb #(
    .S_COUNT                            ( S_COUNT                     ),
    .M_COUNT                            ( M_COUNT                     )   
    )
u_axis_arb_p0(
    .clk                                ( clk                         ),
    .rst_n                              ( rst_n                       ),
    .s_axis_tvalid                      ( cfg_dis_parallel_tx ? '0 : s_axis_tvalid_line),
    .s_axis_tready                      ( cfg_dis_parallel_tx ? '0 : s_axis_tready_line),
    .s_axis_tlast                       ( cfg_dis_parallel_tx ? '0 : s_axis_tlast_line ),
    //.m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready                      ( cfg_dis_parallel_tx ? '0 : m_axis_tready     ),
    //.m_axis_tlast(m_axis_tlast),
    .select                             ( select_line_p0                 )   
    );

axis_arb_rr #(
    .S_COUNT                            ( 2 ),
    .M_COUNT                            ( 1 )   
    )
u_axis_arb_p1(
    .clk                                ( clk                         ),
    .rst_n                              ( rst_n                       ),
    .s_axis_tvalid                      ( cfg_dis_parallel_tx ? s_axis_tvalid_line[3:2] : '0),
    .s_axis_tready                      ( cfg_dis_parallel_tx ? s_axis_tready_line[3:2] : '0),
    .s_axis_tlast                       ( cfg_dis_parallel_tx ? s_axis_tlast_line [3:2] : '0),
    //.m_axis_tvalid(m_axis_tvalid),                                 
    .m_axis_tready                      ( cfg_dis_parallel_tx ? m_axis_tready[2]      : '0),
    //.m_axis_tlast(m_axis_tlast),
    .select                             ( select_line_p1                 )   
    );



generate 
    for (genvar j= 0; j<M_COUNT; j=j+1)
    begin: axis_mux
axis_mux #(
    .S_COUNT                            ( S_COUNT                     ),
    .DATA_WIDTH                         ( DATA_WIDTH                  ),
    .KEEP_ENABLE                        ( KEEP_ENABLE                 ),
    .KEEP_WIDTH                         ( KEEP_WIDTH                  ),
    .ID_ENABLE                          ( ID_ENABLE                   ),
    .ID_WIDTH                           ( ID_WIDTH                    ),
    .DEST_ENABLE                        ( DEST_ENABLE                 ),
    .DEST_WIDTH                         ( DEST_WIDTH                  ),
    .USER_ENABLE                        ( USER_ENABLE                 ),
    .USER_WIDTH                         ( USER_WIDTH                  )
    )
u_axis_mux (
    .clk                                ( clk                         ),
    .rst_n                              ( rst_n                       ),
    .s_axis_tdata                       ( s_axis_tdata_line           ),
    .s_axis_tvalid                      ( s_axis_tvalid_line          ),
    .s_axis_tready                      ( s_axis_tready_merge[j*S_COUNT +: S_COUNT]),
    .s_axis_tlast                       ( s_axis_tlast_line           ),
    .s_axis_tid                         ( s_axis_tid_line             ),
    .s_axis_tkeep                       ( s_axis_tkeep_line           ),
    .s_axis_tdest                       ( s_axis_tdest_line           ),
    .s_axis_tuser                       ( s_axis_tuser_line           ),
    .m_axis_tdata                       ( m_axis_tdata[j*DATA_WIDTH +: DATA_WIDTH]),
    .m_axis_tvalid                      ( m_axis_tvalid[j]            ),
    .m_axis_tready                      ( m_axis_tready[j]            ),
    .m_axis_tlast                       ( m_axis_tlast[j]             ),
    .m_axis_tid                         ( m_axis_tid[j*ID_WIDTH +: ID_WIDTH]),
    .m_axis_tdest                       ( m_axis_tdest[j*DEST_WIDTH +: DEST_WIDTH]),
    .m_axis_tkeep                       ( m_axis_tkeep[j*KEEP_WIDTH +: KEEP_WIDTH]),
    .m_axis_tuser                       ( m_axis_tuser[j*USER_WIDTH +: USER_WIDTH]),
    .select_input                       ( select_line[j]),
    .m_select                           ( select[j*$clog2(S_COUNT     ) +: $clog2(S_COUNT)])
    );
    end
endgenerate
  
endmodule
