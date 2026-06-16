
module lvds_rx_axis_if
import lvds_if_pkg::*;
(

    //wf_if
    input                                           wclk,
    input                                           wrstn,
    input       logic                               lvds_rx_df_push_en,
    input       lvds_rx_wf_data_type                lvds_rx_df_push_data,
    input       [4:0]                               wr_wm,
    input       [4:0]                               rd_wm,
    //dbg
    input       logic                               dbg_rx_en,
    output      logic [10:0]                        dbg_rx_pkt_cnt,
    output      logic                               dbg_rx_pkt_equ,
    output      logic [AXIS_DATA_WIDTH-1:0]         dbg_rx_data,

    //axis_if
    input                                           axis_clk,
    input                                           axis_rstn,
    output      [AXIS_DATA_WIDTH-1:0]               tdata,
    output                                          tlast,
    output                                          tvalid,
    input                                           tready,
    //fc
    output      logic                               send_stop_req,
    output      logic                               send_restart_req

    );

typedef enum logic [1:0] {
    RX_W_IDLE,    
    RX_W_DATA1,
    RX_W_DATA2
} lvds_rx_w_st_type;

lvds_rx_w_st_type                               lvds_rx_cur_st;
lvds_rx_w_st_type                               lvds_rx_next_st;
lvds_rx_wf_data_type                            lvds_rx_df_pop_data;
logic                                           lvds_rx_df_almost_empty;
logic                                           lvds_rx_df_almost_full;
logic                                           lvds_rx_df_pop_en;
logic                                           axis_tlast_set;
logic                                           axis_tlast_clr;
logic                                           tvalid_r_clr;
logic                                           tvalid_r_set;
logic                                           tvalid_r;
logic                                           tlast_r;
logic   [AXIS_DATA_WIDTH-1:0]                   tdata_r;
logic                                           lvds_rx_df_empty;
logic                                           idle_to_d1_en;
logic                                           data_to_d2_en;
logic                                           data_sop_in_d1_en;
logic                                           data_eop_in_d1_en;
logic                                           data_sop_in_d2_en;
logic                                           data_to_idle_en;
logic                                           dbg_rx_en_pos;
logic                                           dbg_rx_en_dly;
logic   [10:0]                                  rx_pkt_cnt;
logic                                           dbg_rx_data_lat;
logic   [1:0]                                   dbg_rx_data_lat_w;
logic                                           dbg_rx_pkt_equ_set;
logic                                           dbg_rx_pkt_equ_clr;

//---------rx word fifo
assign send_stop_req                       = lvds_rx_df_almost_full;
assign send_restart_req                    = lvds_rx_df_almost_empty;

lvds_generic_afifo #(
    .FIFO_DATA_WIDTH                    ( 32+2                        ),
    `ifdef DEC_RX_FIFO_DEPTH_EN
        .FIFO_ADDR_WIDTH                    ( 6                           ),
        .FIFO_WM_WIDTH                      ( 4                           )
    `else
        .FIFO_ADDR_WIDTH                    ( 7                           ),
        .FIFO_WM_WIDTH                      ( 5                           )
    `endif

    )u_lvds_rx_data_afifo (
                  // Outputs
    .fifo_full                          (                             ),
    .fifo_almost_full                   ( lvds_rx_df_almost_full      ),
    .pop_data                           ( lvds_rx_df_pop_data         ),
    .fifo_empty                         ( lvds_rx_df_empty            ),
    .fifo_almost_empty                  ( lvds_rx_df_almost_empty     ),
                  // Inputs
    `ifdef DEC_RX_FIFO_DEPTH_EN
        .wr_wm                              ( wr_wm[3:0]                  ),
        .rd_wm                              ( rd_wm[3:0]                  ),
    `else
        .wr_wm                              ( wr_wm[4:0]                  ),
        .rd_wm                              ( rd_wm[4:0]                  ),
    `endif
    .push_clk                           ( wclk                        ),
    .push_rstn                          ( wrstn                       ),
    .push_en                            ( lvds_rx_df_push_en          ),
    .push_data                          ( lvds_rx_df_push_data        ),
    .pop_clk                            ( axis_clk                    ),
    .pop_rstn                           ( axis_rstn                   ),
    .pop_en                             ( lvds_rx_df_pop_en           )
    );

always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        lvds_rx_cur_st                      <= RX_W_IDLE;
    end
    else begin
        lvds_rx_cur_st                      <= lvds_rx_next_st;
    end

