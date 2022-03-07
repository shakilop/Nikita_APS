module miriscv_instruction_memory (
    input [31:0] addr_i,
    output [31:0] data_o    
);

reg [31:0] RAM [31:0];

initial $readmemh ("test_program.mem", RAM);

assign data_o = RAM[addr_i >> 2];

endmodule