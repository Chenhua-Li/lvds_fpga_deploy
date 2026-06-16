module lvds_dec_8b10b (
    input       [9:0]                               data_i,
    input                                           cur_disp_i,
    input                                           first_i,
    output      logic [7:0]                         data_o,
    output      logic                               datak_o,
    output                                          cur_disp_o,
    output                                          disp_err_o,
    output      dec_err_o
    );

logic   [9:0]                                   data_word_r;
logic   [4:0]                                   b5_r;
logic   [2:0]                                   b3_r;
logic   [2:0]                                   b28_3_p_r;
logic   [2:0]                                   b28_3_n_r;
logic                                           dec_err_5_b_r;
logic                                           dec_err_3_b_r;
logic                                           dec_err28_3_p_r;
logic                                           dec_err28_3_n_r;
logic                                           b3_a7_p_r;
logic                                           b3_a7_n_r;
logic                                           b3_p7_p_r;
logic                                           b3_p7_n_r;
logic                                           b5_k_r;
logic                                           k28_p_r;
logic                                           k28_n_r;
logic   [2:0]                                   rd4_ones_r;
logic   [2:0]                                   rd6_ones_r;
logic                                           rd4_disp_r;
logic                                           rd6_disp_r;
logic                                           rd6_zero_r;
logic                                           rd4_zero_r;
logic                                           rd6_error_r;
logic                                           rd4_error_r;
logic                                           rd6_special_p_r;
logic                                           rd4_special_p_r;
logic                                           rd6_special_n_r;
logic                                           rd4_special_n_r;
logic                                           dec_err_5_r;
logic                                           dec_err_3_r;
logic                                           rd6_special_p_err_r;
logic                                           rd6_special_n_err_r;
logic                                           rd4_special_p_err_r;
logic                                           rd4_special_n_err_r;

assign data_word_r[9]                      = data_i[0];
assign data_word_r[8]                      = data_i[1];
assign data_word_r[7]                      = data_i[2];
assign data_word_r[6]                      = data_i[3];
assign data_word_r[5]                      = data_i[4];
assign data_word_r[4]                      = data_i[5];
assign data_word_r[3]                      = data_i[6];
assign data_word_r[2]                      = data_i[7];
assign data_word_r[1]                      = data_i[8];
assign data_word_r[0]                      = data_i[9];