assign lvds_rx_df_pop_en                   = idle_to_d1_en | data_to_d2_en | data_to_idle_en | data_sop_in_d1_en | data_eop_in_d1_en | data_sop_in_d2_en;
assign idle_to_d1_en                       = (lvds_rx_cur_st == RX_W_IDLE) & ~lvds_rx_df_empty  & ~(tvalid_r & ~tready);
assign data_to_d2_en                       = (lvds_rx_cur_st == RX_W_DATA1) & ~lvds_rx_df_empty;
assign data_to_idle_en                     = (lvds_rx_cur_st == RX_W_DATA2) & ~lvds_rx_df_empty;
//err scenario
assign data_sop_in_d1_en                   = (lvds_rx_cur_st == RX_W_DATA1) & ~lvds_rx_df_empty & lvds_rx_df_pop_data.sop;
assign data_eop_in_d1_en                   = (lvds_rx_cur_st == RX_W_DATA1) & ~lvds_rx_df_empty & lvds_rx_df_pop_data.eop;
assign data_sop_in_d2_en                   = (lvds_rx_cur_st == RX_W_DATA2) & ~lvds_rx_df_empty & lvds_rx_df_pop_data.sop;

always_comb begin
    lvds_rx_next_st                     = RX_W_IDLE;
    case(lvds_rx_cur_st)
        RX_W_IDLE:
            if(idle_to_d1_en)
                lvds_rx_next_st                     = RX_W_DATA1;
            else 
                lvds_rx_next_st                     = RX_W_IDLE;
        RX_W_DATA1:
            if(data_sop_in_d1_en)
                lvds_rx_next_st                     = RX_W_DATA1;
            else if(data_eop_in_d1_en)
                lvds_rx_next_st                     = RX_W_IDLE;
            else if(data_to_d2_en)
                lvds_rx_next_st                     = RX_W_DATA2;
            else 
                lvds_rx_next_st                     = RX_W_DATA1;
        RX_W_DATA2:
            if(data_sop_in_d2_en)
                lvds_rx_next_st                     = RX_W_DATA1;
            else if(data_to_idle_en)
                lvds_rx_next_st                     = RX_W_IDLE;
            else 
                lvds_rx_next_st                     = RX_W_DATA2;
    endcase
end

//---------axis gen
assign tvalid_r_set                        = (lvds_rx_cur_st == RX_W_DATA2) & ~lvds_rx_df_empty & lvds_rx_df_pop_data.eop & ~dbg_rx_en;
assign tvalid_r_clr                        = tvalid_r & tready;
assign axis_tlast_set                      = (lvds_rx_cur_st == RX_W_DATA2) & ~lvds_rx_df_empty & lvds_rx_df_pop_data.eop & ~dbg_rx_en;
assign axis_tlast_clr                      = tlast_r & tready & tvalid_r;
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        tdata_r                             <= 'h0;
        tlast_r                             <= 'h0;
        tvalid_r                            <= 'h0;
    end
    else begin

        if(tvalid_r_set)
            tvalid_r                            <= 'h1;
        else if(tvalid_r_clr)
            tvalid_r                            <= 'h0;

        if(axis_tlast_set)
            tlast_r                             <= 1'b1;
        else if(axis_tlast_clr)
            tlast_r                             <= 1'b0;

        if(idle_to_d1_en | data_to_d2_en | data_to_idle_en | data_sop_in_d1_en | data_sop_in_d2_en)
            tdata_r                             <= {tdata_r[0+:AXIS_DATA_WIDTH-32],lvds_rx_df_pop_data.data};

    end

assign tdata                               = tdata_r;
assign tlast                               = tlast_r;
assign tvalid                              = tvalid_r;

//dbg
assign dbg_rx_pkt_equ_set                  = dbg_rx_data_lat & (rx_pkt_cnt == 11'd1) & (dbg_rx_data == tdata_r);
assign dbg_rx_pkt_equ_clr                  = dbg_rx_data_lat & (rx_pkt_cnt > 11'd1) & (dbg_rx_data != tdata_r);
assign dbg_rx_data_lat_w[0]                = data_sop_in_d2_en & dbg_rx_en;
assign dbg_rx_data_lat_w[1]                = data_to_idle_en & dbg_rx_en;
assign dbg_rx_en_pos                       = ~dbg_rx_en_dly & dbg_rx_en;
//here cdc err can be ignored
assign dbg_rx_pkt_cnt                      = rx_pkt_cnt;

always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        dbg_rx_en_dly                       <= '0;
        dbg_rx_data_lat                     <= '0;
        rx_pkt_cnt                          <= '0;
        dbg_rx_data                         <= '0;
        dbg_rx_pkt_equ                      <= '0;
    end
    else begin
        dbg_rx_en_dly                       <= dbg_rx_en;
        dbg_rx_data_lat                     <= |dbg_rx_data_lat_w;

        if(dbg_rx_en_pos)
            rx_pkt_cnt                          <= '0;
        else if(dbg_rx_data_lat)
            rx_pkt_cnt                          <= rx_pkt_cnt + 1;

        if(dbg_rx_data_lat)
            dbg_rx_data                         <= tdata_r;

        if(dbg_rx_en_pos)
            dbg_rx_pkt_equ                      <= '0;
        else if(dbg_rx_pkt_equ_set)
            dbg_rx_pkt_equ                      <= 1'b1;
        else if(dbg_rx_pkt_equ_clr)
            dbg_rx_pkt_equ                      <= '0;
    end




endmodule

