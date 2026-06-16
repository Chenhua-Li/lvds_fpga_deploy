
module priority_encoder #
(
    parameter WIDTH = 4,
    // LSB priority selection
    parameter LSB_HIGH_PRIORITY = 0
    )
(
    input       logic [WIDTH-1:0]                   input_unencoded,
    output      logic                               output_valid,
    output      logic [$clog2(WIDTH)-1:0]           output_encoded,
    output      logic [WIDTH-1:0]                   output_unencoded
    );

parameter LEVELS = WIDTH > 2 ? $clog2(WIDTH) : 1;
parameter W = 2**LEVELS;

// pad input to even power of two
logic   [W-1:0]                                 input_padded;
logic   [W/2-1:0]                               stage_valid[LEVELS-1:0];
logic   [W/2-1:0]                               stage_enc[LEVELS-1:0];

assign input_padded = {{W-WIDTH{1'b0}}, input_unencoded};

generate
    // process input bits; generate valid bit and encoded bit for each pair
    for (genvar n = 0; n < W/2; n = n + 1) begin : loop_in
        assign stage_valid[0][n] = |input_padded[n*2+1:n*2];
        if (LSB_HIGH_PRIORITY) begin
            // bit 0 is highest priority
            assign stage_enc[0][n] = !input_padded[n*2+0];
        end else begin
            // bit 0 is lowest priority
            assign stage_enc[0][n] = input_padded[n*2+1];
        end
    end

    // compress down to single valid bit and encoded bus
    for (genvar l = 1; l < LEVELS; l = l + 1) begin : loop_levels
        for (genvar n = 0; n < W/(2*2**l); n = n + 1) begin : loop_compress
            assign stage_valid[l][n] = |stage_valid[l-1][n*2+1:n*2];
            if (LSB_HIGH_PRIORITY) begin
                // bit 0 is highest priority
                assign stage_enc[l][(n+1)*(l+1)-1:n*(l+1)] = stage_valid[l-1][n*2+0] ? {1'b0, stage_enc[l-1][(n*2+1)*l-1:(n*2+0)*l]} : {1'b1, stage_enc[l-1][(n*2+2)*l-1:(n*2+1)*l]};
            end else begin
                // bit 0 is lowest priority
                assign stage_enc[l][(n+1)*(l+1)-1:n*(l+1)] = stage_valid[l-1][n*2+1] ? {1'b1, stage_enc[l-1][(n*2+2)*l-1:(n*2+1)*l]} : {1'b0, stage_enc[l-1][(n*2+1)*l-1:(n*2+0)*l]};
            end
        end
    end
endgenerate

assign output_valid                        = stage_valid[LEVELS-1][0];
assign output_encoded                      = stage_enc[LEVELS-1][$clog2(WIDTH)-1:0];
assign output_unencoded                    = 1'b1 << output_encoded;

endmodule

