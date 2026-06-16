
module lvds_subsys_csr #(parameter ADDR_WIDTH=10, parameter DATA_WIDTH=32)(
//dbg
    input       [  1-1:0]                           i_dbg0_tx_ctrl_prbs_rx_pass,
    input       [  1-1:0]                           i_dbg1_tx_ctrl_prbs_rx_pass,
    input       [  1-1:0]                           i_dbg2_tx_ctrl_prbs_rx_pass,
    output      reg [  1-1:0]                       o_dbg0_tx_ctrl_prbs_tx_en,
    output      reg [  1-1:0]                       o_dbg1_tx_ctrl_prbs_tx_en,
    output      reg [  1-1:0]                       o_dbg2_tx_ctrl_prbs_tx_en,
    input       [  1-1:0]                           i_dbg0_tx_ctrl_prbs_rx_done,
    input       [  1-1:0]                           i_dbg1_tx_ctrl_prbs_rx_done,
    input       [  1-1:0]                           i_dbg2_tx_ctrl_prbs_rx_done,

    input       [ 11-1:0]                           i_dbg0_rx_ctrl_rx_pkt_cnt,
    input                                           i_dbg0_rx_ctrl_rx_pkt_equ,
    input       [ 32-1:0]                           i_dbg0_rx_data0_val,
    input       [ 32-1:0]                           i_dbg0_rx_data1_val,
    input       [ 32-1:0]                           i_dbg0_rx_data2_val,
    input                                           i_dbg0_tx_ctrl_tx_done,
    input       [ 11-1:0]                           i_dbg1_rx_ctrl_rx_pkt_cnt,
    input                                           i_dbg1_rx_ctrl_rx_pkt_equ,
    input       [ 32-1:0]                           i_dbg1_rx_data0_val,
    input       [ 32-1:0]                           i_dbg1_rx_data1_val,
    input       [ 32-1:0]                           i_dbg1_rx_data2_val,
    input                                           i_dbg1_tx_ctrl_tx_done,
    input       [ 11-1:0]                           i_dbg2_rx_ctrl_rx_pkt_cnt,
    input                                           i_dbg2_rx_ctrl_rx_pkt_equ,
    input       [ 32-1:0]                           i_dbg2_rx_data0_val,
    input       [ 32-1:0]                           i_dbg2_rx_data1_val,
    input       [ 32-1:0]                           i_dbg2_rx_data2_val,
    input                                           i_dbg2_tx_ctrl_tx_done,
    input       [ 11-1:0]                           i_dbg3_rx_ctrl_rx_pkt_cnt,
    input                                           i_dbg3_rx_ctrl_rx_pkt_equ,
    input       [ 32-1:0]                           i_dbg3_rx_data0_val,
    input       [ 32-1:0]                           i_dbg3_rx_data1_val,
    input       [ 32-1:0]                           i_dbg3_rx_data2_val,
    input                                           i_dbg3_tx_ctrl_tx_done,
    output      reg                                 o_dbg0_rx_ctrl_rx_en,
    output      reg                                 o_dbg0_tx_ctrl_ser_en,
    output      reg                                 o_dbg0_tx_ctrl_der_en,
    output      reg                                 o_dbg0_tx_ctrl_tx_start,
    output      reg                                 o_dbg0_tx_ctrl_tx_en,
    output      reg [ 11-1:0]                       o_dbg0_tx_ctrl_tx_num,
    output      reg [ 32-1:0]                       o_dbg0_tx_data_val,
    output      reg                                 o_dbg1_rx_ctrl_rx_en,
    output      reg                                 o_dbg1_tx_ctrl_ser_en,
    output      reg                                 o_dbg1_tx_ctrl_der_en,
    output      reg                                 o_dbg1_tx_ctrl_tx_start,
    output      reg                                 o_dbg1_tx_ctrl_tx_en,
    output      reg [ 11-1:0]                       o_dbg1_tx_ctrl_tx_num,
    output      reg [ 32-1:0]                       o_dbg1_tx_data_val,
    output      reg                                 o_dbg2_rx_ctrl_rx_en,
    output      reg                                 o_dbg2_tx_ctrl_ser_en,
    output      reg                                 o_dbg2_tx_ctrl_der_en,
    output      reg                                 o_dbg2_tx_ctrl_tx_start,
    output      reg                                 o_dbg2_tx_ctrl_tx_en,
    output      reg [ 11-1:0]                       o_dbg2_tx_ctrl_tx_num,
    output      reg [ 32-1:0]                       o_dbg2_tx_data_val,
    output      reg                                 o_dbg3_rx_ctrl_rx_en,
    output      reg                                 o_dbg3_tx_ctrl_ser_en,
    output      reg                                 o_dbg3_tx_ctrl_der_en,
    output      reg                                 o_dbg3_tx_ctrl_tx_start,
    output      reg                                 o_dbg3_tx_ctrl_tx_en,
    output      reg [ 11-1:0]                       o_dbg3_tx_ctrl_tx_num,
    output      reg [ 32-1:0]                       o_dbg3_tx_data_val,

//intr
    output      reg                                 lvds_err_intr,
//calib_if start
    output      reg                                 csr_rx0_man_read_req,
    input                                           csr_rx0_man_read_ack,
    input                                           csr_rx0_cal_up_req,
    input       [7:0]                               csr_rx0_cal_up_val,
    input       [4:0]                               csr_rx0_cal_lane_num,
    output      reg                                 csr_rx0_cal_up_ack,

    output      reg                                 csr_rx1_man_read_req,
    input                                           csr_rx1_man_read_ack,
    input                                           csr_rx1_cal_up_req,
    input       [7:0]                               csr_rx1_cal_up_val,
    input       [4:0]                               csr_rx1_cal_lane_num,
    output      reg                                 csr_rx1_cal_up_ack,

    output      reg                                 csr_rx2_man_read_req,
    input                                           csr_rx2_man_read_ack,
    input                                           csr_rx2_cal_up_req,
    input       [7:0]                               csr_rx2_cal_up_val,
    input       [4:0]                               csr_rx2_cal_lane_num,
    output      reg                                 csr_rx2_cal_up_ack,

    output      reg                                 csr_rx3_man_read_req,
    input                                           csr_rx3_man_read_ack,
    input                                           csr_rx3_cal_up_req,
    input       [7:0]                               csr_rx3_cal_up_val,
    input       [4:0]                               csr_rx3_cal_lane_num,
    output      reg                                 csr_rx3_cal_up_ack,

//calib_if end
    input                                           apb_pclk,
    input                                           apb_presetn,
    input                                           apb_psel,
    input                                           apb_penable,
    input                                           apb_pwrite,
    input       [ADDR_WIDTH-1:0]                    apb_paddr,
    input       [DATA_WIDTH-1:0]                    apb_pwdata,
    output      reg                                 apb_pready,
    output      reg [DATA_WIDTH- 1:0]               apb_prdata,
    input                                           i_lvds0_calib_rx_cal_done,
    input       [ 32-1:0]                           i_lvds0_man_read_data0_val,
    input       [ 28-1:0]                           i_lvds0_man_read_data1_val,
    input                                           i_lvds1_calib_rx_cal_done,
    input       [ 32-1:0]                           i_lvds1_man_read_data0_val,
    input       [ 28-1:0]                           i_lvds1_man_read_data1_val,
    input                                           i_lvds2_calib_rx_cal_done,
    input       [ 32-1:0]                           i_lvds2_man_read_data0_val,
    input       [ 28-1:0]                           i_lvds2_man_read_data1_val,
    input                                           i_lvds3_calib_rx_cal_done,
    input       [ 32-1:0]                           i_lvds3_man_read_data0_val,
    input       [ 28-1:0]                           i_lvds3_man_read_data1_val,
    output      reg                                 o_send_mode,
    output      reg                                 o_ctrl_dis_parallel_tx,
    output      reg                                 o_ctrl_dis_parallel_rx,
    output      reg                                 o_lvds0_ctrl_tx_rstn,
    output      reg                                 o_lvds0_ctrl_tx_lvds_ctrl_en,
    output      reg                                 o_lvds0_ctrl_rx_rstn,
    output      reg                                 o_lvds0_ctrl_rx_lvds_ctrl_en,
    output      reg                                 o_lvds0_ctrl_tx_auto_sleep_en,
    output      reg [  5-1:0]                       o_lvds0_ctrl_rx_lvds_data_wr_wm,
    output      reg [  5-1:0]                       o_lvds0_ctrl_rx_lvds_data_rd_wm,
    output      reg                                 o_lvds0_ctrl_rx_ecc_correct,
    output      reg                                 o_lvds0_pad_ctrl_tx_lvds_pad_inv_cp,
    output      reg                                 o_lvds0_pad_ctrl_tx_lvds_pad_tx_cm,
    output      reg [  4-1:0]                       o_lvds0_pad_ctrl_tx_lvds_pad_txdrv,
    output      reg                                 o_lvds0_pad_ctrl_tx_lvds_pad_bias_en,
    output      reg                                 o_lvds0_pad_ctrl_rx_lvds_pad_inv_cp,
    output      reg                                 o_lvds0_pad_ctrl_rx_lvds_pad_bias_en,
    output      reg                                 o_lvds0_pad_ctrl_rx_lvds_pad_rterm_en,
    output      reg [  3-1:0]                       o_lvds0_pad_ctrl_rx_lvds_pad_rterm_val,
    output      reg                                 o_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en,
    output      reg [ 32-1:0]                       o_rx0_delay_chain_ctrl0_val,
    output      reg [ 32-1:0]                       o_rx0_delay_chain_ctrl1_val,
    output      reg [ 32-1:0]                       o_rx0_delay_chain_ctrl2_val,
    output      reg [ 32-1:0]                       o_rx0_delay_chain_ctrl3_val,
    output      reg                                 o_lvds1_ctrl_tx_rstn,
    output      reg                                 o_lvds1_ctrl_tx_lvds_ctrl_en,
    output      reg                                 o_lvds1_ctrl_rx_rstn,
    output      reg                                 o_lvds1_ctrl_rx_lvds_ctrl_en,
    output      reg                                 o_lvds1_ctrl_tx_auto_sleep_en,
    output      reg [  5-1:0]                       o_lvds1_ctrl_rx_lvds_data_wr_wm,
    output      reg [  5-1:0]                       o_lvds1_ctrl_rx_lvds_data_rd_wm,
    output      reg                                 o_lvds1_ctrl_rx_ecc_correct,
    output      reg                                 o_lvds1_pad_ctrl_tx_lvds_pad_inv_cp,
    output      reg                                 o_lvds1_pad_ctrl_tx_lvds_pad_tx_cm,
    output      reg [  4-1:0]                       o_lvds1_pad_ctrl_tx_lvds_pad_txdrv,
    output      reg                                 o_lvds1_pad_ctrl_tx_lvds_pad_bias_en,
    output      reg                                 o_lvds1_pad_ctrl_rx_lvds_pad_inv_cp,
    output      reg                                 o_lvds1_pad_ctrl_rx_lvds_pad_bias_en,
    output      reg                                 o_lvds1_pad_ctrl_rx_lvds_pad_rterm_en,
    output      reg [  3-1:0]                       o_lvds1_pad_ctrl_rx_lvds_pad_rterm_val,
    output      reg                                 o_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en,
    output      reg [ 32-1:0]                       o_rx1_delay_chain_ctrl0_val,
    output      reg [ 32-1:0]                       o_rx1_delay_chain_ctrl1_val,
    output      reg [ 32-1:0]                       o_rx1_delay_chain_ctrl2_val,
    output      reg [ 32-1:0]                       o_rx1_delay_chain_ctrl3_val,
    output      reg                                 o_lvds2_ctrl_tx_rstn,
    output      reg                                 o_lvds2_ctrl_tx_lvds_ctrl_en,
    output      reg                                 o_lvds2_ctrl_rx_rstn,
    output      reg                                 o_lvds2_ctrl_rx_lvds_ctrl_en,
    output      reg                                 o_lvds2_ctrl_tx_auto_sleep_en,
    output      reg [  5-1:0]                       o_lvds2_ctrl_rx_lvds_data_wr_wm,
    output      reg [  5-1:0]                       o_lvds2_ctrl_rx_lvds_data_rd_wm,
    output      reg                                 o_lvds2_ctrl_rx_ecc_correct,
    output      reg                                 o_lvds2_pad_ctrl_tx_lvds_pad_inv_cp,
    output      reg                                 o_lvds2_pad_ctrl_tx_lvds_pad_tx_cm,
    output      reg [  4-1:0]                       o_lvds2_pad_ctrl_tx_lvds_pad_txdrv,
    output      reg                                 o_lvds2_pad_ctrl_tx_lvds_pad_bias_en,
    output      reg                                 o_lvds2_pad_ctrl_rx_lvds_pad_inv_cp,
    output      reg                                 o_lvds2_pad_ctrl_rx_lvds_pad_bias_en,
    output      reg                                 o_lvds2_pad_ctrl_rx_lvds_pad_rterm_en,
    output      reg [  3-1:0]                       o_lvds2_pad_ctrl_rx_lvds_pad_rterm_val,
    output      reg                                 o_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en,
    output      reg [ 32-1:0]                       o_rx2_delay_chain_ctrl0_val,
    output      reg [ 32-1:0]                       o_rx2_delay_chain_ctrl1_val,
    output      reg [ 32-1:0]                       o_rx2_delay_chain_ctrl2_val,
    output      reg [ 32-1:0]                       o_rx2_delay_chain_ctrl3_val,
    output      reg                                 o_lvds3_ctrl_tx_rstn,
    output      reg                                 o_lvds3_ctrl_tx_lvds_ctrl_en,
    output      reg                                 o_lvds3_ctrl_rx_rstn,
    output      reg                                 o_lvds3_ctrl_rx_lvds_ctrl_en,
    output      reg                                 o_lvds3_ctrl_tx_auto_sleep_en,
    output      reg [  5-1:0]                       o_lvds3_ctrl_rx_lvds_data_wr_wm,
    output      reg [  5-1:0]                       o_lvds3_ctrl_rx_lvds_data_rd_wm,
    output      reg                                 o_lvds3_ctrl_rx_ecc_correct,
    output      reg                                 o_lvds3_pad_ctrl_tx_lvds_pad_inv_cp,
    output      reg                                 o_lvds3_pad_ctrl_tx_lvds_pad_tx_cm,
    output      reg [  4-1:0]                       o_lvds3_pad_ctrl_tx_lvds_pad_txdrv,
    output      reg                                 o_lvds3_pad_ctrl_tx_lvds_pad_bias_en,
    output      reg                                 o_lvds3_pad_ctrl_rx_lvds_pad_inv_cp,
    output      reg                                 o_lvds3_pad_ctrl_rx_lvds_pad_bias_en,
    output      reg                                 o_lvds3_pad_ctrl_rx_lvds_pad_rterm_en,
    output      reg [  3-1:0]                       o_lvds3_pad_ctrl_rx_lvds_pad_rterm_val,
    output      reg                                 o_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en,
    output      reg [ 32-1:0]                       o_rx3_delay_chain_ctrl0_val,
    output      reg [ 32-1:0]                       o_rx3_delay_chain_ctrl1_val,
    output      reg [ 32-1:0]                       o_rx3_delay_chain_ctrl2_val,
    output      reg [ 32-1:0]                       o_rx3_delay_chain_ctrl3_val,
    output      reg                                 o_lvds0_calib_rx_bit_clk_inv_sel,
    output      reg                                 o_lvds0_calib_rx_cal_mode_en,
    output      reg                                 o_lvds0_calib_auto_calib_en,
    output      reg                                 o_lvds0_calib_tx_cal_mode_en,
    output      reg [  8-1:0]                       o_lvds0_calib_start_calib_dly,
    output      reg [ 16-1:0]                       o_lvds0_calib_extra_dly,
    output      reg [ 10-1:0]                       o_lvds0_cal_mode_pat_val,
    output      reg                                 o_lvds1_calib_rx_bit_clk_inv_sel,
    output      reg                                 o_lvds1_calib_rx_cal_mode_en,
    output      reg                                 o_lvds1_calib_auto_calib_en,
    output      reg                                 o_lvds1_calib_tx_cal_mode_en,
    output      reg [  8-1:0]                       o_lvds1_calib_start_calib_dly,
    output      reg [ 16-1:0]                       o_lvds1_calib_extra_dly,
    output      reg [ 10-1:0]                       o_lvds1_cal_mode_pat_val,
    output      reg                                 o_lvds2_calib_rx_bit_clk_inv_sel,
    output      reg                                 o_lvds2_calib_rx_cal_mode_en,
    output      reg                                 o_lvds2_calib_auto_calib_en,
    output      reg                                 o_lvds2_calib_tx_cal_mode_en,
    output      reg [  8-1:0]                       o_lvds2_calib_start_calib_dly,
    output      reg [ 16-1:0]                       o_lvds2_calib_extra_dly,
    output      reg [ 10-1:0]                       o_lvds2_cal_mode_pat_val,
    output      reg                                 o_lvds3_calib_rx_bit_clk_inv_sel,
    output      reg                                 o_lvds3_calib_rx_cal_mode_en,
    output      reg                                 o_lvds3_calib_auto_calib_en,
    output      reg                                 o_lvds3_calib_tx_cal_mode_en,
    output      reg [  8-1:0]                       o_lvds3_calib_start_calib_dly,
    output      reg [ 16-1:0]                       o_lvds3_calib_extra_dly,
    output      reg [ 10-1:0]                       o_lvds3_cal_mode_pat_val,
    output      reg                                 o_err_mask_rx0_dec_err_mask,
    output      reg                                 o_err_mask_rx0_pkt_c_err_mask,
    output      reg                                 o_err_mask_rx0_pkt_nc_err_mask,
    output      reg                                 o_err_mask_rx1_dec_err_mask,
    output      reg                                 o_err_mask_rx1_pkt_c_err_mask,
    output      reg                                 o_err_mask_rx1_pkt_nc_err_mask,
    output      reg                                 o_err_mask_rx2_dec_err_mask,
    output      reg                                 o_err_mask_rx2_pkt_c_err_mask,
    output      reg                                 o_err_mask_rx2_pkt_nc_err_mask,
    output      reg                                 o_err_mask_rx3_dec_err_mask,
    output      reg                                 o_err_mask_rx3_pkt_c_err_mask,
    output      reg                                 o_err_mask_rx3_pkt_nc_err_mask,
    input       reg                                 i_err_st_rx0_dec_err,
    input       reg                                 i_err_st_rx0_pkt_c_err,
    input       reg                                 i_err_st_rx0_pkt_nc_err,
    input       reg                                 i_err_st_rx1_dec_err,
    input       reg                                 i_err_st_rx1_pkt_c_err,
    input       reg                                 i_err_st_rx1_pkt_nc_err,
    input       reg                                 i_err_st_rx2_dec_err,
    input       reg                                 i_err_st_rx2_pkt_c_err,
    input       reg                                 i_err_st_rx2_pkt_nc_err,
    input       reg                                 i_err_st_rx3_dec_err,
    input       reg                                 i_err_st_rx3_pkt_c_err,
    input       reg                                 i_err_st_rx3_pkt_nc_err,
    output      apb_pslverr
    );


