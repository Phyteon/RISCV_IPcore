`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2021 00:01:02
// Design Name: 
// Module Name: RV_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

import Architecture_AClass::*;
import RegistryFile_Class::*;
import Instruction_Classes::*;
import ProgramCounter_Class::*;
import Multiplexer_Class::*;
import ControlUnit_Class::*;


module RV_core(input `rvtype clk, input `rvtype reset);

    /**
    * Interfaces instantiation.
    */
    ALUInterface main_aluinf(clk); /**< Interface of the main ALU unit */
    ALUInterface pmac_aluinf0(clk); /**< Interface of the upper ALU in the PMAC */
    ALUInterface pmac_aluinf1(clk); /**< Interface of the lower ALU in the PMAC */
    ControlUnitInterface cu_inf(clk); /**< Interface of the control unit */
    MemoryInterface progmem_inf(clk); /**< Interface of program memory */
    MemoryInterface datamem_inf(clk); /**< Interface of data memory */
    ProgramCounterInterface pc_inf(clk); /**< Interface of program counter */
    RegistryFileInterface reg_inf(clk); /**< Interface of registry file */
    MUXInterface#(.inout_type(`rvector), .num_of_ins(2)) mux0_inf();
    MUXInterface#(.inout_type(`rvector), .num_of_ins(2)) mux1_inf();
    MUXInterface#(.inout_type(`rvector), .num_of_ins(2)) mux2_inf();
    MUXInterface#(.inout_type(`rvector), .num_of_ins(3)) mux3_inf();
    MUXInterface#(.inout_type(`rvector), .num_of_ins(2)) mux4_inf();

    /**
    * Module instantiation.
    */
    ProgramCounter_Module pc(.pcinf(pc_inf));
    Memory_Module #("D:\\VivadoProjects\\cordic_test\\RISCV_IPcore\\cordic_test.srcs\\sources_1\\new\\program_mem.hexdat") prog_mem(.memif(progmem_inf));
    Memory_Module data_mem(.memif(datamem_inf));
    ControlUnit_Module cu(.cuinf(cu_inf));
    RegistryFile_Module regfile(.reginf(reg_inf));
    ALU_Module main_alu(.aluinf(main_aluinf));
    ALU_Module pmac_alu0(.aluinf(pmac_aluinf0));
    ALU_Module pmac_alu1(.aluinf(pmac_aluinf1));
    MUX mux0(.muxinf(mux0_inf));
    MUX mux1(.muxinf(mux1_inf));
    MUX mux2(.muxinf(mux2_inf));
    MUX mux3(.muxinf(mux3_inf));
    MUX mux4(.muxinf(mux4_inf));

    /**
    * Internal signals declaration.
    */
    `uint mux0_steer;

    /**
    * Constants.
    */
    initial begin
        pmac_aluinf0.operation <= `alupkg::OperationType'(0); /**< Always perform addition only */
        pmac_aluinf1.operation <= `alupkg::OperationType'(0); /**< Always perform addition only */
        pmac_aluinf1.left_operand <= `REGISTER_BYTE_SIZE; /**< One of the operands is always 4 */
        progmem_inf.MEMW <= 0; /**< Never write program memory */
        progmem_inf.MEMR <= 1; /**< Always read program memory */
        progmem_inf.MSE <= 0; /**< Never sign-extend instructions */
        progmem_inf.MBC <= 3; /**< Always read full words */
    end

    /**
    * Interconnections.
    */
    assign pmac_aluinf0.left_operand = cu_inf.IMM0;
    assign pmac_aluinf0.right_operand = mux1_inf.mux_output;
    assign pmac_aluinf1.right_operand = pc_inf.ADDROUT; /**< Loopback from program counter */
    assign mux0_inf.inputs[1] = pmac_aluinf0.outcome;
    assign mux0_inf.inputs[0] = pmac_aluinf1.outcome;
    assign mux0_inf.steering = mux0_steer;
    assign pc_inf.ADDRIN = mux0_inf.mux_output;

    assign cu_inf.INSTR = progmem_inf.MEMOUT; /**< Feed instructions into Control Unit */
    /**
    ****** Control Unit signals interconnections section.
    */
    always_comb begin
        mux0_steer <= cu_inf.CUJMPCTRL | (cu_inf.CUBCTRL & main_aluinf.alubctrl);
    end
    assign mux1_inf.steering = cu_inf.MUX1; /**< Control signal for mux controlling the input to PMAC */
    assign mux2_inf.steering = cu_inf.MUX2;
    assign mux3_inf.steering = cu_inf.MUX3;
    assign mux4_inf.steering = cu_inf.MUX4;
    assign reg_inf.RS1 = cu_inf.RS1;
    assign reg_inf.RS2 = cu_inf.RS2;
    assign reg_inf.RD = cu_inf.RD;
    assign reg_inf.REGW = cu_inf.REGW;
    assign main_aluinf.operation = cu_inf.ALU0;
    assign mux2_inf.inputs[0] = cu_inf.IMM1;
    assign datamem_inf.MEMW = cu_inf.MEMW;
    assign datamem_inf.MEMR = cu_inf.MEMR;
    assign datamem_inf.MSE = cu_inf.MSE;
    assign datamem_inf.MBC = cu_inf.MBC;
    /**
    ****** End of Control Unit interconnections sections.
    */
    assign mux3_inf.inputs[0] = main_aluinf.outcome;
    assign mux3_inf.inputs[1] = pmac_aluinf1.outcome;
    assign mux3_inf.inputs[2] = datamem_inf.MEMOUT;
    assign reg_inf.REGDATIN = mux3_inf.mux_output;
    assign mux4_inf.inputs[0] = reg_inf.OP1;
    assign mux4_inf.inputs[1] = pc_inf.ADDROUT;
    assign mux2_inf.inputs[1] = reg_inf.OP2;
    assign main_aluinf.left_operand = mux4_inf.mux_output;
    assign main_aluinf.right_operand = mux2_inf.mux_output;
    assign datamem_inf.ADDRIN = main_aluinf.outcome;
    assign datamem_inf.DATAIN = reg_inf.OP2;
    assign mux1_inf.inputs[1] = main_aluinf.outcome;
    assign mux1_inf.inputs[0] = pc_inf.ADDROUT;

    /**
    * Reset signals.
    */
    assign main_aluinf.reset = reset;
    assign pmac_aluinf0.reset = reset;
    assign pmac_aluinf1.reset = reset;
    assign cu_inf.RESET = reset;
    assign progmem_inf.RESET = reset;
    assign datamem_inf.RESET = reset;
    assign pc_inf.RESET = reset;
    assign reg_inf.RESET = reset;
endmodule
