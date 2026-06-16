
module lvds_subsys (
    input       [1:0]                               CORE_ID,       //core_id in X/Y direction from upstream core_unit
    output      [1:0]                               CORE_ID_NEXT,  //core_id in X/Y direction to downstream core_unit
    input                                           apb_pclk,
    //pre level
    output      logic [31:0]                        dout_pre,      //data returned to upstream core_unit
    output      logic                               dout_pre_vld,  //qualifier of data returned to upstream core_unit
    input       logic [32:0]                        din_pre,       //cfg_data from upstream core_unit
    input       logic                               din_pre_vld,   //qualifier of cfg_data from upstream core_unit

    //next level
    input       logic [31:0]                        dout_next,     //data returned from downstream core_unit
    input       logic                               dout_next_vld, //qualifier of data returned from downstream core_unit
    output      logic [32:0]                        din_next,      //cfg_data to downstream core_unit
    output      logic                               din_next_vld,   //qualifier of cfg_data to downstream core_unit

    output                                          lvds_err_intr,
    output      reg                                 o_send_mode,

    input                                           axis_brg_clk,
    input                                           lvds_tx_bclk,
    input                                           scan_mode,
    input                                           rstn_raw,

//tile rx_axis
//  output                                          m0_axis_clk,
    output      [96-1:0]                            m0_axis_tdata,
    output                                          m0_axis_tvalid,
    input                                           m0_axis_tready,
//  output                                          m1_axis_clk,
    output      [96-1:0]                            m1_axis_tdata,
    output                                          m1_axis_tvalid,
    input                                           m1_axis_tready,
//  output                                          m2_axis_clk,
    output      [96-1:0]                            m2_axis_tdata,
    output                                          m2_axis_tvalid,
    input                                           m2_axis_tready,
//  output                                          m3_axis_clk,
    output      [96-1:0]                            m3_axis_tdata,
    output                                          m3_axis_tvalid,
    input                                           m3_axis_tready,

//tile tx_axis
//  input                                           s0_axis_clk,
    input       [96-1:0]                            s0_axis_tdata,
    input                                           s0_axis_tvalid,
    output                                          s0_axis_tready,

//  input                                           s1_axis_clk,
    input       [96-1:0]                            s1_axis_tdata,
    input                                           s1_axis_tvalid,
    output                                          s1_axis_tready,

//  input                                           s2_axis_clk,
    input       [96-1:0]                            s2_axis_tdata,
    input                                           s2_axis_tvalid,
    output                                          s2_axis_tready,

//  input                                           s3_axis_clk,
    input       [96-1:0]                            s3_axis_tdata,
    input                                           s3_axis_tvalid,
    output                                          s3_axis_tready,

//lvds pads
    inout                                           RX0_LVDS_CLK_N,
    inout                                           RX0_LVDS_CLK_P,
    inout                                           RX0_LVDS_DAT0_N,
    inout                                           RX0_LVDS_DAT0_P,
    inout                                           RX0_LVDS_DAT1_N,
    inout                                           RX0_LVDS_DAT1_P,
    inout                                           RX0_LVDS_DAT2_N,
    inout                                           RX0_LVDS_DAT2_P,
    inout                                           RX0_LVDS_DAT3_N,
    inout                                           RX0_LVDS_DAT3_P,
    inout                                           RX0_LVDS_DAT4_N,
    inout                                           RX0_LVDS_DAT4_P,
    inout                                           RX1_LVDS_CLK_N,
    inout                                           RX1_LVDS_CLK_P,
    inout                                           RX1_LVDS_DAT0_N,
    inout                                           RX1_LVDS_DAT0_P,
    inout                                           RX1_LVDS_DAT1_N,
    inout                                           RX1_LVDS_DAT1_P,
    inout                                           RX1_LVDS_DAT2_N,
    inout                                           RX1_LVDS_DAT2_P,
    inout                                           RX1_LVDS_DAT3_N,
    inout                                           RX1_LVDS_DAT3_P,
    inout                                           RX1_LVDS_DAT4_N,
    inout                                           RX1_LVDS_DAT4_P,
    inout                                           RX2_LVDS_CLK_N,
    inout                                           RX2_LVDS_CLK_P,
    inout                                           RX2_LVDS_DAT0_N,
    inout                                           RX2_LVDS_DAT0_P,
    inout                                           RX2_LVDS_DAT1_N,
    inout                                           RX2_LVDS_DAT1_P,
    inout                                           RX2_LVDS_DAT2_N,
    inout                                           RX2_LVDS_DAT2_P,
    inout                                           RX2_LVDS_DAT3_N,
    inout                                           RX2_LVDS_DAT3_P,
    inout                                           RX2_LVDS_DAT4_N,
    inout                                           RX2_LVDS_DAT4_P,
    inout                                           TX0_LVDS_CLK_N,
    inout                                           TX0_LVDS_CLK_P,
    inout                                           TX0_LVDS_DAT0_N,
    inout                                           TX0_LVDS_DAT0_P,
    inout                                           TX0_LVDS_DAT1_N,
    inout                                           TX0_LVDS_DAT1_P,
    inout                                           TX0_LVDS_DAT2_N,
    inout                                           TX0_LVDS_DAT2_P,
    inout                                           TX0_LVDS_DAT3_N,
    inout                                           TX0_LVDS_DAT3_P,
    inout                                           TX0_LVDS_DAT4_N,
    inout                                           TX0_LVDS_DAT4_P,
    inout                                           TX1_LVDS_CLK_N,
    inout                                           TX1_LVDS_CLK_P,
    inout                                           TX1_LVDS_DAT0_N,
    inout                                           TX1_LVDS_DAT0_P,
    inout                                           TX1_LVDS_DAT1_N,
    inout                                           TX1_LVDS_DAT1_P,
    inout                                           TX1_LVDS_DAT2_N,
    inout                                           TX1_LVDS_DAT2_P,
    inout                                           TX1_LVDS_DAT3_N,
    inout                                           TX1_LVDS_DAT3_P,
    inout                                           TX1_LVDS_DAT4_N,
    inout                                           TX1_LVDS_DAT4_P,
    inout                                           TX2_LVDS_CLK_N,
    inout                                           TX2_LVDS_CLK_P,
    inout                                           TX2_LVDS_DAT0_N,
    inout                                           TX2_LVDS_DAT0_P,
    inout                                           TX2_LVDS_DAT1_N,
    inout                                           TX2_LVDS_DAT1_P,
    inout                                           TX2_LVDS_DAT2_N,
    inout                                           TX2_LVDS_DAT2_P,
    inout                                           TX2_LVDS_DAT3_N,
    inout                                           TX2_LVDS_DAT3_P,
    inout                                           TX2_LVDS_DAT4_N,
    inout       TX2_LVDS_DAT4_P
    );

logic                                           apb_psel;
logic                                           apb_penable;
logic                                           apb_pwrite;
logic   [25-1:0]                                apb_paddr;
logic   [31:0]                                  apb_pwdata;
logic                                           apb_pready;
logic   [31:0]                                  apb_prdata;

logic                                           m3_axis_tlast;
logic                                           m2_axis_tlast;
logic                                           m1_axis_tlast;
logic                                           m0_axis_tlast;
logic                                           s3_axis_tlast;
logic                                           s2_axis_tlast;
logic                                           s1_axis_tlast;
logic                                           s0_axis_tlast;
logic   [4*96-1:0]                              s_axis_tdata;
logic   [3:0]                                   s_axis_tlast;
logic   [3:0]                                   s_axis_tvalid;
logic   [3:0]                                   s_axis_tready;

logic   [95:0]                                  rx0_axis_tdata;
logic                                           rx0_axis_tlast;
logic                                           rx0_axis_tready;
logic                                           rx0_axis_tvalid;
logic   [95:0]                                  rx1_axis_tdata;
logic                                           rx1_axis_tlast;
logic                                           rx1_axis_tready;
logic                                           rx1_axis_tvalid;
logic   [95:0]                                  rx2_axis_tdata;
logic                                           rx2_axis_tlast;
logic                                           rx2_axis_tready;
logic                                           rx2_axis_tvalid;
logic   [95:0]                                  rx3_axis_tdata;
logic                                           rx3_axis_tlast;
logic                                           rx3_axis_tready;
logic                                           rx3_axis_tvalid;

logic   [95:0]                                  tx0_axis_tdata;
logic                                           tx0_axis_tlast;
logic                                           tx0_axis_tready;
logic                                           tx0_axis_tvalid;
logic   [95:0]                                  tx1_axis_tdata;
logic                                           tx1_axis_tlast;
logic                                           tx1_axis_tready;
logic                                           tx1_axis_tvalid;
logic   [95:0]                                  tx2_axis_tdata;
logic                                           tx2_axis_tlast;
logic                                           tx2_axis_tready;
logic                                           tx2_axis_tvalid;

logic                                           apb_presetn;
logic   [3:0]                                   s_rstn_syn;

logic   [32*4-1:0]                              cfg_rx3_delay_chain_ctrl;
logic   [32*4-1:0]                              cfg_rx2_delay_chain_ctrl;
logic   [32*4-1:0]                              cfg_rx1_delay_chain_ctrl;
logic   [32*4-1:0]                              cfg_rx0_delay_chain_ctrl;
logic                                           rx_enable;

logic                                           axis_tx_brg_rstn;
logic                                           axis_tx_brg_clk;
logic                                           lvds_tx0_bclk;
logic                                           lvds_tx1_bclk;
logic                                           lvds_tx2_bclk;
//logic                                           lvds_tx3_bclk;
logic                                           axis_rx0_brg_clk;
logic                                           axis_rx1_brg_clk;
logic                                           axis_rx2_brg_clk;
//logic                                           axis_rx3_brg_clk;

logic                                           m_axis_rstn;
logic                                           axis_rx0_brg_rstn;
logic                                           axis_rx1_brg_rstn;
logic                                           axis_rx2_brg_rstn;
//logic                                           axis_rx3_brg_rstn;

logic   [4*96-1:0]                              m_axis_tdata;
logic   [3:0]                                   m_axis_tlast;
logic   [3:0]                                   m_axis_tvalid;
logic   [3:0]                                   m_axis_tready;
logic                                           m_axis_clk;

logic                                           cfg_lvds0_man_read_req;
logic                                           cfg_lvds0_man_read_ack;
logic   [59:0]                                  cfg_lvds0_man_read_data;
logic                                           cfg_lvds0_cal_up_req;
logic   [7:0]                                   cfg_lvds0_cal_up_val;
logic   [4:0]                                   cfg_lvds0_cal_lane_num;
logic                                           cfg_lvds0_cal_up_ack;

logic                                           cfg_lvds1_man_read_req;
logic                                           cfg_lvds1_man_read_ack;
logic   [59:0]                                  cfg_lvds1_man_read_data;
logic                                           cfg_lvds1_cal_up_req;
logic   [7:0]                                   cfg_lvds1_cal_up_val;
logic   [4:0]                                   cfg_lvds1_cal_lane_num;
logic                                           cfg_lvds1_cal_up_ack;

logic                                           cfg_lvds2_man_read_req;
logic                                           cfg_lvds2_man_read_ack;
logic   [59:0]                                  cfg_lvds2_man_read_data;
logic                                           cfg_lvds2_rx_auto_cal_start;
logic                                           cfg_lvds2_tx_auto_cal_start;
logic                                           cfg_lvds2_cal_up_req;
logic   [7:0]                                   cfg_lvds2_cal_up_val;
logic   [4:0]                                   cfg_lvds2_cal_lane_num;
logic                                           cfg_lvds2_cal_up_ack;

logic                                           cfg_lvds3_man_read_req;
logic                                           cfg_lvds3_man_read_ack;
logic   [59:0]                                  cfg_lvds3_man_read_data;
logic                                           cfg_lvds3_rx_auto_cal_start;
logic                                           cfg_lvds3_tx_auto_cal_start;
logic                                           cfg_lvds3_cal_up_req;
logic   [7:0]                                   cfg_lvds3_cal_up_val;
logic   [4:0]                                   cfg_lvds3_cal_lane_num;
logic                                           cfg_lvds3_cal_up_ack;