localparam CTRL_OFFSET_ADDR                                     =   10'h0;
localparam LVDS0_CTRL_OFFSET_ADDR                               =   10'h4;
localparam LVDS0_PAD_CTRL_OFFSET_ADDR                           =   10'h8;
localparam RX0_DELAY_CHAIN_CTRL0_OFFSET_ADDR                    =   10'hc;
localparam RX0_DELAY_CHAIN_CTRL1_OFFSET_ADDR                    =   10'h10;
localparam RX0_DELAY_CHAIN_CTRL2_OFFSET_ADDR                    =   10'h14;
localparam RX0_DELAY_CHAIN_CTRL3_OFFSET_ADDR                    =   10'h18;
localparam LVDS1_CTRL_OFFSET_ADDR                               =   10'h24;
localparam LVDS1_PAD_CTRL_OFFSET_ADDR                           =   10'h28;
localparam RX1_DELAY_CHAIN_CTRL0_OFFSET_ADDR                    =   10'h2c;
localparam RX1_DELAY_CHAIN_CTRL1_OFFSET_ADDR                    =   10'h30;
localparam RX1_DELAY_CHAIN_CTRL2_OFFSET_ADDR                    =   10'h34;
localparam RX1_DELAY_CHAIN_CTRL3_OFFSET_ADDR                    =   10'h38;
localparam LVDS2_CTRL_OFFSET_ADDR                               =   10'h44;
localparam LVDS2_PAD_CTRL_OFFSET_ADDR                           =   10'h48;
localparam RX2_DELAY_CHAIN_CTRL0_OFFSET_ADDR                    =   10'h4c;
localparam RX2_DELAY_CHAIN_CTRL1_OFFSET_ADDR                    =   10'h50;
localparam RX2_DELAY_CHAIN_CTRL2_OFFSET_ADDR                    =   10'h54;
localparam RX2_DELAY_CHAIN_CTRL3_OFFSET_ADDR                    =   10'h58;
localparam LVDS3_CTRL_OFFSET_ADDR                               =   10'h64;
localparam LVDS3_PAD_CTRL_OFFSET_ADDR                           =   10'h68;
localparam RX3_DELAY_CHAIN_CTRL0_OFFSET_ADDR                    =   10'h6c;
localparam RX3_DELAY_CHAIN_CTRL1_OFFSET_ADDR                    =   10'h70;
localparam RX3_DELAY_CHAIN_CTRL2_OFFSET_ADDR                    =   10'h74;
localparam RX3_DELAY_CHAIN_CTRL3_OFFSET_ADDR                    =   10'h78;
localparam LVDS0_CALIB_OFFSET_ADDR                              =   10'h100;
localparam LVDS0_CAL_MODE_PAT_OFFSET_ADDR                       =   10'h104;
localparam LVDS0_MAN_READ_DATA0_OFFSET_ADDR                     =   10'h108;
localparam LVDS0_MAN_READ_DATA1_OFFSET_ADDR                     =   10'h10c;
localparam LVDS1_CALIB_OFFSET_ADDR                              =   10'h110;
localparam LVDS1_CAL_MODE_PAT_OFFSET_ADDR                       =   10'h114;
localparam LVDS1_MAN_READ_DATA0_OFFSET_ADDR                     =   10'h118;
localparam LVDS1_MAN_READ_DATA1_OFFSET_ADDR                     =   10'h11c;
localparam LVDS2_CALIB_OFFSET_ADDR                              =   10'h120;
localparam LVDS2_CAL_MODE_PAT_OFFSET_ADDR                       =   10'h124;
localparam LVDS2_MAN_READ_DATA0_OFFSET_ADDR                     =   10'h128;
localparam LVDS2_MAN_READ_DATA1_OFFSET_ADDR                     =   10'h12c;
localparam LVDS3_CALIB_OFFSET_ADDR                              =   10'h130;
localparam LVDS3_CAL_MODE_PAT_OFFSET_ADDR                       =   10'h134;
localparam LVDS3_MAN_READ_DATA0_OFFSET_ADDR                     =   10'h138;
localparam LVDS3_MAN_READ_DATA1_OFFSET_ADDR                     =   10'h13c;
localparam ERR_MASK_OFFSET_ADDR                                 =   10'h200;
localparam ERR_ST_OFFSET_ADDR                                   =   10'h204;
localparam DBG0_RX_CTRL_OFFSET_ADDR                             =   10'h210;
localparam DBG0_RX_DATA0_OFFSET_ADDR                            =   10'h214;
localparam DBG0_RX_DATA1_OFFSET_ADDR                            =   10'h218;
localparam DBG0_RX_DATA2_OFFSET_ADDR                            =   10'h21c;
localparam DBG0_TX_CTRL_OFFSET_ADDR                             =   10'h220;
localparam DBG0_TX_DATA_OFFSET_ADDR                             =   10'h224;
localparam DBG1_RX_CTRL_OFFSET_ADDR                             =   10'h230;
localparam DBG1_RX_DATA0_OFFSET_ADDR                            =   10'h234;
localparam DBG1_RX_DATA1_OFFSET_ADDR                            =   10'h238;
localparam DBG1_RX_DATA2_OFFSET_ADDR                            =   10'h23c;
localparam DBG1_TX_CTRL_OFFSET_ADDR                             =   10'h240;
localparam DBG1_TX_DATA_OFFSET_ADDR                             =   10'h244;
localparam DBG2_RX_CTRL_OFFSET_ADDR                             =   10'h250;
localparam DBG2_RX_DATA0_OFFSET_ADDR                            =   10'h254;
localparam DBG2_RX_DATA1_OFFSET_ADDR                            =   10'h258;
localparam DBG2_RX_DATA2_OFFSET_ADDR                            =   10'h25c;
localparam DBG2_TX_CTRL_OFFSET_ADDR                             =   10'h260;
localparam DBG2_TX_DATA_OFFSET_ADDR                             =   10'h264;
localparam DBG3_RX_CTRL_OFFSET_ADDR                             =   10'h270;
localparam DBG3_RX_DATA0_OFFSET_ADDR                            =   10'h274;
localparam DBG3_RX_DATA1_OFFSET_ADDR                            =   10'h278;
localparam DBG3_RX_DATA2_OFFSET_ADDR                            =   10'h27c;
localparam DBG3_TX_CTRL_OFFSET_ADDR                             =   10'h280;
localparam DBG3_TX_DATA_OFFSET_ADDR                             =   10'h284;
reg                                             rd_err,wr_err;

reg                                             dbg0_tx_ctrl_prbs_rx_done;
reg                                             dbg1_tx_ctrl_prbs_rx_done;
reg                                             dbg2_tx_ctrl_prbs_rx_done;

wire                                            csr_rx3_man_read_ack_syn;
wire                                            csr_rx2_man_read_ack_syn;
wire                                            csr_rx1_man_read_ack_syn;
wire                                            csr_rx0_man_read_ack_syn;
wire                                            csr_rx3_cal_up_req_syn;
wire                                            csr_rx2_cal_up_req_syn;
wire                                            csr_rx1_cal_up_req_syn;
wire                                            csr_rx0_cal_up_req_syn;

wire                                            csr_rx3_man_read_ack_vld;
wire                                            csr_rx2_man_read_ack_vld;
wire                                            csr_rx1_man_read_ack_vld;
wire                                            csr_rx0_man_read_ack_vld;

wire                                            rx0_man_req_w;
wire                                            rx0_man_req_clr;
wire                                            rx1_man_req_w;
wire                                            rx1_man_req_clr;
wire                                            rx2_man_req_w;
wire                                            rx2_man_req_clr;
wire                                            rx3_man_req_w;
wire                                            rx3_man_req_clr;

reg                                             csr_rx0_cal_up_req_syn_r;
reg                                             csr_rx1_cal_up_req_syn_r;
reg                                             csr_rx2_cal_up_req_syn_r;
reg                                             csr_rx3_cal_up_req_syn_r;
reg                                             csr_rx0_cal_up_req_pos_r;
reg                                             csr_rx1_cal_up_req_pos_r;
reg                                             csr_rx2_cal_up_req_pos_r;
reg                                             csr_rx3_cal_up_req_pos_r;

wire                                            csr_rx0_cal_up_req_pos;
wire                                            csr_rx1_cal_up_req_pos;
wire                                            csr_rx2_cal_up_req_pos;
wire                                            csr_rx3_cal_up_req_pos;

