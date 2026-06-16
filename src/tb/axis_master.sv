module axis_master #(
    parameter DATA_WIDTH = 96,
    parameter BURST_LEN  = 6       // 要发送的数据个数
)(
    input  wire                     clk,
    input  wire                     rst_n,
    // AXI Stream 接口
    output reg  [DATA_WIDTH-1:0]    tdata,
    output reg                      tvalid,
    input  wire                     tready,
    // 控制信号（可选，用于启动传输）
    input  wire                     start
);
    // 内部计数器
    reg [$clog2(BURST_LEN):0]       cnt;
    reg                             sending;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sending <= 1'b0;
            cnt     <= 0;
            tvalid  <= 1'b0;
            tdata   <= 0;
        end else begin
            // 启动传输：当 start 脉冲到来且未发送时，进入发送状态
            if (start && !sending) begin
                sending <= 1'b1;
                cnt     <= 0;
                tvalid  <= 1'b1;
                tdata   <= 96'h111122223333444455556666;      // 第一个数据，可根据需求赋值
            end
            // 发送过程中握手成功
            else if (sending && tvalid && tready) begin
                if (cnt == BURST_LEN - 1) begin
                    // 最后一个数据发送完成，结束传输
                    sending <= 1'b0;
                    tvalid  <= 1'b0;
                end else begin
                    // 准备下一个数据
                    cnt <= cnt + 1;
                    tdata <= tdata << 16;   // 示例：数据移位
                end
            end
        end
    end
endmodule