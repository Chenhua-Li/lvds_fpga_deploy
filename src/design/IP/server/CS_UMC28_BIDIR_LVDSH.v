`timescale 1 ps / 1 ps

///////////////////////////////////////////////////////////////////////
// Port information for CS_UMC28_BIDIR_LVDSH:

// supply1 VDD;
// 0.9V supply

// supply1 VDDIO;
// 1.8V supply

// supply0 VSS;
// 0V substrate connection for ESD

// supply0 VSSS;
// 0V Ground 

// input bias_en;
// Bias circuit enable
// 0 --> Bias circuit disabled
// 1 --> Bias circuit enabled

// input cp;
// Parallel clock used for sampling input or output data 

// input ddr_en;
// DDR / SDR mode.
// 0 --> Data is transmitted as SDR data. Only lsb?s are referred 
//         to and a single clock edge is used ( txda[0] in TX mode 
//         rxda[0] in rx mode ). 
// 1 --> DDR mode enabled. Data is transmitted/received on both 
//         edges of the clock ( lsb first ).

// input inv_cp;
// Invert the sampling clock cp  ( either at TX or RX mode)
// 0 --> sample with cp
// 1 --> sample with inverted cp (move sampling point by 180 degree)

// input reset_n;
// registers clear 
// 0 --> registers are cleared
// 1 --> registers are active

// input rterm_en;
// Termination Resistor enable/disable
// 0 --> Resistor Termination disabled
// 1 --> Resistor Termination enabled

// input [2:0] rterm_val;
// Termination value set bits. This should always be set to the correct value for 100 Ohms. The first two MSBs also trims driver bias resistor to track termination variation.	
//
// typical case termination value:
// 3'b000 --> 88.81  ohm
// 3'b001 --> 93.17  ohm
// 3'b010 --> 97.98  ohm
// 3'b011 --> 103.37 ohm	
// 3'b100 --> 109.38 ohm	
// 3'b101 --> 116.24 ohm	
// 3'b110 --> 124.06 ohm	
// 3'b111 --> 133.09 ohm	
// 
// driver bias resistor trimming ratio based on rterm_val[2:1]: 
// when tx_cm=1 (LVDS mode)
//    2'b00      -->   resistor -21%
//    2'b01      -->   resistor -8.5%
//    2'b10      -->   resistor +4%
//    2'b11      -->   resistor +17%
// when tx_cm=0 (sub-LVDS mode)
//    2'b00      -->   resistor -22%
//    2'b01      -->   resistor -6.5%
//    2'b10      -->   resistor +11%
//    2'b11      -->   resistor +27%

// input rxcm_en;
// Enable receiver common mode generation internally.
// 1'b0 --> Internal common mode generation disabled
// 1'b1 --> Internal common mode generation enabled

// input rxen;
// LVDS receiver enable
// 0 --> Receiver disabled
// 1 --> Receiver enabled

// input sync_en;
// Synchronous TX/RX mode enabled.  
// 0 --> Synchronous mode disabled, data taken directly to LVDS driver and not sampled first.
// 1 --> Synchronous mode enabled. 

// input tx_cm;
// Transmit mode common mode select
// 1'b0 --> 0.9V (sub-lvds)
// 1'b1 --> 1.2V

// input [1:0] txda;
// TX parallel data ( lsb first ).
// If ddr_en = 1 then data is transmitted as lsb first. If ddr_en = 0 then txda[0] is transmitted on a single edge of clock (either rising or falling) and txda[1] is ignored.

// input [3:0] txdrv;
// Drive current for LVDS driver. txdrv[3:2] controls elements turned on for driver and txdrv[1:0] trims output current ratio.
//
// rterm_en=0,tx_cm=1 (LVDS mode)
// txdrv[3:2]   I_out,V_out_nom (differential voltage peak)
//     00  -->   2.20mA,220mV (4 elements)
//     01  -->   2.75mA,275mV (5 elements)
//     10  -->   3.30mA,330mV (6 elements)
//     11  -->   3.85mA,385mV (7 elements)
// rterm_en=1,tx_cm=1 (HS LVDS mode w/ back termination)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   4.40mA,220mV (8 elements)
//     01  -->   5.50mA,275mV (10 elements)
//     10  -->   6.60mA,330mV (12 elements)
//     11  -->   7.70mA,385mV (14 elements)
// rterm_en=0,tx_cm=0 (sub-LVDS mode)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   0.55mA,55mV  (1 elements)
//     01  -->   1.10mA,110mV (2 elements)
//     10  -->   1.65mA,165mV (3 elements)
//     11  -->   2.20mA,220mV (4 elements)
// rterm_en=1,tx_cm=0 (sub-LVDS mode w/ back termination)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   1.10mA,55mV  (2 elements)
//     01  -->   2.20mA,110mV (4 elements)
//     10  -->   3.30mA,165mV (6 elements)
//     11  -->   4.40mA,220mV (8 elements)
// 
// txdrv[1:0]   I_out ratio
//     00  -->  output current -8% 
//     01  -->  output current  0% 
//     10  -->  output current +9% 
//     11  -->  output current +20% 

// input txen;
// LVDS driver enable
// 0 --> Driver disabled
// 1 --> Driver enabled

// input vbias_in;
// Bias voltage from external bandgap gen.
// Set vbias_sel=1'b1 to use. 

// input vbias_sel;
// Select bias voltage for I/O
// 1'b1 --> From external bandgap reference gen on vbias_in.
// 1'b0 --> From internal resistor divider
//	tx_cm=1'b1 --> vbias = VDDIO * 2/3 (tx mode only)
//	tx_cm=1'b0 --> vbias = VDDIO * 1/2 (tx mode only)

// output rxda;
// Receiver data directly from LVDS receiver ( not synchronized)

// output [1:0] rxda_s;
// receiver parallel data sampled on cp.
// If ddr_en = 1 then data is received as lsb first. If ddr_en = 0 then data is received on rxda_s[0] and rxda_s[1] is ignored.

// inout PAD_N;
// Bi-directional LVDS IO pad - negative

// inout PAD_P;
// Bi-directional LVDS IO pad - positive



module CS_UMC28_BIDIR_LVDSH ( 
`ifdef CS_PWR_AWARE
    VDD,
    VDDIO,
    VSS,
    VSSS,
`endif
    BIAS_EN,
    CP,
    DDR_EN,
    INV_CP,
    RESET_N,
    RTERM_EN,
    RTERM_VAL,
    RXCM_EN,
    RXEN,
    SYNC_EN,
    TX_CM,
    TXDA,
    TXDRV,
    TXEN,
    VBIAS_IN,
    VBIAS_SEL,
    RXDA,
    RXDA_S,
    PAD_N,
    PAD_P
);


`ifdef CS_PWR_AWARE
// inputs 
input  VDD;
// 0.9V supply

