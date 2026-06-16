package lvds_if_pkg;

`ifdef FPGA
localparam RX_WF_INPUT_PIPELINE_EN = 1;
`else
localparam RX_WF_INPUT_PIPELINE_EN = 0;
`endif
localparam AXIS_TX_SRAM_INST_EN = 0;
localparam AXIS_DATA_WIDTH = 96;
localparam LVDS_PAD_NUM = 5;

localparam K_IDLE   = 8'h1C;//k28.0
localparam K_SOP    = 8'hF7;//k23.7
localparam K_EOP    = 8'hFB;//k27.7
localparam K_REQ_CALIB = 8'hFC;//k28.7
localparam K_RESEND = 8'hFD;//k29.7
localparam K_WAIT   = 8'hFE;//k30.7
localparam K_PRBS_START = 8'hBC;//K28.5
localparam K_PRBS_END   = 8'hDC;//K28.6

typedef struct packed {
    logic dec_err;
    logic pkt_c_err; //correct err
    logic pkt_nc_err;//non-correct err

} lvds_rx_err_type;

typedef struct packed {
    logic sop;
    logic eop;
    logic [32-1:0] data;
    
} lvds_rx_wf_data_type;

typedef struct packed {
    logic sop;
    logic [32-1:0] data;
    
} lvds_tx_wf_data_type;


endpackage

