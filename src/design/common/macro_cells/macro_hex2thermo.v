module macro_hex2thermo(
    input  [ 6:0]    hex    ,
    output [127:0]   thermo 
);

reg [127:0] dec_hex;
integer     i;

always @(*) begin
    dec_hex = 128'h0;
    for (i=0; i<128; i=i+1)
    begin
        if (hex > $unsigned(i))
            dec_hex[i] = 1'b1;
        else
            dec_hex[i] = 1'b0;
    end
end

assign thermo = dec_hex;

endmodule 
