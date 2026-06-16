
module lvds_tx_axis_if
import lvds_if_pkg::*;
(
//axis
    input                                           axis_clk,
    input                                           axis_rstn,
    input       [AXIS_DATA_WIDTH-1:0]               tdata,
    input                                           tlast,
    input                                           tvalid,
    output      logic                               tready,
    output      logic                               axis_data_vld,

//dbg
    input       logic                               dbg_tx_start,
    input       logic                               dbg_tx_en,
    input       logic [10:0]                        dbg_tx_num,
    input       logic [31:0]                        dbg_tx_dat,
    output      logic                               dbg_tx_done,

//wf
    input                                           lvds_wf_pop_clk,
    input                                           lvds_wf_pop_rstn,
    input                                           lvds_wf_pop_en,
    output      lvds_tx_wf_data_type                lvds_wf_pop_data,
    output      logic                               lvds_wf_afifo_empty,
    output      logic                               lvds_wf_afifo_full
    );

typedef enum logic [1:0] {
    TX_AXIS_IDLE,
    TX_AXIS_D0,
    TX_AXIS_D1
} lvds_tx_axis_st_type;

lvds_tx_axis_st_type                            axis_tx_cur_st;
lvds_tx_axis_st_type                            axis_tx_next_st;
lvds_tx_wf_data_type                            lvds_wf_push_data;
logic   [31:0]                                  lvds_push_data_mux;
logic                                           st_idle_to_data;
logic                                           st_idle_to_data_dbg;
logic                                           st_d0_to_d1;
logic                                           st_d1_to_idle;
logic   [1:0]                                   axis_data_st;
logic   [1:0][AXIS_DATA_WIDTH-1:0]              tdata_buf;
logic   [AXIS_DATA_WIDTH-1:0]                   tdata_r;
logic                                           tx_asf_push_en_vld;
logic                                           tx_asf_fifo_full;
logic                                           d0_push_en;
logic                                           d0_pop_en;
logic                                           d1_pop_en;
logic   [2:0]                                   tready_clr;
logic                                           dbg_tx_start_syn;
logic                                           dbg_tx_start_syn_dly;
logic                                           dbg_tx_start_pos;
logic                                           dbg_tx_cnt_inc;
logic   [10:0]                                  dbg_tx_cnt;
logic                                           dbg_tx_en_syn;

