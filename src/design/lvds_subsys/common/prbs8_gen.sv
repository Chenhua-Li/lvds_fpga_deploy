//prbs8: x8+x6+x5+x4+1

module prbs8_gen(
    input                                           clk,
    input                                           rst_n,
    input                                           en,
    input                                           clr,
    output      logic [7:0]                         prbs_out  // 8-bit PRBS output per cycle
    );

logic   [7:0]                                   shift_r;
logic   [7:0]                                   shift_w0;

function automatic logic [7:0] prbs_shift(
    input       [7:0]                               dat
    );

logic                                           fb;
begin
    fb                                  = dat[7] ^ dat[5] ^ dat[4] ^ dat[3];
end
return {dat[6:0],fb};

endfunction

assign shift_w0                            = prbs_shift(.dat(shift_r));
always_ff @(posedge clk or negedge rst_n)
    if(!rst_n) begin
        shift_r                             <= 8'hff;
        prbs_out                            <= '0;
    end 
    else if(clr)begin
        shift_r                             <= 8'hff;
        prbs_out                            <= '0;
    end
    else if (en) begin
        shift_r                             <= shift_w0;
        prbs_out                            <= shift_r;
    end

endmodule

