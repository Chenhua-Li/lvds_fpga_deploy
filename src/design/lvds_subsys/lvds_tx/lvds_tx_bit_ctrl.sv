module lvds_tx_bit_ctrl
import lvds_if_pkg::*;
(
    input                                           bclk,
    input                                           brstn,
    input                                           wclk_tick,
    input                                           auto_cal_start,
    input                                           prbs_tx_en,
    input       [ 9:0]                              cal_mode_pat,
    input       [35:0]                              pre_enc_data,
    output      logic [ 9:0]                        lvds_tx_bits,
    output      logic                               enc_err

    );

logic   [7:0]                                   enc_a_data_i;
logic                                           enc_a_datak_i;
logic                                           enc_a_cur_disp_i;
logic   [9:0]                                   enc_a_data_o;
logic                                           enc_a_cur_disp_o;
logic                                           enc_a_err_o;
logic   [31:0]                                  pre_enc_data_r;
logic   [3:0]                                   pre_enc_data_type_r;
logic                                           enc_a_cur_disp_r;
logic                                           auto_cal_start_syn;
logic                                           auto_cal_start_pos;
logic                                           auto_cal_start_syn_r;
logic                                           prbs_tx_en_syn;
logic                                           prbs_tx_en_syn_r;
logic                                           prbs_tx_en_pos;
logic                                           prbs_cnt_en;
logic   [7:0]                                   prbs_cnt;
logic   [7:0]                                   prbs_out;
logic                                           prbs_cnt_en_dly;
logic                                           prbs_cnt_en_neg;

macro_sync2r u_syn_auto_cal_start(  
    .ck                                 ( bclk                        ),
    .clb                                ( brstn                       ),
    .d                                  ( auto_cal_start              ),
    .o                                  ( auto_cal_start_syn          )
    );

macro_sync2r u_syn_tx_prbs_en(  
    .ck                                 ( bclk                        ),
    .clb                                ( brstn                       ),
    .d                                  ( prbs_tx_en                  ),
    .o                                  ( prbs_tx_en_syn              )
    );

assign auto_cal_start_pos                  = ~auto_cal_start_syn_r & auto_cal_start_syn;
always_ff @(posedge bclk or negedge brstn)
    if(~brstn) begin
        pre_enc_data_r                      <= 'h0;
        pre_enc_data_type_r                 <= 'h0;
        enc_err                             <= 'h0;
        auto_cal_start_syn_r                <= 'h0;
    end
    else begin

        auto_cal_start_syn_r                <= auto_cal_start_syn;
        if(wclk_tick)
            enc_err                             <= enc_a_err_o;

        if(prbs_tx_en_pos) begin
            pre_enc_data_r[31-:8]               <= K_PRBS_START;
            pre_enc_data_type_r[3]              <= 1'b1;
        end
        else if(prbs_cnt_en) begin
            pre_enc_data_r[31-:8]               <= prbs_out;
            pre_enc_data_type_r[3]              <= 1'b0;
        end
        else if(prbs_cnt_en_neg) begin
            pre_enc_data_r[31-:8]               <= K_PRBS_END;
            pre_enc_data_type_r[3]              <= 1'b1;
        end
        else if(wclk_tick) begin
            pre_enc_data_r                      <= pre_enc_data[31:0];
            pre_enc_data_type_r                 <= pre_enc_data[35:32];
        end
        else begin
            pre_enc_data_r                      <= {pre_enc_data_r[0+:24],8'h0};
            pre_enc_data_type_r                 <= {pre_enc_data_type_r[0+:3],1'h0};
        end
    end

always_ff @(posedge bclk or negedge brstn)
    if(~brstn) begin
        enc_a_cur_disp_r                    <= 'h0;
        lvds_tx_bits                        <= 'h0;
    end
    else begin
        if(auto_cal_start_pos)
            enc_a_cur_disp_r                    <= 1'b0;
        else if(auto_cal_start_syn)
            enc_a_cur_disp_r                    <= 1'b0;
        else
            enc_a_cur_disp_r                    <= enc_a_cur_disp_o;

        if(auto_cal_start_pos)
            lvds_tx_bits                        <= cal_mode_pat;
        else if(auto_cal_start_syn)
            //lvds_tx_bits                        <= ~lvds_tx_bits;
            lvds_tx_bits                        <= lvds_tx_bits;
        else
            lvds_tx_bits                        <= {enc_a_data_o};
    end


assign enc_a_data_i                        = pre_enc_data_r[31-:8];
assign enc_a_datak_i                       = pre_enc_data_type_r[3];
assign enc_a_cur_disp_i                    = enc_a_cur_disp_r;

//8b_10b
lvds_enc_8b10b u_8b10b_enc_a(
    .data_i                             ( enc_a_data_i                ),
    .datak_i                            ( enc_a_datak_i               ),
    .cur_disp_i                         ( enc_a_cur_disp_i            ),
    .data_o                             ( enc_a_data_o                ),
    .cur_disp_o                         ( enc_a_cur_disp_o            ),
    .err_o                              ( enc_a_err_o                 )
    );

//prbs gen
prbs8_gen u_prbs8_gen(
    .clk                                ( bclk                        ),
    .rst_n                              ( brstn                       ),
    .en                                 ( prbs_cnt_en                 ),
    .clr                                ( prbs_tx_en_pos              ),
    .prbs_out                           ( prbs_out                    )
);

assign prbs_cnt_en_neg                     = prbs_cnt_en_dly & ~prbs_cnt_en;
assign prbs_tx_en_pos                      = ~prbs_tx_en_syn_r & prbs_tx_en_syn;
always_ff @(posedge bclk or negedge brstn)
    if(~brstn) begin
        prbs_tx_en_syn_r                    <= '0;
        prbs_cnt                            <= '0;
        prbs_cnt_en                         <= '0;
        prbs_cnt_en_dly                     <= 1'b0;
    end
    else begin
        prbs_tx_en_syn_r                    <= prbs_tx_en_syn;
        prbs_cnt_en_dly                     <= prbs_cnt_en;

        if(prbs_tx_en_pos)
            prbs_cnt_en                         <= 1'b1;
        else if(prbs_cnt_en & (&prbs_cnt))
            prbs_cnt_en                         <= 1'b0;

        if(prbs_tx_en_pos)
            prbs_cnt                            <= '0;
        else if(prbs_cnt_en)
            prbs_cnt                            <= prbs_cnt + 1;

    end

endmodule

