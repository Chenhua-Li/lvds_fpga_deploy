// filename: tb_lvds_core_cfg_wrap.sv
`timescale 1ns / 1ps

module tb_lvds_core_cfg_wrap;

    // 时钟和复位
    logic clk;
    logic rstn;

    // 配置参数
    logic [1:0] CORE_ID;
    logic [1:0] CORE_ID_NEXT;

    // 上游接口（pre level）
    logic [31:0] dout_pre;
    logic        dout_pre_vld;
    logic [32:0] din_pre;
    logic        din_pre_vld;

    // 下游接口（next level）
    logic [31:0] dout_next;
    logic        dout_next_vld;
    logic [32:0] din_next;
    logic        din_next_vld;

    // APB 从机响应（模拟寄存器）
    logic        apb_psel;
    logic        apb_penable;
    logic        apb_pwrite;
    logic [24:0] apb_paddr;
    logic [31:0] apb_pwdata;
    logic        apb_pready;
    logic [31:0] apb_prdata;
    
    int a;

    // 实例化待测模块
    lvds_core_cfg_wrap u_dut (
        .clk            (clk),
        .rstn           (rstn),
        .CORE_ID        (CORE_ID),
        .CORE_ID_NEXT   (CORE_ID_NEXT),

        .dout_pre       (dout_pre),
        .dout_pre_vld   (dout_pre_vld),
        .din_pre        (din_pre),
        .din_pre_vld    (din_pre_vld),

        .dout_next      (dout_next),
        .dout_next_vld  (dout_next_vld),
        .din_next       (din_next),
        .din_next_vld   (din_next_vld),

        .apb_psel       (apb_psel),
        .apb_penable    (apb_penable),
        .apb_pwrite     (apb_pwrite),
        .apb_paddr      (apb_paddr),
        .apb_pwdata     (apb_pwdata),
        .apb_pready     (apb_pready),
        .apb_prdata     (apb_prdata)
    );

    // 时钟生成：100MHz
    always #5 clk = ~clk;

    // 简单 APB 从机：零等待，仅用于写检查
    // 注意：此处 prdata 保持 0（读操作未使用）
    assign apb_pready = apb_psel & apb_penable;
    assign apb_prdata = 32'h0;

    // 监控 APB 写操作，并打印匹配信息
    logic [31:0] expected_data;
    logic [24:0] expected_addr;
    initial begin
        expected_addr = 25'h0000130;  // 10'h130 扩展为 25 位
        expected_data = 32'hffffff17;
    end

    always @(posedge clk) begin
        if (apb_psel && apb_penable && apb_pwrite && apb_pready) begin
            if (apb_paddr === expected_addr && apb_pwdata === expected_data)
                $display("[PASS] APB write matched: addr=0x%0h, data=0x%0h at time %t", 
                         apb_paddr, apb_pwdata, $time);
            else
                $display("[FAIL] APB write mismatch: addr=0x%0h (exp 0x%0h), data=0x%0h (exp 0x%0h)", 
                         apb_paddr, expected_addr, apb_pwdata, expected_data);
        end
    end
    
    // 测试任务：发送地址包 (写操作)
    task send_addr_write(input [24:0] addr, input [1:0] core_id, input burst_hit = 0);
        // 构造地址包：bit32=1 (地址), bit31=burst_hit, bit[27:26]=core_id, bit25=1 (写), bit[24:0]=addr
        din_pre = {1'b1,                    // [32] address flag
                   burst_hit,               // [31] burst_hit
                   1'b0,                   // [30] unused
                   2'b00,                  // [29:28] unused
                   core_id[1:0],           // [27:26] core_id
                   1'b1,                   // [25] op_is_write = 1
                   addr[24:0]};            // [24:0] address
        din_pre_vld = 1;
        @(posedge clk);
        din_pre_vld = 0;
        a = $urandom_range(10, 80);
        #a;
    endtask

    // 测试任务：发送数据包
    task send_write_data(input [31:0] data);
        din_pre = {1'b0, data};  // [32]=0 数据包，低32位为数据
        din_pre_vld = 1;
        @(posedge clk);
        din_pre_vld = 0;
    endtask
    
    task send_addr_read(input [24:0] addr, input [1:0] core_id, input burst_hit = 0);
        // 构造地址包：bit32=1 (地址), bit31=burst_hit, bit[27:26]=core_id, bit25=1 (写), bit[24:0]=addr
        din_pre = {1'b1,                    // [32] address flag
                   burst_hit,               // [31] burst_hit
                   1'b0,                   // [30] unused
                   2'b00,                  // [29:28] unused
                   core_id[1:0],           // [27:26] core_id
                   1'b0,                   // [25] op_is_write = 1
                   addr[24:0]};            // [24:0] address
        din_pre_vld = 1;
        @(posedge clk);
        din_pre_vld = 0;
        a = $urandom_range(10, 80);
        #a;
    endtask

    // 主测试流程
    initial begin
        // 初始化所有信号
        clk = 0;
        rstn = 0;
        CORE_ID = 2'b00;
        din_pre = '0;
        din_pre_vld = 0;
        dout_next = '0;
        dout_next_vld = 0;

        // 复位释放
        repeat(5) @(posedge clk);
        rstn = 1;
        @(posedge clk);
        $display("[INFO] Reset released");

        // 步骤1：发送地址包
        // 地址 25'h0000130，core_id=0，burst_hit=0
        send_addr_write(25'h0000130, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x130, core_id=0, write=1");

        // 地址包需要两个周期才能让内部 wait_data_cur 置位，因此等待最少2个周期再发数据包
        repeat(2) @(posedge clk);

        // 步骤2：发送数据包
        send_write_data(32'hffffff17);
        $display("[INFO] Data packet sent: data=0xffffff17");

        // 等待检测 APB 事务状态
        repeat(4) @(posedge clk);

        // 检查是否有 APB 写匹配
        if (apb_paddr === expected_addr && apb_pwdata === expected_data && apb_pwrite)
            $display("[SUCCESS] Testbench finished: Write operation verified.");
        else
            $display("[ERROR] Testbench finished: Write operation not observed or mismatch.");
        
        repeat(10) @(posedge clk);
        
        send_addr_read(25'h0000130, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x130, core_id=0, write=0");
        
        // 等待检测 APB 事务状态
        repeat(6) @(posedge clk);
        
        // 检查是否有 APB 读匹配
        if (apb_paddr === expected_addr && apb_prdata === expected_data && !apb_pwrite)
            $display("[SUCCESS] Testbench finished: Read operation verified.");
        else
            $display("[ERROR] Testbench finished: Read operation not observed or mismatch.");
        
        repeat(10) @(posedge clk);
        
        $finish;
    end

endmodule