// filename: tb_lvds_subsys_cfg.sv
`timescale 1ns / 1ps

module tb_lvds_subsys_cfg;

    //------------------------------------------------------------------------
    // 参数定义
    //------------------------------------------------------------------------

    //------------------------------------------------------------------------
    // 信号声明
    //------------------------------------------------------------------------
    logic [1:0]  CORE_ID;
    logic [1:0]  CORE_ID_NEXT;
    logic        apb_pclk;
    logic [31:0] dout_pre;
    logic        dout_pre_vld;
    logic [32:0] din_pre;
    logic        din_pre_vld;
    logic [31:0] dout_next;
    logic        dout_next_vld;
    logic [32:0] din_next;
    logic        din_next_vld;
    logic        lvds_err_intr;
    logic        o_send_mode;
    logic        axis_brg_clk;
    logic        lvds_tx_bclk;
    logic        scan_mode;
    logic        rstn_raw;

    // AXI-Stream 接口 (Rx)
    logic [95:0] m0_axis_tdata;
    logic        m0_axis_tvalid;
    logic        m0_axis_tready;
    logic [95:0] m1_axis_tdata;
    logic        m1_axis_tvalid;
    logic        m1_axis_tready;
    logic [95:0] m2_axis_tdata;
    logic        m2_axis_tvalid;
    logic        m2_axis_tready;
    logic [95:0] m3_axis_tdata;
    logic        m3_axis_tvalid;
    logic        m3_axis_tready;

    // AXI-Stream 接口 (Tx)
    logic [95:0] s0_axis_tdata;
    logic        s0_axis_tvalid;
    logic        s0_axis_tready;
    logic [95:0] s1_axis_tdata;
    logic        s1_axis_tvalid;
    logic        s1_axis_tready;
    logic [95:0] s2_axis_tdata;
    logic        s2_axis_tvalid;
    logic        s2_axis_tready;
    logic [95:0] s3_axis_tdata;
    logic        s3_axis_tvalid;
    logic        s3_axis_tready;
    
    // delay para (avoid edge conflict)
    int a;

    // LVDS 焊盘 (inout)
    wire RX0_LVDS_CLK_N, RX0_LVDS_CLK_P;
    wire RX0_LVDS_DAT0_N, RX0_LVDS_DAT0_P;
    wire RX0_LVDS_DAT1_N, RX0_LVDS_DAT1_P;
    wire RX0_LVDS_DAT2_N, RX0_LVDS_DAT2_P;
    wire RX0_LVDS_DAT3_N, RX0_LVDS_DAT3_P;
    wire RX0_LVDS_DAT4_N, RX0_LVDS_DAT4_P;
    wire RX1_LVDS_CLK_N, RX1_LVDS_CLK_P;
    wire RX1_LVDS_DAT0_N, RX1_LVDS_DAT0_P;
    wire RX1_LVDS_DAT1_N, RX1_LVDS_DAT1_P;
    wire RX1_LVDS_DAT2_N, RX1_LVDS_DAT2_P;
    wire RX1_LVDS_DAT3_N, RX1_LVDS_DAT3_P;
    wire RX1_LVDS_DAT4_N, RX1_LVDS_DAT4_P;
    wire RX2_LVDS_CLK_N, RX2_LVDS_CLK_P;
    wire RX2_LVDS_DAT0_N, RX2_LVDS_DAT0_P;
    wire RX2_LVDS_DAT1_N, RX2_LVDS_DAT1_P;
    wire RX2_LVDS_DAT2_N, RX2_LVDS_DAT2_P;
    wire RX2_LVDS_DAT3_N, RX2_LVDS_DAT3_P;
    wire RX2_LVDS_DAT4_N, RX2_LVDS_DAT4_P;
    wire TX0_LVDS_CLK_N, TX0_LVDS_CLK_P;
    wire TX0_LVDS_DAT0_N, TX0_LVDS_DAT0_P;
    wire TX0_LVDS_DAT1_N, TX0_LVDS_DAT1_P;
    wire TX0_LVDS_DAT2_N, TX0_LVDS_DAT2_P;
    wire TX0_LVDS_DAT3_N, TX0_LVDS_DAT3_P;
    wire TX0_LVDS_DAT4_N, TX0_LVDS_DAT4_P;
    wire TX1_LVDS_CLK_N, TX1_LVDS_CLK_P;
    wire TX1_LVDS_DAT0_N, TX1_LVDS_DAT0_P;
    wire TX1_LVDS_DAT1_N, TX1_LVDS_DAT1_P;
    wire TX1_LVDS_DAT2_N, TX1_LVDS_DAT2_P;
    wire TX1_LVDS_DAT3_N, TX1_LVDS_DAT3_P;
    wire TX1_LVDS_DAT4_N, TX1_LVDS_DAT4_P;
    wire TX2_LVDS_CLK_N, TX2_LVDS_CLK_P;
    wire TX2_LVDS_DAT0_N, TX2_LVDS_DAT0_P;
    wire TX2_LVDS_DAT1_N, TX2_LVDS_DAT1_P;
    wire TX2_LVDS_DAT2_N, TX2_LVDS_DAT2_P;
    wire TX2_LVDS_DAT3_N, TX2_LVDS_DAT3_P;
    wire TX2_LVDS_DAT4_N, TX2_LVDS_DAT4_P;

    // 连线
    // Loopback for LVDS channel 0
    assign RX0_LVDS_CLK_N   = TX0_LVDS_CLK_N;
    assign RX0_LVDS_CLK_P   = TX0_LVDS_CLK_P;
    assign RX0_LVDS_DAT0_N  = TX0_LVDS_DAT0_N;
    assign RX0_LVDS_DAT0_P  = TX0_LVDS_DAT0_P;
    assign RX0_LVDS_DAT1_N  = TX0_LVDS_DAT1_N;
    assign RX0_LVDS_DAT1_P  = TX0_LVDS_DAT1_P;
    assign RX0_LVDS_DAT2_N  = TX0_LVDS_DAT2_N;
    assign RX0_LVDS_DAT2_P  = TX0_LVDS_DAT2_P;
    assign RX0_LVDS_DAT3_N  = TX0_LVDS_DAT3_N;
    assign RX0_LVDS_DAT3_P  = TX0_LVDS_DAT3_P;
    assign RX0_LVDS_DAT4_N  = TX0_LVDS_DAT4_N;
    assign RX0_LVDS_DAT4_P  = TX0_LVDS_DAT4_P;
    
    // Loopback for LVDS channel 1
    assign RX1_LVDS_CLK_N   = TX1_LVDS_CLK_N;
    assign RX1_LVDS_CLK_P   = TX1_LVDS_CLK_P;
    assign RX1_LVDS_DAT0_N  = TX1_LVDS_DAT0_N;
    assign RX1_LVDS_DAT0_P  = TX1_LVDS_DAT0_P;
    assign RX1_LVDS_DAT1_N  = TX1_LVDS_DAT1_N;
    assign RX1_LVDS_DAT1_P  = TX1_LVDS_DAT1_P;
    assign RX1_LVDS_DAT2_N  = TX1_LVDS_DAT2_N;
    assign RX1_LVDS_DAT2_P  = TX1_LVDS_DAT2_P;
    assign RX1_LVDS_DAT3_N  = TX1_LVDS_DAT3_N;
    assign RX1_LVDS_DAT3_P  = TX1_LVDS_DAT3_P;
    assign RX1_LVDS_DAT4_N  = TX1_LVDS_DAT4_N;
    assign RX1_LVDS_DAT4_P  = TX1_LVDS_DAT4_P;
    
    // Loopback for LVDS channel 2
    assign RX2_LVDS_CLK_N   = TX2_LVDS_CLK_N;
    assign RX2_LVDS_CLK_P   = TX2_LVDS_CLK_P;
    assign RX2_LVDS_DAT0_N  = TX2_LVDS_DAT0_N;
    assign RX2_LVDS_DAT0_P  = TX2_LVDS_DAT0_P;
    assign RX2_LVDS_DAT1_N  = TX2_LVDS_DAT1_N;
    assign RX2_LVDS_DAT1_P  = TX2_LVDS_DAT1_P;
    assign RX2_LVDS_DAT2_N  = TX2_LVDS_DAT2_N;
    assign RX2_LVDS_DAT2_P  = TX2_LVDS_DAT2_P;
    assign RX2_LVDS_DAT3_N  = TX2_LVDS_DAT3_N;
    assign RX2_LVDS_DAT3_P  = TX2_LVDS_DAT3_P;
    assign RX2_LVDS_DAT4_N  = TX2_LVDS_DAT4_N;
    assign RX2_LVDS_DAT4_P  = TX2_LVDS_DAT4_P;
    
    //------------------------------------------------------------------------
    // DUT 实例化
    //------------------------------------------------------------------------
    lvds_subsys u_dut (
        .CORE_ID                ( CORE_ID                ),
        .CORE_ID_NEXT           ( CORE_ID_NEXT           ),
        .apb_pclk               ( apb_pclk               ),
        .dout_pre               ( dout_pre               ),
        .dout_pre_vld           ( dout_pre_vld           ),
        .din_pre                ( din_pre                ),
        .din_pre_vld            ( din_pre_vld            ),
        .dout_next              ( dout_next              ),
        .dout_next_vld          ( dout_next_vld          ),
        .din_next               ( din_next               ),
        .din_next_vld           ( din_next_vld           ),
        .lvds_err_intr          ( lvds_err_intr          ),
        .o_send_mode            ( o_send_mode            ),
        .axis_brg_clk           ( axis_brg_clk           ),
        .lvds_tx_bclk           ( lvds_tx_bclk           ),
        .scan_mode              ( scan_mode              ),
        .rstn_raw               ( rstn_raw               ),
        .m0_axis_tdata          ( m0_axis_tdata          ),
        .m0_axis_tvalid         ( m0_axis_tvalid         ),
        .m0_axis_tready         ( m0_axis_tready         ),
        .m1_axis_tdata          ( m1_axis_tdata          ),
        .m1_axis_tvalid         ( m1_axis_tvalid         ),
        .m1_axis_tready         ( m1_axis_tready         ),
        .m2_axis_tdata          ( m2_axis_tdata          ),
        .m2_axis_tvalid         ( m2_axis_tvalid         ),
        .m2_axis_tready         ( m2_axis_tready         ),
        .m3_axis_tdata          ( m3_axis_tdata          ),
        .m3_axis_tvalid         ( m3_axis_tvalid         ),
        .m3_axis_tready         ( m3_axis_tready         ),
        .s0_axis_tdata          ( s0_axis_tdata          ),
        .s0_axis_tvalid         ( s0_axis_tvalid         ),
        .s0_axis_tready         ( s0_axis_tready         ),
        .s1_axis_tdata          ( s1_axis_tdata          ),
        .s1_axis_tvalid         ( s1_axis_tvalid         ),
        .s1_axis_tready         ( s1_axis_tready         ),
        .s2_axis_tdata          ( s2_axis_tdata          ),
        .s2_axis_tvalid         ( s2_axis_tvalid         ),
        .s2_axis_tready         ( s2_axis_tready         ),
        .s3_axis_tdata          ( s3_axis_tdata          ),
        .s3_axis_tvalid         ( s3_axis_tvalid         ),
        .s3_axis_tready         ( s3_axis_tready         ),
        .RX0_LVDS_CLK_N         ( RX0_LVDS_CLK_N         ),
        .RX0_LVDS_CLK_P         ( RX0_LVDS_CLK_P         ),
        .RX0_LVDS_DAT0_N        ( RX0_LVDS_DAT0_N        ),
        .RX0_LVDS_DAT0_P        ( RX0_LVDS_DAT0_P        ),
        .RX0_LVDS_DAT1_N        ( RX0_LVDS_DAT1_N        ),
        .RX0_LVDS_DAT1_P        ( RX0_LVDS_DAT1_P        ),
        .RX0_LVDS_DAT2_N        ( RX0_LVDS_DAT2_N        ),
        .RX0_LVDS_DAT2_P        ( RX0_LVDS_DAT2_P        ),
        .RX0_LVDS_DAT3_N        ( RX0_LVDS_DAT3_N        ),
        .RX0_LVDS_DAT3_P        ( RX0_LVDS_DAT3_P        ),
        .RX0_LVDS_DAT4_N        ( RX0_LVDS_DAT4_N        ),
        .RX0_LVDS_DAT4_P        ( RX0_LVDS_DAT4_P        ),
        .RX1_LVDS_CLK_N         ( RX1_LVDS_CLK_N         ),
        .RX1_LVDS_CLK_P         ( RX1_LVDS_CLK_P         ),
        .RX1_LVDS_DAT0_N        ( RX1_LVDS_DAT0_N        ),
        .RX1_LVDS_DAT0_P        ( RX1_LVDS_DAT0_P        ),
        .RX1_LVDS_DAT1_N        ( RX1_LVDS_DAT1_N        ),
        .RX1_LVDS_DAT1_P        ( RX1_LVDS_DAT1_P        ),
        .RX1_LVDS_DAT2_N        ( RX1_LVDS_DAT2_N        ),
        .RX1_LVDS_DAT2_P        ( RX1_LVDS_DAT2_P        ),
        .RX1_LVDS_DAT3_N        ( RX1_LVDS_DAT3_N        ),
        .RX1_LVDS_DAT3_P        ( RX1_LVDS_DAT3_P        ),
        .RX1_LVDS_DAT4_N        ( RX1_LVDS_DAT4_N        ),
        .RX1_LVDS_DAT4_P        ( RX1_LVDS_DAT4_P        ),
        .RX2_LVDS_CLK_N         ( RX2_LVDS_CLK_N         ),
        .RX2_LVDS_CLK_P         ( RX2_LVDS_CLK_P         ),
        .RX2_LVDS_DAT0_N        ( RX2_LVDS_DAT0_N        ),
        .RX2_LVDS_DAT0_P        ( RX2_LVDS_DAT0_P        ),
        .RX2_LVDS_DAT1_N        ( RX2_LVDS_DAT1_N        ),
        .RX2_LVDS_DAT1_P        ( RX2_LVDS_DAT1_P        ),
        .RX2_LVDS_DAT2_N        ( RX2_LVDS_DAT2_N        ),
        .RX2_LVDS_DAT2_P        ( RX2_LVDS_DAT2_P        ),
        .RX2_LVDS_DAT3_N        ( RX2_LVDS_DAT3_N        ),
        .RX2_LVDS_DAT3_P        ( RX2_LVDS_DAT3_P        ),
        .RX2_LVDS_DAT4_N        ( RX2_LVDS_DAT4_N        ),
        .RX2_LVDS_DAT4_P        ( RX2_LVDS_DAT4_P        ),
        .TX0_LVDS_CLK_N         ( TX0_LVDS_CLK_N         ),
        .TX0_LVDS_CLK_P         ( TX0_LVDS_CLK_P         ),
        .TX0_LVDS_DAT0_N        ( TX0_LVDS_DAT0_N        ),
        .TX0_LVDS_DAT0_P        ( TX0_LVDS_DAT0_P        ),
        .TX0_LVDS_DAT1_N        ( TX0_LVDS_DAT1_N        ),
        .TX0_LVDS_DAT1_P        ( TX0_LVDS_DAT1_P        ),
        .TX0_LVDS_DAT2_N        ( TX0_LVDS_DAT2_N        ),
        .TX0_LVDS_DAT2_P        ( TX0_LVDS_DAT2_P        ),
        .TX0_LVDS_DAT3_N        ( TX0_LVDS_DAT3_N        ),
        .TX0_LVDS_DAT3_P        ( TX0_LVDS_DAT3_P        ),
        .TX0_LVDS_DAT4_N        ( TX0_LVDS_DAT4_N        ),
        .TX0_LVDS_DAT4_P        ( TX0_LVDS_DAT4_P        ),
        .TX1_LVDS_CLK_N         ( TX1_LVDS_CLK_N         ),
        .TX1_LVDS_CLK_P         ( TX1_LVDS_CLK_P         ),
        .TX1_LVDS_DAT0_N        ( TX1_LVDS_DAT0_N        ),
        .TX1_LVDS_DAT0_P        ( TX1_LVDS_DAT0_P        ),
        .TX1_LVDS_DAT1_N        ( TX1_LVDS_DAT1_N        ),
        .TX1_LVDS_DAT1_P        ( TX1_LVDS_DAT1_P        ),
        .TX1_LVDS_DAT2_N        ( TX1_LVDS_DAT2_N        ),
        .TX1_LVDS_DAT2_P        ( TX1_LVDS_DAT2_P        ),
        .TX1_LVDS_DAT3_N        ( TX1_LVDS_DAT3_N        ),
        .TX1_LVDS_DAT3_P        ( TX1_LVDS_DAT3_P        ),
        .TX1_LVDS_DAT4_N        ( TX1_LVDS_DAT4_N        ),
        .TX1_LVDS_DAT4_P        ( TX1_LVDS_DAT4_P        ),
        .TX2_LVDS_CLK_N         ( TX2_LVDS_CLK_N         ),
        .TX2_LVDS_CLK_P         ( TX2_LVDS_CLK_P         ),
        .TX2_LVDS_DAT0_N        ( TX2_LVDS_DAT0_N        ),
        .TX2_LVDS_DAT0_P        ( TX2_LVDS_DAT0_P        ),
        .TX2_LVDS_DAT1_N        ( TX2_LVDS_DAT1_N        ),
        .TX2_LVDS_DAT1_P        ( TX2_LVDS_DAT1_P        ),
        .TX2_LVDS_DAT2_N        ( TX2_LVDS_DAT2_N        ),
        .TX2_LVDS_DAT2_P        ( TX2_LVDS_DAT2_P        ),
        .TX2_LVDS_DAT3_N        ( TX2_LVDS_DAT3_N        ),
        .TX2_LVDS_DAT3_P        ( TX2_LVDS_DAT3_P        ),
        .TX2_LVDS_DAT4_N        ( TX2_LVDS_DAT4_N        ),
        .TX2_LVDS_DAT4_P        ( TX2_LVDS_DAT4_P        )
    );
    
    // 信号声明
    logic                      send_start;

    // 实例化 axis_master
    axis_master #(
        .DATA_WIDTH ( 96 ),
        .BURST_LEN  ( 6  )
    ) u_axis_master_0 (
        .clk    ( axis_brg_clk    ),
        .rst_n  ( rstn_raw  ),
        .tdata  ( s0_axis_tdata  ),
        .tvalid ( s0_axis_tvalid ),
        .tready ( s0_axis_tready ),
        .start  ( send_start  )
    );
    
//    // 实例化 axis_master
//    axis_master #(
//        .DATA_WIDTH ( 96 ),
//        .BURST_LEN  ( 6  )
//    ) u_axis_master_1 (
//        .clk    ( axis_brg_clk    ),
//        .rst_n  ( rstn_raw  ),
//        .tdata  ( s1_axis_tdata  ),
//        .tvalid ( s1_axis_tvalid ),
//        .tready ( s1_axis_tready ),
//        .start  ( send_start  )
//    );
    
//    // 实例化 axis_master
//    axis_master #(
//        .DATA_WIDTH ( 96 ),
//        .BURST_LEN  ( 6  )
//    ) u_axis_master_2 (
//        .clk    ( axis_brg_clk    ),
//        .rst_n  ( rstn_raw  ),
//        .tdata  ( s2_axis_tdata  ),
//        .tvalid ( s2_axis_tvalid ),
//        .tready ( s2_axis_tready ),
//        .start  ( send_start  )
//    );
    
//    // 实例化 axis_master
//    axis_master #(
//        .DATA_WIDTH ( 96 ),
//        .BURST_LEN  ( 6  )
//    ) u_axis_master_3 (
//        .clk    ( axis_brg_clk    ),
//        .rst_n  ( rstn_raw  ),
//        .tdata  ( s3_axis_tdata  ),
//        .tvalid ( s3_axis_tvalid ),
//        .tready ( s3_axis_tready ),
//        .start  ( send_start  )
//    );

    //------------------------------------------------------------------------
    // 时钟生成
    //------------------------------------------------------------------------
    initial begin
        apb_pclk      = 0;
        axis_brg_clk  = 0;
        lvds_tx_bclk  = 0;
        forever begin
            #10 apb_pclk = ~apb_pclk;      // 50MHz
        end
    end

    initial begin
        forever begin
            #1 axis_brg_clk = ~axis_brg_clk;  // 500MHz
        end
    end

    initial begin
        forever begin
            #0.5 lvds_tx_bclk = ~lvds_tx_bclk; // 1000MHz
        end
    end

    //------------------------------------------------------------------------
    // 主测试流程（用户填充）
    //------------------------------------------------------------------------
    initial begin
        // 初始化所有输入信号
        CORE_ID       = 2'b00;
        din_pre       = '0;
        din_pre_vld   = 0;
        dout_next     = '0;
        dout_next_vld = 0;
        scan_mode     = 0;
        rstn_raw      = 0;       // 初始复位
        m0_axis_tready= 1;
        m1_axis_tready= 1;
        m2_axis_tready= 1;
        m3_axis_tready= 1;
//        s0_axis_tdata = 0;
//        s0_axis_tvalid= 0;
        s1_axis_tdata = 0;
        s1_axis_tvalid= 0;
        s2_axis_tdata = 0;
        s2_axis_tvalid= 0;
        s3_axis_tdata = 0;
        s3_axis_tvalid= 0;
        send_start    = 0;

        // 用户自定义初始化代码
        // =====================================
        // TODO: 添加您的初始化内容（例如复位释放时序、配置序列等）
        // =====================================

        // 示例：复位释放
        repeat(10) @(posedge apb_pclk);
        rstn_raw = 1;
        $display("[INFO] Reset released");
        repeat(5) @(posedge apb_pclk);

        // 使能lvds 0~3 复位信号
        // 地址 25'h0000004，core_id=0，burst_hit=0
        send_addr_write(25'h0000004, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x004, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000210a);
        $display("[INFO] Data packet sent: data=0x0000210a");
        
        // 地址 25'h0000024，core_id=0，burst_hit=0
        send_addr_write(25'h0000024, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x024, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000210a);
        $display("[INFO] Data packet sent: data=0x0000210a");
        
        // 地址 25'h0000044，core_id=0，burst_hit=0
        send_addr_write(25'h0000044, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x044, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000210a);
        $display("[INFO] Data packet sent: data=0x0000210a");
        
        // 配置自动校准参数
        // 地址 25'h0000100，core_id=0，burst_hit=0
        send_addr_write(25'h0000100, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x100, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h06001604);
        $display("[INFO] Data packet sent: data=0x06001604");
        
        // 地址 25'h0000110，core_id=0，burst_hit=0
        send_addr_write(25'h0000110, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x110, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h06001604);
        $display("[INFO] Data packet sent: data=0x06001604");
        
        // 地址 25'h0000120，core_id=0，burst_hit=0
        send_addr_write(25'h0000120, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x110, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h06001604);
        $display("[INFO] Data packet sent: data=0x06001604");
        
        // 预配值参数
        // 地址 25'h0000010，core_id=0，burst_hit=0
        send_addr_write(25'h0000010, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x010, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h00008000);
        $display("[INFO] Data packet sent: data=0x00008000");
        
        // 地址 25'h0000030，core_id=0，burst_hit=0
        send_addr_write(25'h0000030, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x030, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h00008000);
        $display("[INFO] Data packet sent: data=0x00008000");
        
        // 地址 25'h0000050，core_id=0，burst_hit=0
        send_addr_write(25'h0000050, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x050, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h00008000);
        $display("[INFO] Data packet sent: data=0x00008000");
        
        // 并行模式设置（turn off）
        // 地址 25'h0000000，core_id=0，burst_hit=0
        send_addr_write(25'h0000000, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x000, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h00000000);
        $display("[INFO] Data packet sent: data=0x00000110");
        
        // 释放lvds 0~3 复位信号
        // 地址 25'h0000004，core_id=0，burst_hit=0
        send_addr_write(25'h0000004, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x004, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000211f);
        $display("[INFO] Data packet sent: data=0x0000211f");
        
        // 地址 25'h0000024，core_id=0，burst_hit=0
        send_addr_write(25'h0000024, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x024, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000211f);
        $display("[INFO] Data packet sent: data=0x0000211f");
        
        // 地址 25'h0000044，core_id=0，burst_hit=0
        send_addr_write(25'h0000044, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x044, core_id=0, write=1");

        // 发送数据包
        send_write_data(32'h0000211f);
        $display("[INFO] Data packet sent: data=0x0000211f");

       // wait (rtl level simulation)
       #40000;
//         wait (netlist simulation)
//         #285000;
        
        // check calib done signal
        send_addr_read(25'h0000120, CORE_ID, 0);
        $display("[INFO] Address packet sent: addr=0x120, core_id=0, write=0");
        
        send_start = 1;
        #5;
        send_start = 0;
        
        // 仿真结束
        #10000;
        $finish;
    end
    
//    // 监控 APB 读写操作，并打印匹配信息
//    logic [31:0] expected_data;
//    logic [24:0] expected_addr;
//    initial begin
//        expected_addr = 25'h0000004;  // 10'h130 扩展为 25 位
//        expected_data = 32'h0000210a;
//    end
    
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
        @(posedge apb_pclk);
        din_pre_vld = 0;
        a = $urandom_range(10, 80);
        #a;
        repeat(2) @(posedge apb_pclk);
    endtask

    // 测试任务：发送数据包
    task send_write_data(input [31:0] data);
        din_pre = {1'b0, data};  // [32]=0 数据包，低32位为数据
        din_pre_vld = 1;
        @(posedge apb_pclk);
        din_pre_vld = 0;
        a = $urandom_range(10, 80);
        #a;
        repeat(4) @(posedge apb_pclk);
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
        a = $urandom_range(10, 80);
        #a;
        @(posedge apb_pclk);
        din_pre_vld = 0;
        #50;
        repeat(6) @(posedge apb_pclk);
    endtask

endmodule