wire                                            csr_rx0_cal_up_ack_clr;
wire                                            csr_rx1_cal_up_ack_clr;
wire                                            csr_rx2_cal_up_ack_clr;
wire                                            csr_rx3_cal_up_ack_clr;

reg                                             i_err_st_rx0_dec_err_dly;
reg                                             i_err_st_rx0_pkt_c_err_dly;
reg                                             i_err_st_rx0_pkt_nc_err_dly;
reg                                             i_err_st_rx1_dec_err_dly;
reg                                             i_err_st_rx1_pkt_c_err_dly;
reg                                             i_err_st_rx1_pkt_nc_err_dly;
reg                                             i_err_st_rx2_dec_err_dly;
reg                                             i_err_st_rx2_pkt_c_err_dly;
reg                                             i_err_st_rx2_pkt_nc_err_dly;
reg                                             i_err_st_rx3_dec_err_dly;
reg                                             i_err_st_rx3_pkt_c_err_dly;
reg                                             i_err_st_rx3_pkt_nc_err_dly;

reg                                             i_err_st_rx0_dec_err_pos;
reg                                             i_err_st_rx0_pkt_c_err_pos;
reg                                             i_err_st_rx0_pkt_nc_err_pos;
reg                                             i_err_st_rx1_dec_err_pos;
reg                                             i_err_st_rx1_pkt_c_err_pos;
reg                                             i_err_st_rx1_pkt_nc_err_pos;
reg                                             i_err_st_rx2_dec_err_pos;
reg                                             i_err_st_rx2_pkt_c_err_pos;
reg                                             i_err_st_rx2_pkt_nc_err_pos;
reg                                             i_err_st_rx3_dec_err_pos;
reg                                             i_err_st_rx3_pkt_c_err_pos;
reg                                             i_err_st_rx3_pkt_nc_err_pos;

reg                                             o_err_st_rx0_dec_err;
reg                                             o_err_st_rx0_pkt_c_err;
reg                                             o_err_st_rx0_pkt_nc_err;
reg                                             o_err_st_rx1_dec_err;
reg                                             o_err_st_rx1_pkt_c_err;
reg                                             o_err_st_rx1_pkt_nc_err;
reg                                             o_err_st_rx2_dec_err;
reg                                             o_err_st_rx2_pkt_c_err;
reg                                             o_err_st_rx2_pkt_nc_err;
reg                                             o_err_st_rx3_dec_err;
reg                                             o_err_st_rx3_pkt_c_err;
reg                                             o_err_st_rx3_pkt_nc_err;

wire                                            i_lvds0_calib_rx_cal_done_syn;
wire                                            i_lvds1_calib_rx_cal_done_syn;
wire                                            i_lvds2_calib_rx_cal_done_syn;
wire                                            i_lvds3_calib_rx_cal_done_syn;
wire                                            i_dbg0_tx_ctrl_tx_done_syn;
wire                                            i_dbg1_tx_ctrl_tx_done_syn;
wire                                            i_dbg2_tx_ctrl_tx_done_syn;
wire                                            i_dbg3_tx_ctrl_tx_done_syn;

wire                                            i_dbg0_tx_ctrl_prbs_rx_done_syn;
wire                                            i_dbg1_tx_ctrl_prbs_rx_done_syn;
wire                                            i_dbg2_tx_ctrl_prbs_rx_done_syn;
reg                                             i_dbg0_tx_ctrl_prbs_rx_done_syn_r;
reg                                             i_dbg1_tx_ctrl_prbs_rx_done_syn_r;
reg                                             i_dbg2_tx_ctrl_prbs_rx_done_syn_r;
wire                                            i_dbg0_tx_ctrl_prbs_rx_done_pos;
wire                                            i_dbg1_tx_ctrl_prbs_rx_done_pos;
wire                                            i_dbg2_tx_ctrl_prbs_rx_done_pos;
wire                                            i_dbg0_tx_ctrl_prbs_rx_pass_syn;
wire                                            i_dbg1_tx_ctrl_prbs_rx_pass_syn;
wire                                            i_dbg2_tx_ctrl_prbs_rx_pass_syn;

wire                                            dbg0_tx_ctrl_prbs_rx_done_wr;
wire                                            dbg1_tx_ctrl_prbs_rx_done_wr;
wire                                            dbg2_tx_ctrl_prbs_rx_done_wr;

macro_sync2r u_syn_prbs_rx_done[10:0](  
    .ck                                 ( apb_pclk                    ),
    .clb                                ( apb_presetn                 ),
    .d                                  ({
                                            i_dbg0_tx_ctrl_prbs_rx_done,
                                            i_dbg1_tx_ctrl_prbs_rx_done,
                                            i_dbg2_tx_ctrl_prbs_rx_done,
                                            i_lvds0_calib_rx_cal_done,
                                            i_lvds1_calib_rx_cal_done,
                                            i_lvds2_calib_rx_cal_done,
                                            i_lvds3_calib_rx_cal_done,
                                            i_dbg0_tx_ctrl_tx_done,
                                            i_dbg1_tx_ctrl_tx_done,
                                            i_dbg2_tx_ctrl_tx_done,
                                            i_dbg3_tx_ctrl_tx_done

                                            }),
    .o                                  ({
                                            i_dbg0_tx_ctrl_prbs_rx_done_syn,
                                            i_dbg1_tx_ctrl_prbs_rx_done_syn,
                                            i_dbg2_tx_ctrl_prbs_rx_done_syn,
                                            i_lvds0_calib_rx_cal_done_syn,
                                            i_lvds1_calib_rx_cal_done_syn,
                                            i_lvds2_calib_rx_cal_done_syn,
                                            i_lvds3_calib_rx_cal_done_syn,
                                            i_dbg0_tx_ctrl_tx_done_syn,
                                            i_dbg1_tx_ctrl_tx_done_syn,
                                            i_dbg2_tx_ctrl_tx_done_syn,
                                            i_dbg3_tx_ctrl_tx_done_syn
                                            
                                        })
    );

macro_sync2r u_syn_prbs_rx_pass[2:0](  
    .ck                                 ( apb_pclk                    ),
    .clb                                ( apb_presetn                 ),
    .d                                  ({
                                            i_dbg0_tx_ctrl_prbs_rx_pass,
                                            i_dbg1_tx_ctrl_prbs_rx_pass,
                                            i_dbg2_tx_ctrl_prbs_rx_pass
                                            }),
    .o                                  ({
                                            i_dbg0_tx_ctrl_prbs_rx_pass_syn,
                                            i_dbg1_tx_ctrl_prbs_rx_pass_syn,
                                            i_dbg2_tx_ctrl_prbs_rx_pass_syn
                                            
                                        })
    );

macro_sync2r u_syn_cal_up_req[3:0](  
    .ck                                 ( apb_pclk                    ),
    .clb                                ( apb_presetn                 ),
    .d                                  ({
                                            csr_rx3_cal_up_req,
                                            csr_rx2_cal_up_req,
                                            csr_rx1_cal_up_req,
                                            csr_rx0_cal_up_req
                                            }),
    .o                                  ({
                                            csr_rx3_cal_up_req_syn,
                                            csr_rx2_cal_up_req_syn,
                                            csr_rx1_cal_up_req_syn,
                                            csr_rx0_cal_up_req_syn
                                        })
    );

macro_sync2r u_syn_man_read_ack[3:0](  
    .ck                                 ( apb_pclk                    ),
    .clb                                ( apb_presetn                 ),
    .d                                  ({
                                            csr_rx3_man_read_ack,
                                            csr_rx2_man_read_ack,
                                            csr_rx1_man_read_ack,
                                            csr_rx0_man_read_ack
                                            }),
    .o                                  ({
                                            csr_rx3_man_read_ack_syn,
                                            csr_rx2_man_read_ack_syn,
                                            csr_rx1_man_read_ack_syn,
                                            csr_rx0_man_read_ack_syn
                                        })
    );

assign csr_rx3_man_read_ack_vld            = ~o_lvds3_calib_rx_cal_mode_en ? csr_rx3_man_read_req : csr_rx3_man_read_ack_syn;
assign csr_rx2_man_read_ack_vld            = ~o_lvds2_calib_rx_cal_mode_en ? csr_rx2_man_read_req : csr_rx2_man_read_ack_syn;
assign csr_rx1_man_read_ack_vld            = ~o_lvds1_calib_rx_cal_mode_en ? csr_rx1_man_read_req : csr_rx1_man_read_ack_syn;
assign csr_rx0_man_read_ack_vld            = ~o_lvds0_calib_rx_cal_mode_en ? csr_rx0_man_read_req : csr_rx0_man_read_ack_syn;

assign rx0_man_req_w                       = ~csr_rx0_man_read_req & apb_psel & ~apb_penable & ~apb_pwrite & ~apb_pready & (apb_paddr == LVDS0_MAN_READ_DATA0_OFFSET_ADDR);
assign rx0_man_req_clr                     = csr_rx0_man_read_req & csr_rx0_man_read_ack_vld;

assign rx1_man_req_w                       = ~csr_rx1_man_read_req & apb_psel & ~apb_penable & ~apb_pwrite & ~apb_pready & (apb_paddr == LVDS1_MAN_READ_DATA0_OFFSET_ADDR);
assign rx1_man_req_clr                     = csr_rx1_man_read_req & csr_rx1_man_read_ack_vld;

assign rx2_man_req_w                       = ~csr_rx2_man_read_req & apb_psel & ~apb_penable & ~apb_pwrite & ~apb_pready & (apb_paddr == LVDS2_MAN_READ_DATA0_OFFSET_ADDR);
assign rx2_man_req_clr                     = csr_rx2_man_read_req & csr_rx2_man_read_ack_vld;

assign rx3_man_req_w                       = ~csr_rx3_man_read_req & apb_psel & ~apb_penable & ~apb_pwrite & ~apb_pready & (apb_paddr == LVDS3_MAN_READ_DATA0_OFFSET_ADDR);
assign rx3_man_req_clr                     = csr_rx3_man_read_req & csr_rx3_man_read_ack_vld;

always @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        csr_rx0_man_read_req                <= 1'b0;
        csr_rx1_man_read_req                <= 1'b0;
        csr_rx2_man_read_req                <= 1'b0;
        csr_rx3_man_read_req                <= 1'b0;
    end
    else begin

        if(rx0_man_req_w)
            csr_rx0_man_read_req                <= 1'b1;
        else if(rx0_man_req_clr)
            csr_rx0_man_read_req                <= 1'b0;

        if(rx1_man_req_w)
            csr_rx1_man_read_req                <= 1'b1;
        else if(rx1_man_req_clr)
            csr_rx1_man_read_req                <= 1'b0;

        if(rx2_man_req_w)
            csr_rx2_man_read_req                <= 1'b1;
        else if(rx2_man_req_clr)
            csr_rx2_man_read_req                <= 1'b0;

        if(rx3_man_req_w)
            csr_rx3_man_read_req                <= 1'b1;
        else if(rx3_man_req_clr)
            csr_rx3_man_read_req                <= 1'b0;

    end

assign csr_rx0_cal_up_req_pos              = ~csr_rx0_cal_up_req_syn_r & csr_rx0_cal_up_req_syn;
assign csr_rx1_cal_up_req_pos              = ~csr_rx1_cal_up_req_syn_r & csr_rx1_cal_up_req_syn;
assign csr_rx2_cal_up_req_pos              = ~csr_rx2_cal_up_req_syn_r & csr_rx2_cal_up_req_syn;
assign csr_rx3_cal_up_req_pos              = ~csr_rx3_cal_up_req_syn_r & csr_rx3_cal_up_req_syn;

assign csr_rx0_cal_up_ack_clr              = csr_rx0_cal_up_ack & ~csr_rx0_cal_up_req_syn;
assign csr_rx1_cal_up_ack_clr              = csr_rx1_cal_up_ack & ~csr_rx1_cal_up_req_syn;
assign csr_rx2_cal_up_ack_clr              = csr_rx2_cal_up_ack & ~csr_rx2_cal_up_req_syn;
assign csr_rx3_cal_up_ack_clr              = csr_rx3_cal_up_ack & ~csr_rx3_cal_up_req_syn;

assign i_err_st_rx0_dec_err_pos            = ~i_err_st_rx0_dec_err_dly & i_err_st_rx0_dec_err;
assign i_err_st_rx0_pkt_c_err_pos          = ~i_err_st_rx0_pkt_c_err_dly & i_err_st_rx0_pkt_c_err;
assign i_err_st_rx0_pkt_nc_err_pos         = ~i_err_st_rx0_pkt_nc_err_dly & i_err_st_rx0_pkt_nc_err;
assign i_err_st_rx1_dec_err_pos            = ~i_err_st_rx1_dec_err_dly & i_err_st_rx1_dec_err;
assign i_err_st_rx1_pkt_c_err_pos          = ~i_err_st_rx1_pkt_c_err_dly & i_err_st_rx1_pkt_c_err;
assign i_err_st_rx1_pkt_nc_err_pos         = ~i_err_st_rx1_pkt_nc_err_dly & i_err_st_rx1_pkt_nc_err;
assign i_err_st_rx2_dec_err_pos            = ~i_err_st_rx2_dec_err_dly & i_err_st_rx2_dec_err;
assign i_err_st_rx2_pkt_c_err_pos          = ~i_err_st_rx2_pkt_c_err_dly & i_err_st_rx2_pkt_c_err;
assign i_err_st_rx2_pkt_nc_err_pos         = ~i_err_st_rx2_pkt_nc_err_dly & i_err_st_rx2_pkt_nc_err;
assign i_err_st_rx3_dec_err_pos            = ~i_err_st_rx3_dec_err_dly & i_err_st_rx3_dec_err;
assign i_err_st_rx3_pkt_c_err_pos          = ~i_err_st_rx3_pkt_c_err_dly & i_err_st_rx3_pkt_c_err;
assign i_err_st_rx3_pkt_nc_err_pos         = ~i_err_st_rx3_pkt_nc_err_dly & i_err_st_rx3_pkt_nc_err;

