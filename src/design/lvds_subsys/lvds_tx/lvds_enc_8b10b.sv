
module lvds_enc_8b10b(
    input       logic [7:0]                         data_i,
    input                                           datak_i,
    input                                           cur_disp_i,
    output      logic [9:0]                         data_o,
    output                                          cur_disp_o,
    output      err_o
    );

logic                                           rd6_r;
logic                                           rd4_r;
logic   [5:0]                                   b6n_r;
logic   [5:0]                                   b6c_r;
logic   [3:0]                                   b4n_r;
logic   [3:0]                                   b4c_r;
logic                                           sel_6b_r;
logic                                           sel_4b_r;
logic                                           s_r;

always_comb begin
    casez ({sel_6b_r, cur_disp_i})
        2'b11:  data_o[5:0] =  ~b6n_r;
        2'b10:  data_o[5:0] = b6n_r;
        2'b0?:  data_o[5:0] = b6c_r;
    endcase
    casez ({sel_4b_r, rd6_r})
        2'b11:  data_o[9:6] =  ~b4n_r;
        2'b10:  data_o[9:6] = b4n_r;
        2'b0?:  data_o[9:6] = b4c_r;
    endcase
end

assign err_o                               = (data_o[5:0] == 6'b000000) | (data_o[9:6] == 4'b0000 );
assign cur_disp_o                          = rd4_r;

always_comb begin
  casez ({datak_i, data_i[4:0]})
        6'b?_00000,
        6'b?_00001,
        6'b?_00010,
        6'b?_00100,
        6'b?_01000,
        6'b?_01111,
        6'b?_10000,
        6'b?_10111,
        6'b?_11000,
        6'b?_11011,
        6'b?_11101,
        6'b?_11110,
        6'b?_11111,
        6'b1_11100:
                        rd6_r                               = ~cur_disp_i;
        6'b?_00011,
        6'b?_00101,
        6'b?_00110,
        6'b?_00111,
        6'b?_01001,
        6'b?_01010,
        6'b?_01011,
        6'b?_01100,
        6'b?_01101,
        6'b?_01110,
        6'b?_10001,
        6'b?_10010,
        6'b?_10011,
        6'b?_10100,
        6'b?_10101,
        6'b?_10110,
        6'b?_11001,
        6'b?_11010,
        6'b0_11100:
                        rd6_r                               = cur_disp_i;
    endcase

  casez ({datak_i, data_i[4:0] })
        6'b?_00000,
        6'b?_00001,
        6'b?_00010,
        6'b?_00100,
        6'b?_01000,
        6'b?_01111,
        6'b?_10000,
        6'b?_10111,
        6'b?_11000,
        6'b?_11011,
        6'b?_11101,
        6'b?_11110,
        6'b?_11111,
        6'b1_11100,
        6'b?_00111:
                        sel_6b_r                            = 1'b1;
        default:        sel_6b_r = 1'b0;
    endcase

    casez ({datak_i, data_i[7:5]})
        4'b?_000,
        4'b?_100,
        4'b?_111:
                        rd4_r                               = ~rd6_r;
        4'b0_001,
        4'b0_010,
        4'b?_011,
        4'b0_101,
        4'b0_110,
        4'b1_001,
        4'b1_010,
        4'b1_101,
        4'b1_110:
                        rd4_r                               = rd6_r;
    endcase

    casez ({datak_i, data_i[7:5]})
        4'b0_001,
        4'b0_010,
        4'b0_101,
        4'b0_110:
                        sel_4b_r                            = 1'b0;
        default:        sel_4b_r = 1'b1;
    endcase
end

always_comb begin
    casez ({cur_disp_i, datak_i, data_i[4:0]})
        7'b?_1_11100,
        7'b0_?_10100,
        7'b0_?_10010,
        7'b0_?_10001,
        7'b1_?_01110,
        7'b1_?_01101,
        7'b1_?_01011:
                            s_r                                 = 1'b1;
        default:            s_r = 1'b0;
    endcase
end

always_comb begin

    casez ({datak_i, data_i[4:0]})
        6'b0_00000:     b6n_r = 6'b111001;
        6'b0_00001:     b6n_r = 6'b101110;
        6'b0_00010:     b6n_r = 6'b101101;
        6'b0_00100:     b6n_r = 6'b101011;
        6'b0_00111:     b6n_r = 6'b000111;
        6'b0_01000:     b6n_r = 6'b100111;
        6'b0_01111:     b6n_r = 6'b111010;
        6'b0_10000:     b6n_r = 6'b110110;
        6'b?_10111:     b6n_r = 6'b010111;
        6'b0_11000:     b6n_r = 6'b110011;
        6'b?_11011:     b6n_r = 6'b011011;
        6'b?_11101:     b6n_r = 6'b011101;
        6'b?_11110:     b6n_r = 6'b011110;
        6'b0_11111:     b6n_r = 6'b110101;
        6'b1_11100:     b6n_r = 6'b111100;
        default:            b6n_r = 6'b000000;
    endcase

    casez ({datak_i,data_i[4:0]})
        6'b0_00011:     b6c_r = 6'b100011;
        6'b0_00101:     b6c_r = 6'b100101;
        6'b0_00110:     b6c_r = 6'b100110;
        6'b0_01001:     b6c_r = 6'b101001;
        6'b0_01010:     b6c_r = 6'b101010;
        6'b0_01011:     b6c_r = 6'b001011;
        6'b0_01100:     b6c_r = 6'b101100;
        6'b0_01101:     b6c_r = 6'b001101;
        6'b0_01110:     b6c_r = 6'b001110;
        6'b0_10001:     b6c_r = 6'b110001;
        6'b0_10010:     b6c_r = 6'b110010;
        6'b0_10011:     b6c_r = 6'b010011;
        6'b0_10100:     b6c_r = 6'b110100;
        6'b0_10101:     b6c_r = 6'b010101;
        6'b0_10110:     b6c_r = 6'b010110;
        6'b0_11001:     b6c_r = 6'b011001;
        6'b0_11010:     b6c_r = 6'b011010;
        6'b0_11100:     b6c_r = 6'b011100;
        default:            b6c_r = 6'b000000;
    endcase

    casez ({datak_i, data_i[7:5]})
        4'b?_000:       b4n_r = 4'b1101;
        4'b?_011:       b4n_r = 4'b0011;
        4'b?_100:       b4n_r = 4'b1011;
        4'b?_111:       if ( s_r | datak_i ) begin
                                b4n_r                               = 4'b1110;
                            end else begin
                                b4n_r                               = 4'b0111;
                            end
        4'b1_001:       b4n_r = 4'b0110;
        4'b1_010:       b4n_r = 4'b0101;
        4'b1_101:       b4n_r = 4'b1010;
        4'b1_110:       b4n_r = 4'b1001;
        default:            b4n_r = 4'b0000;
    endcase

    casez ({datak_i, data_i[7:5]})
        4'b0_001:       b4c_r = 4'b1001;
        4'b0_010:       b4c_r = 4'b1010;
        4'b0_101:       b4c_r = 4'b0101;
        4'b0_110:       b4c_r = 4'b0110;
        default:            b4c_r = 4'b0000;
    endcase
end

endmodule

