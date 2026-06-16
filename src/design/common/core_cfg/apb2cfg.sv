
module apb2cfg #(
    parameter ADDR_WIDTH= 25,
    parameter DATA_WIDTH= 32,
    parameter CORE_MEM_ADDR_OFFSET = 25'h1ff_f000
    )(

    //apb_if
    input                                           apb_pclk,
    input                                           apb_presetn,
    input                                           apb_psel,
    input                                           apb_penable,
    input                                           apb_pwrite,
    input       [ADDR_WIDTH-1:0]                    apb_paddr,
    input       [DATA_WIDTH-1:0]                    apb_pwdata,
    output      logic                               apb_pready,
    output      logic [DATA_WIDTH- 1:0]             apb_prdata,
    output                                          apb_pslverr,
    //intr
    output      logic                               core_cfg_intr,
    //core_unit if
    input       logic [31:0]                        core_cfg_dout,     //data returned from downstream core_unit
    input       logic                               core_cfg_dout_vld, //qualifier of data returned from downstream core_unit
    output      logic [32:0]                        core_cfg_din,      //cfg_data to downstream core_unit
    output      logic                               core_cfg_din_vld   //qualifier of cfg_data to downstream core_unit

    );

localparam CORE_CFG_CTRL_OFFSET_ADDR                            = (CORE_MEM_ADDR_OFFSET + 'h0);
localparam CORE_CFG_INTR_OFFSET_ADDR                            = (CORE_MEM_ADDR_OFFSET + 'h4);
localparam CORE_CFG_ST_OFFSET_ADDR                              = (CORE_MEM_ADDR_OFFSET + 'h8);
localparam CORE_CFG_ADDR_OFFSET_ADDR                            = (CORE_MEM_ADDR_OFFSET + 'hc);
localparam CORE_CFG_DATA_OFFSET_ADDR                            = (CORE_MEM_ADDR_OFFSET + 'h10);

typedef enum logic [1:0] {
    CORE_CFG_ST_IDLE,
    CORE_CFG_ST_WR_ADDR,
    CORE_CFG_ST_WR_DATA,
    CORE_CFG_ST_RD
} core_cfg_st_type;

core_cfg_st_type           cfg_cur_st;
core_cfg_st_type           cfg_next_st;
logic   [5:0]              o_core_cfg_latency;
logic                      o_core_cfg_bc_en;
logic                      o_core_cfg_ctrl_en;
logic                      o_core_cfg_intr_en;
logic                      o_core_cfg_intr_wr_mask;
logic                      o_core_cfg_intr_rd_mask;
logic                      o_core_cfg_st_wr_done;
logic                      o_core_cfg_st_rd_done;
logic                      core_cfg_op_lat;
logic   [ADDR_WIDTH-1:0]   core_cfg_addr_lat;
logic   [19:0]             o_core_cfg_addr_reg;
logic   [31:0]             o_core_cfg_data_val;
logic                      core_cfg_rd_start;
logic                      core_cfg_op_r;
logic                      core_cfg_op_w;
logic                      core_cfg_wr_start;
logic                      cfg_wr_st_addr_done;
logic                      cfg_wr_st_data_done;
logic                      cfg_rd_st_done;
logic   [5:0]              st_dly_cnt;
logic                      st_dly_cnt_inc;
logic                      st_dly_cnt_clr;
logic                      core_cfg_din_vld_w;
logic                      core_cfg_dout_vld_lat;
logic   [1:0]              core_cfg_dout_vld_dly;
logic   [1:0]              core_cfg_intr_w;
logic                      core_mem_addr_hit;
logic   [3:0]              o_core_cfg_addr_id;

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        o_core_cfg_ctrl_en                  <=  'h0;
        o_core_cfg_bc_en                    <=  'h0;
        o_core_cfg_latency                  <=  6'd0;
        o_core_cfg_intr_en                  <=  'h0;
        o_core_cfg_intr_wr_mask             <=  'h0;
        o_core_cfg_intr_rd_mask             <=  'h0;
        o_core_cfg_addr_id                  <=  'h0;
    end
    else if(apb_psel & apb_penable & apb_pwrite & ~apb_pready) begin
        case(apb_paddr)
        CORE_CFG_CTRL_OFFSET_ADDR: begin
            o_core_cfg_ctrl_en                  <= apb_pwdata[0:0];
            o_core_cfg_bc_en                    <= apb_pwdata[8:8];
            o_core_cfg_latency             <= apb_pwdata[16+:6];
        end
        CORE_CFG_INTR_OFFSET_ADDR: begin
            o_core_cfg_intr_en                  <= apb_pwdata[0:0];
            o_core_cfg_intr_wr_mask             <= apb_pwdata[1:1];
            o_core_cfg_intr_rd_mask             <= apb_pwdata[2:2];
        end
        CORE_CFG_ADDR_OFFSET_ADDR: begin
            o_core_cfg_addr_id                  <= apb_pwdata[3:0];
        end
        endcase
    end

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        o_core_cfg_st_wr_done              <=  'h0;
        o_core_cfg_st_rd_done              <=  'h0;
    end
    else begin
        if(apb_psel & apb_penable & apb_pwrite & ~apb_pready & (apb_paddr == CORE_CFG_ST_OFFSET_ADDR)) begin
            o_core_cfg_st_wr_done          <= apb_pwdata[0:0] ? 1'b0 : o_core_cfg_st_wr_done;
            o_core_cfg_st_rd_done          <= apb_pwdata[1:1] ? 1'b0 : o_core_cfg_st_rd_done;
        end
        else begin
            if(core_cfg_wr_start | core_cfg_rd_start)
                o_core_cfg_st_wr_done          <= 1'b0;
            else if(cfg_wr_st_data_done)
                o_core_cfg_st_wr_done          <= 1'b1;
            
            if(core_cfg_wr_start | core_cfg_rd_start)
                o_core_cfg_st_rd_done          <= 1'b0;
            else if(core_cfg_dout_vld_lat)
                o_core_cfg_st_rd_done          <= 1'b1;
        end
    end

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        apb_prdata                          <= 0;
    end
    else if(apb_psel & apb_penable & ~apb_pwrite & ~apb_pready) begin
        case(apb_paddr)
        CORE_CFG_CTRL_OFFSET_ADDR: begin
            apb_prdata[23:0]                <= {2'h0,o_core_cfg_latency,7'h0,o_core_cfg_bc_en,7'h0,o_core_cfg_ctrl_en};
            apb_prdata[31:24]               <= 'h0;
        end
        CORE_CFG_INTR_OFFSET_ADDR: begin
            apb_prdata[0:0]                     <= o_core_cfg_intr_en;
            apb_prdata[1:1]                     <= o_core_cfg_intr_wr_mask;
            apb_prdata[2:2]                     <= o_core_cfg_intr_rd_mask;
            apb_prdata[31:3]                    <=  'h0;
        end
        CORE_CFG_ST_OFFSET_ADDR: begin
            apb_prdata[0:0]                     <= o_core_cfg_st_wr_done;
            apb_prdata[1:1]                     <= o_core_cfg_st_rd_done;
            apb_prdata[31:2]                    <=  'h0;
        end
        CORE_CFG_ADDR_OFFSET_ADDR: begin
            apb_prdata[3:0]                     <= o_core_cfg_addr_id;
            apb_prdata[5:4]                     <= 2'b0;
            apb_prdata[6:6]                     <= core_cfg_op_lat;
            apb_prdata[31:7]                    <= core_cfg_addr_lat;
        end
        CORE_CFG_DATA_OFFSET_ADDR: begin
            apb_prdata[31:0]                    <= o_core_cfg_data_val;
        end
        endcase
    end

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        o_core_cfg_data_val                 <=  'h0;
    end
    else begin
        if(core_cfg_dout_vld_lat)
            o_core_cfg_data_val                 <= core_cfg_dout[31:0];
        else if(core_cfg_wr_start)
            o_core_cfg_data_val                 <= apb_pwdata[31:0];
    end

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn)
        apb_pready                          <= 1'b0;
    else if(apb_psel & apb_penable & ~apb_pready & ~core_cfg_op_w)
        apb_pready                          <= 1'b1;
    else if(cfg_wr_st_data_done | cfg_rd_st_done)
        apb_pready                          <= 1'b1;
    else
        apb_pready                          <= 1'b0;

assign apb_pslverr                         = 1'b0;

assign core_mem_addr_hit                   = (apb_paddr < CORE_MEM_ADDR_OFFSET);
assign core_cfg_rd_start                   = ~core_cfg_op_r & apb_psel & apb_penable & ~apb_pwrite & ~apb_pready & core_mem_addr_hit & o_core_cfg_ctrl_en;
assign core_cfg_wr_start                   = ~core_cfg_op_r & apb_psel & apb_penable & apb_pwrite & ~apb_pready & core_mem_addr_hit & o_core_cfg_ctrl_en;
assign cfg_wr_st_addr_done                 = (cfg_cur_st == CORE_CFG_ST_WR_ADDR) & (st_dly_cnt == 6'd3);
assign cfg_wr_st_data_done                 = (cfg_cur_st == CORE_CFG_ST_WR_DATA) & (st_dly_cnt == 6'(o_core_cfg_latency + 3));
assign cfg_rd_st_done                      = (cfg_cur_st == CORE_CFG_ST_RD) & (st_dly_cnt == 6'd3);

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn)
        cfg_cur_st                          <= CORE_CFG_ST_IDLE;
    else
        cfg_cur_st                          <= cfg_next_st;


always_comb begin
    cfg_next_st                         = CORE_CFG_ST_IDLE;
    case(cfg_cur_st)
        CORE_CFG_ST_IDLE: begin
            if(core_cfg_rd_start)
                cfg_next_st                         = CORE_CFG_ST_RD;
            else if(core_cfg_wr_start)
                cfg_next_st                         = CORE_CFG_ST_WR_ADDR;
            else
                cfg_next_st                         = CORE_CFG_ST_IDLE;
        end
        CORE_CFG_ST_WR_ADDR: begin
            if(cfg_wr_st_addr_done)
                cfg_next_st                         = CORE_CFG_ST_WR_DATA;
            else
                cfg_next_st                         = CORE_CFG_ST_WR_ADDR;
        end
        CORE_CFG_ST_WR_DATA: begin
            if(cfg_wr_st_data_done)
                cfg_next_st                         = CORE_CFG_ST_IDLE;
            else
                cfg_next_st                         = CORE_CFG_ST_WR_DATA;
        end
        CORE_CFG_ST_RD: begin
            if(cfg_rd_st_done)
                cfg_next_st                         = CORE_CFG_ST_IDLE;
            else
                cfg_next_st                         = CORE_CFG_ST_RD;
        end
    endcase
end

assign st_dly_cnt_inc                      = (cfg_cur_st != CORE_CFG_ST_IDLE);
assign st_dly_cnt_clr                      = cfg_wr_st_addr_done | cfg_wr_st_data_done | cfg_rd_st_done;
always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn)
        st_dly_cnt                          <= 'h0;
    else if(st_dly_cnt_clr)
        st_dly_cnt                          <= 'h0;
    else if(st_dly_cnt_inc)
        st_dly_cnt                          <= st_dly_cnt + 1;
    else
        st_dly_cnt                          <= 'h0;

assign core_cfg_intr_w[0]                  = o_core_cfg_st_wr_done & ~o_core_cfg_intr_wr_mask & o_core_cfg_intr_en;
assign core_cfg_intr_w[1]                  = o_core_cfg_st_rd_done & ~o_core_cfg_intr_rd_mask & o_core_cfg_intr_en;
assign core_cfg_din_vld_w                  = (core_cfg_wr_start | core_cfg_rd_start | cfg_wr_st_addr_done);
assign core_cfg_dout_vld_lat               = core_cfg_dout_vld_dly[1];
assign core_cfg_op_w                       = apb_psel & apb_penable & core_mem_addr_hit & o_core_cfg_ctrl_en;

always_ff @(posedge apb_pclk or negedge apb_presetn)
    if(!apb_presetn) begin
        core_cfg_op_r                       <= '0;
        core_cfg_dout_vld_dly               <= '0;
        core_cfg_intr                       <= '0;
        core_cfg_din                        <= '0;
        core_cfg_din_vld                    <= '0;
        core_cfg_op_lat                     <= 'h0;
        core_cfg_addr_lat                   <= 'h0;

    end
    else begin

        if(core_cfg_rd_start)
            core_cfg_op_lat                     <=  'h0;
        else if(core_cfg_wr_start)
            core_cfg_op_lat                     <=  'h1;

        if(core_cfg_rd_start | core_cfg_wr_start)
            core_cfg_addr_lat                   <= apb_paddr;

        core_cfg_op_r                       <= core_cfg_op_w;
        core_cfg_intr                       <= |core_cfg_intr_w;
        
        core_cfg_dout_vld_dly               <= {core_cfg_dout_vld_dly[0],core_cfg_dout_vld};
        core_cfg_din_vld                    <= core_cfg_din_vld_w;

        if(core_cfg_rd_start | core_cfg_wr_start)
            core_cfg_din                        <= {
                1'b1,//addr
                core_cfg_wr_start & o_core_cfg_bc_en,//burst
                1'b0,
                o_core_cfg_addr_id[3:0],
                apb_pwrite,//write flag
                {(25-ADDR_WIDTH){1'b0}},
                apb_paddr[ADDR_WIDTH-1:0]
            };

        else if(cfg_wr_st_addr_done)
            core_cfg_din                        <= {
                1'b0,
                o_core_cfg_data_val
            };

    end

endmodule
