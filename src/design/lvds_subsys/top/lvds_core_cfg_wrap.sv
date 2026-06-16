
module lvds_core_cfg_wrap
(
    input                                           clk,
    input                                           rstn,
    input       [1:0]                               CORE_ID,       //core_id in X/Y direction from upstream core_unit
    output      [1:0]                               CORE_ID_NEXT,  //core_id in X/Y direction to downstream core_unit

    //pre level
    output      logic [31:0]                        dout_pre,      //data returned to upstream core_unit
    output      logic                               dout_pre_vld,  //qualifier of data returned to upstream core_unit
    input       logic [32:0]                        din_pre,       //cfg_data from upstream core_unit
    input       logic                               din_pre_vld,   //qualifier of cfg_data from upstream core_unit

    //next level
    input       logic [31:0]                        dout_next,     //data returned from downstream core_unit
    input       logic                               dout_next_vld, //qualifier of data returned from downstream core_unit
    output      logic [32:0]                        din_next,      //cfg_data to downstream core_unit
    output      logic                               din_next_vld,   //qualifier of cfg_data to downstream core_unit

    //apb_if
    output      logic                               apb_psel,
    output      logic                               apb_penable,
    output      logic                               apb_pwrite,
    output      logic  [25-1:0]                     apb_paddr,
    output      logic  [31:0]                       apb_pwdata,
    input       logic                               apb_pready,
    input       logic [31:0]                        apb_prdata

    );


localparam CORE_ADDR_WIDTH = 25;

logic   [31:0]                                  dout_cur;
logic                                           dout_cur_vld;
logic   [32:0]                                  din_cur;
logic                                           din_cur_vld;
logic                                           dout_cur_lat;
logic                                           addr_lat_en;
logic                                           wait_data_cur_set;
logic                                           wait_data_cur_clr;
logic                                           core_wr_en;
logic                                           core_rd_en;
logic                                           wait_data_cur;
logic                                           op_is_write;
logic                                           data_is_addr;
logic                                           din_cur_lat;
logic                                           apb_ack;

assign CORE_ID_NEXT                        = CORE_ID + 1;

core_cfg_pp #(
    .EXTRA_PP                           ( 0                           ),
    .USED_IN_X_DIRECTION                ( 1                           )
    )
u_core_cfg_pp(
    .clk                                ( clk                         ),
    .rstn                               ( rstn                        ),
    .CORE_ID                            ( CORE_ID                     ),
    
    .dout_pre                           ( dout_pre                    ),
    .dout_pre_vld                       ( dout_pre_vld                ),
    .din_pre                            ( din_pre                     ),
    .din_pre_vld                        ( din_pre_vld                 ),
    
    .dout_next                          ( dout_next                   ),
    .dout_next_vld                      ( dout_next_vld               ),
    .din_next                           ( din_next                    ),
    .din_next_vld                       ( din_next_vld                ),
    
    .dout_cur                           ( dout_cur                    ),
    .dout_cur_vld                       ( dout_cur_vld                ),
    .din_cur                            ( din_cur                     ),
    .din_cur_vld                        ( din_cur_vld                 )

    );

assign data_is_addr                        = din_cur[32];
assign op_is_write                         = din_cur[25];
assign din_cur_lat                         = din_cur_vld;
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        dout_cur_vld                        <= '0;
        dout_cur                            <= '0;
    end
    else begin

        if(apb_ack & ~apb_pwrite)
            dout_cur_vld                        <= 1'b1;
        else
            dout_cur_vld                        <= 1'b0;

        if(apb_ack & ~apb_pwrite)
            dout_cur                            <= apb_prdata;

    end

assign addr_lat_en                         = din_cur_lat & data_is_addr & ~apb_psel;
assign wait_data_cur_set                   = din_cur_lat & data_is_addr & op_is_write;
assign wait_data_cur_clr                   = din_cur_lat & ~data_is_addr & wait_data_cur;
assign core_wr_en                          = din_cur_lat & wait_data_cur & ~apb_psel;
assign core_rd_en                          = din_cur_lat & data_is_addr & ~op_is_write;
assign apb_ack                             = (apb_psel & apb_penable & apb_pready);
always_ff @(posedge clk or negedge rstn)
    if(~rstn) begin
        apb_psel                            <= '0;
        apb_penable                         <= '0;
        apb_pwrite                          <= '0;
        apb_paddr                           <= '0;
        apb_pwdata                          <= '0;
        wait_data_cur                       <= '0;
    end
    else begin

        if(wait_data_cur_clr)
            wait_data_cur                       <= '0;
        else if(wait_data_cur_set)
            wait_data_cur                       <= 1'b1;

        if(apb_ack)
            apb_psel                            <= 1'b0;
        else if(core_wr_en | core_rd_en)
            apb_psel                            <= 1'b1;

        if(apb_ack)
            apb_penable                         <= 1'b0;
        else if(apb_psel & ~apb_penable)
            apb_penable                         <= 1'b1;
        
        if(apb_ack)
            apb_pwrite                          <= '0;
        else if(wait_data_cur_set)
            apb_pwrite                          <= '1;

        if(addr_lat_en)
            apb_paddr                           <= din_cur[CORE_ADDR_WIDTH-1:0];

        if(core_wr_en)
            apb_pwdata                          <= din_cur[31:0];

    end

endmodule

