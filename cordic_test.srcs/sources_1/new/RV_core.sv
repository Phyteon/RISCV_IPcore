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


module RV_core(`rvtype clk);

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








endmodule
