`timescale 1 ps / 1 ps

module CS_UMC28_BIDIR_LVDSH (
    input  BIAS_EN,
    input  RTERM_EN,
    input  [2:0] RTERM_VAL,
    input  RXCM_EN,
    input  TX_CM,
    input  [3:0] TXDRV,
    input  VBIAS_IN,
    input  VBIAS_SEL,
 
    input  CP,
    input  INV_CP,
    input  RESET_N,
    input  DDR_EN,
    input  SYNC_EN,
    input  TXEN,
    input  RXEN,

    input  [1:0] TXDA,
    output       RXDA,
    output [1:0] RXDA_S,
    
    inout  PAD_N,
    inout  PAD_P
);

logic       pad_rx_data;
logic       tx_ddr_data;
logic       tx_pad_data;
logic       reset;
logic       tx_d1;
logic       tx_d2;
logic       rx_q1;
logic       rx_q2;
logic [1:0] rx_data_s;
logic [1:0] rxda;

assign reset = ~RESET_N;
assign CP_IN = INV_CP ? ~CP : CP;

IOBUFDS u_iobufds (
    .O   (pad_rx_data),
    .IO  (PAD_P),
    .IOB (PAD_N),
    .I   (tx_pad_data),
    .T   (~TXEN)
);

always_ff @(negedge CP_IN or posedge reset) begin
    if (reset) begin
        tx_d1 <= 1'b0;
        tx_d2 <= 1'b0;
    end else begin
        {tx_d2, tx_d1} <= TXDA;
    end
end

ODDRE1 #(
    .IS_C_INVERTED  (1'b0),
    .IS_D1_INVERTED (1'b0),
    .IS_D2_INVERTED (1'b0),
    .SIM_DEVICE     ("ULTRASCALE_PLUS"),
    .SRVAL          (1'b0)
) u_oddre1 (
    .Q  (tx_ddr_data),
    .C  (CP_IN),
    .D1 (tx_d1),
    .D2 (tx_d2),
    .SR (reset)
);

assign tx_pad_data = DDR_EN ? tx_ddr_data : TXDA[0];

IDDRE1 #(
    .DDR_CLK_EDGE   ("SAME_EDGE_PIPELINED"),
    .IS_CB_INVERTED (1'b1),
    .IS_C_INVERTED  (1'b1)
) u_iddre1 (
    .Q1 (rx_q1),
    .Q2 (rx_q2),
    .C  (CP_IN),
    .CB (~CP_IN),
    .D  (pad_rx_data),
    .R  (reset)
);

always_ff @(posedge CP_IN or posedge reset) begin
    if (reset) begin
        rxda <= 2'b00;
    end else begin
        rxda <= {rx_q2, rx_q1};
    end
end

assign rx_data_s = SYNC_EN ? (DDR_EN ? rxda : {1'b0, pad_rx_data}) : 2'b0;

assign RXDA   = RXEN ? pad_rx_data : 1'bz;
assign RXDA_S = RXEN ? rx_data_s : 2'b0;

endmodule
