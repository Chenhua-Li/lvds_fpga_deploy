
module lvds_rx_bit_ctrl
import lvds_if_pkg::*;
(
    input                                           lvds_rx_bit_clk,
    input                                           lvds_rx_bit_rstn,
    input       [ 9:0]                              lvds_rx_bits,

    input       logic                               cal_mode_mask,
    input                                           wclk_tick,
    output      logic                               tx_stop_send_en,
    output      [31:0]                              wdata_o,
    output                                          wdata_vld_o,
    output                                          sop_o,
    output      logic                               eop_o,
    output      logic                               rec_p_calib_req,
    input       logic                               rec_p_calib_ack,
    output      logic                               prbs_done,
    output      logic                               prbs_pass,
    output      logic                               dec_err_o

    );


logic                                           a_dec_err_r;
logic                                           a_disp_err_r;
logic                                           a_dec_err_w;
logic                                           a_disp_err_w;
logic                                           a_cur_disp_o;
logic                                           a_datak_o;
logic   [7:0]                                   a_data_o;
logic                                           a_cur_disp_i;
logic   [9:0]                                   a_data_i;
logic                                           a_datak_dec;
logic   [7:0]                                   a_data_dec;
logic                                           dvld_lat_buf;
logic                                           dvld_mid;
logic   [2:0]                                   data_mid_buf_lat_w;
logic                                           data_mid_buf_lat;
logic                                           eop_flag_mid;
logic                                           eop_flag_mid_set;
logic                                           eop_flag_mid_clr;
logic                                           eop_lat_buf;
logic                                           eop_lat_buf_clr;
logic                                           sop_lat_buf;
logic                                           sop_lat_buf_clr;
logic   [31:0]                                  data_lat_buf;
logic   [31:0]                                  data_mid_buf;
logic   [31:0]                                  data_pre_buf;
logic   [1:0]                                   byte_cnt;
logic                                           eop_flag;
logic                                           eop_flag_r;
logic                                           eop_flag_r_set;
logic   [1:0]                                   eop_flag_r_clr;
logic                                           sop_flag_mid_set;
logic                                           sop_flag_mid_clr;
logic                                           sop_flag;
logic                                           sop_flag_mask;
logic                                           sop_flag_mid;
logic                                           sop_lat_w;
logic                                           rec_dat_en_clr;
logic                                           rec_dat_en_set;
logic                                           rec_data_en;
logic                                           lvds_rx_rstn_syn;
logic                                           tx_stop_send_en_set;
logic                                           tx_stop_send_en_clr;
logic   [1:0]                                   req_b_cnt;
logic   [2:0]                                   req_w_cnt;
logic                                           req_b_cnt_inc;
logic                                           req_b_cnt_clr;
logic                                           req_w_cnt_inc;
logic                                           req_w_cnt_clr;
logic                                           rec_p_calib_req_set;
logic                                           dec_err_flag_set;
logic                                           dec_err_flag_clr;
logic                                           dec_err_flag;
logic                                           dec_err_mid_buf;
logic                                           dec_err_mid_buf_clr;
logic                                           rec_p_calib_ack_syn;
logic                                           prbs_check_en;
logic                                           prbs_check_en_set;
logic                                           prbs_check_en_clr;
logic                                           prbs_pass_clr;
logic   [7:0]                                   prbs_out;


assign dec_err_o                           = dec_err_mid_buf;
assign lvds_rx_rstn_syn                    = lvds_rx_bit_rstn;
assign dec_err_flag_set                    = a_disp_err_r | a_dec_err_r;
assign dec_err_flag_clr                    = dec_err_flag & wclk_tick;
assign dec_err_mid_buf_clr                 = dec_err_mid_buf & wclk_tick;
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        a_cur_disp_i                        <= 'b0;
        a_data_dec                          <= 'h0;
        a_datak_dec                         <= 'h0;
        a_dec_err_r                         <= 'h0;
        a_disp_err_r                        <= 'h0;
        dec_err_flag                        <= 'h0;
        dec_err_mid_buf                     <= 'h0;
    end
    else begin
        a_cur_disp_i                        <= a_cur_disp_o;
        a_data_dec                          <= a_data_o;
        a_datak_dec                         <= a_datak_o;
        a_dec_err_r                         <= a_dec_err_w;
        a_disp_err_r                        <= a_disp_err_w;

        if(dec_err_flag_set)
            dec_err_flag                        <= 1'b1;
        else if(dec_err_flag_clr)
            dec_err_flag                        <= 1'b0;

        if(dec_err_flag_clr)
            dec_err_mid_buf                     <= 'h1;
        else if(dec_err_mid_buf_clr)
            dec_err_mid_buf                     <= 'h0;

    end

assign a_data_i                            = lvds_rx_bits[9:0];