always_comb begin
    b5_r                                = 0;
    dec_err_5_b_r                       = 0;
    k28_p_r                             = 0;
    b5_k_r                              = 0;
    k28_n_r                             = 0;
    casez(data_word_r[9:4])
        6'b100111,
        6'b011000:  b5_r    = 5'd0;
        6'b011101,
        6'b100010:  b5_r    = 5'd1;
        6'b101101,
        6'b010010:  b5_r    = 5'd2;
        6'b110001:  b5_r    = 5'd3;
        6'b110101,
        6'b001010:  b5_r    = 5'd4;
        6'b101001:  b5_r    = 5'd5;
        6'b011001:  b5_r    = 5'd6;
        6'b111000,
        6'b000111:  b5_r    = 5'd7;
        6'b111001,
        6'b000110:  b5_r    = 5'd8;
        6'b100101:  b5_r    = 5'd9;
        6'b010101:  b5_r    = 5'd10;
        6'b110100:  b5_r    = 5'd11;
        6'b001101:  b5_r    = 5'd12;
        6'b101100:  b5_r    = 5'd13;
        6'b011100:  b5_r    = 5'd14;
        6'b010111,
        6'b101000:  b5_r    = 5'd15;
        6'b011011,
        6'b100100:  b5_r    = 5'd16;
        6'b100011:  b5_r    = 5'd17;
        6'b010011:  b5_r    = 5'd18;
        6'b110010:  b5_r    = 5'd19;
        6'b001011:  b5_r    = 5'd20;
        6'b101010:  b5_r    = 5'd21;
        6'b011010:  b5_r    = 5'd22;
        6'b111010,
        6'b000101:  begin
                            b5_r                                = 5'd23;
                            b5_k_r                              = 1;
                        end
        6'b110011,
        6'b001100:  b5_r    = 5'd24;
        6'b100110:  b5_r    = 5'd25;
        6'b010110:  b5_r    = 5'd26;
        6'b110110,
        6'b001001:  begin
                            b5_r                                = 5'd27;
                            b5_k_r                              = 1;
                        end
        6'b001110:  b5_r    = 5'd28;
        6'b101110,
        6'b010001:  begin
                            b5_r                                = 5'd29;
                            b5_k_r                              = 1;
                        end
        6'b011110,
        6'b100001:  begin
                            b5_r                                = 5'd30;
                            b5_k_r                              = 1;
                        end
        6'b101011,
        6'b010100:  b5_r    = 5'd31;
        6'b001111:  begin
                            b5_r                                = 5'd28;
                            k28_n_r                             = 1;
                        end
        6'b110000:  begin
                            b5_r                                = 5'd28;
                            k28_p_r                             = 1;
                        end
        default:        dec_err_5_b_r   = 1;
    endcase

    b3_r                                = 0;
    dec_err_3_b_r                       = 0;
    b3_a7_p_r                           = 0;
    b3_p7_p_r                           = 0;
    b3_a7_n_r                           = 0;
    b3_p7_n_r                           = 0;
    casez(data_word_r[3:0])
        4'b0100,
        4'b1011:    b3_r = 3'd0;
        4'b1001:    b3_r = 3'd1;
        4'b0101:    b3_r = 3'd2;
        4'b0011,
        4'b1100:    b3_r = 3'd3;
        4'b0010,
        4'b1101:    b3_r = 3'd4;
        4'b1010:    b3_r = 3'd5;
        4'b0110:    b3_r = 3'd6;
        4'b0001:    begin
                        b3_r                                = 3'd7;
                        b3_p7_p_r                           = 1;
                    end
        4'b1000:    begin
                        b3_r                                = 3'd7;
                        b3_a7_p_r                           = 1;
                    end
        4'b1110:    begin
                        b3_r                                = 3'd7;
                        b3_p7_n_r                           = 1;
                    end
        4'b0111:    begin
                        b3_r                                = 3'd7;
                        b3_a7_n_r                           = 1;
                    end
        default:    dec_err_3_b_r   = 1;
    endcase

    b28_3_p_r                           = 0;
    dec_err28_3_p_r                     = 0;
    casez(data_word_r[3:0])
        4'b0100:        b28_3_p_r = 3'd0;
        4'b1001:        b28_3_p_r = 3'd1;
        4'b0101:        b28_3_p_r = 3'd2;
        4'b0011:        b28_3_p_r = 3'd3;
        4'b0010:        b28_3_p_r = 3'd4;
        4'b1010:        b28_3_p_r = 3'd5;
        4'b0110:        b28_3_p_r = 3'd6;
        4'b1000:        b28_3_p_r = 3'd7;
        default:        dec_err28_3_p_r = 1;
    endcase

    b28_3_n_r                           = 0;
    dec_err28_3_n_r                     = 0;
    casez(data_word_r[3:0])
        4'b1011:        b28_3_n_r = 3'd0;
        4'b0110:        b28_3_n_r = 3'd1;
        4'b1010:        b28_3_n_r = 3'd2;
        4'b1100:        b28_3_n_r = 3'd3;
        4'b1101:        b28_3_n_r = 3'd4;
        4'b0101:        b28_3_n_r = 3'd5;
        4'b1001:        b28_3_n_r = 3'd6;
        4'b0111:        b28_3_n_r = 3'd7;
        default:        dec_err28_3_n_r = 1;
    endcase
end

always_comb begin
    rd6_ones_r                          = data_word_r[9] +
                        data_word_r[8] +
                        data_word_r[7] +
                        data_word_r[6] +
                        data_word_r[5] +
                        data_word_r[4];
    rd4_ones_r                          = data_word_r[3] +
                        data_word_r[2] +
                        data_word_r[1] +
                        data_word_r[0];