logic                                           rx0_axis_rstn;
logic                                           rx1_axis_rstn;
logic                                           rx2_axis_rstn;
logic                                           rx3_axis_rstn;
//logic   [1:0]                                   rx_select3;
logic   [1:0]                                   rx_select2;
logic   [1:0]                                   rx_select1;
logic   [1:0]                                   rx_select0;
logic   [15:0]                                  cfg_lvds0_calib_extra_dly;
logic   [15:0]                                  cfg_lvds1_calib_extra_dly;
logic   [15:0]                                  cfg_lvds2_calib_extra_dly;
logic   [15:0]                                  cfg_lvds3_calib_extra_dly;
logic   [2:0]                                   lvds0_rx_err_syn;
logic   [2:0]                                   lvds1_rx_err_syn;
logic   [2:0]                                   lvds2_rx_err_syn;
logic   [2:0]                                   lvds3_rx_err_syn;
logic   [2:0]                                   lvds0_rx_err_o;
logic   [2:0]                                   lvds0_rx_err_ack;
logic   [2:0]                                   lvds1_rx_err_o;
logic   [2:0]                                   lvds1_rx_err_ack;
logic   [2:0]                                   lvds2_rx_err_o;
logic   [2:0]                                   lvds2_rx_err_ack;
logic   [2:0]                                   lvds3_rx_err_o;
logic   [2:0]                                   lvds3_rx_err_ack;
logic                                           cfg_rx0_ecc_correct;
logic                                           cfg_rx1_ecc_correct;
logic                                           cfg_rx2_ecc_correct;
logic                                           cfg_rx3_ecc_correct;
logic                                           cfg_ctrl_dis_parallel_rx;
logic                                           cfg_ctrl_dis_parallel_tx;
logic                                           cfg_err_mask_rx0_dec_err_mask;
logic                                           cfg_err_mask_rx0_pkt_c_err_mask;
logic                                           cfg_err_mask_rx0_pkt_nc_err_mask;
logic                                           cfg_err_mask_rx1_dec_err_mask;
logic                                           cfg_err_mask_rx1_pkt_c_err_mask;
logic                                           cfg_err_mask_rx1_pkt_nc_err_mask;
logic                                           cfg_err_mask_rx2_dec_err_mask;
logic                                           cfg_err_mask_rx2_pkt_c_err_mask;
logic                                           cfg_err_mask_rx2_pkt_nc_err_mask;
logic                                           cfg_err_mask_rx3_dec_err_mask;
logic                                           cfg_err_mask_rx3_pkt_c_err_mask;
logic                                           cfg_err_mask_rx3_pkt_nc_err_mask;
logic                                           err_st_rx0_dec_err;
logic                                           err_st_rx0_pkt_c_err;
logic                                           err_st_rx0_pkt_nc_err;
logic                                           err_st_rx1_dec_err;
logic                                           err_st_rx1_pkt_c_err;
logic                                           err_st_rx1_pkt_nc_err;
logic                                           err_st_rx2_dec_err;
logic                                           err_st_rx2_pkt_c_err;
logic                                           err_st_rx2_pkt_nc_err;
logic                                           err_st_rx3_dec_err;
logic                                           err_st_rx3_pkt_c_err;
logic                                           err_st_rx3_pkt_nc_err;
logic   [9:0]                                   cfg_lvds0_cal_mode_pat_val;
logic                                           cfg_lvds0_calib_auto_calib_en;
logic                                           cfg_lvds0_calib_rx_bit_clk_inv_sel;
logic                                           cfg_lvds0_calib_rx_cal_mode_en;
logic   [7:0]                                   cfg_lvds0_calib_start_calib_dly;
logic                                           cfg_lvds0_calib_tx_cal_mode_en;
logic                                           cfg_lvds0_ctrl_rx_ecc_correct;
logic                                           cfg_lvds0_ctrl_rx_lvds_ctrl_en;
logic   [4:0]                                   cfg_lvds0_ctrl_rx_lvds_data_rd_wm;
logic   [4:0]                                   cfg_lvds0_ctrl_rx_lvds_data_wr_wm;
logic                                           cfg_lvds0_ctrl_rx_rstn;
logic                                           cfg_lvds0_ctrl_tx_auto_sleep_en;
logic                                           cfg_lvds0_ctrl_tx_lvds_ctrl_en;
logic                                           cfg_lvds0_ctrl_tx_rstn;
logic                                           cfg_lvds0_pad_ctrl_rx_lvds_pad_bias_en;
logic                                           cfg_lvds0_pad_ctrl_rx_lvds_pad_inv_cp;
logic                                           cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_en;
logic   [2:0]                                   cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_val;
logic                                           cfg_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en;
logic                                           cfg_lvds0_pad_ctrl_tx_lvds_pad_bias_en;
logic                                           cfg_lvds0_pad_ctrl_tx_lvds_pad_inv_cp;
logic                                           cfg_lvds0_pad_ctrl_tx_lvds_pad_tx_cm;
logic   [3:0]                                   cfg_lvds0_pad_ctrl_tx_lvds_pad_txdrv;
logic   [9:0]                                   cfg_lvds1_cal_mode_pat_val;
logic                                           cfg_lvds1_calib_auto_calib_en;
logic                                           cfg_lvds1_calib_rx_bit_clk_inv_sel;
logic                                           cfg_lvds1_calib_rx_cal_mode_en;
logic   [7:0]                                   cfg_lvds1_calib_start_calib_dly;
logic                                           cfg_lvds1_calib_tx_cal_mode_en;
logic                                           cfg_lvds1_ctrl_rx_ecc_correct;
logic                                           cfg_lvds1_ctrl_rx_lvds_ctrl_en;
logic   [4:0]                                   cfg_lvds1_ctrl_rx_lvds_data_rd_wm;
logic   [4:0]                                   cfg_lvds1_ctrl_rx_lvds_data_wr_wm;
logic                                           cfg_lvds1_ctrl_rx_rstn;
logic                                           cfg_lvds1_ctrl_tx_auto_sleep_en;
logic                                           cfg_lvds1_ctrl_tx_lvds_ctrl_en;
logic                                           cfg_lvds1_ctrl_tx_rstn;
logic                                           cfg_lvds1_pad_ctrl_rx_lvds_pad_bias_en;
logic                                           cfg_lvds1_pad_ctrl_rx_lvds_pad_inv_cp;
logic                                           cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_en;
logic   [2:0]                                   cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_val;
logic                                           cfg_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en;
logic                                           cfg_lvds1_pad_ctrl_tx_lvds_pad_bias_en;
logic                                           cfg_lvds1_pad_ctrl_tx_lvds_pad_inv_cp;
logic                                           cfg_lvds1_pad_ctrl_tx_lvds_pad_tx_cm;
logic   [3:0]                                   cfg_lvds1_pad_ctrl_tx_lvds_pad_txdrv;
logic   [9:0]                                   cfg_lvds2_cal_mode_pat_val;
logic                                           cfg_lvds2_calib_auto_calib_en;
logic                                           cfg_lvds2_calib_rx_bit_clk_inv_sel;
logic                                           cfg_lvds2_calib_rx_cal_mode_en;
logic   [7:0]                                   cfg_lvds2_calib_start_calib_dly;
logic                                           cfg_lvds2_calib_tx_cal_mode_en;
logic                                           cfg_lvds2_ctrl_rx_ecc_correct;
logic                                           cfg_lvds2_ctrl_rx_lvds_ctrl_en;
logic   [4:0]                                   cfg_lvds2_ctrl_rx_lvds_data_rd_wm;
logic   [4:0]                                   cfg_lvds2_ctrl_rx_lvds_data_wr_wm;
logic                                           cfg_lvds2_ctrl_rx_rstn;
logic                                           cfg_lvds2_ctrl_tx_auto_sleep_en;
logic                                           cfg_lvds2_ctrl_tx_lvds_ctrl_en;
logic                                           cfg_lvds2_ctrl_tx_rstn;
logic                                           cfg_lvds2_pad_ctrl_rx_lvds_pad_bias_en;
logic                                           cfg_lvds2_pad_ctrl_rx_lvds_pad_inv_cp;
logic                                           cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_en;
logic   [2:0]                                   cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_val;
logic                                           cfg_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en;
logic                                           cfg_lvds2_pad_ctrl_tx_lvds_pad_bias_en;
logic                                           cfg_lvds2_pad_ctrl_tx_lvds_pad_inv_cp;
logic                                           cfg_lvds2_pad_ctrl_tx_lvds_pad_tx_cm;
logic   [3:0]                                   cfg_lvds2_pad_ctrl_tx_lvds_pad_txdrv;
logic   [9:0]                                   cfg_lvds3_cal_mode_pat_val;
logic                                           cfg_lvds3_calib_auto_calib_en;
logic                                           cfg_lvds3_calib_rx_bit_clk_inv_sel;
logic                                           cfg_lvds3_calib_rx_cal_mode_en;
logic   [7:0]                                   cfg_lvds3_calib_start_calib_dly;
logic                                           cfg_lvds3_calib_tx_cal_mode_en;
logic                                           cfg_lvds3_ctrl_rx_ecc_correct;
logic                                           cfg_lvds3_ctrl_rx_lvds_ctrl_en;
logic   [4:0]                                   cfg_lvds3_ctrl_rx_lvds_data_rd_wm;
logic   [4:0]                                   cfg_lvds3_ctrl_rx_lvds_data_wr_wm;
logic                                           cfg_lvds3_ctrl_rx_rstn;
logic                                           cfg_lvds3_ctrl_tx_auto_sleep_en;
logic                                           cfg_lvds3_ctrl_tx_lvds_ctrl_en;
logic                                           cfg_lvds3_ctrl_tx_rstn;
logic                                           cfg_lvds3_pad_ctrl_rx_lvds_pad_bias_en;
logic                                           cfg_lvds3_pad_ctrl_rx_lvds_pad_inv_cp;
logic                                           cfg_lvds3_pad_ctrl_rx_lvds_pad_rterm_en;
logic   [2:0]                                   cfg_lvds3_pad_ctrl_rx_lvds_pad_rterm_val;
logic                                           cfg_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en;
logic                                           cfg_lvds3_pad_ctrl_tx_lvds_pad_bias_en;
logic                                           cfg_lvds3_pad_ctrl_tx_lvds_pad_inv_cp;
logic                                           cfg_lvds3_pad_ctrl_tx_lvds_pad_tx_cm;
logic   [3:0]                                   cfg_lvds3_pad_ctrl_tx_lvds_pad_txdrv;
logic   [31:0]                                  cfg_rx0_delay_chain_ctrl0_val;
logic   [31:0]                                  cfg_rx0_delay_chain_ctrl1_val;
logic   [31:0]                                  cfg_rx0_delay_chain_ctrl2_val;
logic   [31:0]                                  cfg_rx0_delay_chain_ctrl3_val;
logic   [31:0]                                  cfg_rx1_delay_chain_ctrl0_val;
logic   [31:0]                                  cfg_rx1_delay_chain_ctrl1_val;
logic   [31:0]                                  cfg_rx1_delay_chain_ctrl2_val;
logic   [31:0]                                  cfg_rx1_delay_chain_ctrl3_val;
logic   [31:0]                                  cfg_rx2_delay_chain_ctrl0_val;
logic   [31:0]                                  cfg_rx2_delay_chain_ctrl1_val;
logic   [31:0]                                  cfg_rx2_delay_chain_ctrl2_val;
logic   [31:0]                                  cfg_rx2_delay_chain_ctrl3_val;
logic   [31:0]                                  cfg_rx3_delay_chain_ctrl0_val;
logic   [31:0]                                  cfg_rx3_delay_chain_ctrl1_val;
logic   [31:0]                                  cfg_rx3_delay_chain_ctrl2_val;
logic   [31:0]                                  cfg_rx3_delay_chain_ctrl3_val;