lvds_dec_8b10b dec_a (
    .first_i                            ( 1'b1                        ),
    .data_i                             ( a_data_i                    ),
    .cur_disp_i                         ( a_cur_disp_i                ),
    .data_o                             ( a_data_o                    ),
    .datak_o                            ( a_datak_o                   ),
    .cur_disp_o                         ( a_cur_disp_o                ),
    .disp_err_o                         ( a_disp_err_w                ),
    .dec_err_o                          ( a_dec_err_w                 )
    );

assign rec_dat_en_set                      = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_SOP);
//clear data flag when next packet does Not come
assign rec_dat_en_clr                      = rec_data_en & eop_flag_r & (byte_cnt == 2'b10);
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        rec_data_en                         <= 'h0;
    end
    else begin
        if(rec_dat_en_set)
            rec_data_en                         <= 'h1;
        else if(rec_dat_en_clr)
            rec_data_en                         <= 'h0;
    end

assign tx_stop_send_en_set                 = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_WAIT);
assign tx_stop_send_en_clr                 = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_RESEND);
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        tx_stop_send_en                     <= 1'b0;
    end
    else begin
        if(tx_stop_send_en_set)
            tx_stop_send_en                     <= 1'b1;
        else if(tx_stop_send_en_clr)
            tx_stop_send_en                     <= 1'b0;
    end

always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        byte_cnt                            <= 2'b00;
    end
    else if(sop_lat_w) begin
        byte_cnt                            <= 2'b00;
    end
    else if(rec_data_en & ~cal_mode_mask) begin
        case(byte_cnt)
            2'b00:
                byte_cnt                            <= 2'b01;
            2'b01:
                byte_cnt                            <= 2'b11;
            2'b11:
                byte_cnt                            <= 2'b10;
            2'b10:
                byte_cnt                            <= 2'b00;
            default:
                byte_cnt                            <= 2'b00;
        endcase
    end

always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        data_pre_buf                        <= 32'h0;
    end
    else if(rec_data_en & ~a_datak_dec) begin
        case(byte_cnt)
            2'b00:
                data_pre_buf[24+:8]                 <= {a_data_dec};
            2'b01:
                data_pre_buf[16+:8]                 <= {a_data_dec};
            2'b11:
                data_pre_buf[08+:8]                 <= {a_data_dec};
            2'b10:
                data_pre_buf[0+:8]                  <= {a_data_dec};
            default:
                data_pre_buf                        <= data_pre_buf;
        endcase
    end