input  VDDIO;
// 1.8V supply

input  VSS;
// 0V substrate connection for ESD

input  VSSS;
// 0V Ground 
`endif

`ifndef CS_PWR_AWARE
// inputs 
supply1  VDD;
// 0.9V supply

supply1  VDDIO;
// 1.8V supply

supply0  VSS;
// 0V substrate connection for ESD

supply0  VSSS;
// 0V Ground 
`endif


input  BIAS_EN;
// Bias circuit enable
// 0 --> Bias circuit disabled
// 1 --> Bias circuit enabled

input  CP;
// Parallel clock used for sampling input or output data 

input  DDR_EN;
// DDR / SDR mode.
// 0 --> Data is transmitted as SDR data. Only lsb?s are referred 
//         to and a single clock edge is used ( txda[0] in TX mode 
//         rxda[0] in rx mode ). 
// 1 --> DDR mode enabled. Data is transmitted/received on both 
//         edges of the clock ( lsb first ).

input  INV_CP;
// Invert the sampling clock cp  ( either at TX or RX mode)
// 0 --> sample with cp
// 1 --> sample with inverted cp (move sampling point by 180 degree)

input  RESET_N;
// registers clear 
// 0 --> registers are cleared
// 1 --> registers are active

input  RTERM_EN;
// Termination Resistor enable/disable
// 0 --> Resistor Termination disabled
// 1 --> Resistor Termination enabled

input [2:0] RTERM_VAL;
// Termination value set bits. This should always be set to the correct value for 100 Ohms. The first two MSBs also trims driver bias resistor to track termination variation.  
// 
// typical case termination value:
// 3'b000 --> 76  ohm
// 3'b001 --> 80  ohm
// 3'b010 --> 85  ohm
// 3'b011 --> 90 ohm    
// 3'b100 --> 96 ohm    
// 3'b101 --> 102 ohm   
// 3'b110 --> 109 ohm   
// 3'b111 --> 118 ohm   
// 
// driver bias resistor trimming ratio based on rterm_val[2:1]: 
// when tx_cm=1 (LVDS mode)
//    2'b00      -->   resistor -21%
//    2'b01      -->   resistor -8.5%
//    2'b10      -->   resistor +4%
//    2'b11      -->   resistor +17%
// when tx_cm=0 (sub-LVDS mode)
//    2'b00      -->   resistor -22%
//    2'b01      -->   resistor -6.5%
//    2'b10      -->   resistor +11%
//    2'b11      -->   resistor +27%

input  RXCM_EN;
// Enable receiver common mode generation internally.
// 1'b0 --> Internal common mode generation disabled
// 1'b1 --> Internal common mode generation enabled

input  RXEN;
// LVDS receiver enable
// 0 --> Receiver disabled
// 1 --> Receiver enabled

input  SYNC_EN;
// Synchronous TX/RX mode enabled.  
// 0 --> Synchronous mode disabled, data taken directly to LVDS driver and not sampled first.
// 1 --> Synchronous mode enabled. 

input  TX_CM;
// Transmit mode common mode select
// 1'b0 --> 0.9V (sub-lvds)
// 1'b1 --> 1.2V

input [1:0] TXDA;
// TX parallel data ( lsb first ).
// If ddr_en = 1 then data is transmitted as lsb first. If ddr_en = 0 then txda[0] is transmitted on a single edge of clock (either rising or falling) and txda[1] is ignored.

input [3:0] TXDRV;
// Drive current for LVDS driver. txdrv[3:2] controls elements turned on for driver and txdrv[1:0] trims output current ratio.
// 
// rterm_en=0,tx_cm=1 (LVDS mode)
// txdrv[3:2]   I_out,V_out_nom (differential voltage peak)
//     00  -->   2.20mA,220mV (4 elements)
//     01  -->   2.75mA,275mV (5 elements)
//     10  -->   3.30mA,330mV (6 elements)
//     11  -->   3.85mA,385mV (7 elements)
// rterm_en=1,tx_cm=1 (HS LVDS mode w/ back termination)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   4.40mA,220mV (8 elements)
//     01  -->   5.50mA,275mV (10 elements)
//     10  -->   6.60mA,330mV (12 elements)
//     11  -->   7.70mA,385mV (14 elements)
// rterm_en=0,tx_cm=0 (sub-LVDS mode)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   0.55mA,55mV  (1 elements)
//     01  -->   1.10mA,110mV (2 elements)
//     10  -->   1.65mA,165mV (3 elements)
//     11  -->   2.20mA,220mV (4 elements)
// rterm_en=1,tx_cm=0 (sub-LVDS mode w/ back termination)
// txdrv[3:2]   I_out,V_out_nom
//     00  -->   1.10mA,55mV  (2 elements)
//     01  -->   2.20mA,110mV (4 elements)
//     10  -->   3.30mA,165mV (6 elements)
//     11  -->   4.40mA,220mV (8 elements)
// 
// txdrv[1:0]   I_out ratio
//     00  -->  output current -8% 
//     01  -->  output current  0% 
//     10  -->  output current +9% 
//     11  -->  output current +20% 

input  TXEN;
// LVDS driver enable
// 0 --> Driver disabled
// 1 --> Driver enabled

input  VBIAS_IN;
// Bias voltage from external bandgap gen.
// Set vbias_sel=1'b1 to use. 

input  VBIAS_SEL;
// Select bias voltage for I/O
// 1'b1 --> From external bandgap reference gen on vbias_in.
// 1'b0 --> From internal resistor divider
//  tx_cm=1'b1 --> vbias = VDDIO * 2/3 (tx mode only)
//  tx_cm=1'b0 --> vbias = VDDIO * 1/2 (tx mode only)

// outputs 
output  RXDA;
// Receiver data directly from LVDS receiver ( not synchronized)

output [1:0] RXDA_S;
// receiver parallel data sampled on cp.
// If ddr_en = 1 then data is received as lsb first. If ddr_en = 0 then data is received on rxda_s[0] and rxda_s[1] is ignored.

// inouts 
inout  PAD_N;
// Bi-directional LVDS IO pad - negative

inout  PAD_P;
// Bi-directional LVDS IO pad - positive


// supplies 
`ifndef SYNTHESIS
    LVDSBDIR_core XLVDSBDIR_core (
        .VDD(VDD), .VDDIO(VDDIO), .VSS(VSS), 
        .VSSS(VSSS), .bias_en(BIAS_EN), .cp(CP), 
        .ddr_en(DDR_EN), .inv_cp(INV_CP), .reset_n(RESET_N), 
        .rterm_en(RTERM_EN), .rterm_val(RTERM_VAL), .rxcm_en(RXCM_EN), 
        .rxen(RXEN), .sync_en(SYNC_EN), .tx_cm(TX_CM), 
        .txda(TXDA), .txdrv(TXDRV), .txen(TXEN), 
        .vbias_in(VBIAS_IN), .vbias_sel(VBIAS_SEL), .rxda(RXDA), 
        .rxda_s(RXDA_S), .PAD_N(PAD_N), .PAD_P(PAD_P)
    );