assign i_dbg0_tx_ctrl_prbs_rx_done_pos     = ~i_dbg0_tx_ctrl_prbs_rx_done_syn_r & i_dbg0_tx_ctrl_prbs_rx_done_syn;
assign i_dbg1_tx_ctrl_prbs_rx_done_pos     = ~i_dbg1_tx_ctrl_prbs_rx_done_syn_r & i_dbg1_tx_ctrl_prbs_rx_done_syn;
assign i_dbg2_tx_ctrl_prbs_rx_done_pos     = ~i_dbg2_tx_ctrl_prbs_rx_done_syn_r & i_dbg2_tx_ctrl_prbs_rx_done_syn;
assign dbg0_tx_ctrl_prbs_rx_done_wr        = apb_psel & apb_penable & apb_pwrite & ~apb_pready & (apb_paddr == DBG0_TX_CTRL_OFFSET_ADDR);
assign dbg1_tx_ctrl_prbs_rx_done_wr        = apb_psel & apb_penable & apb_pwrite & ~apb_pready & (apb_paddr == DBG1_TX_CTRL_OFFSET_ADDR);
assign dbg2_tx_ctrl_prbs_rx_done_wr        = apb_psel & apb_penable & apb_pwrite & ~apb_pready & (apb_paddr == DBG2_TX_CTRL_OFFSET_ADDR);


always @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        csr_rx0_cal_up_req_syn_r            <= 1'b0;
        csr_rx0_cal_up_req_pos_r            <= 1'b0;
        csr_rx1_cal_up_req_syn_r            <= 1'b0;
        csr_rx1_cal_up_req_pos_r            <= 1'b0;
        csr_rx2_cal_up_req_syn_r            <= 1'b0;
        csr_rx2_cal_up_req_pos_r            <= 1'b0;
        csr_rx3_cal_up_req_syn_r            <= 1'b0;
        csr_rx3_cal_up_req_pos_r            <= 1'b0;
        csr_rx0_cal_up_ack                  <= 1'b0;
        csr_rx1_cal_up_ack                  <= 1'b0;
        csr_rx2_cal_up_ack                  <= 1'b0;
        csr_rx3_cal_up_ack                  <= 1'b0;
        i_err_st_rx0_dec_err_dly            <= '0;
        i_err_st_rx0_pkt_c_err_dly          <= '0;
        i_err_st_rx0_pkt_nc_err_dly         <= '0;
        i_err_st_rx1_dec_err_dly            <= '0;
        i_err_st_rx1_pkt_c_err_dly          <= '0;
        i_err_st_rx1_pkt_nc_err_dly         <= '0;
        i_err_st_rx2_dec_err_dly            <= '0;
        i_err_st_rx2_pkt_c_err_dly          <= '0;
        i_err_st_rx2_pkt_nc_err_dly         <= '0;
        i_err_st_rx3_dec_err_dly            <= '0;
        i_err_st_rx3_pkt_c_err_dly          <= '0;
        i_err_st_rx3_pkt_nc_err_dly         <= '0;

        i_dbg0_tx_ctrl_prbs_rx_done_syn_r   <= '0;
        i_dbg1_tx_ctrl_prbs_rx_done_syn_r   <= '0;
        i_dbg2_tx_ctrl_prbs_rx_done_syn_r   <= '0;
    end
    else begin
        csr_rx0_cal_up_req_syn_r            <= csr_rx0_cal_up_req_syn;
        csr_rx0_cal_up_req_pos_r            <= csr_rx0_cal_up_req_pos;
        csr_rx1_cal_up_req_syn_r            <= csr_rx1_cal_up_req_syn;
        csr_rx1_cal_up_req_pos_r            <= csr_rx1_cal_up_req_pos;
        csr_rx2_cal_up_req_syn_r            <= csr_rx2_cal_up_req_syn;
        csr_rx2_cal_up_req_pos_r            <= csr_rx2_cal_up_req_pos;
        csr_rx3_cal_up_req_syn_r            <= csr_rx3_cal_up_req_syn;
        csr_rx3_cal_up_req_pos_r            <= csr_rx3_cal_up_req_pos;
        
        if(csr_rx0_cal_up_req_pos_r)
            csr_rx0_cal_up_ack                  <= 1'b1;
        else if(csr_rx0_cal_up_ack_clr)
            csr_rx0_cal_up_ack                  <= 1'b0;

        if(csr_rx1_cal_up_req_pos_r)
            csr_rx1_cal_up_ack                  <= 1'b1;
        else if(csr_rx1_cal_up_ack_clr)
            csr_rx1_cal_up_ack                  <= 1'b0;

        if(csr_rx2_cal_up_req_pos_r)
            csr_rx2_cal_up_ack                  <= 1'b1;
        else if(csr_rx2_cal_up_ack_clr)
            csr_rx2_cal_up_ack                  <= 1'b0;

        if(csr_rx3_cal_up_req_pos_r)
            csr_rx3_cal_up_ack                  <= 1'b1;
        else if(csr_rx3_cal_up_ack_clr)
            csr_rx3_cal_up_ack                  <= 1'b0;

        i_err_st_rx0_dec_err_dly            <= i_err_st_rx0_dec_err;
        i_err_st_rx0_pkt_c_err_dly          <= i_err_st_rx0_pkt_c_err;
        i_err_st_rx0_pkt_nc_err_dly         <= i_err_st_rx0_pkt_nc_err;
        i_err_st_rx1_dec_err_dly            <= i_err_st_rx1_dec_err;
        i_err_st_rx1_pkt_c_err_dly          <= i_err_st_rx1_pkt_c_err;
        i_err_st_rx1_pkt_nc_err_dly         <= i_err_st_rx1_pkt_nc_err;
        i_err_st_rx2_dec_err_dly            <= i_err_st_rx2_dec_err;
        i_err_st_rx2_pkt_c_err_dly          <= i_err_st_rx2_pkt_c_err;
        i_err_st_rx2_pkt_nc_err_dly         <= i_err_st_rx2_pkt_nc_err;
        i_err_st_rx3_dec_err_dly            <= i_err_st_rx3_dec_err;
        i_err_st_rx3_pkt_c_err_dly          <= i_err_st_rx3_pkt_c_err;
        i_err_st_rx3_pkt_nc_err_dly         <= i_err_st_rx3_pkt_nc_err;

        i_dbg0_tx_ctrl_prbs_rx_done_syn_r   <= i_dbg0_tx_ctrl_prbs_rx_done_syn;
        i_dbg1_tx_ctrl_prbs_rx_done_syn_r   <= i_dbg1_tx_ctrl_prbs_rx_done_syn;
        i_dbg2_tx_ctrl_prbs_rx_done_syn_r   <= i_dbg2_tx_ctrl_prbs_rx_done_syn;
    end


always @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        dbg0_tx_ctrl_prbs_rx_done           <= 1'b0;
        dbg1_tx_ctrl_prbs_rx_done           <= 1'b0;
        dbg2_tx_ctrl_prbs_rx_done           <= 1'b0;
    end
    else begin
        if(i_dbg0_tx_ctrl_prbs_rx_done_pos)
            dbg0_tx_ctrl_prbs_rx_done           <= 1'b1;
        else if(dbg0_tx_ctrl_prbs_rx_done_wr)
            dbg0_tx_ctrl_prbs_rx_done           <= apb_pwdata[5];

        if(i_dbg1_tx_ctrl_prbs_rx_done_pos)
            dbg1_tx_ctrl_prbs_rx_done           <= 1'b1;
        else if(dbg1_tx_ctrl_prbs_rx_done_wr)
            dbg1_tx_ctrl_prbs_rx_done           <= apb_pwdata[5];

        if(i_dbg2_tx_ctrl_prbs_rx_done_pos)
            dbg2_tx_ctrl_prbs_rx_done           <= 1'b1;
        else if(dbg2_tx_ctrl_prbs_rx_done_wr)
            dbg2_tx_ctrl_prbs_rx_done           <= apb_pwdata[5];

    end

wire                                            lvds_err_intr_set;
wire                                            lvds_err_intr_clr;
wire                                            lvds_err_or;

assign lvds_err_or                         = 
    (~o_err_mask_rx0_dec_err_mask    & o_err_st_rx0_dec_err   ) |
    (~o_err_mask_rx0_pkt_c_err_mask  & o_err_st_rx0_pkt_c_err ) |
    (~o_err_mask_rx0_pkt_nc_err_mask & o_err_st_rx0_pkt_nc_err) |

    (~o_err_mask_rx1_dec_err_mask    & o_err_st_rx1_dec_err   ) |
    (~o_err_mask_rx1_pkt_c_err_mask  & o_err_st_rx1_pkt_c_err ) |
    (~o_err_mask_rx1_pkt_nc_err_mask & o_err_st_rx1_pkt_nc_err) |

    (~o_err_mask_rx2_dec_err_mask    & o_err_st_rx2_dec_err   ) |
    (~o_err_mask_rx2_pkt_c_err_mask  & o_err_st_rx2_pkt_c_err ) |
    (~o_err_mask_rx2_pkt_nc_err_mask & o_err_st_rx2_pkt_nc_err) |

    (~o_err_mask_rx3_dec_err_mask    & o_err_st_rx3_dec_err   ) |
    (~o_err_mask_rx3_pkt_c_err_mask  & o_err_st_rx3_pkt_c_err ) |
    (~o_err_mask_rx3_pkt_nc_err_mask & o_err_st_rx3_pkt_nc_err);


assign lvds_err_intr_set                   = lvds_err_or & ~lvds_err_intr;
assign lvds_err_intr_clr                   = ~lvds_err_or & lvds_err_intr;
always @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        lvds_err_intr                       <= 1'b0;
    end
    else begin 
        if(lvds_err_intr_set)
            lvds_err_intr                       <= 1'b1;
        else if(lvds_err_intr_clr)
            lvds_err_intr                       <= 1'b0;
    end

