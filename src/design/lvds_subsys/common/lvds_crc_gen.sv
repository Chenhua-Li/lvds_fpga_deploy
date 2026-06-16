// CRC polynomial coefficients: x^16 + x^15 + x^2 + 1
//                              0x8005 (hex)
// CRC width:                   16 bits
// CRC shift direction:         left (big endian)
// Input word width:            32 bits

module lvds_crc_gen(
    input       logic [15:0]                        crc_in,
    input       logic [31:0]                        data_in,
    output      logic [15:0]                        crc_out
    );

always_comb begin
    crc_out[0]                          = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[14] ^ crc_in[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[30] ^ data_in[31];
    crc_out[1]                          = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[11] ^ crc_in[12] ^ crc_in[15] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[31];
    crc_out[2]                          = crc_in[0] ^ crc_in[12] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ data_in[0] ^ data_in[1] ^ data_in[14] ^ data_in[16] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31];
    crc_out[3]                          = crc_in[1] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ data_in[1] ^ data_in[2] ^ data_in[15] ^ data_in[17] ^ data_in[29] ^ data_in[30] ^ data_in[31];
    crc_out[4]                          = crc_in[0] ^ crc_in[2] ^ crc_in[14] ^ crc_in[15] ^ data_in[2] ^ data_in[3] ^ data_in[16] ^ data_in[18] ^ data_in[30] ^ data_in[31];
    crc_out[5]                          = crc_in[1] ^ crc_in[3] ^ crc_in[15] ^ data_in[3] ^ data_in[4] ^ data_in[17] ^ data_in[19] ^ data_in[31];
    crc_out[6]                          = crc_in[2] ^ crc_in[4] ^ data_in[4] ^ data_in[5] ^ data_in[18] ^ data_in[20];
    crc_out[7]                          = crc_in[3] ^ crc_in[5] ^ data_in[5] ^ data_in[6] ^ data_in[19] ^ data_in[21];
    crc_out[8]                          = crc_in[4] ^ crc_in[6] ^ data_in[6] ^ data_in[7] ^ data_in[20] ^ data_in[22];
    crc_out[9]                          = crc_in[5] ^ crc_in[7] ^ data_in[7] ^ data_in[8] ^ data_in[21] ^ data_in[23];
    crc_out[10]                         = crc_in[6] ^ crc_in[8] ^ data_in[8] ^ data_in[9] ^ data_in[22] ^ data_in[24];
    crc_out[11]                         = crc_in[7] ^ crc_in[9] ^ data_in[9] ^ data_in[10] ^ data_in[23] ^ data_in[25];
    crc_out[12]                         = crc_in[8] ^ crc_in[10] ^ data_in[10] ^ data_in[11] ^ data_in[24] ^ data_in[26];
    crc_out[13]                         = crc_in[9] ^ crc_in[11] ^ data_in[11] ^ data_in[12] ^ data_in[25] ^ data_in[27];
    crc_out[14]                         = crc_in[10] ^ crc_in[12] ^ data_in[12] ^ data_in[13] ^ data_in[26] ^ data_in[28];
    crc_out[15]                         = crc_in[0] ^ crc_in[1] ^ crc_in[2] ^ crc_in[3] ^ crc_in[4] ^ crc_in[5] ^ crc_in[6] ^ crc_in[7] ^ crc_in[8] ^ crc_in[9] ^ crc_in[10] ^ crc_in[13] ^ crc_in[14] ^ crc_in[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[29] ^ data_in[30] ^ data_in[31];
end

endmodule