end
assign rd6_zero_r                          = (rd6_ones_r == 3'd3);
assign rd4_zero_r                          = (rd4_ones_r == 3'd2);
assign rd6_special_p_r                     = data_word_r[9:4] == 6'b000111;
assign rd4_special_p_r                     = data_word_r[3:0] == 4'b0011;
assign rd6_special_n_r                     = data_word_r[9:4] == 6'b111000;
assign rd4_special_n_r                     = data_word_r[3:0] == 4'b1100;

always_comb begin
    if (rd6_special_p_r) begin
        rd6_disp_r                          = 1;
    end else if (rd6_special_n_r) begin
        rd6_disp_r                          = 0;
    end else begin
        if (rd6_zero_r) begin
            rd6_disp_r                          = cur_disp_i;
        end else if (rd6_ones_r > 3'd3) begin
            rd6_disp_r                          = 1;
        end else begin
            rd6_disp_r                          = 0;
        end
    end
end

always_comb begin
    if (rd4_special_p_r) begin
        rd4_disp_r                          = 1;
    end else if (rd4_special_n_r) begin
        rd4_disp_r                          = 0;
    end else begin
        if (rd4_zero_r) begin
            rd4_disp_r                          = rd6_disp_r;
        end else if (rd4_ones_r > 3'd2) begin
            rd4_disp_r                          = 1;
        end else begin
            rd4_disp_r                          = 0;
        end
    end
end

assign rd6_error_r                         = ~rd6_zero_r & ~(cur_disp_i ^ rd6_disp_r);
assign rd4_error_r                         = ~rd4_zero_r & ~(rd6_disp_r ^ rd4_disp_r);
always_comb begin
    if (k28_p_r | k28_n_r) begin
        datak_o                             = 1;
        dec_err_5_r                         = 0;
        if (k28_p_r) begin
            data_o[4:0]                         = b5_r;
            data_o[7:5]                         = b28_3_n_r;
            dec_err_3_r                         = dec_err28_3_n_r;
        end else begin
            data_o[4:0]                         = b5_r;
            data_o[7:5]                         = b28_3_p_r;
            dec_err_3_r                         = dec_err28_3_p_r;
        end
    end else begin
            data_o[4:0]                         = b5_r;
            data_o[7:5]                         = b3_r;
            dec_err_5_r                         = dec_err_5_b_r;
            dec_err_3_r                         = 0;
            if (dec_err_3_b_r) dec_err_3_r = 1;
            if (~rd4_zero_r & ~rd6_zero_r & (rd4_disp_r == rd6_disp_r)) dec_err_3_r = 1;
            if (rd6_special_p_r & rd4_disp_r & ~rd4_zero_r) dec_err_3_r = 1;
            if (rd6_special_n_r & ~rd4_disp_r & ~rd4_zero_r) dec_err_3_r = 1;
            if (rd4_special_p_r & ~rd6_disp_r & ~rd6_zero_r) dec_err_3_r = 1;
            if (rd4_special_n_r & rd6_disp_r & ~rd6_zero_r) dec_err_3_r = 1;
            if (rd6_special_p_r & rd4_special_n_r) dec_err_3_r = 1;
            if (rd6_special_n_r & rd4_special_p_r) dec_err_3_r = 1;
            if (b3_a7_p_r && ~b5_k_r && (data_word_r[5:4] != 2'b00)) dec_err_3_r = 1;
            if (b3_a7_n_r && ~b5_k_r && (data_word_r[5:4] != 2'b11)) dec_err_3_r = 1;
            if (b3_p7_p_r && ~b5_k_r && (data_word_r[5:4] == 2'b00)) dec_err_3_r = 1;
            if (b3_p7_n_r && ~b5_k_r && (data_word_r[5:4] == 2'b11)) dec_err_3_r = 1;
            datak_o                             = ((b3_a7_p_r | b3_a7_n_r) && b5_k_r);
    end
end

assign rd6_special_p_err_r                 = rd6_special_p_r & ~cur_disp_i;
assign rd6_special_n_err_r                 = rd6_special_n_r & cur_disp_i;
assign rd4_special_p_err_r                 = rd4_special_p_r & ~rd6_disp_r;
assign rd4_special_n_err_r                 = rd4_special_n_r & rd6_disp_r;
assign dec_err_o                           = dec_err_5_r | dec_err_3_r;
assign disp_err_o                          = ~first_i && (rd6_error_r | rd4_error_r | rd6_special_p_err_r | rd6_special_n_err_r | rd4_special_p_err_r | rd4_special_n_err_r);
assign cur_disp_o                          = rd4_disp_r;

endmodule