always @(posedge apb_pclk or negedge apb_presetn) begin
    if(!apb_presetn) begin
        wr_err                              <= 0;
        o_ctrl_dis_parallel_tx              <=  'h1;
        o_ctrl_dis_parallel_rx              <=  'h1;
        o_send_mode                         <= '0;
        o_lvds0_ctrl_tx_rstn                <=  'h1;
        o_lvds0_ctrl_tx_lvds_ctrl_en        <=  'h1;
        o_lvds0_ctrl_rx_rstn                <=  'h0;
        o_lvds0_ctrl_rx_lvds_ctrl_en        <=  'h1;
        o_lvds0_ctrl_tx_auto_sleep_en       <=  'h0;
        o_lvds0_ctrl_rx_lvds_data_wr_wm     <=  'h8;
        o_lvds0_ctrl_rx_lvds_data_rd_wm     <=  'h8;
        o_lvds0_ctrl_rx_ecc_correct         <=  'h0;
        o_lvds0_pad_ctrl_tx_lvds_pad_inv_cp <=  'h0;
        o_lvds0_pad_ctrl_tx_lvds_pad_tx_cm  <=  'h0;
        o_lvds0_pad_ctrl_tx_lvds_pad_txdrv  <=  'h0;
        o_lvds0_pad_ctrl_tx_lvds_pad_bias_en<=  'h1;
        o_lvds0_pad_ctrl_rx_lvds_pad_inv_cp <=  'h0;
        o_lvds0_pad_ctrl_rx_lvds_pad_bias_en<=  'h1;
        o_lvds0_pad_ctrl_rx_lvds_pad_rterm_en<=  'h0;
        o_lvds0_pad_ctrl_rx_lvds_pad_rterm_val<=  'h0;
        o_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en<=  'h0;
        o_rx0_delay_chain_ctrl0_val         <=  'h0;
        o_rx0_delay_chain_ctrl1_val         <=  'h0;
        o_rx0_delay_chain_ctrl2_val         <=  'h0;
        o_rx0_delay_chain_ctrl3_val         <=  'h0;
        o_lvds1_ctrl_tx_rstn                <=  'h1;
        o_lvds1_ctrl_tx_lvds_ctrl_en        <=  'h1;
        o_lvds1_ctrl_rx_rstn                <=  'h0;
        o_lvds1_ctrl_rx_lvds_ctrl_en        <=  'h1;
        o_lvds1_ctrl_tx_auto_sleep_en       <=  'h0;
        o_lvds1_ctrl_rx_lvds_data_wr_wm     <=  'h8;
        o_lvds1_ctrl_rx_lvds_data_rd_wm     <=  'h8;
        o_lvds1_ctrl_rx_ecc_correct         <=  'h0;
        o_lvds1_pad_ctrl_tx_lvds_pad_inv_cp <=  'h0;
        o_lvds1_pad_ctrl_tx_lvds_pad_tx_cm  <=  'h0;
        o_lvds1_pad_ctrl_tx_lvds_pad_txdrv  <=  'h0;
        o_lvds1_pad_ctrl_tx_lvds_pad_bias_en<=  'h1;
        o_lvds1_pad_ctrl_rx_lvds_pad_inv_cp <=  'h0;
        o_lvds1_pad_ctrl_rx_lvds_pad_bias_en<=  'h1;
        o_lvds1_pad_ctrl_rx_lvds_pad_rterm_en<=  'h0;
        o_lvds1_pad_ctrl_rx_lvds_pad_rterm_val<=  'h0;
        o_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en<=  'h0;
        o_rx1_delay_chain_ctrl0_val         <=  'h0;
        o_rx1_delay_chain_ctrl1_val         <=  'h0;
        o_rx1_delay_chain_ctrl2_val         <=  'h0;
        o_rx1_delay_chain_ctrl3_val         <=  'h0;
        o_lvds2_ctrl_tx_rstn                <=  'h1;
        o_lvds2_ctrl_tx_lvds_ctrl_en        <=  'h1;
        o_lvds2_ctrl_rx_rstn                <=  'h0;
        o_lvds2_ctrl_rx_lvds_ctrl_en        <=  'h1;
        o_lvds2_ctrl_tx_auto_sleep_en       <=  'h0;
        o_lvds2_ctrl_rx_lvds_data_wr_wm     <=  'h8;
        o_lvds2_ctrl_rx_lvds_data_rd_wm     <=  'h8;
        o_lvds2_ctrl_rx_ecc_correct         <=  'h0;
        o_lvds2_pad_ctrl_tx_lvds_pad_inv_cp <=  'h0;
        o_lvds2_pad_ctrl_tx_lvds_pad_tx_cm  <=  'h0;
        o_lvds2_pad_ctrl_tx_lvds_pad_txdrv  <=  'h0;
        o_lvds2_pad_ctrl_tx_lvds_pad_bias_en<=  'h1;
        o_lvds2_pad_ctrl_rx_lvds_pad_inv_cp <=  'h0;
        o_lvds2_pad_ctrl_rx_lvds_pad_bias_en<=  'h1;
        o_lvds2_pad_ctrl_rx_lvds_pad_rterm_en<=  'h0;
        o_lvds2_pad_ctrl_rx_lvds_pad_rterm_val<=  'h0;
        o_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en<=  'h0;
        o_rx2_delay_chain_ctrl0_val         <=  'h0;
        o_rx2_delay_chain_ctrl1_val         <=  'h0;
        o_rx2_delay_chain_ctrl2_val         <=  'h0;
        o_rx2_delay_chain_ctrl3_val         <=  'h0;
        o_lvds3_ctrl_tx_rstn                <=  'h1;
        o_lvds3_ctrl_tx_lvds_ctrl_en        <=  'h1;
        o_lvds3_ctrl_rx_rstn                <=  'h0;
        o_lvds3_ctrl_rx_lvds_ctrl_en        <=  'h1;
        o_lvds3_ctrl_tx_auto_sleep_en       <=  'h0;
        o_lvds3_ctrl_rx_lvds_data_wr_wm     <=  'h8;
        o_lvds3_ctrl_rx_lvds_data_rd_wm     <=  'h8;
        o_lvds3_ctrl_rx_ecc_correct         <=  'h0;
        o_lvds3_pad_ctrl_tx_lvds_pad_inv_cp <=  'h0;
        o_lvds3_pad_ctrl_tx_lvds_pad_tx_cm  <=  'h0;
        o_lvds3_pad_ctrl_tx_lvds_pad_txdrv  <=  'h0;
        o_lvds3_pad_ctrl_tx_lvds_pad_bias_en<=  'h1;
        o_lvds3_pad_ctrl_rx_lvds_pad_inv_cp <=  'h0;
        o_lvds3_pad_ctrl_rx_lvds_pad_bias_en<=  'h1;
        o_lvds3_pad_ctrl_rx_lvds_pad_rterm_en<=  'h0;
        o_lvds3_pad_ctrl_rx_lvds_pad_rterm_val<=  'h0;
        o_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en<=  'h0;
        o_rx3_delay_chain_ctrl0_val         <=  'h0;
        o_rx3_delay_chain_ctrl1_val         <=  'h0;
        o_rx3_delay_chain_ctrl2_val         <=  'h0;
        o_rx3_delay_chain_ctrl3_val         <=  'h0;
        o_lvds0_calib_rx_bit_clk_inv_sel    <=  'h0;
        o_lvds0_calib_rx_cal_mode_en        <=  'h0;
        o_lvds0_calib_auto_calib_en         <=  'h0;
        o_lvds0_calib_tx_cal_mode_en        <=  'h0;
        o_lvds0_calib_start_calib_dly       <=  'h16;
        o_lvds0_calib_extra_dly             <=  'h100;
        o_lvds0_cal_mode_pat_val            <=  'h155;
        o_lvds1_calib_rx_bit_clk_inv_sel    <=  'h0;
        o_lvds1_calib_rx_cal_mode_en        <=  'h0;
        o_lvds1_calib_auto_calib_en         <=  'h0;
        o_lvds1_calib_tx_cal_mode_en        <=  'h0;
        o_lvds1_calib_start_calib_dly       <=  'h16;
        o_lvds1_calib_extra_dly             <=  'h100;
        o_lvds1_cal_mode_pat_val            <=  'h155;
        o_lvds2_calib_rx_bit_clk_inv_sel    <=  'h0;
        o_lvds2_calib_rx_cal_mode_en        <=  'h0;
        o_lvds2_calib_auto_calib_en         <=  'h0;
        o_lvds2_calib_tx_cal_mode_en        <=  'h0;
        o_lvds2_calib_start_calib_dly       <=  'h16;
        o_lvds2_calib_extra_dly             <=  'h100;
        o_lvds2_cal_mode_pat_val            <=  'h155;
        o_lvds3_calib_rx_bit_clk_inv_sel    <=  'h0;
        o_lvds3_calib_rx_cal_mode_en        <=  'h0;
        o_lvds3_calib_auto_calib_en         <=  'h0;
        o_lvds3_calib_tx_cal_mode_en        <=  'h0;
        o_lvds3_calib_start_calib_dly       <=  'h16;
        o_lvds3_calib_extra_dly             <=  'h100;
        o_lvds3_cal_mode_pat_val            <=  'h155;
        o_err_mask_rx0_dec_err_mask         <=  'h1;
        o_err_mask_rx0_pkt_c_err_mask       <=  'h1;
        o_err_mask_rx0_pkt_nc_err_mask      <=  'h1;
        o_err_mask_rx1_dec_err_mask         <=  'h1;
        o_err_mask_rx1_pkt_c_err_mask       <=  'h1;
        o_err_mask_rx1_pkt_nc_err_mask      <=  'h1;
        o_err_mask_rx2_dec_err_mask         <=  'h1;
        o_err_mask_rx2_pkt_c_err_mask       <=  'h1;
        o_err_mask_rx2_pkt_nc_err_mask      <=  'h1;
        o_err_mask_rx3_dec_err_mask         <=  'h1;
        o_err_mask_rx3_pkt_c_err_mask       <=  'h1;
        o_err_mask_rx3_pkt_nc_err_mask      <=  'h1;
        o_err_st_rx0_dec_err                <=  'h0;
        o_err_st_rx0_pkt_c_err              <=  'h0;
        o_err_st_rx0_pkt_nc_err             <=  'h0;
        o_err_st_rx1_dec_err                <=  'h0;
        o_err_st_rx1_pkt_c_err              <=  'h0;
        o_err_st_rx1_pkt_nc_err             <=  'h0;
        o_err_st_rx2_dec_err                <=  'h0;
        o_err_st_rx2_pkt_c_err              <=  'h0;
        o_err_st_rx2_pkt_nc_err             <=  'h0;
        o_err_st_rx3_dec_err                <=  'h0;
        o_err_st_rx3_pkt_c_err              <=  'h0;
        o_err_st_rx3_pkt_nc_err             <=  'h0;
        o_dbg0_rx_ctrl_rx_en                <=  'h0;
        o_dbg0_tx_ctrl_ser_en               <=  'h0;
        o_dbg0_tx_ctrl_der_en               <=  'h0;
        o_dbg0_tx_ctrl_tx_start             <=  'h0;
        o_dbg0_tx_ctrl_tx_en                <=  'h0;
        o_dbg0_tx_ctrl_prbs_tx_en           <=  'h0;
        o_dbg1_tx_ctrl_prbs_tx_en           <=  'h0;
        o_dbg2_tx_ctrl_prbs_tx_en           <=  'h0;
        o_dbg0_tx_ctrl_tx_num               <=  'h0;
        o_dbg0_tx_data_val                  <=  'h0;
        o_dbg1_rx_ctrl_rx_en                <=  'h0;
        o_dbg1_tx_ctrl_ser_en               <=  'h0;
        o_dbg1_tx_ctrl_der_en               <=  'h0;
        o_dbg1_tx_ctrl_tx_start             <=  'h0;
        o_dbg1_tx_ctrl_tx_en                <=  'h0;
        o_dbg1_tx_ctrl_tx_num               <=  'h0;
        o_dbg1_tx_data_val                  <=  'h0;
        o_dbg2_rx_ctrl_rx_en                <=  'h0;
        o_dbg2_tx_ctrl_ser_en               <=  'h0;
        o_dbg2_tx_ctrl_der_en               <=  'h0;
        o_dbg2_tx_ctrl_tx_start             <=  'h0;
        o_dbg2_tx_ctrl_tx_en                <=  'h0;
        o_dbg2_tx_ctrl_tx_num               <=  'h0;
        o_dbg2_tx_data_val                  <=  'h0;
        o_dbg3_rx_ctrl_rx_en                <=  'h0;
        o_dbg3_tx_ctrl_ser_en               <=  'h0;
        o_dbg3_tx_ctrl_der_en               <=  'h0;
        o_dbg3_tx_ctrl_tx_start             <=  'h0;
        o_dbg3_tx_ctrl_tx_en                <=  'h0;
        o_dbg3_tx_ctrl_tx_num               <=  'h0;
        o_dbg3_tx_data_val                  <=  'h0;

    end
    else if(apb_psel&apb_penable&apb_pwrite&~apb_pready) begin
        case(apb_paddr)
        CTRL_OFFSET_ADDR: begin
            o_ctrl_dis_parallel_tx              <= apb_pwdata[0];
            o_ctrl_dis_parallel_rx              <= apb_pwdata[1];
            o_send_mode                         <= apb_pwdata[2];
        end
        LVDS0_CTRL_OFFSET_ADDR: begin
            o_lvds0_ctrl_tx_rstn                <= apb_pwdata[0];
            o_lvds0_ctrl_tx_lvds_ctrl_en        <= apb_pwdata[1];
            o_lvds0_ctrl_rx_rstn                <= apb_pwdata[2];
            o_lvds0_ctrl_rx_lvds_ctrl_en        <= apb_pwdata[3];
            o_lvds0_ctrl_tx_auto_sleep_en       <= apb_pwdata[4];
            o_lvds0_ctrl_rx_lvds_data_wr_wm     <= apb_pwdata[9:5];
            o_lvds0_ctrl_rx_lvds_data_rd_wm     <= apb_pwdata[14:10];
            o_lvds0_ctrl_rx_ecc_correct         <= apb_pwdata[15];
        end
        LVDS0_PAD_CTRL_OFFSET_ADDR: begin
            o_lvds0_pad_ctrl_tx_lvds_pad_inv_cp <= apb_pwdata[0];
            o_lvds0_pad_ctrl_tx_lvds_pad_tx_cm  <= apb_pwdata[1];
            o_lvds0_pad_ctrl_tx_lvds_pad_txdrv  <= apb_pwdata[5:2];
            o_lvds0_pad_ctrl_tx_lvds_pad_bias_en<= apb_pwdata[6];
            o_lvds0_pad_ctrl_rx_lvds_pad_inv_cp <= apb_pwdata[7];
            o_lvds0_pad_ctrl_rx_lvds_pad_bias_en<= apb_pwdata[8];
            o_lvds0_pad_ctrl_rx_lvds_pad_rterm_en<= apb_pwdata[9];
            o_lvds0_pad_ctrl_rx_lvds_pad_rterm_val<= apb_pwdata[12:10];
            o_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en<= apb_pwdata[13];
        end
        RX0_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            o_rx0_delay_chain_ctrl0_val         <= apb_pwdata[31:0];
        end
        RX0_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            o_rx0_delay_chain_ctrl1_val         <= apb_pwdata[31:0];
        end
        RX0_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            o_rx0_delay_chain_ctrl2_val         <= apb_pwdata[31:0];
        end
        RX0_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            o_rx0_delay_chain_ctrl3_val         <= apb_pwdata[31:0];
        end
        LVDS1_CTRL_OFFSET_ADDR: begin
            o_lvds1_ctrl_tx_rstn                <= apb_pwdata[0];
            o_lvds1_ctrl_tx_lvds_ctrl_en        <= apb_pwdata[1];
            o_lvds1_ctrl_rx_rstn                <= apb_pwdata[2];
            o_lvds1_ctrl_rx_lvds_ctrl_en        <= apb_pwdata[3];
            o_lvds1_ctrl_tx_auto_sleep_en       <= apb_pwdata[4];
            o_lvds1_ctrl_rx_lvds_data_wr_wm     <= apb_pwdata[9:5];
            o_lvds1_ctrl_rx_lvds_data_rd_wm     <= apb_pwdata[14:10];
            o_lvds1_ctrl_rx_ecc_correct         <= apb_pwdata[15];
        end
        LVDS1_PAD_CTRL_OFFSET_ADDR: begin
            o_lvds1_pad_ctrl_tx_lvds_pad_inv_cp <= apb_pwdata[0];
            o_lvds1_pad_ctrl_tx_lvds_pad_tx_cm  <= apb_pwdata[1];
            o_lvds1_pad_ctrl_tx_lvds_pad_txdrv  <= apb_pwdata[5:2];
            o_lvds1_pad_ctrl_tx_lvds_pad_bias_en<= apb_pwdata[6];
            o_lvds1_pad_ctrl_rx_lvds_pad_inv_cp <= apb_pwdata[7];
            o_lvds1_pad_ctrl_rx_lvds_pad_bias_en<= apb_pwdata[8];
            o_lvds1_pad_ctrl_rx_lvds_pad_rterm_en<= apb_pwdata[9];
            o_lvds1_pad_ctrl_rx_lvds_pad_rterm_val<= apb_pwdata[12:10];
            o_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en<= apb_pwdata[13];
        end
        RX1_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            o_rx1_delay_chain_ctrl0_val         <= apb_pwdata[31:0];
        end
        RX1_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            o_rx1_delay_chain_ctrl1_val         <= apb_pwdata[31:0];
        end
        RX1_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            o_rx1_delay_chain_ctrl2_val         <= apb_pwdata[31:0];
        end
        RX1_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            o_rx1_delay_chain_ctrl3_val         <= apb_pwdata[31:0];
        end
        LVDS2_CTRL_OFFSET_ADDR: begin
            o_lvds2_ctrl_tx_rstn                <= apb_pwdata[0];
            o_lvds2_ctrl_tx_lvds_ctrl_en        <= apb_pwdata[1];
            o_lvds2_ctrl_rx_rstn                <= apb_pwdata[2];
            o_lvds2_ctrl_rx_lvds_ctrl_en        <= apb_pwdata[3];
            o_lvds2_ctrl_tx_auto_sleep_en       <= apb_pwdata[4];
            o_lvds2_ctrl_rx_lvds_data_wr_wm     <= apb_pwdata[9:5];
            o_lvds2_ctrl_rx_lvds_data_rd_wm     <= apb_pwdata[14:10];
            o_lvds2_ctrl_rx_ecc_correct         <= apb_pwdata[15];
        end
        LVDS2_PAD_CTRL_OFFSET_ADDR: begin
            o_lvds2_pad_ctrl_tx_lvds_pad_inv_cp <= apb_pwdata[0];
            o_lvds2_pad_ctrl_tx_lvds_pad_tx_cm  <= apb_pwdata[1];
            o_lvds2_pad_ctrl_tx_lvds_pad_txdrv  <= apb_pwdata[5:2];
            o_lvds2_pad_ctrl_tx_lvds_pad_bias_en<= apb_pwdata[6];
            o_lvds2_pad_ctrl_rx_lvds_pad_inv_cp <= apb_pwdata[7];
            o_lvds2_pad_ctrl_rx_lvds_pad_bias_en<= apb_pwdata[8];
            o_lvds2_pad_ctrl_rx_lvds_pad_rterm_en<= apb_pwdata[9];
            o_lvds2_pad_ctrl_rx_lvds_pad_rterm_val<= apb_pwdata[12:10];
            o_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en<= apb_pwdata[13];
        end
        RX2_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            o_rx2_delay_chain_ctrl0_val         <= apb_pwdata[31:0];
        end
        RX2_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            o_rx2_delay_chain_ctrl1_val         <= apb_pwdata[31:0];
        end
        RX2_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            o_rx2_delay_chain_ctrl2_val         <= apb_pwdata[31:0];
        end
        RX2_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            o_rx2_delay_chain_ctrl3_val         <= apb_pwdata[31:0];
        end
        LVDS3_CTRL_OFFSET_ADDR: begin
            o_lvds3_ctrl_tx_rstn                <= apb_pwdata[0];
            o_lvds3_ctrl_tx_lvds_ctrl_en        <= apb_pwdata[1];
            o_lvds3_ctrl_rx_rstn                <= apb_pwdata[2];
            o_lvds3_ctrl_rx_lvds_ctrl_en        <= apb_pwdata[3];
            o_lvds3_ctrl_tx_auto_sleep_en       <= apb_pwdata[4];
            o_lvds3_ctrl_rx_lvds_data_wr_wm     <= apb_pwdata[9:5];
            o_lvds3_ctrl_rx_lvds_data_rd_wm     <= apb_pwdata[14:10];
            o_lvds3_ctrl_rx_ecc_correct         <= apb_pwdata[15];
        end
        LVDS3_PAD_CTRL_OFFSET_ADDR: begin
            o_lvds3_pad_ctrl_tx_lvds_pad_inv_cp <= apb_pwdata[0];
            o_lvds3_pad_ctrl_tx_lvds_pad_tx_cm  <= apb_pwdata[1];
            o_lvds3_pad_ctrl_tx_lvds_pad_txdrv  <= apb_pwdata[5:2];
            o_lvds3_pad_ctrl_tx_lvds_pad_bias_en<= apb_pwdata[6];
            o_lvds3_pad_ctrl_rx_lvds_pad_inv_cp <= apb_pwdata[7];
            o_lvds3_pad_ctrl_rx_lvds_pad_bias_en<= apb_pwdata[8];
            o_lvds3_pad_ctrl_rx_lvds_pad_rterm_en<= apb_pwdata[9];
            o_lvds3_pad_ctrl_rx_lvds_pad_rterm_val<= apb_pwdata[12:10];
            o_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en<= apb_pwdata[13];
        end
        RX3_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            o_rx3_delay_chain_ctrl0_val         <= apb_pwdata[31:0];
        end
        RX3_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            o_rx3_delay_chain_ctrl1_val         <= apb_pwdata[31:0];
        end
        RX3_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            o_rx3_delay_chain_ctrl2_val         <= apb_pwdata[31:0];
        end
        RX3_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            o_rx3_delay_chain_ctrl3_val         <= apb_pwdata[31:0];
        end
        LVDS0_CALIB_OFFSET_ADDR: begin
            o_lvds0_calib_rx_bit_clk_inv_sel    <= apb_pwdata[0];
            o_lvds0_calib_rx_cal_mode_en        <= apb_pwdata[1];
            o_lvds0_calib_auto_calib_en         <= apb_pwdata[2];
            o_lvds0_calib_tx_cal_mode_en        <= apb_pwdata[4];
            o_lvds0_calib_start_calib_dly       <= apb_pwdata[15:8];
            o_lvds0_calib_extra_dly             <= apb_pwdata[31:16];
        end
        LVDS0_CAL_MODE_PAT_OFFSET_ADDR: begin
            o_lvds0_cal_mode_pat_val            <= apb_pwdata[9:0];
        end
        LVDS1_CALIB_OFFSET_ADDR: begin
            o_lvds1_calib_rx_bit_clk_inv_sel    <= apb_pwdata[0];
            o_lvds1_calib_rx_cal_mode_en        <= apb_pwdata[1];
            o_lvds1_calib_auto_calib_en         <= apb_pwdata[2];
            o_lvds1_calib_tx_cal_mode_en        <= apb_pwdata[4];
            o_lvds1_calib_start_calib_dly       <= apb_pwdata[15:8];
            o_lvds1_calib_extra_dly             <= apb_pwdata[31:16];
        end
        LVDS1_CAL_MODE_PAT_OFFSET_ADDR: begin
            o_lvds1_cal_mode_pat_val            <= apb_pwdata[9:0];
        end
        LVDS2_CALIB_OFFSET_ADDR: begin
            o_lvds2_calib_rx_bit_clk_inv_sel    <= apb_pwdata[0];
            o_lvds2_calib_rx_cal_mode_en        <= apb_pwdata[1];
            o_lvds2_calib_auto_calib_en         <= apb_pwdata[2];
            o_lvds2_calib_tx_cal_mode_en        <= apb_pwdata[4];
            o_lvds2_calib_start_calib_dly       <= apb_pwdata[15:8];
            o_lvds2_calib_extra_dly             <= apb_pwdata[31:16];
        end
        LVDS2_CAL_MODE_PAT_OFFSET_ADDR: begin
            o_lvds2_cal_mode_pat_val            <= apb_pwdata[9:0];
        end
        LVDS3_CALIB_OFFSET_ADDR: begin
            o_lvds3_calib_rx_bit_clk_inv_sel    <= apb_pwdata[0];
            o_lvds3_calib_rx_cal_mode_en        <= apb_pwdata[1];
            o_lvds3_calib_auto_calib_en         <= apb_pwdata[2];
            o_lvds3_calib_tx_cal_mode_en        <= apb_pwdata[4];
            o_lvds3_calib_start_calib_dly       <= apb_pwdata[15:8];
            o_lvds3_calib_extra_dly             <= apb_pwdata[31:16];
        end
        LVDS3_CAL_MODE_PAT_OFFSET_ADDR: begin
            o_lvds3_cal_mode_pat_val            <= apb_pwdata[9:0];
        end
        ERR_MASK_OFFSET_ADDR: begin
            o_err_mask_rx0_dec_err_mask         <= apb_pwdata[0];
            o_err_mask_rx0_pkt_c_err_mask       <= apb_pwdata[1];
            o_err_mask_rx0_pkt_nc_err_mask      <= apb_pwdata[2];
            o_err_mask_rx1_dec_err_mask         <= apb_pwdata[3];
            o_err_mask_rx1_pkt_c_err_mask       <= apb_pwdata[4];
            o_err_mask_rx1_pkt_nc_err_mask      <= apb_pwdata[5];
            o_err_mask_rx2_dec_err_mask         <= apb_pwdata[6];
            o_err_mask_rx2_pkt_c_err_mask       <= apb_pwdata[7];
            o_err_mask_rx2_pkt_nc_err_mask      <= apb_pwdata[8];
            o_err_mask_rx3_dec_err_mask         <= apb_pwdata[9];
            o_err_mask_rx3_pkt_c_err_mask       <= apb_pwdata[10];
            o_err_mask_rx3_pkt_nc_err_mask      <= apb_pwdata[11];
        end
        ERR_ST_OFFSET_ADDR: begin
            o_err_st_rx0_dec_err                <= apb_pwdata[0]  ? 1'b0 : o_err_st_rx0_dec_err;
            o_err_st_rx0_pkt_c_err              <= apb_pwdata[1]  ? 1'b0 : o_err_st_rx0_pkt_c_err;
            o_err_st_rx0_pkt_nc_err             <= apb_pwdata[2]  ? 1'b0 : o_err_st_rx0_pkt_nc_err;
            o_err_st_rx1_dec_err                <= apb_pwdata[3]  ? 1'b0 : o_err_st_rx1_dec_err;
            o_err_st_rx1_pkt_c_err              <= apb_pwdata[4]  ? 1'b0 : o_err_st_rx1_pkt_c_err;
            o_err_st_rx1_pkt_nc_err             <= apb_pwdata[5]  ? 1'b0 : o_err_st_rx1_pkt_nc_err;
            o_err_st_rx2_dec_err                <= apb_pwdata[6]  ? 1'b0 : o_err_st_rx2_dec_err;
            o_err_st_rx2_pkt_c_err              <= apb_pwdata[7]  ? 1'b0 : o_err_st_rx2_pkt_c_err;
            o_err_st_rx2_pkt_nc_err             <= apb_pwdata[8]  ? 1'b0 : o_err_st_rx2_pkt_nc_err;
            o_err_st_rx3_dec_err                <= apb_pwdata[9]  ? 1'b0 : o_err_st_rx3_dec_err;
            o_err_st_rx3_pkt_c_err              <= apb_pwdata[10] ? 1'b0 : o_err_st_rx3_pkt_c_err;
            o_err_st_rx3_pkt_nc_err             <= apb_pwdata[11] ? 1'b0 : o_err_st_rx3_pkt_nc_err;
        end

        DBG0_RX_CTRL_OFFSET_ADDR: begin
            o_dbg0_rx_ctrl_rx_en                <= apb_pwdata[0];
        end
        DBG0_TX_CTRL_OFFSET_ADDR: begin
            o_dbg0_tx_ctrl_ser_en               <= apb_pwdata[0];
            o_dbg0_tx_ctrl_der_en               <= apb_pwdata[1];
            o_dbg0_tx_ctrl_tx_start             <= apb_pwdata[2];
            o_dbg0_tx_ctrl_tx_en                <= apb_pwdata[3];
            o_dbg0_tx_ctrl_prbs_tx_en           <= apb_pwdata[4];
            o_dbg0_tx_ctrl_tx_num               <= apb_pwdata[18:8];
        end
        DBG0_TX_DATA_OFFSET_ADDR: begin
            o_dbg0_tx_data_val                  <= apb_pwdata[31:0];
        end
        DBG1_RX_CTRL_OFFSET_ADDR: begin
            o_dbg1_rx_ctrl_rx_en                <= apb_pwdata[0];
        end
        DBG1_TX_CTRL_OFFSET_ADDR: begin
            o_dbg1_tx_ctrl_ser_en               <= apb_pwdata[0];
            o_dbg1_tx_ctrl_der_en               <= apb_pwdata[1];
            o_dbg1_tx_ctrl_tx_start             <= apb_pwdata[2];
            o_dbg1_tx_ctrl_tx_en                <= apb_pwdata[3];
            o_dbg1_tx_ctrl_prbs_tx_en           <= apb_pwdata[4];
            o_dbg1_tx_ctrl_tx_num               <= apb_pwdata[18:8];
        end
        DBG1_TX_DATA_OFFSET_ADDR: begin
            o_dbg1_tx_data_val                  <= apb_pwdata[31:0];
        end
        DBG2_RX_CTRL_OFFSET_ADDR: begin
            o_dbg2_rx_ctrl_rx_en                <= apb_pwdata[0];
        end
        DBG2_TX_CTRL_OFFSET_ADDR: begin
            o_dbg2_tx_ctrl_ser_en               <= apb_pwdata[0];
            o_dbg2_tx_ctrl_der_en               <= apb_pwdata[1];
            o_dbg2_tx_ctrl_tx_start             <= apb_pwdata[2];
            o_dbg2_tx_ctrl_tx_en                <= apb_pwdata[3];
            o_dbg2_tx_ctrl_prbs_tx_en           <= apb_pwdata[4];
            o_dbg2_tx_ctrl_tx_num               <= apb_pwdata[18:8];
        end
        DBG2_TX_DATA_OFFSET_ADDR: begin
            o_dbg2_tx_data_val                  <= apb_pwdata[31:0];
        end
        DBG3_RX_CTRL_OFFSET_ADDR: begin
            o_dbg3_rx_ctrl_rx_en                <= apb_pwdata[0];
        end
        DBG3_TX_CTRL_OFFSET_ADDR: begin
            o_dbg3_tx_ctrl_ser_en               <= apb_pwdata[0];
            o_dbg3_tx_ctrl_der_en               <= apb_pwdata[1];
            o_dbg3_tx_ctrl_tx_start             <= apb_pwdata[2];
            o_dbg3_tx_ctrl_tx_en                <= apb_pwdata[3];
            o_dbg3_tx_ctrl_tx_num               <= apb_pwdata[18:8];
        end
        DBG3_TX_DATA_OFFSET_ADDR: begin
            o_dbg3_tx_data_val                  <= apb_pwdata[31:0];
        end

        default:wr_err<= 1;
        endcase
    end
    else begin
            wr_err                              <= 0;

        if(i_err_st_rx0_dec_err_pos)
            o_err_st_rx0_dec_err                <= 1'b1;

        if(i_err_st_rx0_pkt_c_err_pos)
            o_err_st_rx0_pkt_c_err              <= 1'b1;

        if(i_err_st_rx0_pkt_nc_err_pos)
            o_err_st_rx0_pkt_nc_err             <= 1'b1;

        if(i_err_st_rx1_dec_err_pos)
            o_err_st_rx1_dec_err                <= 1'b1;

        if(i_err_st_rx1_pkt_c_err_pos)
            o_err_st_rx1_pkt_c_err              <= 1'b1;

        if(i_err_st_rx1_pkt_nc_err_pos)
            o_err_st_rx1_pkt_nc_err             <= 1'b1;

        if(i_err_st_rx2_dec_err_pos)
            o_err_st_rx2_dec_err                <= 1'b1;

        if(i_err_st_rx2_pkt_c_err_pos)
            o_err_st_rx2_pkt_c_err              <= 1'b1;

        if(i_err_st_rx2_pkt_nc_err_pos)
            o_err_st_rx2_pkt_nc_err             <= 1'b1;

        if(i_err_st_rx3_dec_err_pos)
            o_err_st_rx3_dec_err                <= 1'b1;

        if(i_err_st_rx3_pkt_c_err_pos)
            o_err_st_rx3_pkt_c_err              <= 1'b1;

        if(i_err_st_rx3_pkt_nc_err_pos)
            o_err_st_rx3_pkt_nc_err             <= 1'b1;


        if(csr_rx0_cal_up_req_pos) begin
            case(csr_rx0_cal_lane_num)
                5'd0:
                    o_rx0_delay_chain_ctrl0_val[0*8+:8] <= csr_rx0_cal_up_val;
                5'd1:
                    o_rx0_delay_chain_ctrl0_val[1*8+:8] <= csr_rx0_cal_up_val;
                5'd2:
                    o_rx0_delay_chain_ctrl0_val[2*8+:8] <= csr_rx0_cal_up_val;
                5'd3:
                    o_rx0_delay_chain_ctrl0_val[3*8+:8] <= csr_rx0_cal_up_val;
                5'd4:
                    o_rx0_delay_chain_ctrl1_val[0*8+:8] <= csr_rx0_cal_up_val;
                5'd31:
                    o_rx0_delay_chain_ctrl1_val[1*16+:16]<= {csr_rx0_cal_up_val,csr_rx0_cal_up_val};
            endcase
        end
        
        if(csr_rx1_cal_up_req_pos) begin
            case(csr_rx1_cal_lane_num)
                5'd0:
                    o_rx1_delay_chain_ctrl0_val[0*8+:8] <= csr_rx1_cal_up_val;
                5'd1:
                    o_rx1_delay_chain_ctrl0_val[1*8+:8] <= csr_rx1_cal_up_val;
                5'd2:
                    o_rx1_delay_chain_ctrl0_val[2*8+:8] <= csr_rx1_cal_up_val;
                5'd3:
                    o_rx1_delay_chain_ctrl0_val[3*8+:8] <= csr_rx1_cal_up_val;
                5'd4:
                    o_rx1_delay_chain_ctrl1_val[0*8+:8] <= csr_rx1_cal_up_val;
                5'd31:
                    o_rx1_delay_chain_ctrl1_val[1*16+:16]<= {csr_rx1_cal_up_val,csr_rx1_cal_up_val};
            endcase
        end
        
        if(csr_rx2_cal_up_req_pos) begin
            case(csr_rx2_cal_lane_num)
                5'd0:
                    o_rx2_delay_chain_ctrl0_val[0*8+:8] <= csr_rx2_cal_up_val;
                5'd1:
                    o_rx2_delay_chain_ctrl0_val[1*8+:8] <= csr_rx2_cal_up_val;
                5'd2:
                    o_rx2_delay_chain_ctrl0_val[2*8+:8] <= csr_rx2_cal_up_val;
                5'd3:
                    o_rx2_delay_chain_ctrl0_val[3*8+:8] <= csr_rx2_cal_up_val;
                5'd4:
                    o_rx2_delay_chain_ctrl1_val[0*8+:8] <= csr_rx2_cal_up_val;
                5'd31:
                    o_rx2_delay_chain_ctrl1_val[1*16+:16]<= {csr_rx2_cal_up_val,csr_rx2_cal_up_val};
            endcase
        end
        
        if(csr_rx3_cal_up_req_pos) begin
            case(csr_rx3_cal_lane_num)
                5'd0:
                    o_rx3_delay_chain_ctrl0_val[0*8+:8] <= csr_rx3_cal_up_val;
                5'd1:
                    o_rx3_delay_chain_ctrl0_val[1*8+:8] <= csr_rx3_cal_up_val;
                5'd2:
                    o_rx3_delay_chain_ctrl0_val[2*8+:8] <= csr_rx3_cal_up_val;
                5'd3:
                    o_rx3_delay_chain_ctrl0_val[3*8+:8] <= csr_rx3_cal_up_val;
                5'd4:
                    o_rx3_delay_chain_ctrl1_val[0*8+:8] <= csr_rx3_cal_up_val;
                5'd31:
                    o_rx3_delay_chain_ctrl1_val[1*16+:16]<= {csr_rx3_cal_up_val,csr_rx3_cal_up_val};
            endcase
        end

    end
 end

