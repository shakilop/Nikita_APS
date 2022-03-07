`timescale 1ns / 1ps

module tb_miriscv();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 6;         // 10 ns reset
  parameter     RAM_SIZE = 512;       // in 32-bit words

  // clock, reset
  reg clk;
  reg rst;

  miriscv dut (
    .clk_i    (clk),
    .rst_i  (rst)
  );

  initial begin
    clk   = 1'b0;
    rst = 1'b1;
    #RST_WAIT;
    rst = 1'b0;
  end

  always begin
    #HF_CYCLE;
    clk = ~clk;
  end

endmodule