assign sop_lat_w                           = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_SOP);
assign data_mid_buf_lat_w[0]               = rec_data_en & (byte_cnt == 2'b10) & ~a_datak_dec;
assign data_mid_buf_lat_w[1]               = rec_data_en & (byte_cnt == 2'b10) & a_datak_dec & (a_data_dec == K_SOP);
assign data_mid_buf_lat_w[2]               = rec_data_en & (byte_cnt == 2'b10) & eop_flag_r;
assign sop_flag_mid_set                    = data_mid_buf_lat & sop_flag & ~sop_flag_mask;
assign sop_flag_mid_clr                    = wclk_tick & sop_flag_mid;
assign sop_lat_buf_clr                     = wclk_tick & sop_lat_buf;
assign eop_flag                            = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_EOP) & rec_data_en;
assign eop_flag_mid_set                    = data_mid_buf_lat & eop_flag_r;
assign eop_flag_mid_clr                    = wclk_tick & eop_flag_mid;
assign eop_lat_buf_clr                     = wclk_tick & eop_lat_buf;
assign eop_flag_r_set                      = eop_flag;
assign eop_flag_r_clr[0]                   = eop_flag_mid_set & eop_flag_r;
assign eop_flag_r_clr[1]                   = eop_flag_mid_clr & eop_flag_r;

always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        data_mid_buf_lat                    <= 1'b0;
        sop_flag                            <= 1'b0;
        sop_flag_mask                       <= 1'b0;
        eop_flag_r                          <= 1'b0;
        data_mid_buf                        <= 'h0;
        data_lat_buf                        <= 'h0;
        sop_flag_mid                        <= 'h0;
        sop_lat_buf                         <= 'h0;
        eop_flag_mid                        <= 'h0;
        dvld_mid                            <= 'h0;
        dvld_lat_buf                        <= 'h0;
        eop_lat_buf                         <= 'h0;
    end
    else begin
        data_mid_buf_lat                    <= |data_mid_buf_lat_w;

        sop_flag_mask                       <= ~cal_mode_mask & a_datak_dec & (a_data_dec == K_SOP) & rec_data_en;
        if(sop_lat_w)
            sop_flag                            <= 1'b1;
        else if(sop_flag_mid_set)
            sop_flag                            <= 1'b0;
        
        if(sop_flag_mid_set)
            sop_flag_mid                        <= 1'b1;
        else if(sop_flag_mid_clr)
            sop_flag_mid                        <= 1'b0;

        if(sop_flag_mid_clr)
            sop_lat_buf                         <= 1'b1;
        else if(sop_lat_buf_clr)
            sop_lat_buf                         <= 1'b0;

        if(|eop_flag_r_clr)
            eop_flag_r                          <= 1'b0;
        else if(eop_flag_r_set)
            eop_flag_r                          <= 1'b1;

        if(eop_flag_mid_set)
            eop_flag_mid                        <= 1'h1;
        else if(eop_flag_mid_clr)
            eop_flag_mid                        <= 1'h0;

        if(eop_flag_mid_clr)
            eop_lat_buf                         <= 1'b1;
        else if(eop_lat_buf_clr)
            eop_lat_buf                         <= 1'b0;

        if(data_mid_buf_lat)
            data_mid_buf                        <= data_pre_buf;

        if(wclk_tick & dvld_mid)
            data_lat_buf                        <= data_mid_buf;

        if(data_mid_buf_lat)
            dvld_mid                            <= 1'b1;
        else if(wclk_tick & dvld_mid)
            dvld_mid                            <= 1'b0;
        
        if(wclk_tick)
            dvld_lat_buf                        <= dvld_mid;
    end

assign wdata_o                             = data_lat_buf;
assign wdata_vld_o                         = dvld_lat_buf;
assign sop_o                               = sop_lat_buf;
assign eop_o                               = eop_lat_buf;
                                 
// for calib
macro_sync2r u_syn_rec_p_calib_ack(
    .ck                                 ( lvds_rx_bit_clk             ),
    .clb                                ( lvds_rx_rstn_syn            ),
    .d                                  ( rec_p_calib_ack             ),
    .o                                  ( rec_p_calib_ack_syn         )
    );

assign req_b_cnt_inc                       = a_datak_dec & (a_data_dec == K_REQ_CALIB);
assign req_b_cnt_clr                       = (|req_b_cnt) & (a_data_dec != K_REQ_CALIB);
assign req_w_cnt_inc                       = a_datak_dec & (a_data_dec == K_REQ_CALIB) & (req_b_cnt == 2'b10);
assign req_w_cnt_clr                       = rec_p_calib_ack_syn & rec_p_calib_req;
assign rec_p_calib_req_set                 = (req_w_cnt == 3'd7) & req_w_cnt_inc;

always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        req_b_cnt                           <= 'h0;
        req_w_cnt                           <= 'h0;
        rec_p_calib_req                     <= 'h0;
    end
    else begin
        if(req_b_cnt_clr) begin
            req_b_cnt                           <= 'h0;
        end
        else if(req_b_cnt_inc) begin
            case(req_b_cnt)
                2'b00: req_b_cnt <= 2'b01;
                2'b01: req_b_cnt <= 2'b11;
                2'b11: req_b_cnt <= 2'b10;
                2'b10: req_b_cnt <= 2'b00;
                default: req_b_cnt <= 2'b00;
            endcase
        end

        if(req_w_cnt_clr)
            req_w_cnt                           <= '0;
        else if(req_w_cnt_inc)
            req_w_cnt                           <= req_w_cnt + 1;

        if(req_w_cnt_clr)
            rec_p_calib_req                     <= 'h0;
        else if(rec_p_calib_req_set)
            rec_p_calib_req                     <= 1;

    end

//prbs check

prbs8_gen u_prbs8_gen(
    .clk                                ( lvds_rx_bit_clk             ),
    .rst_n                              ( lvds_rx_rstn_syn            ),
    .en                                 ( prbs_check_en               ),
    .clr                                ( prbs_check_en_set           ),
    .prbs_out                           ( prbs_out                    )
    );

assign prbs_pass_clr                       = prbs_check_en & (a_data_dec != prbs_out) & ~a_datak_dec;
assign prbs_check_en_set                   = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_PRBS_START);
assign prbs_check_en_clr                   = ~cal_mode_mask & a_datak_dec & (a_data_dec == K_PRBS_END);
always_ff @(posedge lvds_rx_bit_clk or negedge lvds_rx_rstn_syn)
    if(~lvds_rx_rstn_syn) begin
        prbs_check_en                       <= 1'b0;
        prbs_done                           <= 1'b0;
        prbs_pass                           <= 1'b0;
    end
    else begin
        if(prbs_check_en_set)
            prbs_check_en                       <= 1'b1;
        else if(prbs_check_en_clr)
            prbs_check_en                       <= 1'b0;

        if(prbs_check_en_set)
            prbs_done                           <= 1'b0;
        else if(prbs_check_en_clr)
            prbs_done                           <= 1'b1;

        if(prbs_pass_clr)
            prbs_pass                           <= 1'b0;
        else if(prbs_check_en_set)
            prbs_pass                           <= 1'b1;

    end

endmodule