//--------------axis if
assign d0_push_en                          = (axis_data_st == 2'b01) & tvalid & ~st_d1_to_idle;
assign d0_pop_en                           = (axis_data_st == 2'b01) & ~tvalid & st_d1_to_idle;
assign d1_pop_en                           = (axis_data_st == 2'b10) & st_d1_to_idle;

always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        axis_data_st                        <= 2'b00;
    end
    else begin
        case(axis_data_st)
            2'b00:
                if(tvalid)
                    axis_data_st                        <= 2'b01;
            2'b01:
                if(d0_push_en)
                    axis_data_st                        <= 2'b10;
                else if(d0_pop_en)
                    axis_data_st                        <= 2'b00;
            2'b10:
                if(d1_pop_en)
                    axis_data_st                        <= 2'b01;
            default:
                axis_data_st                        <= 2'b00;
        endcase
    end

assign tready_clr[0]                       = d0_push_en;
assign tready_clr[1]                       = axis_data_st[1] & ~st_d1_to_idle;
assign tready_clr[2]                       = dbg_tx_en_syn;

assign tdata_r                             = dbg_tx_en_syn ? {
    ~dbg_tx_dat,
    {dbg_tx_dat[3:0],dbg_tx_dat[7:4],dbg_tx_dat[11:8],dbg_tx_dat[15:12],dbg_tx_dat[19:16],dbg_tx_dat[23:20],dbg_tx_dat[27:24],dbg_tx_dat[31:28]},
    dbg_tx_dat} :
    axis_data_st[1] ? tdata_buf[1] : tdata_buf[0];
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        axis_data_vld                       <= 1'b0;
        tready                              <= 1'b1;
        tdata_buf                           <= '0;
    end
    else begin
        
        axis_data_vld                       <= axis_data_st[0];

        if(|tready_clr)
            tready                              <= 1'b0;
        else
            tready                              <= 1'b1;

        if(~axis_data_st[1] & tvalid)
            tdata_buf[0]                        <= tdata;

        if(d0_push_en)
            tdata_buf[1]                        <= tdata_buf[0];
    end

//--------------wf
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        axis_tx_cur_st                      <= TX_AXIS_IDLE;
    end
    else begin
        axis_tx_cur_st                      <= axis_tx_next_st;
    end

assign st_idle_to_data                     = (axis_tx_cur_st == TX_AXIS_IDLE) & (axis_data_st != 2'b00) & ~tx_asf_fifo_full;
assign st_idle_to_data_dbg                 = (axis_tx_cur_st == TX_AXIS_IDLE) & dbg_tx_start_syn & dbg_tx_en_syn & (dbg_tx_cnt != dbg_tx_num) & ~tx_asf_fifo_full;
assign st_d0_to_d1                         = (axis_tx_cur_st == TX_AXIS_D0) & ~tx_asf_fifo_full;
assign st_d1_to_idle                       = (axis_tx_cur_st == TX_AXIS_D1) & ~tx_asf_fifo_full;

always_comb begin
    axis_tx_next_st                     = TX_AXIS_IDLE;
    case(axis_tx_cur_st)
        TX_AXIS_IDLE:
            if(st_idle_to_data | st_idle_to_data_dbg)
                axis_tx_next_st                     = TX_AXIS_D0;
            else
                axis_tx_next_st                     = TX_AXIS_IDLE;
        TX_AXIS_D0:
            if(st_d0_to_d1)
                axis_tx_next_st                     = TX_AXIS_D1;
            else
                axis_tx_next_st                     = TX_AXIS_D0;

        TX_AXIS_D1:
            if(st_d1_to_idle)
                axis_tx_next_st                     = TX_AXIS_IDLE;
            else
                axis_tx_next_st                     = TX_AXIS_D1;
    endcase
end

always_comb begin
    lvds_push_data_mux                  = '0;
    case(axis_tx_cur_st)
        TX_AXIS_IDLE:
            lvds_push_data_mux                  = tdata_r[AXIS_DATA_WIDTH-1-(32*0)-:32];
        TX_AXIS_D0:
            lvds_push_data_mux                  = tdata_r[AXIS_DATA_WIDTH-1-(32*1)-:32];
        TX_AXIS_D1:
            lvds_push_data_mux                  = tdata_r[AXIS_DATA_WIDTH-1-(32*2)-:32];
    endcase
end

assign tx_asf_push_en_vld                  = st_idle_to_data | st_d0_to_d1 | st_d1_to_idle | st_idle_to_data_dbg;
assign lvds_wf_push_data.sop               = st_idle_to_data | st_idle_to_data_dbg;
assign lvds_wf_push_data.data              = lvds_push_data_mux;
assign lvds_wf_afifo_full                  = tx_asf_fifo_full;

lvds_generic_afifo #(
    .FIFO_DATA_WIDTH                    ( 32+1                        ),
    .FIFO_ADDR_WIDTH                    ( 3                           ),
    .FIFO_WM_WIDTH                      ( 1                           )

    )
 u_tx_wf(
                   // Outputs
    .fifo_full                          ( tx_asf_fifo_full            ),
    .fifo_almost_full                   (                             ),
    .pop_data                           ( lvds_wf_pop_data            ),
    .fifo_empty                         ( lvds_wf_afifo_empty         ),
    .fifo_almost_empty                  (                             ),
                   // Inputs
    .push_clk                           ( axis_clk                    ),
    .push_rstn                          ( axis_rstn                   ),
    .push_en                            ( tx_asf_push_en_vld          ),
    .push_data                          ( lvds_wf_push_data           ),
    .wr_wm                              ( 1'h1                        ),
    .pop_clk                            ( lvds_wf_pop_clk             ),
    .pop_rstn                           ( lvds_wf_pop_rstn            ),
    .pop_en                             ( lvds_wf_pop_en              ),
    .rd_wm                              ( 1'h1                        )
    );

//dbg logic
macro_sync2r u_syn_dbg_tx_start(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( dbg_tx_start                ),
    .o                                  ( dbg_tx_start_syn            )
    );

macro_sync2r u_syn_dbg_tx_en(  
    .ck                                 ( axis_clk                    ),
    .clb                                ( axis_rstn                   ),
    .d                                  ( dbg_tx_en                   ),
    .o                                  ( dbg_tx_en_syn               )
    );

assign dbg_tx_start_pos                    = ~dbg_tx_start_syn_dly & dbg_tx_start_syn;
assign dbg_tx_cnt_inc                      = st_d1_to_idle & dbg_tx_en_syn;
always_ff @(posedge axis_clk or negedge axis_rstn)
    if(~axis_rstn) begin
        dbg_tx_start_syn_dly                <= '0;
        dbg_tx_cnt                          <= '0;
        dbg_tx_done                         <= '0;
    end
    else begin

        dbg_tx_done                         <= (dbg_tx_cnt == dbg_tx_num);

        dbg_tx_start_syn_dly                <= dbg_tx_start_syn;

        if(dbg_tx_start_pos)
            dbg_tx_cnt                          <= '0;
        else if(dbg_tx_cnt_inc)
            dbg_tx_cnt                          <= dbg_tx_cnt + 1;
        else if(~dbg_tx_en_syn)
            dbg_tx_cnt                          <= '0;

    end

endmodule


