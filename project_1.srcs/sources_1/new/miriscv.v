`include "miriscv_defines.v"

module miriscv(
    input clk_i,
    input rst_i
);


//Instruction wire
wire [31:0] instr;

//PC reg
reg [31:0] PC;

//ALU wire (reg's)
reg [31:0]  operand_a;
reg [31:0]  operand_b;
wire [31:0] alu_result;
wire        alu_comp;

//Register file wires(reg's)
wire [31:0] reg_o1;
wire [31:0] reg_o2;
reg [31:0] reg_input_data;

//Data memory wires(reg's)
wire [31:0] memory_output_data;

//Imm_X
wire [31:0] imm_I;
assign imm_I = {{20{instr[31]}},instr[31:20]};
wire [31:0] imm_S;
assign imm_S = {{20{instr[31]}},instr[31:25],instr[11:7]};
wire [31:0] imm_J;
assign imm_J = {{12{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21]} << 1;
wire [31:0] imm_B;
assign imm_B = {{20{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8]} << 1;

//decoder wire
wire [1:0]                  ex_op_a_sel;
wire [2:0]                  ex_op_b_sel;
wire [`ALU_OP_WIDTH-1:0]    alu_op;
wire                        mem_req;
wire                        mem_we;
wire [2:0]                  mem_size;
wire                        gpr_we_a;
wire                        wb_src_sel;
wire                        branch;
wire                        jal;
wire                        jalr;


miriscv_alu alu_inst (.operator_i(alu_op),
                      .operand_a_i(operand_a),
                      .operand_b_i(operand_b),
                      .result_o(alu_result),
                      .comparison_result_o(alu_comp)
                      );

miriscv_register_file register_file_inst (.clk_i(clk_i),
                                          .rst_i(rst_i),
                                          .write_enable_i(gpr_we_a),
                                          .input_a1_i(instr[19:15]),
                                          .input_a2_i(instr[24:20]),
                                          .input_a3_i(instr[11:7]),
                                          .data_i(reg_input_data),
                                          .output_a1_o(reg_o1),
                                          .output_a2_o(reg_o2)
                                          );

miriscv_data_memory data_memory_inst (.clk_i(clk_i),
                                      .address_i(alu_result),
                                      .data_i(reg_o2),
                                      .req_i(mem_req),
                                      .we_i(mem_we),
                                      .wsize_i(mem_size),
                                      .data_o(memory_output_data)
                                      );

miriscv_instruction_memory instruction_memory_inst (.addr_i(PC),
                                                    .data_o(instr)
                                                    );

miriscv_decode decoder_inst (.fetched_instr_i(instr),
                             .ex_op_a_sel_o(ex_op_a_sel),
                             .ex_op_b_sel_o(ex_op_b_sel),
                             .alu_op_o(alu_op),
                             .mem_req_o(mem_req),
                             .mem_we_o(mem_we),
                             .mem_size_o(mem_size),
                             .gpr_we_a_o(gpr_we_a),
                             .wb_src_sel_o(wb_src_sel),
                             .branch_o(branch),
                             .jal_o(jal),
                             .jalr_o(jalr)
                             );
//Reset block
always @(posedge clk_i) begin
    if (rst_i) begin
        PC <= 0;
    end
end                         

//ALU 1 OPERAND CHOSE
always @* begin
    case (ex_op_a_sel)
        `OP_A_RS1: operand_a <= reg_o1;
        `OP_A_CURR_PC: operand_a <= PC;
        `OP_A_ZERO: operand_a <= 0;
    endcase
end
 
//ALU 2 OPERAND CHOSE
 always @* begin
    case (ex_op_b_sel)
        `OP_B_RS2: operand_b <= reg_o2;
        `OP_B_IMM_I: operand_b <= imm_I;
        `OP_B_IMM_U: operand_b <= {instr[31:12], 1'd0};
        `OP_B_IMM_S: operand_b <= imm_S;
        `OP_B_INCR: operand_b <= 4;
    endcase
 end
 
 //Register file write select
 always @* begin
    case (wb_src_sel)
        `WB_EX_RESULT: reg_input_data <= alu_result;
        `WB_LSU_DATA: reg_input_data <= memory_output_data;
    endcase
 end
 
 //PC selection + summ
 always @(posedge clk_i) begin
    if (rst_i) begin
        PC <= 0;
    end
    case (jalr)       
        1'd1: PC = reg_o1;
        1'd0: 
            case ((alu_comp&&branch)|jal)
                1'd0: PC <= PC + 4;
                1'd1:
                    case (branch)
                        1'd0: PC <= PC + imm_J;
                        1'd1: PC <= PC + imm_B;
                    endcase
            endcase                  
    endcase
 end
                        
endmodule