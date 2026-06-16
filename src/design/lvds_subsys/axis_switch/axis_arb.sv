
 module axis_arb#(
 // Number of AXI stream inputs
    parameter S_COUNT = 4,
     // Number of AXI stream outputs
    parameter M_COUNT = 3
    
    )
(
    input       logic                               clk,
    input       logic                               rst_n,

    input       logic [S_COUNT-1:0]                 s_axis_tvalid,
    input       logic [S_COUNT-1:0]                 s_axis_tready,
    input       logic [S_COUNT-1:0]                 s_axis_tlast,
    input       logic [M_COUNT-1:0]                 m_axis_tready,
    output      logic [M_COUNT*($clog2(S_COUNT)+1)-1:0]select
    );

localparam S_W = $clog2(S_COUNT);
localparam COUNT = (S_COUNT > M_COUNT) ? S_COUNT : M_COUNT;

logic   [M_COUNT-1:0][(S_W+1)-1:0]              select_r;
logic   [M_COUNT-1:0][(S_W+1)-1:0]              select_next;
logic   [M_COUNT-1:0][(S_W+1)-1:0]              select_map_p;
logic   [S_COUNT-1:0]                           s_input_r;
logic   [S_COUNT-1:0]                           s_input_next;
logic   [S_COUNT-1:0]                           s_input_valid;
logic   [S_COUNT-1:0]                           s_connect_r;
logic   [S_COUNT-1:0]                           s_connect_next;
logic   [S_COUNT-1:0]                           s_input;
logic   [S_COUNT-1:0]                           s_input_media;
logic                                           a;
logic                                           b;
logic   [(COUNT+1)-1:0][(S_W+1)-1:0]            s_ones_count;
logic   [(M_COUNT+1)-1:0][(S_W+1)-1:0]          m_ones_count;
logic   [COUNT-1:0][(S_W+1)-1:0]                s_ones_location;

generate for(genvar i=0;i<M_COUNT;i++) begin
    if(i<=S_COUNT)
        assign select_map_p[i] = i+1;
    else
        assign select_map_p[i] = '0;
end
endgenerate
assign select                              = select_next;

generate for (genvar l = 0; l < S_COUNT; l=l+1) begin
    assign s_input_media[l] = (s_axis_tvalid[l] & s_axis_tlast[l]) ? 1 : (s_input_r[l] | s_input_next[l]);
end
endgenerate

generate
for (genvar p = 0; p < S_COUNT; p=p+1) begin
    assign s_input[p] = (s_axis_tvalid[p] & s_axis_tready[p] & s_axis_tlast[p]) ? 0 : s_input_media[p];
end
endgenerate

always_ff @(posedge clk or negedge rst_n)
    if (~rst_n) begin
        select_r                            <= 0;
        s_input_r                           <= 0;
        s_connect_r                         <= 0;
    end
    else begin
        select_r                            <= select_next;
        s_input_r                           <= s_input_next;
        s_connect_r                         <= s_connect_next;
    end

always_ff @(posedge clk or negedge rst_n)
    if (~rst_n) begin
        a                                   <= 0;
    end
    else begin
        a                                   <= b;
    end

always_comb begin
    b                                   = a;
    if (|s_axis_tvalid) begin
        b                                   = 1;
    end
end

// generate s_input 
always_comb begin

    s_connect_next                      = s_connect_r;
    s_input_next                        = s_input_r;
    
    for (int unsigned i= 0;i<S_COUNT;i=i+1) begin
        if (s_axis_tvalid[i]) begin
            if(s_axis_tlast[i]) begin
                s_input_next[i]                     = 1'b0;
            end else begin
                s_input_next[i]                     = 1'b1;
            end
        end
    end 
    

    for (int unsigned k= 0;k<M_COUNT;k=k+1) begin
        if((select_r[k]== 0) | (s_axis_tvalid[select_r[k]-1] & s_axis_tready[select_r[k]-1] & s_axis_tlast[select_r[k]-1])) begin
            s_connect_next[select_r[k]-1]= 1'b0;
        end
        else begin
            s_connect_next[select_r[k]-1]= 1'b1;
        end
    end 

    // accroding s_connect gen s_input_valid
    s_input_valid                       = s_input & (~s_connect_next);

end

// renew slecet singal
always_comb begin

    select_next                         = select_r;
    s_ones_count                        = 0;
    m_ones_count                        = 0;
    s_ones_location                     = 0;

    for(int unsigned m= 0; m<S_COUNT; m=m+1) begin
        if(s_input_valid[m]) begin
            s_ones_location[(s_ones_count[m])]= m+1;
            s_ones_count[(m+1)]= s_ones_count[m] + 1;
        end
        else
            s_ones_count[(m+1)]= s_ones_count[m];
    end 
    
    for(int unsigned n= 0; n<M_COUNT; n=n+1) begin
        if((m_axis_tready[n]) & ((select_r[n]== 0) | (s_axis_tvalid[select_r[n]-1] & s_axis_tready[select_r[n]-1] & s_axis_tlast[select_r[n]-1]))) begin
            select_next[n]   = b ? s_ones_location[(m_ones_count[n])] : 0;
            m_ones_count[(n+1)]= m_ones_count[n] + 1;
        end
        else if((!m_axis_tready[n]) & (s_axis_tvalid[select_r[n]-1] & s_axis_tready[select_r[n]-1] & s_axis_tlast[select_r[n]-1])) begin
            select_next[n]   = 0;
            m_ones_count[(n+1)]= m_ones_count[n];
        end else
            m_ones_count[(n+1)]= m_ones_count[n];
    end
end

endmodule