//dbg
logic   [95:0]                                  dbg0_rx_data;
logic   [95:0]                                  dbg1_rx_data;
logic   [95:0]                                  dbg2_rx_data;
logic   [95:0]                                  dbg3_rx_data;
logic   [ 11-1:0]                               dbg0_rx_ctrl_rx_pkt_cnt;
logic                                           dbg0_rx_ctrl_rx_pkt_equ;
logic                                           dbg0_tx_ctrl_tx_done;
logic   [ 11-1:0]                               dbg1_rx_ctrl_rx_pkt_cnt;
logic                                           dbg1_rx_ctrl_rx_pkt_equ;
logic                                           dbg1_tx_ctrl_tx_done;
logic   [ 11-1:0]                               dbg2_rx_ctrl_rx_pkt_cnt;
logic                                           dbg2_rx_ctrl_rx_pkt_equ;
logic                                           dbg2_tx_ctrl_tx_done;
logic   [ 11-1:0]                               dbg3_rx_ctrl_rx_pkt_cnt;
logic                                           dbg3_rx_ctrl_rx_pkt_equ;
logic                                           dbg3_tx_ctrl_tx_done;
logic                                           dbg0_rx_ctrl_rx_en;
logic                                           dbg0_tx_ctrl_ser_en;
logic                                           dbg0_tx_ctrl_der_en;
logic                                           dbg0_tx_ctrl_tx_start;
logic                                           dbg0_tx_ctrl_tx_en;
logic   [ 11-1:0]                               dbg0_tx_ctrl_tx_num;
logic   [ 32-1:0]                               dbg0_tx_data;
logic                                           dbg1_rx_ctrl_rx_en;
logic                                           dbg1_tx_ctrl_ser_en;
logic                                           dbg1_tx_ctrl_der_en;
logic                                           dbg1_tx_ctrl_tx_start;
logic                                           dbg1_tx_ctrl_tx_en;
logic   [ 11-1:0]                               dbg1_tx_ctrl_tx_num;
logic   [ 32-1:0]                               dbg1_tx_data;
logic                                           dbg2_rx_ctrl_rx_en;
logic                                           dbg2_tx_ctrl_ser_en;
logic                                           dbg2_tx_ctrl_der_en;
logic                                           dbg2_tx_ctrl_tx_start;
logic                                           dbg2_tx_ctrl_tx_en;
logic   [ 11-1:0]                               dbg2_tx_ctrl_tx_num;
logic   [ 32-1:0]                               dbg2_tx_data;
logic                                           dbg3_rx_ctrl_rx_en;
logic                                           dbg3_tx_ctrl_ser_en;
logic                                           dbg3_tx_ctrl_der_en;
logic                                           dbg3_tx_ctrl_tx_start;
logic                                           dbg3_tx_ctrl_tx_en;
logic   [ 11-1:0]                               dbg3_tx_ctrl_tx_num;
logic   [ 32-1:0]                               dbg3_tx_data;
logic                                           s0_axis_clk;
logic                                           s1_axis_clk;
logic                                           s2_axis_clk;
logic                                           s3_axis_clk;
logic                                           dbg0_cfg_prbs_tx_en;
logic                                           dbg0_prbs_done;
logic                                           dbg0_prbs_pass;
logic                                           dbg1_cfg_prbs_tx_en;
logic                                           dbg1_prbs_done;
logic                                           dbg1_prbs_pass;
logic                                           dbg2_cfg_prbs_tx_en;
logic                                           dbg2_prbs_done;
logic                                           dbg2_prbs_pass;


assign s0_axis_clk                         = axis_brg_clk;
assign s1_axis_clk                         = axis_brg_clk;
assign s2_axis_clk                         = axis_brg_clk;
assign s3_axis_clk                         = axis_brg_clk;

//assign rx_select3                          = cfg_ctrl_dis_parallel_rx ? 2'b11 : rx3_axis_tdata[4+:2];
assign rx_select2                          = rx2_axis_tdata[4+:2];
assign rx_select1                          = cfg_ctrl_dis_parallel_rx ? 2'b01 : rx1_axis_tdata[4+:2];
assign rx_select0                          = cfg_ctrl_dis_parallel_rx ? 2'b00 : rx0_axis_tdata[4+:2];

assign {m3_axis_tdata ,m2_axis_tdata ,m1_axis_tdata ,m0_axis_tdata }= m_axis_tdata;
assign {m3_axis_tlast ,m2_axis_tlast ,m1_axis_tlast ,m0_axis_tlast }= m_axis_tlast;
assign {m3_axis_tvalid,m2_axis_tvalid,m1_axis_tvalid,m0_axis_tvalid}= m_axis_tvalid;
assign m_axis_tready                       = {m3_axis_tready,m2_axis_tready,m1_axis_tready,m0_axis_tready};
//assign m0_axis_clk                         = m_axis_clk;
//assign m1_axis_clk                         = m_axis_clk;
//assign m2_axis_clk                         = m_axis_clk;
//assign m3_axis_clk                         = m_axis_clk;

macro_buf u_axis_tx_brg_clk_buf  (.a(axis_brg_clk), .o(axis_tx_brg_clk));
macro_buf u_m_axis_clk_buf       (.a(axis_brg_clk), .o(m_axis_clk));
macro_buf u_lvds_tx0_bclk_buf    (.a(lvds_tx_bclk), .o(lvds_tx0_bclk));
macro_buf u_lvds_tx1_bclk_buf    (.a(lvds_tx_bclk), .o(lvds_tx1_bclk));
macro_buf u_lvds_tx2_bclk_buf    (.a(lvds_tx_bclk), .o(lvds_tx2_bclk));
//macro_buf u_lvds_tx3_bclk_buf    (.a(lvds_tx_bclk), .o(lvds_tx3_bclk));

macro_buf u_axis_rx0_brg_clk_buf (.a(axis_brg_clk), .o(axis_rx0_brg_clk));
macro_buf u_axis_rx1_brg_clk_buf (.a(axis_brg_clk), .o(axis_rx1_brg_clk));
macro_buf u_axis_rx2_brg_clk_buf (.a(axis_brg_clk), .o(axis_rx2_brg_clk));
//macro_buf u_axis_rx3_brg_clk_buf (.a(axis_brg_clk), .o(axis_rx3_brg_clk));

macro_reset_sync2 u_axis_rx_brg_rstn_syn[2:0](  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( {
                                            axis_rx2_brg_clk,axis_rx1_brg_clk,axis_rx0_brg_clk}),
    .reset_sync_n                       ( {
                                            axis_rx2_brg_rstn,axis_rx1_brg_rstn,axis_rx0_brg_rstn})
    );

macro_reset_sync2 u_axis_tx_brg_rstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( axis_tx_brg_clk             ),
    .reset_sync_n                       ( axis_tx_brg_rstn            )
    );

macro_reset_sync2 u_m_axis_rstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( m_axis_clk                  ),
    .reset_sync_n                       ( m_axis_rstn                 )
    );

macro_reset_sync2 u_s_rstn_syn[3:0](  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( {s2_axis_clk,s2_axis_clk,s1_axis_clk,s0_axis_clk}),
    .reset_sync_n                       ( s_rstn_syn[3:0]             )
    );


macro_reset_sync2 u_apb_rstn_syn(  
    .test_en                            ( scan_mode                   ),
    .reset_n                            ( rstn_raw                    ), 
    .ck                                 ( apb_pclk                    ),
    .reset_sync_n                       ( apb_presetn                 )
    );

assign s_axis_tdata                        = {
                        s3_axis_tdata,
                        s2_axis_tdata,
                        s1_axis_tdata,
                        s0_axis_tdata
                      };


macro_sync2r u_lvds_rx_err_syn[4*3-1:0](  
    .ck                                 ( apb_pclk                    ),
    .clb                                ( apb_presetn                 ),
    .d                                  ( {lvds3_rx_err_o,lvds2_rx_err_o,lvds1_rx_err_o,lvds0_rx_err_o}),
    .o                                  ( {lvds3_rx_err_syn,lvds2_rx_err_syn,lvds1_rx_err_syn,lvds0_rx_err_syn})
    );

assign {err_st_rx0_dec_err,err_st_rx0_pkt_c_err,err_st_rx0_pkt_nc_err}= lvds0_rx_err_syn;
assign {err_st_rx1_dec_err,err_st_rx1_pkt_c_err,err_st_rx1_pkt_nc_err}= lvds1_rx_err_syn;
assign {err_st_rx2_dec_err,err_st_rx2_pkt_c_err,err_st_rx2_pkt_nc_err}= lvds2_rx_err_syn;
assign {err_st_rx3_dec_err,err_st_rx3_pkt_c_err,err_st_rx3_pkt_nc_err}= lvds3_rx_err_syn;
assign lvds0_rx_err_ack                    = lvds0_rx_err_syn;
assign lvds1_rx_err_ack                    = lvds1_rx_err_syn;
assign lvds2_rx_err_ack                    = lvds2_rx_err_syn;
assign lvds3_rx_err_ack                    = lvds3_rx_err_syn;

//assign s_axis_tlast                        = {s3_axis_tlast,s2_axis_tlast,s1_axis_tlast,s0_axis_tlast};
assign s_axis_tlast                        = {s3_axis_tvalid,s2_axis_tvalid,s1_axis_tvalid,s0_axis_tvalid};
assign s_axis_tvalid                       = {s3_axis_tvalid,s2_axis_tvalid,s1_axis_tvalid,s0_axis_tvalid};
assign {s3_axis_tready,s2_axis_tready,s1_axis_tready, s0_axis_tready}= s_axis_tready;
assign rx_enable                           = 1'b1;

assign cfg_rx0_delay_chain_ctrl            = {
                                    cfg_rx0_delay_chain_ctrl3_val,
                                    cfg_rx0_delay_chain_ctrl2_val,
                                    cfg_rx0_delay_chain_ctrl1_val,
                                    cfg_rx0_delay_chain_ctrl0_val};

assign cfg_rx1_delay_chain_ctrl            = {
                                    cfg_rx1_delay_chain_ctrl3_val,
                                    cfg_rx1_delay_chain_ctrl2_val,
                                    cfg_rx1_delay_chain_ctrl1_val,
                                    cfg_rx1_delay_chain_ctrl0_val};

assign cfg_rx2_delay_chain_ctrl            = {
                                    cfg_rx2_delay_chain_ctrl3_val,
                                    cfg_rx2_delay_chain_ctrl2_val,
                                    cfg_rx2_delay_chain_ctrl1_val,
                                    cfg_rx2_delay_chain_ctrl0_val};

assign cfg_rx3_delay_chain_ctrl            = {
                                    cfg_rx3_delay_chain_ctrl3_val,
                                    cfg_rx3_delay_chain_ctrl2_val,
                                    cfg_rx3_delay_chain_ctrl1_val,
                                    cfg_rx3_delay_chain_ctrl0_val};