always @(posedge apb_pclk or negedge apb_presetn) begin
    if(!apb_presetn) begin
        apb_prdata                          <= 0;
        rd_err                              <= 0;
    end
    else if(apb_psel&apb_penable&~apb_pwrite&~apb_pready) begin
        case(apb_paddr)
        CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_ctrl_dis_parallel_tx;
            apb_prdata[1]                       <= o_ctrl_dis_parallel_rx;
            apb_prdata[2]                       <= o_send_mode;
            apb_prdata[31:3]                    <=  'h0;
        end
        LVDS0_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds0_ctrl_tx_rstn;
            apb_prdata[1]                       <= o_lvds0_ctrl_tx_lvds_ctrl_en;
            apb_prdata[2]                       <= o_lvds0_ctrl_rx_rstn;
            apb_prdata[3]                       <= o_lvds0_ctrl_rx_lvds_ctrl_en;
            apb_prdata[4]                       <= o_lvds0_ctrl_tx_auto_sleep_en;
            apb_prdata[9:5]                     <= o_lvds0_ctrl_rx_lvds_data_wr_wm;
            apb_prdata[14:10]                   <= o_lvds0_ctrl_rx_lvds_data_rd_wm;
            apb_prdata[15]                      <= o_lvds0_ctrl_rx_ecc_correct;
            apb_prdata[31:16]                   <=  'h0;
        end
        LVDS0_PAD_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds0_pad_ctrl_tx_lvds_pad_inv_cp;
            apb_prdata[1]                       <= o_lvds0_pad_ctrl_tx_lvds_pad_tx_cm;
            apb_prdata[5:2]                     <= o_lvds0_pad_ctrl_tx_lvds_pad_txdrv;
            apb_prdata[6]                       <= o_lvds0_pad_ctrl_tx_lvds_pad_bias_en;
            apb_prdata[7]                       <= o_lvds0_pad_ctrl_rx_lvds_pad_inv_cp;
            apb_prdata[8]                       <= o_lvds0_pad_ctrl_rx_lvds_pad_bias_en;
            apb_prdata[9]                       <= o_lvds0_pad_ctrl_rx_lvds_pad_rterm_en;
            apb_prdata[12:10]                   <= o_lvds0_pad_ctrl_rx_lvds_pad_rterm_val;
            apb_prdata[13]                      <= o_lvds0_pad_ctrl_rx_lvds_pad_rxcm_en;
            apb_prdata[31:14]                   <=  'h0;
        end
        RX0_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx0_delay_chain_ctrl0_val;
        end
        RX0_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx0_delay_chain_ctrl1_val;
        end
        RX0_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx0_delay_chain_ctrl2_val;
        end
        RX0_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx0_delay_chain_ctrl3_val;
        end
        LVDS1_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds1_ctrl_tx_rstn;
            apb_prdata[1]                       <= o_lvds1_ctrl_tx_lvds_ctrl_en;
            apb_prdata[2]                       <= o_lvds1_ctrl_rx_rstn;
            apb_prdata[3]                       <= o_lvds1_ctrl_rx_lvds_ctrl_en;
            apb_prdata[4]                       <= o_lvds1_ctrl_tx_auto_sleep_en;
            apb_prdata[9:5]                     <= o_lvds1_ctrl_rx_lvds_data_wr_wm;
            apb_prdata[14:10]                   <= o_lvds1_ctrl_rx_lvds_data_rd_wm;
            apb_prdata[15]                      <= o_lvds1_ctrl_rx_ecc_correct;
            apb_prdata[31:16]                   <=  'h0;
        end
        LVDS1_PAD_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds1_pad_ctrl_tx_lvds_pad_inv_cp;
            apb_prdata[1]                       <= o_lvds1_pad_ctrl_tx_lvds_pad_tx_cm;
            apb_prdata[5:2]                     <= o_lvds1_pad_ctrl_tx_lvds_pad_txdrv;
            apb_prdata[6]                       <= o_lvds1_pad_ctrl_tx_lvds_pad_bias_en;
            apb_prdata[7]                       <= o_lvds1_pad_ctrl_rx_lvds_pad_inv_cp;
            apb_prdata[8]                       <= o_lvds1_pad_ctrl_rx_lvds_pad_bias_en;
            apb_prdata[9]                       <= o_lvds1_pad_ctrl_rx_lvds_pad_rterm_en;
            apb_prdata[12:10]                   <= o_lvds1_pad_ctrl_rx_lvds_pad_rterm_val;
            apb_prdata[13]                      <= o_lvds1_pad_ctrl_rx_lvds_pad_rxcm_en;
            apb_prdata[31:14]                   <=  'h0;
        end
        RX1_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx1_delay_chain_ctrl0_val;
        end
        RX1_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx1_delay_chain_ctrl1_val;
        end
        RX1_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx1_delay_chain_ctrl2_val;
        end
        RX1_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx1_delay_chain_ctrl3_val;
        end
        LVDS2_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds2_ctrl_tx_rstn;
            apb_prdata[1]                       <= o_lvds2_ctrl_tx_lvds_ctrl_en;
            apb_prdata[2]                       <= o_lvds2_ctrl_rx_rstn;
            apb_prdata[3]                       <= o_lvds2_ctrl_rx_lvds_ctrl_en;
            apb_prdata[4]                       <= o_lvds2_ctrl_tx_auto_sleep_en;
            apb_prdata[9:5]                     <= o_lvds2_ctrl_rx_lvds_data_wr_wm;
            apb_prdata[14:10]                   <= o_lvds2_ctrl_rx_lvds_data_rd_wm;
            apb_prdata[15]                      <= o_lvds2_ctrl_rx_ecc_correct;
            apb_prdata[31:16]                   <=  'h0;
        end
        LVDS2_PAD_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds2_pad_ctrl_tx_lvds_pad_inv_cp;
            apb_prdata[1]                       <= o_lvds2_pad_ctrl_tx_lvds_pad_tx_cm;
            apb_prdata[5:2]                     <= o_lvds2_pad_ctrl_tx_lvds_pad_txdrv;
            apb_prdata[6]                       <= o_lvds2_pad_ctrl_tx_lvds_pad_bias_en;
            apb_prdata[7]                       <= o_lvds2_pad_ctrl_rx_lvds_pad_inv_cp;
            apb_prdata[8]                       <= o_lvds2_pad_ctrl_rx_lvds_pad_bias_en;
            apb_prdata[9]                       <= o_lvds2_pad_ctrl_rx_lvds_pad_rterm_en;
            apb_prdata[12:10]                   <= o_lvds2_pad_ctrl_rx_lvds_pad_rterm_val;
            apb_prdata[13]                      <= o_lvds2_pad_ctrl_rx_lvds_pad_rxcm_en;
            apb_prdata[31:14]                   <=  'h0;
        end
        RX2_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx2_delay_chain_ctrl0_val;
        end
        RX2_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx2_delay_chain_ctrl1_val;
        end
        RX2_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx2_delay_chain_ctrl2_val;
        end
        RX2_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx2_delay_chain_ctrl3_val;
        end
        LVDS3_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds3_ctrl_tx_rstn;
            apb_prdata[1]                       <= o_lvds3_ctrl_tx_lvds_ctrl_en;
            apb_prdata[2]                       <= o_lvds3_ctrl_rx_rstn;
            apb_prdata[3]                       <= o_lvds3_ctrl_rx_lvds_ctrl_en;
            apb_prdata[4]                       <= o_lvds3_ctrl_tx_auto_sleep_en;
            apb_prdata[9:5]                     <= o_lvds3_ctrl_rx_lvds_data_wr_wm;
            apb_prdata[14:10]                   <= o_lvds3_ctrl_rx_lvds_data_rd_wm;
            apb_prdata[15]                      <= o_lvds3_ctrl_rx_ecc_correct;
            apb_prdata[31:16]                   <=  'h0;
        end
        LVDS3_PAD_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds3_pad_ctrl_tx_lvds_pad_inv_cp;
            apb_prdata[1]                       <= o_lvds3_pad_ctrl_tx_lvds_pad_tx_cm;
            apb_prdata[5:2]                     <= o_lvds3_pad_ctrl_tx_lvds_pad_txdrv;
            apb_prdata[6]                       <= o_lvds3_pad_ctrl_tx_lvds_pad_bias_en;
            apb_prdata[7]                       <= o_lvds3_pad_ctrl_rx_lvds_pad_inv_cp;
            apb_prdata[8]                       <= o_lvds3_pad_ctrl_rx_lvds_pad_bias_en;
            apb_prdata[9]                       <= o_lvds3_pad_ctrl_rx_lvds_pad_rterm_en;
            apb_prdata[12:10]                   <= o_lvds3_pad_ctrl_rx_lvds_pad_rterm_val;
            apb_prdata[13]                      <= o_lvds3_pad_ctrl_rx_lvds_pad_rxcm_en;
            apb_prdata[31:14]                   <=  'h0;
        end
        RX3_DELAY_CHAIN_CTRL0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx3_delay_chain_ctrl0_val;
        end
        RX3_DELAY_CHAIN_CTRL1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx3_delay_chain_ctrl1_val;
        end
        RX3_DELAY_CHAIN_CTRL2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx3_delay_chain_ctrl2_val;
        end
        RX3_DELAY_CHAIN_CTRL3_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_rx3_delay_chain_ctrl3_val;
        end
        LVDS0_CALIB_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds0_calib_rx_bit_clk_inv_sel;
            apb_prdata[1]                       <= o_lvds0_calib_rx_cal_mode_en;
            apb_prdata[2]                       <= o_lvds0_calib_auto_calib_en;
            apb_prdata[3]                       <= i_lvds0_calib_rx_cal_done_syn;
            apb_prdata[4]                       <= o_lvds0_calib_tx_cal_mode_en;
            apb_prdata[15:8]                    <= o_lvds0_calib_start_calib_dly;
            apb_prdata[31:16]                   <= o_lvds0_calib_extra_dly;
        end
        LVDS0_CAL_MODE_PAT_OFFSET_ADDR: begin
            apb_prdata[9:0]                     <= o_lvds0_cal_mode_pat_val;
            apb_prdata[31:10]                   <=  'h0;
        end
        LVDS0_MAN_READ_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_lvds0_man_read_data0_val;
        end
        LVDS0_MAN_READ_DATA1_OFFSET_ADDR: begin
            apb_prdata[27:0]                    <= i_lvds0_man_read_data1_val;
            apb_prdata[31:28]                   <=  'h0;
        end
        LVDS1_CALIB_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds1_calib_rx_bit_clk_inv_sel;
            apb_prdata[1]                       <= o_lvds1_calib_rx_cal_mode_en;
            apb_prdata[2]                       <= o_lvds1_calib_auto_calib_en;
            apb_prdata[3]                       <= i_lvds1_calib_rx_cal_done_syn;
            apb_prdata[4]                       <= o_lvds1_calib_tx_cal_mode_en;
            apb_prdata[15:8]                    <= o_lvds1_calib_start_calib_dly;
            apb_prdata[31:16]                   <= o_lvds1_calib_extra_dly;
        end
        LVDS1_CAL_MODE_PAT_OFFSET_ADDR: begin
            apb_prdata[9:0]                     <= o_lvds1_cal_mode_pat_val;
            apb_prdata[31:10]                   <=  'h0;
        end
        LVDS1_MAN_READ_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_lvds1_man_read_data0_val;
        end
        LVDS1_MAN_READ_DATA1_OFFSET_ADDR: begin
            apb_prdata[27:0]                    <= i_lvds1_man_read_data1_val;
            apb_prdata[31:28]                   <=  'h0;
        end
        LVDS2_CALIB_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds2_calib_rx_bit_clk_inv_sel;
            apb_prdata[1]                       <= o_lvds2_calib_rx_cal_mode_en;
            apb_prdata[2]                       <= o_lvds2_calib_auto_calib_en;
            apb_prdata[3]                       <= i_lvds2_calib_rx_cal_done_syn;
            apb_prdata[4]                       <= o_lvds2_calib_tx_cal_mode_en;
            apb_prdata[15:8]                    <= o_lvds2_calib_start_calib_dly;
            apb_prdata[31:16]                   <= o_lvds2_calib_extra_dly;
        end
        LVDS2_CAL_MODE_PAT_OFFSET_ADDR: begin
            apb_prdata[9:0]                     <= o_lvds2_cal_mode_pat_val;
            apb_prdata[31:10]                   <=  'h0;
        end
        LVDS2_MAN_READ_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_lvds2_man_read_data0_val;
        end
        LVDS2_MAN_READ_DATA1_OFFSET_ADDR: begin
            apb_prdata[27:0]                    <= i_lvds2_man_read_data1_val;
            apb_prdata[31:28]                   <=  'h0;
        end
        LVDS3_CALIB_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_lvds3_calib_rx_bit_clk_inv_sel;
            apb_prdata[1]                       <= o_lvds3_calib_rx_cal_mode_en;
            apb_prdata[2]                       <= o_lvds3_calib_auto_calib_en;
            apb_prdata[3]                       <= i_lvds3_calib_rx_cal_done_syn;
            apb_prdata[4]                       <= o_lvds3_calib_tx_cal_mode_en;
            apb_prdata[15:8]                    <= o_lvds3_calib_start_calib_dly;
            apb_prdata[31:16]                   <= o_lvds3_calib_extra_dly;
        end
        LVDS3_CAL_MODE_PAT_OFFSET_ADDR: begin
            apb_prdata[9:0]                     <= o_lvds3_cal_mode_pat_val;
            apb_prdata[31:10]                   <=  'h0;
        end
        LVDS3_MAN_READ_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_lvds3_man_read_data0_val;
        end
        LVDS3_MAN_READ_DATA1_OFFSET_ADDR: begin
            apb_prdata[27:0]                    <= i_lvds3_man_read_data1_val;
            apb_prdata[31:28]                   <=  'h0;
        end
        ERR_MASK_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_err_mask_rx0_dec_err_mask;
            apb_prdata[1]                       <= o_err_mask_rx0_pkt_c_err_mask;
            apb_prdata[2]                       <= o_err_mask_rx0_pkt_nc_err_mask;
            apb_prdata[3]                       <= o_err_mask_rx1_dec_err_mask;
            apb_prdata[4]                       <= o_err_mask_rx1_pkt_c_err_mask;
            apb_prdata[5]                       <= o_err_mask_rx1_pkt_nc_err_mask;
            apb_prdata[6]                       <= o_err_mask_rx2_dec_err_mask;
            apb_prdata[7]                       <= o_err_mask_rx2_pkt_c_err_mask;
            apb_prdata[8]                       <= o_err_mask_rx2_pkt_nc_err_mask;
            apb_prdata[9]                       <= o_err_mask_rx3_dec_err_mask;
            apb_prdata[10]                      <= o_err_mask_rx3_pkt_c_err_mask;
            apb_prdata[11]                      <= o_err_mask_rx3_pkt_nc_err_mask;
            apb_prdata[31:12]                   <=  'h0;
        end
        ERR_ST_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_err_st_rx0_dec_err;
            apb_prdata[1]                       <= o_err_st_rx0_pkt_c_err;
            apb_prdata[2]                       <= o_err_st_rx0_pkt_nc_err;
            apb_prdata[3]                       <= o_err_st_rx1_dec_err;
            apb_prdata[4]                       <= o_err_st_rx1_pkt_c_err;
            apb_prdata[5]                       <= o_err_st_rx1_pkt_nc_err;
            apb_prdata[6]                       <= o_err_st_rx2_dec_err;
            apb_prdata[7]                       <= o_err_st_rx2_pkt_c_err;
            apb_prdata[8]                       <= o_err_st_rx2_pkt_nc_err;
            apb_prdata[9]                       <= o_err_st_rx3_dec_err;
            apb_prdata[10]                      <= o_err_st_rx3_pkt_c_err;
            apb_prdata[11]                      <= o_err_st_rx3_pkt_nc_err;
            apb_prdata[31:12]                   <=  'h0;
        end
        DBG0_RX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg0_rx_ctrl_rx_en;
            apb_prdata[18:8]                    <= i_dbg0_rx_ctrl_rx_pkt_cnt;
            apb_prdata[19]                      <= i_dbg0_rx_ctrl_rx_pkt_equ;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG0_RX_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg0_rx_data0_val;
        end
        DBG0_RX_DATA1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg0_rx_data1_val;
        end
        DBG0_RX_DATA2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg0_rx_data2_val;
        end
        DBG0_TX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg0_tx_ctrl_ser_en;
            apb_prdata[1]                       <= o_dbg0_tx_ctrl_der_en;
            apb_prdata[2]                       <= o_dbg0_tx_ctrl_tx_start;
            apb_prdata[3]                       <= o_dbg0_tx_ctrl_tx_en;
            apb_prdata[4]                       <= o_dbg0_tx_ctrl_prbs_tx_en;
            apb_prdata[5]                       <= dbg0_tx_ctrl_prbs_rx_done;
            apb_prdata[6]                       <= i_dbg0_tx_ctrl_prbs_rx_pass_syn;
            apb_prdata[18:8]                    <= o_dbg0_tx_ctrl_tx_num;
            apb_prdata[19]                      <= i_dbg0_tx_ctrl_tx_done_syn;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG0_TX_DATA_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_dbg0_tx_data_val;
        end
        DBG1_RX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg1_rx_ctrl_rx_en;
            apb_prdata[18:8]                    <= i_dbg1_rx_ctrl_rx_pkt_cnt;
            apb_prdata[19]                      <= i_dbg1_rx_ctrl_rx_pkt_equ;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG1_RX_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg1_rx_data0_val;
        end
        DBG1_RX_DATA1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg1_rx_data1_val;
        end
        DBG1_RX_DATA2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg1_rx_data2_val;
        end
        DBG1_TX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg1_tx_ctrl_ser_en;
            apb_prdata[1]                       <= o_dbg1_tx_ctrl_der_en;
            apb_prdata[2]                       <= o_dbg1_tx_ctrl_tx_start;
            apb_prdata[3]                       <= o_dbg1_tx_ctrl_tx_en;
            apb_prdata[4]                       <= o_dbg1_tx_ctrl_prbs_tx_en;
            apb_prdata[5]                       <= dbg1_tx_ctrl_prbs_rx_done;
            apb_prdata[6]                       <= i_dbg1_tx_ctrl_prbs_rx_pass_syn;
            apb_prdata[18:8]                    <= o_dbg1_tx_ctrl_tx_num;
            apb_prdata[19]                      <= i_dbg1_tx_ctrl_tx_done_syn;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG1_TX_DATA_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_dbg1_tx_data_val;
        end
        DBG2_RX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg2_rx_ctrl_rx_en;
            apb_prdata[18:8]                    <= i_dbg2_rx_ctrl_rx_pkt_cnt;
            apb_prdata[19]                      <= i_dbg2_rx_ctrl_rx_pkt_equ;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG2_RX_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg2_rx_data0_val;
        end
        DBG2_RX_DATA1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg2_rx_data1_val;
        end
        DBG2_RX_DATA2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg2_rx_data2_val;
        end
        DBG2_TX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg2_tx_ctrl_ser_en;
            apb_prdata[1]                       <= o_dbg2_tx_ctrl_der_en;
            apb_prdata[2]                       <= o_dbg2_tx_ctrl_tx_start;
            apb_prdata[3]                       <= o_dbg2_tx_ctrl_tx_en;
            apb_prdata[4]                       <= o_dbg2_tx_ctrl_prbs_tx_en;
            apb_prdata[5]                       <= dbg2_tx_ctrl_prbs_rx_done;
            apb_prdata[6]                       <= i_dbg2_tx_ctrl_prbs_rx_pass_syn;
            apb_prdata[18:8]                    <= o_dbg2_tx_ctrl_tx_num;
            apb_prdata[19]                      <= i_dbg2_tx_ctrl_tx_done_syn;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG2_TX_DATA_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_dbg2_tx_data_val;
        end
        DBG3_RX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg3_rx_ctrl_rx_en;
            apb_prdata[18:8]                    <= i_dbg3_rx_ctrl_rx_pkt_cnt;
            apb_prdata[19]                      <= i_dbg3_rx_ctrl_rx_pkt_equ;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG3_RX_DATA0_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg3_rx_data0_val;
        end
        DBG3_RX_DATA1_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg3_rx_data1_val;
        end
        DBG3_RX_DATA2_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= i_dbg3_rx_data2_val;
        end
        DBG3_TX_CTRL_OFFSET_ADDR: begin
            apb_prdata[0]                       <= o_dbg3_tx_ctrl_ser_en;
            apb_prdata[1]                       <= o_dbg3_tx_ctrl_der_en;
            apb_prdata[2]                       <= o_dbg3_tx_ctrl_tx_start;
            apb_prdata[3]                       <= o_dbg3_tx_ctrl_tx_en;
            apb_prdata[18:8]                    <= o_dbg3_tx_ctrl_tx_num;
            apb_prdata[19]                      <= i_dbg3_tx_ctrl_tx_done_syn;
            apb_prdata[31:20]                   <=  'h0;
        end
        DBG3_TX_DATA_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_dbg3_tx_data_val;
        end
        default:rd_err<= 1;
        endcase
    end
    else
        rd_err                              <= 0;
end

always @(posedge apb_pclk or negedge apb_presetn) begin
    if(!apb_presetn) begin
        apb_pready                          <= 1'b0;
    end
    else if(apb_psel&apb_penable&~apb_pready) begin
        apb_pready                          <= 1'b1;
    end
    else begin
        apb_pready                          <= 1'b0;
    end
end

assign apb_pslverr                         = wr_err|rd_err;
endmodule
