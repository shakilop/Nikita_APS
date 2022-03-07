module miriscv_register_file (
input clk_i,
input rst_i,
input write_enable_i,
input [4:0] input_a1_i,
input [4:0] input_a2_i,
input [4:0] input_a3_i,
input [31:0] data_i,
output [31:0] output_a1_o,
output [31:0] output_a2_o
);

//Memory register
reg [31:0] register[31:0];
//counter
reg [5:0] i;

assign output_a1_o = register[input_a1_i];
assign output_a2_o = register[input_a2_i];


//Write
always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i = 0; i < 32; i = i + 1)
            register[i] <= 0;
    end else
    if (write_enable_i) begin
        if (input_a3_i != 0) begin
            register[input_a3_i] <= data_i;
        end       
    end
end

endmodule