`endif


endmodule




///////////////////////////////////////////////////////////////////////
// *
// * Schematic name: LVDSBDIR_core
// *
module LVDSBDIR_core (bias_en, cp, ddr_en, inv_cp, PAD_N,
	PAD_P, reset_n, rterm_en, rterm_val, rxcm_en, rxda, rxda_s,
	rxen, sync_en, tx_cm, txda, txdrv, txen, vbias_in,
	vbias_sel, VDD, VDDIO, VSS, VSSS);
inout PAD_P;
inout [3:0] txdrv;
inout tx_cm;
inout rxen;
inout VSSS;
inout sync_en;
inout rxda;
inout reset_n;
inout bias_en;
inout rxcm_en;
inout rterm_en;
inout VDD;
inout [2:0] rterm_val;
inout inv_cp;
inout [1:0] txda;
inout [1:0] rxda_s;
inout vbias_sel;
inout cp;
inout PAD_N;
inout VSS;
inout vbias_in;
inout VDDIO;
inout ddr_en;
inout txen;
wire PAD_P;
wire tx_cm;
wire rxcmln;
wire rxen;
wire reset_n;
wire bias_en;
wire rterm_en;
wire iptat8u;
wire iptat16u;
wire VDD;
wire [2:0] rterm_val;
wire inv_cp;
wire [1:0] rxda_s;
wire [1:0] ibg16u;
wire txdinp;
wire PAD_N;
wire en_des;
wire bias_pd;
wire txen;
wire [3:0] txdrv;
wire clk1;
wire pdHB;
wire tx_and_rx_pd;
wire sync_en;
wire VSSS;
wire rxda;
wire rxcm_en;
wire txdinm;
wire rxcmlp;
wire [1:0] txda;
wire cp;
wire rxcmosn;
wire vbias_sel;
wire pdH;
wire [1:0] txdin;
wire vref;
wire VSS;
wire cpB;
wire vbias_in;
wire VDDIO;
wire ddr_en;
wire bias_enB;
CS_UMC28_BIDIR_LVDSH_and2x1cstm X1 ( .IN0(rxen), .IN1(sync_en), .OUT(en_des), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
// warning : unmatched subckt nmoscap_18
CS_UMC28_BIDIR_LVDSH_biastop_lvdsbdir Xbiastop ( .cm_sel(tx_cm), .ibg16u({ibg16u[1], ibg16u[0]}), .iptat16u(iptat16u),
	.iptat8u(iptat8u), .pd(bias_pd), .pdH(pdH), .pdHB(pdHB), .vbias_in(vbias_in), .vbias_sel(vbias_sel), .VDD(VDD),
	.VDDHV(VDDIO), .vref(vref), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_invx1cstm Xinv_bias_en ( .IN(bias_en), .OUT(bias_enB), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_deserializer_1_2_lvdsbdir Xdeserializer ( .clk_in(clk1), .ddr_en(ddr_en), .en(en_des), .reset_n(reset_n),
	.rxcmosn(rxcmln), .rxcmosp(rxcmlp), .rxda_s({rxda_s[1], rxda_s[0]}), .VDD(VDD), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_invx1cstm Xinv_cp ( .IN(cp), .OUT(cpB), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_or2x1cstm Xor_biaspd ( .IN0(bias_enB), .IN1(tx_and_rx_pd), .OUT(bias_pd), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_lvds_bdir_analog_top Xlvds_analog_top ( .ibg16u({ibg16u[1], ibg16u[0]}), .iptat16u(iptat16u), .iptat8u(iptat8u),
	.lvds_tx_dinm(txdinm), .lvds_tx_dinp(txdinp), .PAD_N(PAD_N), .PAD_P(PAD_P), .rterm_en(rterm_en), .rterm_val({rterm_val[2], rterm_val[1],
	rterm_val[0]}), .rxcm_en(rxcm_en), .rxcmln(rxcmln), .rxcmlp(rxcmlp), .rxcmosn(rxcmosn), .rxcmosp(rxda), .rxen(rxen),
	.tx_cm(tx_cm), .txdrv({txdrv[3], txdrv[2], txdrv[1], txdrv[0]}), .txen(txen), .VDDIO(VDDIO),
	.VDDLV(VDD), .vref(vref), .VSS(VSS), .VSSIO(VSSS));
CS_UMC28_BIDIR_LVDSH_nor2x1cstm Xpdor ( .IN0(rxen), .IN1(txen), .OUT(tx_and_rx_pd), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_bufx4cstm Xdbuf_1_ ( .IN(txda[1]), .OUT(txdin[1]), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_bufx4cstm Xdbuf_0_ ( .IN(txda[0]), .OUT(txdin[0]), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_mux2x3sym_lvds Xmux_cp ( .IN0(cp), .IN1(cpB), .OUT(clk1), .SEL(inv_cp),
	.SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_serializer_2_1_lvdsbdir Xserializer ( .clk_in(clk1), .ddr_en(ddr_en), .din({txdin[1], txdin[0]}),
	.doutm(txdinm), .doutp(txdinp), .en(txen), .en_sync(sync_en), .reset_n(reset_n), .VDD(VDD), .VSS(VSS));
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
// warning : unmatched subckt ndio
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_bufx4cstm
// *
module CS_UMC28_BIDIR_LVDSH_bufx4cstm (IN, OUT, SUB, VNEG, VPOS);
inout VPOS;
inout SUB;
inout OUT;
inout VNEG;
inout IN;
wire VPOS;
wire SUB;
wire OUT;
wire outB;
wire VNEG;
wire IN;
CS_UMC28_BIDIR_LVDSH_invx1cstm X1 ( .IN(IN), .OUT(outB), .SUB(SUB), .VNEG(VNEG),
	.VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_invx4cstm X2 ( .IN(outB), .OUT(OUT), .SUB(SUB), .VNEG(VNEG),
	.VPOS(VPOS));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_deserializer_1_2_lvdsbdir
// *
module CS_UMC28_BIDIR_LVDSH_deserializer_1_2_lvdsbdir (clk_in, ddr_en, en, reset_n, rxcmosn,
	rxcmosp, rxda_s, VDD, VSS);
inout rxcmosp;
inout clk_in;
inout reset_n;
inout VDD;
inout [1:0] rxda_s;
inout en;
inout rxcmosn;
inout VSS;
inout ddr_en;
wire rxcmosp;
wire clk_in;
wire reset_n;
wire [1:0] dout1;
wire VDD;
wire clk2;
wire clk2B;
wire [1:0] rxda_s;
wire en;
wire clk_in_gate;
wire rxcmosn;
wire v1;
wire VSS;
wire [1:0] dout;
wire ddr_en;
CS_UMC28_BIDIR_LVDSH_nand2x2clk X2 ( .IN0(en), .IN1(clk_in), .OUT(clk_in_gate), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_tiehighx1cstm X6 ( .OUT(v1), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ckBgen4x X7 ( .IN(clk_in_gate), .OUT(clk2), .OUTB(clk2B), .VDD(VDD),
	.VSS(VSS));
CS_UMC28_BIDIR_LVDSH_invx12cstm Xbuf_dout_1_ ( .IN(dout1[1]), .OUT(rxda_s[1]), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx12cstm Xbuf_dout_0_ ( .IN(dout1[0]), .OUT(rxda_s[0]), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_demux2_sensamp Xdemux ( .clk2(clk2B), .clk2B(clk2), .d0(dout[1]), .d1(dout[0]),
	.inm(rxcmosn), .inp(rxcmosp), .reset_n(reset_n), .VDD(VDD), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_nand2x4clk_wx2 Xgate_dout_1_ ( .IN0(ddr_en), .IN1(dout[1]), .OUT(dout1[1]), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x4clk_wx2 Xgate_dout_0_ ( .IN0(v1), .IN1(dout[0]), .OUT(dout1[0]), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_ckBgen4x
// *
module CS_UMC28_BIDIR_LVDSH_ckBgen4x (IN, OUT, OUTB, VDD, VSS);
inout VDD;
inout OUT;
inout OUTB;
inout IN;
inout VSS;
wire VDD;
wire NET4;
wire OUT;
wire OUTB;
wire NET2;
wire NET1;
wire IN;
wire VSS;
CS_UMC28_BIDIR_LVDSH_invx4cstm X2 ( .IN(NET4), .OUT(OUT), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx2cstm X4 ( .IN(NET1), .OUT(NET2), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx4cstm X5 ( .IN(NET2), .OUT(OUTB), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx1cstm X6 ( .IN(IN), .OUT(NET4), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx2cstm X7 ( .IN(IN), .OUT(NET1), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_demux2_sensamp
// *
module CS_UMC28_BIDIR_LVDSH_demux2_sensamp (clk2, clk2B, d0, d1, inm,
	inp, reset_n, VDD, VSS);
inout reset_n;
inout d1;
inout VDD;
inout clk2;
inout clk2B;
inout inm;
inout d0;
inout inp;
inout VSS;
wire NET7;
wire reset_n;
wire d1B_nc;
wire VDD;
wire d1;
wire clk2;
wire clk2B;
wire in_clk2B;
wire in_clk2;
wire inm;
wire d0;
wire inp;
wire in_clk2B_delB_nc;
wire d0B_nc;
wire VSS;
wire in_clk2B_del;
wire NET6;
CS_UMC28_BIDIR_LVDSH_sensamp_latch_npair X1 ( .clk(clk2), .inm(inm), .inp(inp), .Q(in_clk2),
	.QB(NET7), .VDD(VDD), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_sensamp_latch_npair X2 ( .clk(clk2B), .inm(inm), .inp(inp), .Q(in_clk2B),
	.QB(NET6), .VDD(VDD), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_ffbrbx1cstmckb Xa_int ( .CLK(clk2B), .CLKB(clk2), .D(in_clk2B), .Q(in_clk2B_del),
	.QB(in_clk2B_delB_nc), .RB(reset_n), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrbx1cstmckb Xa_out ( .CLK(clk2), .CLKB(clk2B), .D(in_clk2B_del), .Q(d1),
	.QB(d1B_nc), .RB(reset_n), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrbx1cstmckb Xb_out ( .CLK(clk2), .CLKB(clk2B), .D(in_clk2), .Q(d0),
	.QB(d0B_nc), .RB(reset_n), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_sensamp_latch_npair
// *
module CS_UMC28_BIDIR_LVDSH_sensamp_latch_npair (clk, inm, inp, Q, QB,
	VDD, VSS);
inout VDD;
inout inm;
inout Q;
inout inp;
inout clk;
inout QB;
inout VSS;
wire outr;
wire outs;
wire VDD;
wire q1;
wire qb1;
wire inm;
wire Q;
wire inp;
wire clk;
wire QB;
wire VSS;
CS_UMC28_BIDIR_LVDSH_invx1cstm X1 ( .IN(q1), .OUT(QB), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx1cstm X2 ( .IN(qb1), .OUT(Q), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_sensamp_npairx1cstm X3 ( .clk(clk), .inm(inm), .inp(inp), .outm(outs),
	.outp(outr), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_srlatchx1cstm Xsrlatch ( .Q(q1), .QB(qb1), .RB(outr), .SB(outs),
	.SUB(VSS), .VNEG(VSS), .VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_lvds_bdir_analog_top
// *
module CS_UMC28_BIDIR_LVDSH_lvds_bdir_analog_top (ibg16u, iptat16u, iptat8u, lvds_tx_dinm, lvds_tx_dinp,
	PAD_N, PAD_P, rterm_en, rterm_val, rxcm_en, rxcmln, rxcmlp,
	rxcmosn, rxcmosp, rxen, tx_cm, txdrv, txen, VDDIO,
	VDDLV, vref, VSS, VSSIO);
inout PAD_P;
inout rxcmln;
inout tx_cm;
inout rxcmosp;
inout VSSIO;
inout rxen;
inout lvds_tx_dinm;
inout rterm_en;
inout iptat8u;
inout iptat16u;
inout [2:0] rterm_val;
inout [1:0] ibg16u;
inout PAD_N;
inout txen;
inout [3:0] txdrv;
inout lvds_tx_dinp;
inout rxcm_en;
inout VDDLV;
inout rxcmlp;
inout rxcmosn;
inout vref;
inout VSS;
inout VDDIO;
wire PAD_P;
wire rxcmln;
wire tx_cm;
wire rxcmosp;
wire txvcm_test;
wire txvota_test;
wire rxnn2;
wire VSSIO;
wire rxen;
wire lvds_tx_dinm;
wire rterm_en;
wire rxnp2;
wire iptat8u;
wire iptat16u;
wire [2:0] rterm_val;
wire [1:0] ibg16u;
wire PAD_N;
wire vcsnslv;
wire rxpp2;
wire txen;
wire tielow;
wire [3:0] txdrv;
wire rxin_to_cml2cmosp;
wire lvds_tx_dinp;
wire rxcm_en;
wire VDDLV;
wire nc1;
wire rxcmlp;
wire rxcmosn;
wire rxin_to_cml2cmosm;
wire vref;
wire VSS;
wire VDDIO;
wire rxpn2;
CS_UMC28_BIDIR_LVDSH_res_term_dhdi_ud X1 ( .ENRES100(rterm_en), .ENRES10K(tielow), .ENRXCM(rxcm_en), .NXN(PAD_N),
	.NXP(PAD_P), .RTRIM({rterm_val[2], rterm_val[1], rterm_val[0]}), .vcm_rx(VDDLV), .vcmfb(nc1), .VDD(VDDLV),
	.VDDH(VDDIO), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_tielowx1cstm X2 ( .OUT(tielow), .SUB(VSS), .VNEG(VSS), .VPOS(VDDLV));
CS_UMC28_BIDIR_LVDSH_lvds_rx_core Xlvdsrx ( .en(rxen), .ibg({ibg16u[1], ibg16u[0]}), .out3n(rxin_to_cml2cmosm),
	.out3p(rxin_to_cml2cmosp), .outn(rxcmln), .outp(rxcmlp), .vcsnlv(vcsnslv), .VDDHV(VDDIO), .VDDLV(VDDLV), .vinnn(rxnn2),
	.vinnp(rxnp2), .vinpn(rxpn2), .vinpp(rxpp2), .VSS(VSSIO));
CS_UMC28_BIDIR_LVDSH_cml2cmosbuf_diff Xcml2cmos ( .en(rxen), .inm(rxin_to_cml2cmosm), .inp(rxin_to_cml2cmosp), .outm(rxcmosn),
	.outp(rxcmosp), .vcsns(vcsnslv), .VDDLV(VDDLV), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_esd_secondary Xesd_2nd_3_ ( .IN(PAD_P), .OUT(rxnp2), .VNEG(VSSIO), .VPOS(VDDIO));
CS_UMC28_BIDIR_LVDSH_esd_secondary Xesd_2nd_2_ ( .IN(PAD_N), .OUT(rxnn2), .VNEG(VSSIO), .VPOS(VDDIO));
CS_UMC28_BIDIR_LVDSH_esd_secondary Xesd_2nd_1_ ( .IN(PAD_P), .OUT(rxpp2), .VNEG(VSSIO), .VPOS(VDDIO));
CS_UMC28_BIDIR_LVDSH_esd_secondary Xesd_2nd_0_ ( .IN(PAD_N), .OUT(rxpn2), .VNEG(VSSIO), .VPOS(VDDIO));
CS_UMC28_BIDIR_LVDSH_LVDSTX_all_bidir Xtx_data ( .iptat16u(iptat16u), .iptat8u(iptat8u), .rterm_val({rterm_val[2], rterm_val[1]}),
	.tx_cm(tx_cm), .tx_rt_en(rterm_en), .txdrv({txdrv[3], txdrv[2], txdrv[1], txdrv[0]}), .txen(txen),
	.TXN(PAD_N), .TXN1(lvds_tx_dinm), .TXP(PAD_P), .TXP1(lvds_tx_dinp), .vcm_test(txvcm_test), .VDDIO(VDDIO), .VDDLV(VDDLV),
	.vota_test(txvota_test), .vref(vref), .VSS(VSS), .VSSIO(VSSIO));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_LVDSTX_all_bidir
// *
module CS_UMC28_BIDIR_LVDSH_LVDSTX_all_bidir (iptat16u, iptat8u, rterm_val, tx_cm, tx_rt_en,
	txdrv, txen, TXN, TXN1, TXP, TXP1, vcm_test,
	VDDIO, VDDLV, vota_test, vref, VSS, VSSIO);
inout tx_cm;
inout VSSIO;
inout TXN;
inout TXP;
inout iptat8u;
inout iptat16u;
inout vcm_test;
inout [2:1] rterm_val;
inout tx_rt_en;
inout txen;
inout [3:0] txdrv;
inout vota_test;
inout TXP1;
inout VDDLV;
inout TXN1;
inout vref;
inout VSS;
inout VDDIO;
wire tx_cm;
wire VSSIO;
wire TXN;
wire TXP;
wire iptat8u;
wire iptat16u;
wire vcm_test;
wire [2:1] rterm_val;
wire tx_rt_en;
wire txen;
wire [3:0] txdrv;
wire vota_test;
wire TXP1;
wire VDDLV;
wire TXN1;
wire vref;
wire VSS;
wire VDDIO;
CS_UMC28_BIDIR_LVDSH_LVDSTX_all Xtx_data ( .iptat16u(iptat16u), .iptat8u(iptat8u), .rterm_val({rterm_val[2], rterm_val[1]}),
	.tx_cm(tx_cm), .tx_rt_en(tx_rt_en), .txdrv({txdrv[3], txdrv[2], txdrv[1], txdrv[0]}), .txen(txen),
	.TXN(TXN), .TXN1(TXN1), .TXP(TXP), .TXP1(TXP1), .vcm_test(vcm_test), .VDDIO(VDDIO), .VDDLV(VDDLV),
	.vota_test(vota_test), .vref(vref), .VSS(VSS), .VSSIO(VSSIO));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_and2x1cstm
// *
module CS_UMC28_BIDIR_LVDSH_and2x1cstm (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
inout VPOS;
inout SUB;
inout IN1;
inout OUT;
inout VNEG;
inout IN0;
wire VPOS;
wire SUB;
wire OUT;
wire IN1;
wire outB;
wire VNEG;
wire IN0;
CS_UMC28_BIDIR_LVDSH_invx1cstm X1 ( .IN(outB), .OUT(OUT), .SUB(SUB), .VNEG(VNEG),
	.VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm_sub Xnd1 ( .IN0(IN0), .IN1(IN1), .OUT(outB), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_mux2x1cstm
// *
module CS_UMC28_BIDIR_LVDSH_mux2x1cstm (IN0, IN1, OUT, SEL, SUB,
	VNEG, VPOS);
inout VPOS;
inout SUB;
inout IN1;
inout OUT;
inout SEL;
inout VNEG;
inout IN0;
wire VPOS;
wire SUB;
wire IN1;
wire OUT;
wire SEL;
wire NET3;
wire NET2;
wire VNEG;
wire NET1;
wire IN0;
CS_UMC28_BIDIR_LVDSH_nand2x1cstm X1 ( .IN0(SEL), .IN1(IN1), .OUT(NET2), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm X2 ( .IN0(NET1), .IN1(IN0), .OUT(NET3), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm X3 ( .IN0(NET3), .IN1(NET2), .OUT(OUT), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_invx1cstm X4 ( .IN(SEL), .OUT(NET1), .SUB(SUB), .VNEG(VNEG),
	.VPOS(VPOS));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_or2x1cstm
// *
module CS_UMC28_BIDIR_LVDSH_or2x1cstm (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
inout VPOS;
inout SUB;
inout IN1;
inout OUT;
inout VNEG;
inout IN0;
wire VPOS;
wire SUB;
wire OUT;
wire IN1;
wire n_nor;
wire VNEG;
wire IN0;
CS_UMC28_BIDIR_LVDSH_invx1cstm X1 ( .IN(n_nor), .OUT(OUT), .SUB(SUB), .VNEG(VNEG),
	.VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_nor2x1cstm X2 ( .IN0(IN0), .IN1(IN1), .OUT(n_nor), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_serializer_2_1_lvdsbdir
// *
module CS_UMC28_BIDIR_LVDSH_serializer_2_1_lvdsbdir (clk_in, ddr_en, din, doutm, doutp,
	en, en_sync, reset_n, VDD, VSS);
inout doutm;
inout clk_in;
inout en_sync;
inout reset_n;
inout VDD;
inout doutp;
inout en;
inout [1:0] din;
inout VSS;
inout ddr_en;
wire en_clk;
wire doutm;
wire clk_in;
wire en_sync;
wire reset_n;
wire clk_inB;
wire VDD;
wire [1:0] dout_sdrB;
wire clkB;
wire doutp;
wire [1:0] dout_sdr_async;
wire en;
wire dout_ddr;
wire v0;
wire sdr_en;
wire [1:0] din;
wire clk_in_gate;
wire reset;
wire ddr_sel;
wire [1:0] dout_sdr;
wire clk;
wire VSS;
wire dout;
wire en_async;
wire ddr_en;
CS_UMC28_BIDIR_LVDSH_serializer2to1_ddr X1 ( .clk2(clk_in_gate), .din({din[1], din[0]}), .out(dout_ddr),
	.rst(reset), .VDD(VDD), .VSS(VSS));
CS_UMC28_BIDIR_LVDSH_ckBgen4x X2 ( .IN(clk_in_gate), .OUT(clk), .OUTB(clkB), .VDD(VDD),
	.VSS(VSS));
CS_UMC28_BIDIR_LVDSH_mux2x1cstm X3 ( .IN0(dout_sdr_async[0]), .IN1(dout_ddr), .OUT(dout), .SEL(ddr_sel),
	.SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx1cstm X4 ( .IN(reset_n), .OUT(reset), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nor2x1cstm X5 ( .IN0(sdr_en), .IN1(en_async), .OUT(ddr_sel), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx1cstm X6 ( .IN(ddr_en), .OUT(sdr_en), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_invx1cstm X7 ( .IN(en_sync), .OUT(en_async), .SUB(VSS), .VNEG(VSS),
	.VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_and2x1cstm X8 ( .IN0(en_sync), .IN1(en), .OUT(en_clk), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_mux2x1cstm Xmuxdout_1_ ( .IN0(dout_sdr[1]), .IN1(din[1]), .OUT(dout_sdr_async[1]), .SEL(en_async),
	.SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_mux2x1cstm Xmuxdout_0_ ( .IN0(dout_sdr[0]), .IN1(din[0]), .OUT(dout_sdr_async[0]), .SEL(en_async),
	.SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ckBgen4x X11 ( .IN(dout), .OUT(doutp), .OUTB(doutm), .VDD(VDD),
	.VSS(VSS));
CS_UMC28_BIDIR_LVDSH_tielowx1cstm X10 ( .OUT(v0), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x2clk Xclkgate2 ( .IN0(en_clk), .IN1(clk_inB), .OUT(clk_in_gate), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x1clk Xclkgate ( .IN0(en_clk), .IN1(clk_in), .OUT(clk_inB), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xff_sdr_1_ ( .CLK(clk), .CLKB(clkB), .D(din[1]), .Q(dout_sdr[1]),
	.QB(dout_sdrB[1]), .RST(reset), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xff_sdr_0_ ( .CLK(clk), .CLKB(clkB), .D(din[0]), .Q(dout_sdr[0]),
	.QB(dout_sdrB[0]), .RST(reset), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_serializer2to1_ddr
// *
module CS_UMC28_BIDIR_LVDSH_serializer2to1_ddr (clk2, din, out, rst, VDD,
	VSS);
inout out;
inout VDD;
inout clk2;
inout [1:0] din;
inout rst;
inout VSS;
wire dout1;
wire out;
wire VDD;
wire clk2;
wire clkB;
wire NET4;
wire [1:0] din;
wire dnd0;
wire NET3;
wire dnd1;
wire rst;
wire NET1;
wire dout0;
wire clk;
wire VSS;
wire dout10;
CS_UMC28_BIDIR_LVDSH_ckBgen4x Xclkinv ( .IN(clk2), .OUT(clk), .OUTB(clkB), .VDD(VDD),
	.VSS(VSS));
CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xff0 ( .CLK(clk), .CLKB(clkB), .D(din[1]), .Q(dout10),
	.QB(NET4), .RST(rst), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xff1 ( .CLK(clk), .CLKB(clkB), .D(din[0]), .Q(dout0),
	.QB(NET3), .RST(rst), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xff2 ( .CLK(clkB), .CLKB(clk), .D(dout10), .Q(dout1),
	.QB(NET1), .RST(rst), .SUB(VSS), .VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm Xnd0 ( .IN0(clk), .IN1(dout1), .OUT(dnd1), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm Xnd1 ( .IN0(clkB), .IN1(dout0), .OUT(dnd0), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm Xndout ( .IN0(dnd0), .IN1(dnd1), .OUT(out), .SUB(VSS),
	.VNEG(VSS), .VPOS(VDD));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_biastop_lvdsbdir
// *
module CS_UMC28_BIDIR_LVDSH_biastop_lvdsbdir (pd, vref, VDD, VDDHV, VSS, pdH, pdHB, vbias_sel, vbias_in, cm_sel,
		ibg16u, iptat8u, iptat16u); 

input pd;
input vbias_sel;
input vbias_in;
input cm_sel;

// supplies
input VDD;
input VSS;
input VDDHV;

// outputs

parameter ibg16u_lpdgth 		= 2;
parameter iptat8u_lpdgth 		= 1;
parameter iptat16u_lpdgth 		= 1; 

output [ibg16u_lpdgth-1:0] ibg16u;
output [iptat8u_lpdgth-1:0] iptat8u;
output [iptat16u_lpdgth-1:0] iptat16u;

reg [ibg16u_lpdgth-1:0] ibg16u;
reg [iptat8u_lpdgth-1:0] iptat8u;
reg [iptat16u_lpdgth-1:0] iptat16u;

output vref;

output pdH;
output pdHB;

reg vref;

assign pdH = pd;
assign pdHB = ~pd;

always @(pd) begin
	case (pd)
		1'b0 : begin
			vref = 1;
			ibg16u = {ibg16u_lpdgth{1'b1}};
			iptat8u = {iptat8u_lpdgth{1'b1}};
			iptat16u = {iptat16u_lpdgth{1'b1}};
		end
		default : begin
			vref = 0;
			ibg16u = {ibg16u_lpdgth{1'b0}};
			iptat8u = {iptat8u_lpdgth{1'b0}};
			iptat16u = {iptat16u_lpdgth{1'b0}};
		end
	endcase
end

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nand2x4clk_wx2
// *
module CS_UMC28_BIDIR_LVDSH_nand2x4clk_wx2(IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;

nand (OUT,IN1,IN0);
specify
	specparam
		tplh0 = 2*15,
		tphl0 = 2*15,
		tplh1 = 2*15,
		tphl1 = 2*15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nand2x1cstm_sub
// *
module CS_UMC28_BIDIR_LVDSH_nand2x1cstm_sub(IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;

nand (OUT,IN1,IN0);
specify
	specparam
		tplh0 = 2*15,
		tphl0 = 2*15,
		tplh1 = 2*15,
		tphl1 = 2*15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nand2x1cstm
// *
module CS_UMC28_BIDIR_LVDSH_nand2x1cstm (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;

nand (OUT,IN1,IN0);
specify
	specparam
		tplh0 = 2*15,
		tphl0 = 2*15,
		tplh1 = 2*15,
		tphl1 = 2*15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nand2x1clk
// *
module CS_UMC28_BIDIR_LVDSH_nand2x1clk (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;

nand (OUT,IN1,IN0);
specify
	specparam
		tplh0 = 2*15,
		tphl0 = 2*15,
		tplh1 = 15,
		tphl1 = 15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nand2x2clk
// *
module CS_UMC28_BIDIR_LVDSH_nand2x2clk (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;

nand (OUT,IN1,IN0);
specify
	specparam
		tplh0 = 2*15,
		tphl0 = 2*15,
		tplh1 = 15,
		tphl1 = 15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_nor2x1cstm
// *
module CS_UMC28_BIDIR_LVDSH_nor2x1cstm (IN0, IN1, OUT, SUB, VNEG,
	VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN1;
input IN0;


nor (OUT,IN0,IN1);
specify
	specparam
		tplh0 = 3*15,
		tphl0 = 1*15,
		tplh1 = 3*15,
		tphl1 = 1*15;
	(IN0 => OUT) = (tplh0,tphl0);
	(IN1 => OUT) = (tplh1,tphl1);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_tiehighx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_tiehighx1cstm (OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;

buf (OUT,1'b1);

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_tielowx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_tielowx1cstm (OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;

buf (OUT,1'b0);

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_invx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_invx1cstm (IN, OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN;

not (OUT,IN);
specify
	specparam
		tplh0 = 1*15,
		tphl0 = 1*15;
	(IN => OUT) = (tplh0,tphl0);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_invx2cstm
// *
module CS_UMC28_BIDIR_LVDSH_invx2cstm (IN, OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN;

not (OUT,IN);
specify
	specparam
		tplh0 = 1*15,
		tphl0 = 1*15;
	(IN => OUT) = (tplh0,tphl0);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_invx4cstm
// *
module CS_UMC28_BIDIR_LVDSH_invx4cstm (IN, OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN;

not (OUT,IN);
specify
	specparam
		tplh0 = 1*15,
		tphl0 = 1*15;
	(IN => OUT) = (tplh0,tphl0);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_invx12cstm
// *
module CS_UMC28_BIDIR_LVDSH_invx12cstm (IN, OUT, SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output OUT;
input IN;

not (OUT,IN);
specify
	specparam
		tplh0 = 1*15,
		tphl0 = 1*15;
	(IN => OUT) = (tplh0,tphl0);
endspecify

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_ffbrbx1cstmckb
// *
module CS_UMC28_BIDIR_LVDSH_ffbrbx1cstmckb(CLK, CLKB, D, Q, QB, RB,
	SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
input D;
input CLK;
input CLKB;
input RB;
output QB;
output Q;

wire RST; 
assign RST = ~RB; 

CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb Xffbrx1cstmckb (.CLK(CLK), .CLKB(CLKB), .D(D), .Q(Q), .QB(QB), .RST(RST),
	.SUB(SUB), .VNEG(VNEG), .VPOS(VPOS));

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb
// *
module CS_UMC28_BIDIR_LVDSH_ffbrx1cstmckb (CLK, CLKB, D, Q, QB, RST,
	SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
input D;
input CLK;
input CLKB;
input RST;
output QB;
output Q;

specify
	`ifdef MY_TIMING_CHECKS
	$setup(D, posedge CLK, 2*15);
	$hold(posedge CLK, D, 1*15);
	$setup(negedge RST, posedge CLK, 3*15);
	`endif
	specparam
		tplh0 = 5*15,
		tphl0 = 5*15,
		tplhr = 5*15,
		tphlr = 5*15;
	//if (RST) (CLK => QB) = (tplh0,tphl0);
	//if (RST) (CLK => Q) = (tplh0+`INV_DELAY,tphl0+`INV_DELAY);
	(CLK => QB) = (tplh0,tphl0);
	(CLK => Q) = (tplh0+15,tphl0+15);
	(RST => Q) = (tplhr,tphlr);
endspecify

reg q1;
initial begin
	if (RST)
		q1 = 0;
	else begin
		q1 = 0;
	end
end


reg clkblock;
initial begin
	clkblock = 1'b0;
	#(150*15) clkblock = 1'b1;
end
and (clk1, CLK, clkblock, ~CLKB);
always @(posedge clk1 or posedge RST) begin
	if (RST)
		q1 <= 1'b0;
	else
        	q1 <= D;
end

not (QB,q1);
not (Q,QB);

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_sensamp_npairx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_sensamp_npairx1cstm (clk, inm, inp, outp, outm, VPOS, VNEG, SUB); 
output outp;
output outm;
input inp;
input inm;
input clk;
input VPOS;
input VNEG;
input SUB;
wire outp;
wire outm;

CS_UMC28_BIDIR_LVDSH_sensampx1cstm Xsensampx1cstm (.clk(clk), .inm(inm), .inp(inp), .outm(outm), .outp(outp),
	.SUB(SUB), .VNEG(VNEG), .VPOS(VPOS));

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_sensampx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_sensampx1cstm (clk, inm, inp, outm, outp,
        SUB, VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;
output outp;
output outm;
input inp;
input inm;
input clk;

specify
	specparam
		tplh0 = 3*15,
		tphl0 = 3*15;
	(clk => outp) = (tplh0,tphl0);
	(clk => outm) = (tplh0,tphl0);
endspecify

reg outp1;
reg outm1;
buf (outp,outp1);
buf (outm,outm1);
always @ (posedge clk) begin
	case ({inp, inm})
		2'b01 : begin 
			outp1 = 1'b0; 
			outm1 = 1'b1; 
		end
		2'b10 : begin 
			outp1 = 1'b1; 
			outm1 = 1'b0; 
		end
		default : begin outp1 = 1'b1; outm1 = 1'b1; end
	endcase 
end

always @ (negedge clk) begin
	outp1 = 1'b1; 
	outm1 = 1'b1;
end

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_srlatchx1cstm
// *
module CS_UMC28_BIDIR_LVDSH_srlatchx1cstm (Q, QB, RB, SB, SUB,
	VNEG, VPOS);

output Q;
output QB;

input VPOS;
input SUB;
input VNEG;
input SB;
input RB;
// *

reg qr1;
initial begin
	qr1 = 0;
end

reg set;
reg reset;

always @(Q or QB or SB or RB)
	case ({Q,QB})
		2'b00 : {set,reset} = {~SB,~RB};
		2'b01 : {set,reset} = {~SB,~RB};
		2'b10 : {set,reset} = {~SB,~RB};
		2'b11 : {set,reset} = {~SB,~RB};
		default : {set,reset} = {qr1,~qr1};
	endcase

CS_UMC28_BIDIR_LVDSH_nand2x1cstm X1 ( .IN0(QB), .IN1(~set), .OUT(Q), .SUB(SUB),
        .VNEG(VNEG), .VPOS(VPOS));
CS_UMC28_BIDIR_LVDSH_nand2x1cstm X2 ( .IN0(Q), .IN1(~reset), .OUT(QB), .SUB(SUB),
	.VNEG(VNEG), .VPOS(VPOS));
// *
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_cml2cmosbuf_diff
// *
module CS_UMC28_BIDIR_LVDSH_cml2cmosbuf_diff(inp, inm, vcsns, en, outp, outm, VDDLV, VSS); 
input VDDLV;
input VSS;

input vcsns;
input inp;
input inm;
input en; 

output outp;
output outm;
wire out; 
assign outp = out;
assign outm = ~out; 

CS_UMC28_BIDIR_LVDSH_cml2cmos_sub_diff Xcml2cmos_sub_diff (.inp(inp), .inm(inm), .vcsns(vcsns), .enB(~en), .out(out), .VDD(VDDLV), .VSS(VSS));
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_cml2cmos_sub_diff
// *
module CS_UMC28_BIDIR_LVDSH_cml2cmos_sub_diff(inp, inm, vcsns, enB, out, VDD, VSS); 
input VDD;
input VSS;

input vcsns;
input inp;
input inm;
input enB; 

output out;

wire enable = ~enB & vcsns; 
wire din = inp & ~inm; 

bufif1 #(1*15) (out,din,enable); 
endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_mux2x3sym_lvds
// *
module CS_UMC28_BIDIR_LVDSH_mux2x3sym_lvds(IN0, IN1, OUT, SEL, SUB,
	VNEG, VPOS);
input VPOS;
input VNEG;
input SUB;

input IN1;
input IN0;
input SEL;

output OUT;
wire out_int; 


assign out_int = (SEL ? IN1 : IN0);
assign #(3*15) OUT = out_int; 

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_esd_secondary
// *
module CS_UMC28_BIDIR_LVDSH_esd_secondary (IN, OUT, VPOS, VNEG);
input IN;
input VPOS;
input VNEG;
output OUT;

assign OUT = IN; 

endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_lvds_rx_core
// *
module CS_UMC28_BIDIR_LVDSH_lvds_rx_core (VDDHV, VDDLV, VSS, ibg, vcsnlv, 
			  vinnp, vinnn, vinpp, vinpn, outp, outn, out3p, out3n, en);

input VDDHV;
input VDDLV;
input VSS;
input [1:0] ibg;

input vinnp;
input vinnn;
input vinpp;
input vinpn;

input en;

output outp;
output outn; 
output out3p;
output out3n;

output vcsnlv; 

wire bias_ok = en & ibg[1] & ibg[0]; 
assign vcsnlv = bias_ok; 

wire data_in = vinnp & vinpp & ~vinnn & ~vinpn; 

bufif1 #(5*15) (outp, data_in, bias_ok);
notif1 #(5*15) (outn, data_in, bias_ok);
bufif1 #(5*15) (out3p, data_in, bias_ok);
notif1 #(5*15) (out3n, data_in, bias_ok);



endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_res_term_dhdi_ud
// *
module CS_UMC28_BIDIR_LVDSH_res_term_dhdi_ud(VDDH, VDD, VSS,
			NXP, NXN, vcmfb, vcm_rx,
			RTRIM, ENRES100, ENRES10K, ENRXCM); 

input VDDH;
input VDD;
input VSS;

inout NXP;	// inout likely not required
inout NXN;	// inout likely not required
input vcmfb;
input vcm_rx; 

input [2:0] RTRIM;
input ENRES100;
input ENRES10K;
input ENRXCM;

// This block has no internals since it's function doesn't translate to
// verilog


endmodule
// *
// * Schematic name: CS_UMC28_BIDIR_LVDSH_LVDSTX_all
// *
module CS_UMC28_BIDIR_LVDSH_LVDSTX_all (VDDIO, VDDLV, VSS, VSSIO, 
		   TXP1, TXN1, TXP, TXN,
		   txen, txdrv, tx_cm, tx_rt_en, rterm_val,
		   vota_test, vcm_test, 
		   vref, iptat8u, iptat16u);

input txen;
input [3:0] txdrv;
input tx_cm;
input tx_rt_en; 
input [2:1] rterm_val; 
input vref; 

input TXN1;
input TXP1;


// outputs
inout TXN;
inout TXP;

// supplies
input VDDIO;
input VDDLV;
input VSS;
input VSSIO;

// bias
input iptat16u;
input iptat8u;

// Test voltages
output vota_test;
output vcm_test; 


assign bias_ok = &({iptat16u,iptat8u});

// LVDS Outputs
bufif1 #(3*15) (TXP,TXP1 & ~TXN1,bias_ok & txen);
notif1 #(3*15) (TXN,TXP1 & ~TXN1,bias_ok & txen);

assign vota_test = txen; 
assign vcm_test = txen;


endmodule
