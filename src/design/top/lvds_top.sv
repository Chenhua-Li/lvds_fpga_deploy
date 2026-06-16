`timescale 1ns / 1ps

module lvds_top (
    // 系统时钟
    input                                           Sys_Clk,
    
    // LVDS IO 管脚（双向inout）
    inout                                           RX0_LVDS_CLK_N,
    inout                                           RX0_LVDS_CLK_P,
    inout                                           RX0_LVDS_DAT0_N,
    inout                                           RX0_LVDS_DAT0_P,
    inout                                           RX0_LVDS_DAT1_N,
    inout                                           RX0_LVDS_DAT1_P,
    inout                                           RX0_LVDS_DAT2_N,
    inout                                           RX0_LVDS_DAT2_P,
    inout                                           RX0_LVDS_DAT3_N,
    inout                                           RX0_LVDS_DAT3_P,
    inout                                           RX0_LVDS_DAT4_N,
    inout                                           RX0_LVDS_DAT4_P,
    
    inout                                           RX1_LVDS_CLK_N,
    inout                                           RX1_LVDS_CLK_P,
    inout                                           RX1_LVDS_DAT0_N,
    inout                                           RX1_LVDS_DAT0_P,
    inout                                           RX1_LVDS_DAT1_N,
    inout                                           RX1_LVDS_DAT1_P,
    inout                                           RX1_LVDS_DAT2_N,
    inout                                           RX1_LVDS_DAT2_P,
    inout                                           RX1_LVDS_DAT3_N,
    inout                                           RX1_LVDS_DAT3_P,
    inout                                           RX1_LVDS_DAT4_N,
    inout                                           RX1_LVDS_DAT4_P,
    
    inout                                           RX2_LVDS_CLK_N,
    inout                                           RX2_LVDS_CLK_P,
    inout                                           RX2_LVDS_DAT0_N,
    inout                                           RX2_LVDS_DAT0_P,
    inout                                           RX2_LVDS_DAT1_N,
    inout                                           RX2_LVDS_DAT1_P,
    inout                                           RX2_LVDS_DAT2_N,
    inout                                           RX2_LVDS_DAT2_P,
    inout                                           RX2_LVDS_DAT3_N,
    inout                                           RX2_LVDS_DAT3_P,
    inout                                           RX2_LVDS_DAT4_N,
    inout                                           RX2_LVDS_DAT4_P,
    
    inout                                           TX0_LVDS_CLK_N,
    inout                                           TX0_LVDS_CLK_P,
    inout                                           TX0_LVDS_DAT0_N,
    inout                                           TX0_LVDS_DAT0_P,
    inout                                           TX0_LVDS_DAT1_N,
    inout                                           TX0_LVDS_DAT1_P,
    inout                                           TX0_LVDS_DAT2_N,
    inout                                           TX0_LVDS_DAT2_P,
    inout                                           TX0_LVDS_DAT3_N,
    inout                                           TX0_LVDS_DAT3_P,
    inout                                           TX0_LVDS_DAT4_N,
    inout                                           TX0_LVDS_DAT4_P,
    
    inout                                           TX1_LVDS_CLK_N,
    inout                                           TX1_LVDS_CLK_P,
    inout                                           TX1_LVDS_DAT0_N,
    inout                                           TX1_LVDS_DAT0_P,
    inout                                           TX1_LVDS_DAT1_N,
    inout                                           TX1_LVDS_DAT1_P,
    inout                                           TX1_LVDS_DAT2_N,
    inout                                           TX1_LVDS_DAT2_P,
    inout                                           TX1_LVDS_DAT3_N,
    inout                                           TX1_LVDS_DAT3_P,
    inout                                           TX1_LVDS_DAT4_N,
    inout                                           TX1_LVDS_DAT4_P,
    
    inout                                           TX2_LVDS_CLK_N,
    inout                                           TX2_LVDS_CLK_P,
    inout                                           TX2_LVDS_DAT0_N,
    inout                                           TX2_LVDS_DAT0_P,
    inout                                           TX2_LVDS_DAT1_N,
    inout                                           TX2_LVDS_DAT1_P,
    inout                                           TX2_LVDS_DAT2_N,
    inout                                           TX2_LVDS_DAT2_P,
    inout                                           TX2_LVDS_DAT3_N,
    inout                                           TX2_LVDS_DAT3_P,
    inout                                           TX2_LVDS_DAT4_N,
    inout                                           TX2_LVDS_DAT4_P
);

//logic [1:0] CORE_ID_NEXT;
// clk
logic apb_pclk;
logic axis_brg_clk;
logic lvds_tx_bclk;

// virtual io 0
logic [31:0]                        dout_pre;
logic                               dout_pre_vld;
logic [32:0]                        din_pre;
logic                               din_pre_vld;
    
logic [31:0]                        dout_next;
logic                               dout_next_vld;
logic [32:0]                        din_next;
logic                               din_next_vld;
    
logic                               lvds_err_intr;
logic                               o_send_mode;
     
logic                               scan_mode;
logic                               rstn_raw;

// virtual io 1
logic      [95:0]                              m0_axis_tdata;
logic                                          m0_axis_tvalid;
logic                                           m0_axis_tready;
logic      [95:0]                              m1_axis_tdata;
logic                                          m1_axis_tvalid;
logic                                           m1_axis_tready;
logic      [95:0]                              m2_axis_tdata;
logic                                          m2_axis_tvalid;
logic                                           m2_axis_tready;
logic      [95:0]                              m3_axis_tdata;
logic                                          m3_axis_tvalid;
logic                                           m3_axis_tready;

logic       [95:0]                              s0_axis_tdata;
logic       [95:0]                              s1_axis_tdata;
logic       [95:0]                              s2_axis_tdata;
logic       [95:0]                              s3_axis_tdata;
logic                                           s0_axis_tvalid;
logic                                           s1_axis_tvalid;
logic                                           s2_axis_tvalid;
logic                                           s3_axis_tvalid;
logic                                          s0_axis_tready;
logic                                          s1_axis_tready;
logic                                          s2_axis_tready;
logic                                          s3_axis_tready;

clk_wiz_0 clk_gen_0(
    // Clock out ports
    .apb_pclk(apb_pclk),     // output apb_pclk
    .axis_brg_clk(axis_brg_clk),     // output axis_brg_clk
    .lvds_tx_bclk(lvds_tx_bclk),     // output lvds_tx_bclk
    // Clock in ports
    .clk_in1(Sys_Clk)    // input clk_in1
);

// virtual io
vio_0 virtual_io_0 (
  .clk(apb_pclk),                // input wire clk
  .probe_in0(dout_pre),    // input wire [31 : 0] probe_in0
  .probe_in1(dout_pre_vld),    // input wire [0 : 0] probe_in1
  .probe_in2(din_next),    // input wire [32 : 0] probe_in2
  .probe_in3(din_next_vld),    // input wire [0 : 0] probe_in3
  .probe_in4(lvds_err_intr),    // input wire [0 : 0] probe_in4
  .probe_in5(o_send_mode),    // input wire [0 : 0] probe_in5
  .probe_out0(din_pre),  // output wire [32 : 0] probe_out0
  .probe_out1(din_pre_vld),  // output wire [0 : 0] probe_out1
  .probe_out2(dout_next),  // output wire [31 : 0] probe_out2
  .probe_out3(dout_next_vld),  // output wire [0 : 0] probe_out3
  .probe_out4(scan_mode),  // output wire [0 : 0] probe_out4
  .probe_out5(rstn_raw)  // output wire [0 : 0] probe_out5
);

vio_1 virtual_io_1 (
  .clk(axis_brg_clk),                  // input wire clk
  .probe_in0(m0_axis_tdata),      // input wire [95 : 0] probe_in0
  .probe_in1(m0_axis_tvalid),      // input wire [0 : 0] probe_in1
  .probe_in2(m1_axis_tdata),      // input wire [95 : 0] probe_in2
  .probe_in3(m1_axis_tvalid),      // input wire [0 : 0] probe_in3
  .probe_in4(m2_axis_tdata),      // input wire [95 : 0] probe_in4
  .probe_in5(m2_axis_tvalid),      // input wire [0 : 0] probe_in5
  .probe_in6(m3_axis_tdata),      // input wire [95 : 0] probe_in6
  .probe_in7(m3_axis_tvalid),      // input wire [0 : 0] probe_in7
  .probe_in8(s0_axis_tready),      // input wire [0 : 0] probe_in8
  .probe_in9(s1_axis_tready),      // input wire [0 : 0] probe_in9
  .probe_in10(s2_axis_tready),    // input wire [0 : 0] probe_in10
  .probe_in11(s3_axis_tready),    // input wire [0 : 0] probe_in11
  .probe_out0(m0_axis_tready),    // output wire [0 : 0] probe_out0
  .probe_out1(m1_axis_tready),    // output wire [0 : 0] probe_out1
  .probe_out2(m2_axis_tready),    // output wire [0 : 0] probe_out2
  .probe_out3(m3_axis_tready),    // output wire [0 : 0] probe_out3
  .probe_out4(s0_axis_tdata),    // output wire [95 : 0] probe_out4
  .probe_out5(s0_axis_tvalid),    // output wire [0 : 0] probe_out5
  .probe_out6(s1_axis_tdata),    // output wire [95 : 0] probe_out6
  .probe_out7(s1_axis_tvalid),    // output wire [0 : 0] probe_out7
  .probe_out8(s2_axis_tdata),    // output wire [95 : 0] probe_out8
  .probe_out9(s2_axis_tvalid),    // output wire [0 : 0] probe_out9
  .probe_out10(s3_axis_tdata),  // output wire [95 : 0] probe_out10
  .probe_out11(s3_axis_tvalid)  // output wire [0 : 0] probe_out11
);

lvds_subsys u_lvds_subsys (
    // 核心ID
    .CORE_ID                (2'b00                  ),
    .CORE_ID_NEXT           (                       ),
    
    // APB时钟
    .apb_pclk               (apb_pclk               ),
    
    // 上游级联
    .dout_pre               (dout_pre               ),
    .dout_pre_vld           (dout_pre_vld           ),
    .din_pre                (din_pre                ),
    .din_pre_vld            (din_pre_vld            ),
    
    // 下游级联
    .dout_next              (dout_next              ),
    .dout_next_vld          (dout_next_vld          ),
    .din_next               (din_next               ),
    .din_next_vld           (din_next_vld           ),
    
    // 中断与控制
    .lvds_err_intr          (lvds_err_intr          ),
    .o_send_mode            (o_send_mode            ),
    
    // 时钟
    .axis_brg_clk           (axis_brg_clk           ),
    .lvds_tx_bclk           (lvds_tx_bclk           ),
    
    // 测试与复位
    .scan_mode              (1'b0                   ),
    .rstn_raw               (rstn_raw               ),
    
    // RX AXIS
    .m0_axis_tdata          (m0_axis_tdata          ),
    .m0_axis_tvalid         (m0_axis_tvalid         ),
    .m0_axis_tready         (m0_axis_tready         ),
    .m1_axis_tdata          (m1_axis_tdata          ),
    .m1_axis_tvalid         (m1_axis_tvalid         ),
    .m1_axis_tready         (m1_axis_tready         ),
    .m2_axis_tdata          (m2_axis_tdata          ),
    .m2_axis_tvalid         (m2_axis_tvalid         ),
    .m2_axis_tready         (m2_axis_tready         ),
    .m3_axis_tdata          (m3_axis_tdata          ),
    .m3_axis_tvalid         (m3_axis_tvalid         ),
    .m3_axis_tready         (m3_axis_tready         ),
    
    // TX AXIS
    .s0_axis_tdata          (s0_axis_tdata          ),
    .s0_axis_tvalid         (s0_axis_tvalid         ),
    .s0_axis_tready         (s0_axis_tready         ),
    .s1_axis_tdata          (s1_axis_tdata          ),
    .s1_axis_tvalid         (s1_axis_tvalid         ),
    .s1_axis_tready         (s1_axis_tready         ),
    .s2_axis_tdata          (s2_axis_tdata          ),
    .s2_axis_tvalid         (s2_axis_tvalid         ),
    .s2_axis_tready         (s2_axis_tready         ),
    .s3_axis_tdata          (s3_axis_tdata          ),
    .s3_axis_tvalid         (s3_axis_tvalid         ),
    .s3_axis_tready         (s3_axis_tready         ),
    
    // LVDS 双向管脚
    .RX0_LVDS_CLK_N         (RX0_LVDS_CLK_N         ),
    .RX0_LVDS_CLK_P         (RX0_LVDS_CLK_P         ),
    .RX0_LVDS_DAT0_N        (RX0_LVDS_DAT0_N        ),
    .RX0_LVDS_DAT0_P        (RX0_LVDS_DAT0_P        ),
    .RX0_LVDS_DAT1_N        (RX0_LVDS_DAT1_N        ),
    .RX0_LVDS_DAT1_P        (RX0_LVDS_DAT1_P        ),
    .RX0_LVDS_DAT2_N        (RX0_LVDS_DAT2_N        ),
    .RX0_LVDS_DAT2_P        (RX0_LVDS_DAT2_P        ),
    .RX0_LVDS_DAT3_N        (RX0_LVDS_DAT3_N        ),
    .RX0_LVDS_DAT3_P        (RX0_LVDS_DAT3_P        ),
    .RX0_LVDS_DAT4_N        (RX0_LVDS_DAT4_N        ),
    .RX0_LVDS_DAT4_P        (RX0_LVDS_DAT4_P        ),
    
    .RX1_LVDS_CLK_N         (RX1_LVDS_CLK_N         ),
    .RX1_LVDS_CLK_P         (RX1_LVDS_CLK_P         ),
    .RX1_LVDS_DAT0_N        (RX1_LVDS_DAT0_N        ),
    .RX1_LVDS_DAT0_P        (RX1_LVDS_DAT0_P        ),
    .RX1_LVDS_DAT1_N        (RX1_LVDS_DAT1_N        ),
    .RX1_LVDS_DAT1_P        (RX1_LVDS_DAT1_P        ),
    .RX1_LVDS_DAT2_N        (RX1_LVDS_DAT2_N        ),
    .RX1_LVDS_DAT2_P        (RX1_LVDS_DAT2_P        ),
    .RX1_LVDS_DAT3_N        (RX1_LVDS_DAT3_N        ),
    .RX1_LVDS_DAT3_P        (RX1_LVDS_DAT3_P        ),
    .RX1_LVDS_DAT4_N        (RX1_LVDS_DAT4_N        ),
    .RX1_LVDS_DAT4_P        (RX1_LVDS_DAT4_P        ),
    
    .RX2_LVDS_CLK_N         (RX2_LVDS_CLK_N         ),
    .RX2_LVDS_CLK_P         (RX2_LVDS_CLK_P         ),
    .RX2_LVDS_DAT0_N        (RX2_LVDS_DAT0_N        ),
    .RX2_LVDS_DAT0_P        (RX2_LVDS_DAT0_P        ),
    .RX2_LVDS_DAT1_N        (RX2_LVDS_DAT1_N        ),
    .RX2_LVDS_DAT1_P        (RX2_LVDS_DAT1_P        ),
    .RX2_LVDS_DAT2_N        (RX2_LVDS_DAT2_N        ),
    .RX2_LVDS_DAT2_P        (RX2_LVDS_DAT2_P        ),
    .RX2_LVDS_DAT3_N        (RX2_LVDS_DAT3_N        ),
    .RX2_LVDS_DAT3_P        (RX2_LVDS_DAT3_P        ),
    .RX2_LVDS_DAT4_N        (RX2_LVDS_DAT4_N        ),
    .RX2_LVDS_DAT4_P        (RX2_LVDS_DAT4_P        ),
    
    .TX0_LVDS_CLK_N         (TX0_LVDS_CLK_N         ),
    .TX0_LVDS_CLK_P         (TX0_LVDS_CLK_P         ),
    .TX0_LVDS_DAT0_N        (TX0_LVDS_DAT0_N        ),
    .TX0_LVDS_DAT0_P        (TX0_LVDS_DAT0_P        ),
    .TX0_LVDS_DAT1_N        (TX0_LVDS_DAT1_N        ),
    .TX0_LVDS_DAT1_P        (TX0_LVDS_DAT1_P        ),
    .TX0_LVDS_DAT2_N        (TX0_LVDS_DAT2_N        ),
    .TX0_LVDS_DAT2_P        (TX0_LVDS_DAT2_P        ),
    .TX0_LVDS_DAT3_N        (TX0_LVDS_DAT3_N        ),
    .TX0_LVDS_DAT3_P        (TX0_LVDS_DAT3_P        ),
    .TX0_LVDS_DAT4_N        (TX0_LVDS_DAT4_N        ),
    .TX0_LVDS_DAT4_P        (TX0_LVDS_DAT4_P        ),
    
    .TX1_LVDS_CLK_N         (TX1_LVDS_CLK_N         ),
    .TX1_LVDS_CLK_P         (TX1_LVDS_CLK_P         ),
    .TX1_LVDS_DAT0_N        (TX1_LVDS_DAT0_N        ),
    .TX1_LVDS_DAT0_P        (TX1_LVDS_DAT0_P        ),
    .TX1_LVDS_DAT1_N        (TX1_LVDS_DAT1_N        ),
    .TX1_LVDS_DAT1_P        (TX1_LVDS_DAT1_P        ),
    .TX1_LVDS_DAT2_N        (TX1_LVDS_DAT2_N        ),
    .TX1_LVDS_DAT2_P        (TX1_LVDS_DAT2_P        ),
    .TX1_LVDS_DAT3_N        (TX1_LVDS_DAT3_N        ),
    .TX1_LVDS_DAT3_P        (TX1_LVDS_DAT3_P        ),
    .TX1_LVDS_DAT4_N        (TX1_LVDS_DAT4_N        ),
    .TX1_LVDS_DAT4_P        (TX1_LVDS_DAT4_P        ),
    
    .TX2_LVDS_CLK_N         (TX2_LVDS_CLK_N         ),
    .TX2_LVDS_CLK_P         (TX2_LVDS_CLK_P         ),
    .TX2_LVDS_DAT0_N        (TX2_LVDS_DAT0_N        ),
    .TX2_LVDS_DAT0_P        (TX2_LVDS_DAT0_P        ),
    .TX2_LVDS_DAT1_N        (TX2_LVDS_DAT1_N        ),
    .TX2_LVDS_DAT1_P        (TX2_LVDS_DAT1_P        ),
    .TX2_LVDS_DAT2_N        (TX2_LVDS_DAT2_N        ),
    .TX2_LVDS_DAT2_P        (TX2_LVDS_DAT2_P        ),
    .TX2_LVDS_DAT3_N        (TX2_LVDS_DAT3_N        ),
    .TX2_LVDS_DAT3_P        (TX2_LVDS_DAT3_P        ),
    .TX2_LVDS_DAT4_N        (TX2_LVDS_DAT4_N        ),
    .TX2_LVDS_DAT4_P        (TX2_LVDS_DAT4_P        )
);

endmodule
