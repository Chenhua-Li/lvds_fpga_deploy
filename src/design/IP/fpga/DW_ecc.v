// Author: Gemini ...
module DW_ecc(
    gen, 
    correct_n, 
    datain, 
    chkin,
    err_detect, 
    err_multpl, 
    dataout, 
    chkout
);

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------
parameter integer width = 96;
parameter integer chkbits = 8;
parameter integer synd_sel = 0; // 0: chkout outputs checkbits, 1: chkout outputs syndrome

// -----------------------------------------------------------------------------
// Ports
// -----------------------------------------------------------------------------
input  wire                 gen;        // 1 = generate, 0 = check/correct
input  wire                 correct_n;  // 0 = correct single errors, 1 = no correction
input  wire [width-1:0]     datain;     // Data input
input  wire [chkbits-1:0]   chkin;      // Checkbit input

output reg                  err_detect; // Error detected flag
output reg                  err_multpl; // Multiple-bit error detected flag
output reg  [width-1:0]     dataout;    // Data output (corrected if applied)
output reg  [chkbits-1:0]   chkout;     // Checkbit output / Syndrome output

// -----------------------------------------------------------------------------
// Internal Variables
// -----------------------------------------------------------------------------
integer i, j;
reg [103:1] code_data_only;    // 用0填充校验位占位符的数据
reg [6:0]   gen_cb;            // 根据输入 datain 生成的 7-bit 汉明码
reg         gen_p_overall;     // 根据输入 datain 生成的 1-bit 全局校验码

reg [103:1] rx_code;           // 拼装接收到的完整 103-bit 码字 (排除全局校验)
reg [6:0]   synd_val;          // 伴随式 (汉明域)
reg         p_chk;             // 伴随式 (全局校验域: 1代表发生奇数个错误)
reg [7:0]   syndrome;          // 完整的 8-bit Syndrome {p_chk, synd_val}

reg [103:1] corrected_code;    // 纠错后的码字
reg         corrected_p_overall; // 纠错后的全局校验位

// -----------------------------------------------------------------------------
// Combinational Logic
// -----------------------------------------------------------------------------
always @(*) begin
    // -------------------------------------------------------------------------
    // 1. 将 96-bit 原始数据映射到 103-bit 空间 (避开 2^n 的校验位位置)
    // -------------------------------------------------------------------------
    j = 0;
    for (i = 1; i <= 103; i = i + 1) begin
        if (i == 1 || i == 2 || i == 4 || i == 8 || i == 16 || i == 32 || i == 64) begin
            code_data_only[i] = 1'b0; // 校验位位置先预留为 0
        end else begin
            code_data_only[i] = datain[j];
            j = j + 1;
        end
    end

    // -------------------------------------------------------------------------
    // 2. 核心计算：计算生成校验码 (不管 gen 是何值，我们都需要它)
    // -------------------------------------------------------------------------
    gen_cb = 7'b0;
    for (i = 1; i <= 103; i = i + 1) begin
        if (code_data_only[i] == 1'b1) begin
            gen_cb = gen_cb ^ i[6:0]; // 汉明码基于索引做 XOR
        end
    end
    // 全局校验位 = 数据位异或和 ^ 校验位异或和 (使其整体维持偶校验)
    gen_p_overall = (^code_data_only) ^ (^gen_cb);

    // -------------------------------------------------------------------------
    // 3. 将输入的 chkin 和 datain 拼接成当前接收码字 (用于 check 模式)
    // -------------------------------------------------------------------------
    rx_code = code_data_only;
    rx_code[1]  = chkin[0];
    rx_code[2]  = chkin[1];
    rx_code[4]  = chkin[2];
    rx_code[8]  = chkin[3];
    rx_code[16] = chkin[4];
    rx_code[32] = chkin[5];
    rx_code[64] = chkin[6];

    // 计算 Syndrome (当前输入的校验位 与 标准生成的校验位 做 XOR)
    synd_val = gen_cb ^ chkin[6:0]; 
    p_chk    = gen_p_overall ^ chkin[7]; 
    syndrome = {p_chk, synd_val};

    // 默认赋值：将输入视作已纠错的数据，之后按需翻转
    corrected_code = rx_code;
    corrected_p_overall = chkin[7];

    // =========================================================================
    // 分支逻辑：生成模式 (gen=1) vs 检错纠错模式 (gen=0)
    // =========================================================================
    if (gen == 1'b1) begin
        // --- GENERATE MODE (编码模式) ---
        err_detect = 1'b0;
        err_multpl = 1'b0;
        dataout    = datain;
        chkout     = {gen_p_overall, gen_cb}; // 输出计算得出的8-bit ECC校验码
        
    end else begin
        // --- CHECK & CORRECT MODE (解码、检错与纠错模式) ---
        err_detect = (synd_val != 7'b0) | p_chk;      // 只要不全0就有错
        err_multpl = (synd_val != 7'b0) & (~p_chk);   // 汉明校验有错且全局校验无错 -> 双比特错误！

        // 如果使能了纠错 (active low)，且识别为单比特错误 (p_chk 为 1)
        if (correct_n == 1'b0) begin
            if (p_chk == 1'b1) begin
                if (synd_val == 7'b0) begin
                    // 只有全局校验位出错
                    corrected_p_overall = ~chkin[7];
                end else begin
                    // 数据位或汉明校验位出错，根据 synd_val 指示的索引进行翻转纠正
                    for (i = 1; i <= 103; i = i + 1) begin
                        if (synd_val == i[6:0]) begin
                            corrected_code[i] = ~corrected_code[i];
                        end
                    end
                end
            end
        end

        // 提取纠错（或原样）后的数据发送给 dataout
        j = 0;
        for (i = 1; i <= 103; i = i + 1) begin
            if (!(i == 1 || i == 2 || i == 4 || i == 8 || i == 16 || i == 32 || i == 64)) begin
                dataout[j] = corrected_code[i];
                j = j + 1;
            end
        end

        // 根据 synd_sel 参数决定 chkout 的输出内容
        if (synd_sel == 1) begin
            // 输出伴随式用于分析
            chkout = syndrome; 
        end else begin
            // 输出纠错（或原样）后的 8-bit ECC校验码
            chkout[0] = corrected_code[1];
            chkout[1] = corrected_code[2];
            chkout[2] = corrected_code[4];
            chkout[3] = corrected_code[8];
            chkout[4] = corrected_code[16];
            chkout[5] = corrected_code[32];
            chkout[6] = corrected_code[64];
            chkout[7] = corrected_p_overall;
        end
    end
end

endmodule