axis_mimo_tx u_axis_mimo_tx (
           // Outputs
    .s_axis_tready                      ( s_axis_tready[3:0]          ),
    .m_axis_tdata                       ({tx2_axis_tdata,
                                         tx1_axis_tdata,tx0_axis_tdata}),
    .m_axis_tkeep                       (                             ),
    .m_axis_tvalid                      ({tx2_axis_tvalid,
                                          tx1_axis_tvalid,tx0_axis_tvalid}),
    .m_axis_tlast                       ({tx2_axis_tlast,
                                          tx1_axis_tlast,tx0_axis_tlast}),
    .m_axis_tid                         (                             ),
    .m_axis_tdest                       (                             ),
    .m_axis_tuser                       (                             ),
    .select                             (                             ),
           // Inputs
    .cfg_dis_parallel_tx                ( cfg_ctrl_dis_parallel_tx    ),
    .clk                                ( axis_tx_brg_clk             ),
    .rst_n                              ( axis_tx_brg_rstn            ),
    .s_clk                              ( {s3_axis_clk,s2_axis_clk,s1_axis_clk,s0_axis_clk}),
    .s_rst_n                            ( s_rstn_syn[3:0]             ),
    .s_axis_tdata                       ( s_axis_tdata[4*96-1:0]      ),
    .s_axis_tkeep                       ( '0                          ),
    .s_axis_tvalid                      ( s_axis_tvalid[3:0]          ),
    .s_axis_tlast                       ( s_axis_tlast[3:0]           ),
    .s_axis_tid                         ( '0                          ),
    .s_axis_tdest                       ( '0                          ),
    .s_axis_tuser                       ( '0                          ),
    .m_axis_tready                      ({tx2_axis_tready,
                                          tx1_axis_tready,tx0_axis_tready})
    );

axis_mimo_rx u_axis_mimo_rx(
          // Outputs
    .s_axis_tready                      ({rx2_axis_tready,
                                          rx1_axis_tready,rx0_axis_tready}),
    .m_axis_tdata                       ( m_axis_tdata[4*96-1:0]      ),
    .m_axis_tvalid                      ( m_axis_tvalid[3:0]          ),
    .m_axis_tlast                       ( m_axis_tlast[3:0]           ),
    .m_axis_tkeep                       (                             ),
    .m_axis_tid                         (                             ),
    .m_axis_tdest                       (                             ),
    .m_axis_tuser                       (                             ),
          // Inputs
    .clk                                ( m_axis_clk                  ),
    .rst_n                              ( m_axis_rstn                 ),
    .s_clk                              ({axis_rx2_brg_clk,
                                          axis_rx1_brg_clk,axis_rx0_brg_clk}),
    .s_rst_n                            ({axis_rx2_brg_rstn,
                                          axis_rx1_brg_rstn,axis_rx0_brg_rstn}),

    .s_axis_tdata                       ({rx2_axis_tdata,
                                          rx1_axis_tdata,rx0_axis_tdata}),
    .s_axis_tvalid                      ({rx2_axis_tvalid,
                                          rx1_axis_tvalid,rx0_axis_tvalid}),
    .s_axis_tlast                       ({rx2_axis_tlast,
                                          rx1_axis_tlast,rx0_axis_tlast}),
    .s_axis_tkeep                       ( '0                          ),
    .s_axis_tid                         ( '0                          ),
    .s_axis_tdest                       ( '0                          ),
    .s_axis_tuser                       ( '0                          ),
    .m_axis_tready                      ( m_axis_tready[3:0]          ),
    .enable                             ( rx_enable                   ),
    .select                             ({rx_select2,
                                        rx_select1,rx_select0})
    );

lvds_tx_rx_wrap u_lvds0_tx_rx_wrap(
                   // Inouts
    .TX_LVDS_CLK_N                      ( TX0_LVDS_CLK_N              ),
    .TX_LVDS_CLK_P                      ( TX0_LVDS_CLK_P              ),
    .TX_LVDS_DAT0_N                     ( TX0_LVDS_DAT0_N             ),
    .TX_LVDS_DAT0_P                     ( TX0_LVDS_DAT0_P             ),
    .TX_LVDS_DAT1_N                     ( TX0_LVDS_DAT1_N             ),
    .TX_LVDS_DAT1_P                     ( TX0_LVDS_DAT1_P             ),
    .TX_LVDS_DAT2_N                     ( TX0_LVDS_DAT2_N             ),
    .TX_LVDS_DAT2_P                     ( TX0_LVDS_DAT2_P             ),
    .TX_LVDS_DAT3_N                     ( TX0_LVDS_DAT3_N             ),
    .TX_LVDS_DAT3_P                     ( TX0_LVDS_DAT3_P             ),
    .TX_LVDS_DAT4_N                     ( TX0_LVDS_DAT4_N             ),
    .TX_LVDS_DAT4_P                     ( TX0_LVDS_DAT4_P             ),
    .RX_LVDS_CLK_N                      ( RX0_LVDS_CLK_N              ),
    .RX_LVDS_CLK_P                      ( RX0_LVDS_CLK_P              ),
    .RX_LVDS_DAT0_N                     ( RX0_LVDS_DAT0_N             ),
    .RX_LVDS_DAT0_P                     ( RX0_LVDS_DAT0_P             ),
    .RX_LVDS_DAT1_N                     ( RX0_LVDS_DAT1_N             ),
    .RX_LVDS_DAT1_P                     ( RX0_LVDS_DAT1_P             ),
    .RX_LVDS_DAT2_N                     ( RX0_LVDS_DAT2_N             ),
    .RX_LVDS_DAT2_P                     ( RX0_LVDS_DAT2_P             ),
    .RX_LVDS_DAT3_N                     ( RX0_LVDS_DAT3_N             ),
    .RX_LVDS_DAT3_P                     ( RX0_LVDS_DAT3_P             ),
    .RX_LVDS_DAT4_N                     ( RX0_LVDS_DAT4_N             ),
    .RX_LVDS_DAT4_P                     ( RX0_LVDS_DAT4_P             ),

    //dbg
    .cfg_prbs_tx_en                     ( dbg0_cfg_prbs_tx_en         ),
    .prbs_done                          ( dbg0_prbs_done              ),
    .prbs_pass                          ( dbg0_prbs_pass              ),
    .cfg_dbg_rx_en                      ( dbg0_rx_ctrl_rx_en          ),
    .cfg_dbg_rx_pkt_cnt                 ( dbg0_rx_ctrl_rx_pkt_cnt     ),
    .cfg_dbg_rx_pkt_equ                 ( dbg0_rx_ctrl_rx_pkt_equ     ),
    .cfg_dbg_rx_data                    ( dbg0_rx_data                ),
    .cfg_dbg_tx_start                   ( dbg0_tx_ctrl_tx_start       ),
    .cfg_dbg_tx_en                      ( dbg0_tx_ctrl_tx_en          ),
    .cfg_dbg_tx_num                     ( dbg0_tx_ctrl_tx_num         ),
    .cfg_dbg_tx_dat                     ( dbg0_tx_data                ),
    .cfg_dbg_tx_done                    ( dbg0_tx_ctrl_tx_done        ),
    .cfg_dbg_ser_en                     ( dbg0_tx_ctrl_ser_en         ),
    .cfg_dbg_der_en                     ( dbg0_tx_ctrl_der_en         ),

    //err
    .rx_err_o                           ( lvds0_rx_err_o              ),
    .rx_err_ack                         ( lvds0_rx_err_ack            ),
    //calib
    .cfg_auto_calib_en                  ( cfg_lvds0_calib_auto_calib_en),
    .cfg_start_calib_dly                ( cfg_lvds0_calib_start_calib_dly),
    .cfg_calib_extra_dly                ( cfg_lvds0_calib_extra_dly   ),
    .cfg_rx_bit_clk_inv_sel             ( cfg_lvds0_calib_rx_bit_clk_inv_sel),
    .cfg_rx_man_read_req                ( cfg_lvds0_man_read_req      ),
    .cfg_rx_man_read_ack                ( cfg_lvds0_man_read_ack      ),
    .cfg_rx_man_read_data               ( cfg_lvds0_man_read_data     ),
    .cfg_tx_cal_mode_pat                ( cfg_lvds0_cal_mode_pat_val  ),
    .cfg_rx_cal_mode_en                 ( cfg_lvds0_calib_rx_cal_mode_en),
    .cfg_tx_cal_mode_en                 ( cfg_lvds0_calib_tx_cal_mode_en),
    .cfg_rx_cal_done                    ( i_lvds0_calib_rx_cal_done   ),
    .cfg_rx_cal_up_req                  ( cfg_lvds0_cal_up_req        ),
    .cfg_rx_cal_up_val                  ( cfg_lvds0_cal_up_val        ),
    .cfg_rx_cal_lane_num                ( cfg_lvds0_cal_lane_num      ),
    .cfg_rx_cal_up_ack                  ( cfg_lvds0_cal_up_ack        ),

    //tx
    .tx_bclk                            ( lvds_tx0_bclk               ),
    .tx_rstn_raw                        ( rstn_raw & cfg_lvds0_ctrl_tx_rstn),
    .scan_mode                          ( scan_mode                   ),
    .cfg_tx_auto_sleep_en               ( cfg_lvds0_ctrl_tx_auto_sleep_en),
    .cfg_tx_lvds_ctrl_en                ( cfg_lvds0_ctrl_tx_lvds_ctrl_en),
    .tx_axis_clk                        ( axis_tx_brg_clk             ),
    .tx_axis_tdata                      ( tx0_axis_tdata              ),
    .tx_axis_tlast                      ( tx0_axis_tlast              ),
    .tx_axis_tvalid                     ( tx0_axis_tvalid             ),
    .tx_axis_tready                     ( tx0_axis_tready             ),
    .cfg_tx_lvds_pad_inv_cp             ( cfg_lvds0_pad_ctrl_tx_lvds_pad_inv_cp),
    .cfg_tx_lvds_pad_tx_cm              ( cfg_lvds0_pad_ctrl_tx_lvds_pad_tx_cm),
    .cfg_tx_lvds_pad_txdrv              ( cfg_lvds0_pad_ctrl_tx_lvds_pad_txdrv[3:0]),
    .cfg_tx_lvds_pad_bias_en            ( cfg_lvds0_pad_ctrl_tx_lvds_pad_bias_en),
    //rx
    .rx_rstn_raw                        ( rstn_raw & cfg_lvds0_ctrl_rx_rstn),
    .rx_axis_clk                        ( axis_rx0_brg_clk            ),
    .cfg_ecc_correct                    ( cfg_lvds0_ctrl_rx_ecc_correct),
    .test_rx_axis_rstn                  ( rx0_axis_rstn               ),
    .rx_axis_tdata                      ( rx0_axis_tdata              ),
    .rx_axis_tlast                      ( rx0_axis_tlast              ),
    .rx_axis_tvalid                     ( rx0_axis_tvalid             ),
    .rx_axis_tready                     ( rx0_axis_tready             ),
    .cfg_rx_delay_chain_ctrl            ( cfg_rx0_delay_chain_ctrl[6*8-1:0]),
    .cfg_rx_lvds_ctrl_en                ( cfg_lvds0_ctrl_rx_lvds_ctrl_en),
    .cfg_rx_lvds_data_wr_wm             ( cfg_lvds0_ctrl_rx_lvds_data_wr_wm[4:0]),
    .cfg_rx_lvds_data_rd_wm             ( cfg_lvds0_ctrl_rx_lvds_data_rd_wm[4:0]),
    .cfg_rx_lvds_pad_inv_cp             ( cfg_lvds0_pad_ctrl_rx_lvds_pad_inv_cp),
    .cfg_rx_lvds_pad_bias_en            ( cfg_lvds0_pad_ctrl_rx_lvds_pad_bias_en),
    .cfg_rx_lvds_pad_rterm_en           ( cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_en),
    .cfg_rx_lvds_pad_rterm_val          ( cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_val[2:0]),
    .cfg_rx_lvds_pad_rxcm_en            ( cfg_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en));

lvds_tx_rx_wrap u_lvds1_tx_rx_wrap(
                   // Inouts
    .TX_LVDS_CLK_N                      ( TX1_LVDS_CLK_N              ),
    .TX_LVDS_CLK_P                      ( TX1_LVDS_CLK_P              ),
    .TX_LVDS_DAT0_N                     ( TX1_LVDS_DAT0_N             ),
    .TX_LVDS_DAT0_P                     ( TX1_LVDS_DAT0_P             ),
    .TX_LVDS_DAT1_N                     ( TX1_LVDS_DAT1_N             ),
    .TX_LVDS_DAT1_P                     ( TX1_LVDS_DAT1_P             ),
    .TX_LVDS_DAT2_N                     ( TX1_LVDS_DAT2_N             ),
    .TX_LVDS_DAT2_P                     ( TX1_LVDS_DAT2_P             ),
    .TX_LVDS_DAT3_N                     ( TX1_LVDS_DAT3_N             ),
    .TX_LVDS_DAT3_P                     ( TX1_LVDS_DAT3_P             ),
    .TX_LVDS_DAT4_N                     ( TX1_LVDS_DAT4_N             ),
    .TX_LVDS_DAT4_P                     ( TX1_LVDS_DAT4_P             ),
    .RX_LVDS_CLK_N                      ( RX1_LVDS_CLK_N              ),
    .RX_LVDS_CLK_P                      ( RX1_LVDS_CLK_P              ),
    .RX_LVDS_DAT0_N                     ( RX1_LVDS_DAT0_N             ),
    .RX_LVDS_DAT0_P                     ( RX1_LVDS_DAT0_P             ),
    .RX_LVDS_DAT1_N                     ( RX1_LVDS_DAT1_N             ),
    .RX_LVDS_DAT1_P                     ( RX1_LVDS_DAT1_P             ),
    .RX_LVDS_DAT2_N                     ( RX1_LVDS_DAT2_N             ),
    .RX_LVDS_DAT2_P                     ( RX1_LVDS_DAT2_P             ),
    .RX_LVDS_DAT3_N                     ( RX1_LVDS_DAT3_N             ),
    .RX_LVDS_DAT3_P                     ( RX1_LVDS_DAT3_P             ),
    .RX_LVDS_DAT4_N                     ( RX1_LVDS_DAT4_N             ),
    .RX_LVDS_DAT4_P                     ( RX1_LVDS_DAT4_P             ),

    //dbg
    .cfg_prbs_tx_en                     ( dbg1_cfg_prbs_tx_en         ),
    .prbs_done                          ( dbg1_prbs_done              ),
    .prbs_pass                          ( dbg1_prbs_pass              ),
    .cfg_dbg_rx_en                      ( dbg1_rx_ctrl_rx_en          ),
    .cfg_dbg_rx_pkt_cnt                 ( dbg1_rx_ctrl_rx_pkt_cnt     ),
    .cfg_dbg_rx_pkt_equ                 ( dbg1_rx_ctrl_rx_pkt_equ     ),
    .cfg_dbg_rx_data                    ( dbg1_rx_data                ),
    .cfg_dbg_tx_start                   ( dbg1_tx_ctrl_tx_start       ),
    .cfg_dbg_tx_en                      ( dbg1_tx_ctrl_tx_en          ),
    .cfg_dbg_tx_num                     ( dbg1_tx_ctrl_tx_num         ),
    .cfg_dbg_tx_dat                     ( dbg1_tx_data                ),
    .cfg_dbg_tx_done                    ( dbg1_tx_ctrl_tx_done        ),
    .cfg_dbg_ser_en                     ( dbg1_tx_ctrl_ser_en         ),
    .cfg_dbg_der_en                     ( dbg1_tx_ctrl_der_en         ),

    //err
    .rx_err_o                           ( lvds1_rx_err_o              ),
    .rx_err_ack                         ( lvds1_rx_err_ack            ),
    //calib
    .cfg_auto_calib_en                  ( cfg_lvds1_calib_auto_calib_en),
    .cfg_start_calib_dly                ( cfg_lvds1_calib_start_calib_dly),
    .cfg_calib_extra_dly                ( cfg_lvds1_calib_extra_dly   ),
    .cfg_rx_bit_clk_inv_sel             ( cfg_lvds1_calib_rx_bit_clk_inv_sel),
    .cfg_rx_man_read_req                ( cfg_lvds1_man_read_req      ),
    .cfg_rx_man_read_ack                ( cfg_lvds1_man_read_ack      ),
    .cfg_rx_man_read_data               ( cfg_lvds1_man_read_data     ),
    .cfg_tx_cal_mode_pat                ( cfg_lvds1_cal_mode_pat_val  ),
    .cfg_rx_cal_mode_en                 ( cfg_lvds1_calib_rx_cal_mode_en),
    .cfg_tx_cal_mode_en                 ( cfg_lvds1_calib_tx_cal_mode_en),
    .cfg_rx_cal_done                    ( i_lvds1_calib_rx_cal_done   ),
    .cfg_rx_cal_up_req                  ( cfg_lvds1_cal_up_req        ),
    .cfg_rx_cal_up_val                  ( cfg_lvds1_cal_up_val        ),
    .cfg_rx_cal_lane_num                ( cfg_lvds1_cal_lane_num      ),
    .cfg_rx_cal_up_ack                  ( cfg_lvds1_cal_up_ack        ),

    //tx
    .tx_bclk                            ( lvds_tx1_bclk               ),
    .tx_rstn_raw                        ( rstn_raw & cfg_lvds1_ctrl_tx_rstn),
    .scan_mode                          ( scan_mode                   ),
    .cfg_tx_auto_sleep_en               ( cfg_lvds1_ctrl_tx_auto_sleep_en),
    .cfg_tx_lvds_ctrl_en                ( cfg_lvds1_ctrl_tx_lvds_ctrl_en),
    .tx_axis_clk                        ( axis_tx_brg_clk             ),
    .tx_axis_tdata                      ( tx1_axis_tdata              ),
    .tx_axis_tlast                      ( tx1_axis_tlast              ),
    .tx_axis_tvalid                     ( tx1_axis_tvalid             ),
    .tx_axis_tready                     ( tx1_axis_tready             ),
    .cfg_tx_lvds_pad_inv_cp             ( cfg_lvds1_pad_ctrl_tx_lvds_pad_inv_cp),
    .cfg_tx_lvds_pad_tx_cm              ( cfg_lvds1_pad_ctrl_tx_lvds_pad_tx_cm),
    .cfg_tx_lvds_pad_txdrv              ( cfg_lvds1_pad_ctrl_tx_lvds_pad_txdrv[3:0]),
    .cfg_tx_lvds_pad_bias_en            ( cfg_lvds1_pad_ctrl_tx_lvds_pad_bias_en),
    //rx
    .rx_rstn_raw                        ( rstn_raw & cfg_lvds1_ctrl_rx_rstn),
    .rx_axis_clk                        ( axis_rx1_brg_clk            ),
    .cfg_ecc_correct                    ( cfg_lvds1_ctrl_rx_ecc_correct),
    .test_rx_axis_rstn                  ( rx1_axis_rstn               ),
    .rx_axis_tdata                      ( rx1_axis_tdata              ),
    .rx_axis_tlast                      ( rx1_axis_tlast              ),
    .rx_axis_tvalid                     ( rx1_axis_tvalid             ),
    .rx_axis_tready                     ( rx1_axis_tready             ),
    .cfg_rx_delay_chain_ctrl            ( cfg_rx1_delay_chain_ctrl[6*8-1:0]),
    .cfg_rx_lvds_ctrl_en                ( cfg_lvds1_ctrl_rx_lvds_ctrl_en),
    .cfg_rx_lvds_data_wr_wm             ( cfg_lvds1_ctrl_rx_lvds_data_wr_wm[4:0]),
    .cfg_rx_lvds_data_rd_wm             ( cfg_lvds1_ctrl_rx_lvds_data_rd_wm[4:0]),
    .cfg_rx_lvds_pad_inv_cp             ( cfg_lvds1_pad_ctrl_rx_lvds_pad_inv_cp),
    .cfg_rx_lvds_pad_bias_en            ( cfg_lvds1_pad_ctrl_rx_lvds_pad_bias_en),
    .cfg_rx_lvds_pad_rterm_en           ( cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_en),
    .cfg_rx_lvds_pad_rterm_val          ( cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_val[2:0]),
    .cfg_rx_lvds_pad_rxcm_en            ( cfg_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en));

lvds_tx_rx_wrap u_lvds2_tx_rx_wrap(
                   // Inouts
    .TX_LVDS_CLK_N                      ( TX2_LVDS_CLK_N              ),
    .TX_LVDS_CLK_P                      ( TX2_LVDS_CLK_P              ),
    .TX_LVDS_DAT0_N                     ( TX2_LVDS_DAT0_N             ),
    .TX_LVDS_DAT0_P                     ( TX2_LVDS_DAT0_P             ),
    .TX_LVDS_DAT1_N                     ( TX2_LVDS_DAT1_N             ),
    .TX_LVDS_DAT1_P                     ( TX2_LVDS_DAT1_P             ),
    .TX_LVDS_DAT2_N                     ( TX2_LVDS_DAT2_N             ),
    .TX_LVDS_DAT2_P                     ( TX2_LVDS_DAT2_P             ),
    .TX_LVDS_DAT3_N                     ( TX2_LVDS_DAT3_N             ),
    .TX_LVDS_DAT3_P                     ( TX2_LVDS_DAT3_P             ),
    .TX_LVDS_DAT4_N                     ( TX2_LVDS_DAT4_N             ),
    .TX_LVDS_DAT4_P                     ( TX2_LVDS_DAT4_P             ),
    .RX_LVDS_CLK_N                      ( RX2_LVDS_CLK_N              ),
    .RX_LVDS_CLK_P                      ( RX2_LVDS_CLK_P              ),
    .RX_LVDS_DAT0_N                     ( RX2_LVDS_DAT0_N             ),
    .RX_LVDS_DAT0_P                     ( RX2_LVDS_DAT0_P             ),
    .RX_LVDS_DAT1_N                     ( RX2_LVDS_DAT1_N             ),
    .RX_LVDS_DAT1_P                     ( RX2_LVDS_DAT1_P             ),
    .RX_LVDS_DAT2_N                     ( RX2_LVDS_DAT2_N             ),
    .RX_LVDS_DAT2_P                     ( RX2_LVDS_DAT2_P             ),
    .RX_LVDS_DAT3_N                     ( RX2_LVDS_DAT3_N             ),
    .RX_LVDS_DAT3_P                     ( RX2_LVDS_DAT3_P             ),
    .RX_LVDS_DAT4_N                     ( RX2_LVDS_DAT4_N             ),
    .RX_LVDS_DAT4_P                     ( RX2_LVDS_DAT4_P             ),

    //dbg
    .cfg_prbs_tx_en                     ( dbg2_cfg_prbs_tx_en         ),
    .prbs_done                          ( dbg2_prbs_done              ),
    .prbs_pass                          ( dbg2_prbs_pass              ),
    .cfg_dbg_rx_en                      ( dbg2_rx_ctrl_rx_en          ),
    .cfg_dbg_rx_pkt_cnt                 ( dbg2_rx_ctrl_rx_pkt_cnt     ),
    .cfg_dbg_rx_pkt_equ                 ( dbg2_rx_ctrl_rx_pkt_equ     ),
    .cfg_dbg_rx_data                    ( dbg2_rx_data                ),
    .cfg_dbg_tx_start                   ( dbg2_tx_ctrl_tx_start       ),
    .cfg_dbg_tx_en                      ( dbg2_tx_ctrl_tx_en          ),
    .cfg_dbg_tx_num                     ( dbg2_tx_ctrl_tx_num         ),
    .cfg_dbg_tx_dat                     ( dbg2_tx_data                ),
    .cfg_dbg_tx_done                    ( dbg2_tx_ctrl_tx_done        ),
    .cfg_dbg_ser_en                     ( dbg2_tx_ctrl_ser_en         ),
    .cfg_dbg_der_en                     ( dbg2_tx_ctrl_der_en         ),

    //err
    .rx_err_o                           ( lvds2_rx_err_o              ),
    .rx_err_ack                         ( lvds2_rx_err_ack            ),
    //calib
    .cfg_auto_calib_en                  ( cfg_lvds2_calib_auto_calib_en),
    .cfg_start_calib_dly                ( cfg_lvds2_calib_start_calib_dly),
    .cfg_calib_extra_dly                ( cfg_lvds2_calib_extra_dly   ),
    .cfg_rx_bit_clk_inv_sel             ( cfg_lvds2_calib_rx_bit_clk_inv_sel),
    .cfg_rx_man_read_req                ( cfg_lvds2_man_read_req      ),
    .cfg_rx_man_read_ack                ( cfg_lvds2_man_read_ack      ),
    .cfg_rx_man_read_data               ( cfg_lvds2_man_read_data     ),
    .cfg_tx_cal_mode_pat                ( cfg_lvds2_cal_mode_pat_val  ),
    .cfg_rx_cal_mode_en                 ( cfg_lvds2_calib_rx_cal_mode_en),
    .cfg_tx_cal_mode_en                 ( cfg_lvds2_calib_tx_cal_mode_en),
    .cfg_rx_cal_done                    ( i_lvds2_calib_rx_cal_done   ),
    .cfg_rx_cal_up_req                  ( cfg_lvds2_cal_up_req        ),
    .cfg_rx_cal_up_val                  ( cfg_lvds2_cal_up_val        ),
    .cfg_rx_cal_lane_num                ( cfg_lvds2_cal_lane_num      ),
    .cfg_rx_cal_up_ack                  ( cfg_lvds2_cal_up_ack        ),
    
    //tx
    .tx_bclk                            ( lvds_tx2_bclk               ),
    .tx_rstn_raw                        ( rstn_raw & cfg_lvds2_ctrl_tx_rstn),
    .scan_mode                          ( scan_mode                   ),
    .cfg_tx_auto_sleep_en               ( cfg_lvds2_ctrl_tx_auto_sleep_en),
    .cfg_tx_lvds_ctrl_en                ( cfg_lvds2_ctrl_tx_lvds_ctrl_en),
    .tx_axis_clk                        ( axis_tx_brg_clk             ),
    .tx_axis_tdata                      ( tx2_axis_tdata              ),
    .tx_axis_tlast                      ( tx2_axis_tlast              ),
    .tx_axis_tvalid                     ( tx2_axis_tvalid             ),
    .tx_axis_tready                     ( tx2_axis_tready             ),
    .cfg_tx_lvds_pad_inv_cp             ( cfg_lvds2_pad_ctrl_tx_lvds_pad_inv_cp),
    .cfg_tx_lvds_pad_tx_cm              ( cfg_lvds2_pad_ctrl_tx_lvds_pad_tx_cm),
    .cfg_tx_lvds_pad_txdrv              ( cfg_lvds2_pad_ctrl_tx_lvds_pad_txdrv[3:0]),
    .cfg_tx_lvds_pad_bias_en            ( cfg_lvds2_pad_ctrl_tx_lvds_pad_bias_en),
    //rx
    .rx_rstn_raw                        ( rstn_raw & cfg_lvds2_ctrl_rx_rstn),
    .rx_axis_clk                        ( axis_rx2_brg_clk            ),
    .cfg_ecc_correct                    ( cfg_lvds2_ctrl_rx_ecc_correct),
    .test_rx_axis_rstn                  ( rx2_axis_rstn               ),
    .rx_axis_tdata                      ( rx2_axis_tdata              ),
    .rx_axis_tlast                      ( rx2_axis_tlast              ),
    .rx_axis_tvalid                     ( rx2_axis_tvalid             ),
    .rx_axis_tready                     ( rx2_axis_tready             ),
    .cfg_rx_delay_chain_ctrl            ( cfg_rx2_delay_chain_ctrl[6*8-1:0]),
    .cfg_rx_lvds_ctrl_en                ( cfg_lvds2_ctrl_rx_lvds_ctrl_en),
    .cfg_rx_lvds_data_wr_wm             ( cfg_lvds2_ctrl_rx_lvds_data_wr_wm[4:0]),
    .cfg_rx_lvds_data_rd_wm             ( cfg_lvds2_ctrl_rx_lvds_data_rd_wm[4:0]),
    .cfg_rx_lvds_pad_inv_cp             ( cfg_lvds2_pad_ctrl_rx_lvds_pad_inv_cp),
    .cfg_rx_lvds_pad_bias_en            ( cfg_lvds2_pad_ctrl_rx_lvds_pad_bias_en),
    .cfg_rx_lvds_pad_rterm_en           ( cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_en),
    .cfg_rx_lvds_pad_rterm_val          ( cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_val[2:0]),
    .cfg_rx_lvds_pad_rxcm_en            ( cfg_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en));

assign dbg3_rx_ctrl_rx_pkt_cnt             = '0;
assign dbg3_rx_ctrl_rx_pkt_equ             = '0;
assign dbg3_rx_data                        = '0;
assign dbg3_tx_ctrl_tx_done                = '0;
assign cfg_lvds3_man_read_ack              = cfg_lvds3_man_read_req;
assign cfg_lvds3_man_read_data             = '0;
assign i_lvds3_calib_rx_cal_done           = '0;
assign cfg_lvds3_cal_up_req                = '0;
assign cfg_lvds3_cal_up_val                = '0;
assign cfg_lvds3_cal_lane_num              = '0;
assign lvds3_rx_err_o                      = '0;

lvds_core_cfg_wrap u_lvds_core_cfg_wrap(
    .clk                                ( apb_pclk                    ),
    .rstn                               ( apb_presetn                 ),
    .CORE_ID                            ( CORE_ID                     ),       //core_id in X/Y direction from upstream core_unit
    .CORE_ID_NEXT                       ( CORE_ID_NEXT                ),  //core_id in X/Y direction to downstream core_unit
    
    .dout_pre                           ( dout_pre                    ),      //data returned to upstream core_unit
    .dout_pre_vld                       ( dout_pre_vld                ),  //qualifier of data returned to upstream core_unit
    .din_pre                            ( din_pre                     ),       //cfg_data from upstream core_unit
    .din_pre_vld                        ( din_pre_vld                 ),   //qualifier of cfg_data from upstream core_unit
    
    .dout_next                          ( dout_next                   ),     //data returned from downstream core_unit
    .dout_next_vld                      ( dout_next_vld               ), //qualifier of data returned from downstream core_unit
    .din_next                           ( din_next                    ),      //cfg_data to downstream core_unit
    .din_next_vld                       ( din_next_vld                ),   //qualifier of cfg_data to downstream core_unit
    
    .apb_psel                           ( apb_psel                    ),
    .apb_penable                        ( apb_penable                 ),
    .apb_pwrite                         ( apb_pwrite                  ),
    .apb_paddr                          ( apb_paddr                   ),
    .apb_pwdata                         ( apb_pwdata                  ),
    .apb_pready                         ( apb_pready                  ),
    .apb_prdata                         ( apb_prdata                  )

    );

lvds_subsys_csr u_lvds_subsys_csr(
//dbg
    .i_dbg0_tx_ctrl_prbs_rx_pass        ( dbg0_prbs_pass              ),
    .i_dbg1_tx_ctrl_prbs_rx_pass        ( dbg1_prbs_pass              ),
    .i_dbg2_tx_ctrl_prbs_rx_pass        ( dbg2_prbs_pass              ),
    .o_dbg0_tx_ctrl_prbs_tx_en          ( dbg0_cfg_prbs_tx_en         ),
    .o_dbg1_tx_ctrl_prbs_tx_en          ( dbg1_cfg_prbs_tx_en         ),
    .o_dbg2_tx_ctrl_prbs_tx_en          ( dbg2_cfg_prbs_tx_en         ),
    .i_dbg0_tx_ctrl_prbs_rx_done        ( dbg0_prbs_done              ),
    .i_dbg1_tx_ctrl_prbs_rx_done        ( dbg1_prbs_done              ),
    .i_dbg2_tx_ctrl_prbs_rx_done        ( dbg2_prbs_done              ),

    .i_dbg0_rx_ctrl_rx_pkt_cnt          ( dbg0_rx_ctrl_rx_pkt_cnt     ),
    .i_dbg0_rx_ctrl_rx_pkt_equ          ( dbg0_rx_ctrl_rx_pkt_equ     ),
    .i_dbg0_rx_data0_val                ( dbg0_rx_data[0+:32]         ),
    .i_dbg0_rx_data1_val                ( dbg0_rx_data[32+:32]        ),
    .i_dbg0_rx_data2_val                ( dbg0_rx_data[64+:32]        ),
    .i_dbg0_tx_ctrl_tx_done             ( dbg0_tx_ctrl_tx_done        ),
    .i_dbg1_rx_ctrl_rx_pkt_cnt          ( dbg1_rx_ctrl_rx_pkt_cnt     ),
    .i_dbg1_rx_ctrl_rx_pkt_equ          ( dbg1_rx_ctrl_rx_pkt_equ     ),
    .i_dbg1_rx_data0_val                ( dbg1_rx_data[0+:32]         ),
    .i_dbg1_rx_data1_val                ( dbg1_rx_data[32+:32]        ),
    .i_dbg1_rx_data2_val                ( dbg1_rx_data[64+:32]        ),
    .i_dbg1_tx_ctrl_tx_done             ( dbg1_tx_ctrl_tx_done        ),
    .i_dbg2_rx_ctrl_rx_pkt_cnt          ( dbg2_rx_ctrl_rx_pkt_cnt     ),
    .i_dbg2_rx_ctrl_rx_pkt_equ          ( dbg2_rx_ctrl_rx_pkt_equ     ),
    .i_dbg2_rx_data0_val                ( dbg2_rx_data[0+:32]         ),
    .i_dbg2_rx_data1_val                ( dbg2_rx_data[32+:32]        ),
    .i_dbg2_rx_data2_val                ( dbg2_rx_data[64+:32]        ),
    .i_dbg2_tx_ctrl_tx_done             ( dbg2_tx_ctrl_tx_done        ),
    .i_dbg3_rx_ctrl_rx_pkt_cnt          ( dbg3_rx_ctrl_rx_pkt_cnt     ),
    .i_dbg3_rx_ctrl_rx_pkt_equ          ( dbg3_rx_ctrl_rx_pkt_equ     ),
    .i_dbg3_rx_data0_val                ( dbg3_rx_data[0+:32]         ),
    .i_dbg3_rx_data1_val                ( dbg3_rx_data[32+:32]        ),
    .i_dbg3_rx_data2_val                ( dbg3_rx_data[64+:32]        ),
    .i_dbg3_tx_ctrl_tx_done             ( dbg3_tx_ctrl_tx_done        ),
    .o_dbg0_rx_ctrl_rx_en               ( dbg0_rx_ctrl_rx_en          ),
    .o_dbg0_tx_ctrl_ser_en              ( dbg0_tx_ctrl_ser_en         ),
    .o_dbg0_tx_ctrl_der_en              ( dbg0_tx_ctrl_der_en         ),
    .o_dbg0_tx_ctrl_tx_start            ( dbg0_tx_ctrl_tx_start       ),
    .o_dbg0_tx_ctrl_tx_en               ( dbg0_tx_ctrl_tx_en          ),
    .o_dbg0_tx_ctrl_tx_num              ( dbg0_tx_ctrl_tx_num         ),
    .o_dbg0_tx_data_val                 ( dbg0_tx_data                ),
    .o_dbg1_rx_ctrl_rx_en               ( dbg1_rx_ctrl_rx_en          ),
    .o_dbg1_tx_ctrl_ser_en              ( dbg1_tx_ctrl_ser_en         ),
    .o_dbg1_tx_ctrl_der_en              ( dbg1_tx_ctrl_der_en         ),
    .o_dbg1_tx_ctrl_tx_start            ( dbg1_tx_ctrl_tx_start       ),
    .o_dbg1_tx_ctrl_tx_en               ( dbg1_tx_ctrl_tx_en          ),
    .o_dbg1_tx_ctrl_tx_num              ( dbg1_tx_ctrl_tx_num         ),
    .o_dbg1_tx_data_val                 ( dbg1_tx_data                ),
    .o_dbg2_rx_ctrl_rx_en               ( dbg2_rx_ctrl_rx_en          ),
    .o_dbg2_tx_ctrl_ser_en              ( dbg2_tx_ctrl_ser_en         ),
    .o_dbg2_tx_ctrl_der_en              ( dbg2_tx_ctrl_der_en         ),
    .o_dbg2_tx_ctrl_tx_start            ( dbg2_tx_ctrl_tx_start       ),
    .o_dbg2_tx_ctrl_tx_en               ( dbg2_tx_ctrl_tx_en          ),
    .o_dbg2_tx_ctrl_tx_num              ( dbg2_tx_ctrl_tx_num         ),
    .o_dbg2_tx_data_val                 ( dbg2_tx_data                ),
    .o_dbg3_rx_ctrl_rx_en               ( dbg3_rx_ctrl_rx_en          ),
    .o_dbg3_tx_ctrl_ser_en              ( dbg3_tx_ctrl_ser_en         ),
    .o_dbg3_tx_ctrl_der_en              ( dbg3_tx_ctrl_der_en         ),
    .o_dbg3_tx_ctrl_tx_start            ( dbg3_tx_ctrl_tx_start       ),
    .o_dbg3_tx_ctrl_tx_en               ( dbg3_tx_ctrl_tx_en          ),
    .o_dbg3_tx_ctrl_tx_num              ( dbg3_tx_ctrl_tx_num         ),
    .o_dbg3_tx_data_val                 ( dbg3_tx_data                ),

    .lvds_err_intr                      ( lvds_err_intr               ),
//calib if
    .csr_rx0_man_read_req               ( cfg_lvds0_man_read_req      ),
    .csr_rx0_man_read_ack               ( cfg_lvds0_man_read_ack      ),
    .csr_rx0_cal_up_req                 ( cfg_lvds0_cal_up_req        ),
    .csr_rx0_cal_up_val                 ( cfg_lvds0_cal_up_val        ),
    .csr_rx0_cal_lane_num               ( cfg_lvds0_cal_lane_num      ),
    .csr_rx0_cal_up_ack                 ( cfg_lvds0_cal_up_ack        ),

    .csr_rx1_man_read_req               ( cfg_lvds1_man_read_req      ),
    .csr_rx1_man_read_ack               ( cfg_lvds1_man_read_ack      ),
    .csr_rx1_cal_up_req                 ( cfg_lvds1_cal_up_req        ),
    .csr_rx1_cal_up_val                 ( cfg_lvds1_cal_up_val        ),
    .csr_rx1_cal_lane_num               ( cfg_lvds1_cal_lane_num      ),
    .csr_rx1_cal_up_ack                 ( cfg_lvds1_cal_up_ack        ),

    .csr_rx2_man_read_req               ( cfg_lvds2_man_read_req      ),
    .csr_rx2_man_read_ack               ( cfg_lvds2_man_read_ack      ),
    .csr_rx2_cal_up_req                 ( cfg_lvds2_cal_up_req        ),
    .csr_rx2_cal_up_val                 ( cfg_lvds2_cal_up_val        ),
    .csr_rx2_cal_lane_num               ( cfg_lvds2_cal_lane_num      ),
    .csr_rx2_cal_up_ack                 ( cfg_lvds2_cal_up_ack        ),

    .csr_rx3_man_read_req               ( cfg_lvds3_man_read_req      ),
    .csr_rx3_man_read_ack               ( cfg_lvds3_man_read_ack      ),
    .csr_rx3_cal_up_req                 ( cfg_lvds3_cal_up_req        ),
    .csr_rx3_cal_up_val                 ( cfg_lvds3_cal_up_val        ),
    .csr_rx3_cal_lane_num               ( cfg_lvds3_cal_lane_num      ),
    .csr_rx3_cal_up_ack                 ( cfg_lvds3_cal_up_ack        ),

                  // Outputs
    .apb_pready                         ( apb_pready                  ),
    .apb_prdata                         ( apb_prdata                  ),
    .o_send_mode                        ( o_send_mode                 ),
    .o_ctrl_dis_parallel_tx             ( cfg_ctrl_dis_parallel_tx    ),
    .o_ctrl_dis_parallel_rx             ( cfg_ctrl_dis_parallel_rx    ),
    .o_lvds0_ctrl_tx_rstn               ( cfg_lvds0_ctrl_tx_rstn      ),
    .o_lvds0_ctrl_tx_lvds_ctrl_en       ( cfg_lvds0_ctrl_tx_lvds_ctrl_en),
    .o_lvds0_ctrl_rx_rstn               ( cfg_lvds0_ctrl_rx_rstn      ),
    .o_lvds0_ctrl_rx_lvds_ctrl_en       ( cfg_lvds0_ctrl_rx_lvds_ctrl_en),
    .o_lvds0_ctrl_tx_auto_sleep_en      ( cfg_lvds0_ctrl_tx_auto_sleep_en),
    .o_lvds0_ctrl_rx_lvds_data_wr_wm    ( cfg_lvds0_ctrl_rx_lvds_data_wr_wm[5-1:0]),
    .o_lvds0_ctrl_rx_lvds_data_rd_wm    ( cfg_lvds0_ctrl_rx_lvds_data_rd_wm[5-1:0]),
    .o_lvds0_ctrl_rx_ecc_correct        ( cfg_lvds0_ctrl_rx_ecc_correct),
    .o_lvds0_pad_ctrl_tx_lvds_pad_inv_cp( cfg_lvds0_pad_ctrl_tx_lvds_pad_inv_cp),
    .o_lvds0_pad_ctrl_tx_lvds_pad_tx_cm ( cfg_lvds0_pad_ctrl_tx_lvds_pad_tx_cm),
    .o_lvds0_pad_ctrl_tx_lvds_pad_txdrv ( cfg_lvds0_pad_ctrl_tx_lvds_pad_txdrv[4-1:0]),
    .o_lvds0_pad_ctrl_tx_lvds_pad_bias_en( cfg_lvds0_pad_ctrl_tx_lvds_pad_bias_en),
    .o_lvds0_pad_ctrl_rx_lvds_pad_inv_cp( cfg_lvds0_pad_ctrl_rx_lvds_pad_inv_cp),
    .o_lvds0_pad_ctrl_rx_lvds_pad_bias_en( cfg_lvds0_pad_ctrl_rx_lvds_pad_bias_en),
    .o_lvds0_pad_ctrl_rx_lvds_pad_rterm_en( cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_en),
    .o_lvds0_pad_ctrl_rx_lvds_pad_rterm_val( cfg_lvds0_pad_ctrl_rx_lvds_pad_rterm_val[3-1:0]),
    .o_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en( cfg_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en),
    .o_rx0_delay_chain_ctrl0_val        ( cfg_rx0_delay_chain_ctrl0_val[32-1:0]),
    .o_rx0_delay_chain_ctrl1_val        ( cfg_rx0_delay_chain_ctrl1_val[32-1:0]),
    .o_rx0_delay_chain_ctrl2_val        ( cfg_rx0_delay_chain_ctrl2_val[32-1:0]),
    .o_rx0_delay_chain_ctrl3_val        ( cfg_rx0_delay_chain_ctrl3_val[32-1:0]),
    .o_lvds1_ctrl_tx_rstn               ( cfg_lvds1_ctrl_tx_rstn      ),
    .o_lvds1_ctrl_tx_lvds_ctrl_en       ( cfg_lvds1_ctrl_tx_lvds_ctrl_en),
    .o_lvds1_ctrl_rx_rstn               ( cfg_lvds1_ctrl_rx_rstn      ),
    .o_lvds1_ctrl_rx_lvds_ctrl_en       ( cfg_lvds1_ctrl_rx_lvds_ctrl_en),
    .o_lvds1_ctrl_tx_auto_sleep_en      ( cfg_lvds1_ctrl_tx_auto_sleep_en),
    .o_lvds1_ctrl_rx_lvds_data_wr_wm    ( cfg_lvds1_ctrl_rx_lvds_data_wr_wm[5-1:0]),
    .o_lvds1_ctrl_rx_lvds_data_rd_wm    ( cfg_lvds1_ctrl_rx_lvds_data_rd_wm[5-1:0]),
    .o_lvds1_ctrl_rx_ecc_correct        ( cfg_lvds1_ctrl_rx_ecc_correct),
    .o_lvds1_pad_ctrl_tx_lvds_pad_inv_cp( cfg_lvds1_pad_ctrl_tx_lvds_pad_inv_cp),
    .o_lvds1_pad_ctrl_tx_lvds_pad_tx_cm ( cfg_lvds1_pad_ctrl_tx_lvds_pad_tx_cm),
    .o_lvds1_pad_ctrl_tx_lvds_pad_txdrv ( cfg_lvds1_pad_ctrl_tx_lvds_pad_txdrv[4-1:0]),
    .o_lvds1_pad_ctrl_tx_lvds_pad_bias_en( cfg_lvds1_pad_ctrl_tx_lvds_pad_bias_en),
    .o_lvds1_pad_ctrl_rx_lvds_pad_inv_cp( cfg_lvds1_pad_ctrl_rx_lvds_pad_inv_cp),
    .o_lvds1_pad_ctrl_rx_lvds_pad_bias_en( cfg_lvds1_pad_ctrl_rx_lvds_pad_bias_en),
    .o_lvds1_pad_ctrl_rx_lvds_pad_rterm_en( cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_en),
    .o_lvds1_pad_ctrl_rx_lvds_pad_rterm_val( cfg_lvds1_pad_ctrl_rx_lvds_pad_rterm_val[3-1:0]),
    .o_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en( cfg_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en),
    .o_rx1_delay_chain_ctrl0_val        ( cfg_rx1_delay_chain_ctrl0_val[32-1:0]),
    .o_rx1_delay_chain_ctrl1_val        ( cfg_rx1_delay_chain_ctrl1_val[32-1:0]),
    .o_rx1_delay_chain_ctrl2_val        ( cfg_rx1_delay_chain_ctrl2_val[32-1:0]),
    .o_rx1_delay_chain_ctrl3_val        ( cfg_rx1_delay_chain_ctrl3_val[32-1:0]),
    .o_lvds2_ctrl_tx_rstn               ( cfg_lvds2_ctrl_tx_rstn      ),
    .o_lvds2_ctrl_tx_lvds_ctrl_en       ( cfg_lvds2_ctrl_tx_lvds_ctrl_en),
    .o_lvds2_ctrl_rx_rstn               ( cfg_lvds2_ctrl_rx_rstn      ),
    .o_lvds2_ctrl_rx_lvds_ctrl_en       ( cfg_lvds2_ctrl_rx_lvds_ctrl_en),
    .o_lvds2_ctrl_tx_auto_sleep_en      ( cfg_lvds2_ctrl_tx_auto_sleep_en),
    .o_lvds2_ctrl_rx_lvds_data_wr_wm    ( cfg_lvds2_ctrl_rx_lvds_data_wr_wm[5-1:0]),
    .o_lvds2_ctrl_rx_lvds_data_rd_wm    ( cfg_lvds2_ctrl_rx_lvds_data_rd_wm[5-1:0]),
    .o_lvds2_ctrl_rx_ecc_correct        ( cfg_lvds2_ctrl_rx_ecc_correct),
    .o_lvds2_pad_ctrl_tx_lvds_pad_inv_cp( cfg_lvds2_pad_ctrl_tx_lvds_pad_inv_cp),
    .o_lvds2_pad_ctrl_tx_lvds_pad_tx_cm ( cfg_lvds2_pad_ctrl_tx_lvds_pad_tx_cm),
    .o_lvds2_pad_ctrl_tx_lvds_pad_txdrv ( cfg_lvds2_pad_ctrl_tx_lvds_pad_txdrv[4-1:0]),
    .o_lvds2_pad_ctrl_tx_lvds_pad_bias_en( cfg_lvds2_pad_ctrl_tx_lvds_pad_bias_en),
    .o_lvds2_pad_ctrl_rx_lvds_pad_inv_cp( cfg_lvds2_pad_ctrl_rx_lvds_pad_inv_cp),
    .o_lvds2_pad_ctrl_rx_lvds_pad_bias_en( cfg_lvds2_pad_ctrl_rx_lvds_pad_bias_en),
    .o_lvds2_pad_ctrl_rx_lvds_pad_rterm_en( cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_en),
    .o_lvds2_pad_ctrl_rx_lvds_pad_rterm_val( cfg_lvds2_pad_ctrl_rx_lvds_pad_rterm_val[3-1:0]),
    .o_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en( cfg_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en),
    .o_rx2_delay_chain_ctrl0_val        ( cfg_rx2_delay_chain_ctrl0_val[32-1:0]),
    .o_rx2_delay_chain_ctrl1_val        ( cfg_rx2_delay_chain_ctrl1_val[32-1:0]),
    .o_rx2_delay_chain_ctrl2_val        ( cfg_rx2_delay_chain_ctrl2_val[32-1:0]),
    .o_rx2_delay_chain_ctrl3_val        ( cfg_rx2_delay_chain_ctrl3_val[32-1:0]),
    .o_lvds3_ctrl_tx_rstn               ( cfg_lvds3_ctrl_tx_rstn      ),
    .o_lvds3_ctrl_tx_lvds_ctrl_en       ( cfg_lvds3_ctrl_tx_lvds_ctrl_en),
    .o_lvds3_ctrl_rx_rstn               ( cfg_lvds3_ctrl_rx_rstn      ),
    .o_lvds3_ctrl_rx_lvds_ctrl_en       ( cfg_lvds3_ctrl_rx_lvds_ctrl_en),
    .o_lvds3_ctrl_tx_auto_sleep_en      ( cfg_lvds3_ctrl_tx_auto_sleep_en),
    .o_lvds3_ctrl_rx_lvds_data_wr_wm    ( cfg_lvds3_ctrl_rx_lvds_data_wr_wm[5-1:0]),
    .o_lvds3_ctrl_rx_lvds_data_rd_wm    ( cfg_lvds3_ctrl_rx_lvds_data_rd_wm[5-1:0]),
    .o_lvds3_ctrl_rx_ecc_correct        ( cfg_lvds3_ctrl_rx_ecc_correct),
    .o_lvds3_pad_ctrl_tx_lvds_pad_inv_cp( cfg_lvds3_pad_ctrl_tx_lvds_pad_inv_cp),
    .o_lvds3_pad_ctrl_tx_lvds_pad_tx_cm ( cfg_lvds3_pad_ctrl_tx_lvds_pad_tx_cm),
    .o_lvds3_pad_ctrl_tx_lvds_pad_txdrv ( cfg_lvds3_pad_ctrl_tx_lvds_pad_txdrv[4-1:0]),
    .o_lvds3_pad_ctrl_tx_lvds_pad_bias_en( cfg_lvds3_pad_ctrl_tx_lvds_pad_bias_en),
    .o_lvds3_pad_ctrl_rx_lvds_pad_inv_cp( cfg_lvds3_pad_ctrl_rx_lvds_pad_inv_cp),
    .o_lvds3_pad_ctrl_rx_lvds_pad_bias_en( cfg_lvds3_pad_ctrl_rx_lvds_pad_bias_en),
    .o_lvds3_pad_ctrl_rx_lvds_pad_rterm_en( cfg_lvds3_pad_ctrl_rx_lvds_pad_rterm_en),
    .o_lvds3_pad_ctrl_rx_lvds_pad_rterm_val( cfg_lvds3_pad_ctrl_rx_lvds_pad_rterm_val[3-1:0]),
    .o_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en( cfg_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en),
    .o_rx3_delay_chain_ctrl0_val        ( cfg_rx3_delay_chain_ctrl0_val[32-1:0]),
    .o_rx3_delay_chain_ctrl1_val        ( cfg_rx3_delay_chain_ctrl1_val[32-1:0]),
    .o_rx3_delay_chain_ctrl2_val        ( cfg_rx3_delay_chain_ctrl2_val[32-1:0]),
    .o_rx3_delay_chain_ctrl3_val        ( cfg_rx3_delay_chain_ctrl3_val[32-1:0]),
    .o_lvds0_calib_rx_bit_clk_inv_sel   ( cfg_lvds0_calib_rx_bit_clk_inv_sel),
    .o_lvds0_calib_rx_cal_mode_en       ( cfg_lvds0_calib_rx_cal_mode_en),
    .o_lvds0_calib_auto_calib_en        ( cfg_lvds0_calib_auto_calib_en),
    .o_lvds0_calib_tx_cal_mode_en       ( cfg_lvds0_calib_tx_cal_mode_en),
    .o_lvds0_calib_start_calib_dly      ( cfg_lvds0_calib_start_calib_dly[8-1:0]),
    .o_lvds0_calib_extra_dly            ( cfg_lvds0_calib_extra_dly[16-1:0]),
    .o_lvds0_cal_mode_pat_val           ( cfg_lvds0_cal_mode_pat_val[10-1:0]),
    .o_lvds1_calib_rx_bit_clk_inv_sel   ( cfg_lvds1_calib_rx_bit_clk_inv_sel),
    .o_lvds1_calib_rx_cal_mode_en       ( cfg_lvds1_calib_rx_cal_mode_en),
    .o_lvds1_calib_auto_calib_en        ( cfg_lvds1_calib_auto_calib_en),
    .o_lvds1_calib_tx_cal_mode_en       ( cfg_lvds1_calib_tx_cal_mode_en),
    .o_lvds1_calib_start_calib_dly      ( cfg_lvds1_calib_start_calib_dly[8-1:0]),
    .o_lvds1_calib_extra_dly            ( cfg_lvds1_calib_extra_dly[16-1:0]),
    .o_lvds1_cal_mode_pat_val           ( cfg_lvds1_cal_mode_pat_val[10-1:0]),
    .o_lvds2_calib_rx_bit_clk_inv_sel   ( cfg_lvds2_calib_rx_bit_clk_inv_sel),
    .o_lvds2_calib_rx_cal_mode_en       ( cfg_lvds2_calib_rx_cal_mode_en),
    .o_lvds2_calib_auto_calib_en        ( cfg_lvds2_calib_auto_calib_en),
    .o_lvds2_calib_tx_cal_mode_en       ( cfg_lvds2_calib_tx_cal_mode_en),
    .o_lvds2_calib_start_calib_dly      ( cfg_lvds2_calib_start_calib_dly[8-1:0]),
    .o_lvds2_calib_extra_dly            ( cfg_lvds2_calib_extra_dly[16-1:0]),
    .o_lvds2_cal_mode_pat_val           ( cfg_lvds2_cal_mode_pat_val[10-1:0]),
    .o_lvds3_calib_rx_bit_clk_inv_sel   ( cfg_lvds3_calib_rx_bit_clk_inv_sel),
    .o_lvds3_calib_rx_cal_mode_en       ( cfg_lvds3_calib_rx_cal_mode_en),
    .o_lvds3_calib_auto_calib_en        ( cfg_lvds3_calib_auto_calib_en),
    .o_lvds3_calib_tx_cal_mode_en       ( cfg_lvds3_calib_tx_cal_mode_en),
    .o_lvds3_calib_start_calib_dly      ( cfg_lvds3_calib_start_calib_dly[8-1:0]),
    .o_lvds3_calib_extra_dly            ( cfg_lvds3_calib_extra_dly[16-1:0]),
    .o_lvds3_cal_mode_pat_val           ( cfg_lvds3_cal_mode_pat_val[10-1:0]),
    .o_err_mask_rx0_dec_err_mask        ( cfg_err_mask_rx0_dec_err_mask),
    .o_err_mask_rx0_pkt_c_err_mask      ( cfg_err_mask_rx0_pkt_c_err_mask),
    .o_err_mask_rx0_pkt_nc_err_mask     ( cfg_err_mask_rx0_pkt_nc_err_mask),
    .o_err_mask_rx1_dec_err_mask        ( cfg_err_mask_rx1_dec_err_mask),
    .o_err_mask_rx1_pkt_c_err_mask      ( cfg_err_mask_rx1_pkt_c_err_mask),
    .o_err_mask_rx1_pkt_nc_err_mask     ( cfg_err_mask_rx1_pkt_nc_err_mask),
    .o_err_mask_rx2_dec_err_mask        ( cfg_err_mask_rx2_dec_err_mask),
    .o_err_mask_rx2_pkt_c_err_mask      ( cfg_err_mask_rx2_pkt_c_err_mask),
    .o_err_mask_rx2_pkt_nc_err_mask     ( cfg_err_mask_rx2_pkt_nc_err_mask),
    .o_err_mask_rx3_dec_err_mask        ( cfg_err_mask_rx3_dec_err_mask),
    .o_err_mask_rx3_pkt_c_err_mask      ( cfg_err_mask_rx3_pkt_c_err_mask),
    .o_err_mask_rx3_pkt_nc_err_mask     ( cfg_err_mask_rx3_pkt_nc_err_mask),
    .i_err_st_rx0_dec_err               ( err_st_rx0_dec_err          ),
    .i_err_st_rx0_pkt_c_err             ( err_st_rx0_pkt_c_err        ),
    .i_err_st_rx0_pkt_nc_err            ( err_st_rx0_pkt_nc_err       ),
    .i_err_st_rx1_dec_err               ( err_st_rx1_dec_err          ),
    .i_err_st_rx1_pkt_c_err             ( err_st_rx1_pkt_c_err        ),
    .i_err_st_rx1_pkt_nc_err            ( err_st_rx1_pkt_nc_err       ),
    .i_err_st_rx2_dec_err               ( err_st_rx2_dec_err          ),
    .i_err_st_rx2_pkt_c_err             ( err_st_rx2_pkt_c_err        ),
    .i_err_st_rx2_pkt_nc_err            ( err_st_rx2_pkt_nc_err       ),
    .i_err_st_rx3_dec_err               ( err_st_rx3_dec_err          ),
    .i_err_st_rx3_pkt_c_err             ( err_st_rx3_pkt_c_err        ),
    .i_err_st_rx3_pkt_nc_err            ( err_st_rx3_pkt_nc_err       ),
    .apb_pslverr                        ( apb_pslverr                 ),
                  // Inputs
    .apb_pclk                           ( apb_pclk                    ),
    .apb_presetn                        ( apb_presetn                 ),
    .apb_psel                           ( apb_psel                    ),
    .apb_penable                        ( apb_penable                 ),
    .apb_pwrite                         ( apb_pwrite                  ),
    .apb_paddr                          ( apb_paddr[10-1:0]           ),
    .apb_pwdata                         ( apb_pwdata[32-1:0]          ),
    .i_lvds0_calib_rx_cal_done          ( i_lvds0_calib_rx_cal_done   ),
    .i_lvds0_man_read_data0_val         ( cfg_lvds0_man_read_data[32-1:0]),
    .i_lvds0_man_read_data1_val         ( cfg_lvds0_man_read_data[32+:28]),
    .i_lvds1_calib_rx_cal_done          ( i_lvds1_calib_rx_cal_done   ),
    .i_lvds1_man_read_data0_val         ( cfg_lvds1_man_read_data[32-1:0]),
    .i_lvds1_man_read_data1_val         ( cfg_lvds1_man_read_data[32+:28]),
    .i_lvds2_calib_rx_cal_done          ( i_lvds2_calib_rx_cal_done   ),
    .i_lvds2_man_read_data0_val         ( cfg_lvds2_man_read_data[32-1:0]),
    .i_lvds2_man_read_data1_val         ( cfg_lvds2_man_read_data[32+:28]),
    .i_lvds3_calib_rx_cal_done          ( i_lvds3_calib_rx_cal_done   ),
    .i_lvds3_man_read_data0_val         ( cfg_lvds3_man_read_data[32-1:0]),
    .i_lvds3_man_read_data1_val         ( cfg_lvds3_man_read_data[32+:28])
    );


endmodule

