`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2021 22:29:46
// Design Name: 
// Module Name: ALU_Class
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

import Architecture_AClass::*;

// Global package alias
`define alupkg ALU_Class

`define OPERATION_ENUM_VEC_BITWIDTH 4
`define ALU_INTERNALS_INITIAL_STATE `NULL_REG_VAL
`define ALUVECTOR_BITWIDTH (`REGISTER_GLOBAL_BITWIDTH + 1)

// Typedefs aliases
`define aluvector `alupkg::riscv_aluvector
`define alu_operation_vector `alupkg::riscv_alu_operation_vector
`define alu_operation_type `alupkg::OperationType

package ALU_Class;
    /////////////////////////////////
    // Typedef:
    //      riscv_aluvector
    // Info:
    //      This type represents output from ALU unit and has one extra bit,
    //      to indicate overflow.
    /////////////////////////////////
    typedef `packed_arr(`rvtype, `ALUVECTOR_BITWIDTH, riscv_aluvector);

    /////////////////////////////////
    // Typedef:
    //      riscv_alu_operation_vector
    // Info:
    //      This type represents bus used for transmitting ALU unit operations.
    /////////////////////////////////
    typedef `packed_arr(`rvtype, `OPERATION_ENUM_VEC_BITWIDTH, riscv_alu_operation_vector);

    /////////////////////////////////
    // Typedef:
    //      enum OperationType
    // Info:
    //      This type represents possible operations to be performed by the ALU unit.
    /////////////////////////////////
    typedef enum `rvtype [`OPERATION_ENUM_VEC_BITWIDTH - 1 : 0]
                        {  ALU_ADD = 1,
                           ALU_SUB = 2,
                           ALU_XOR = 3,
                           ALU_AND = 4,
                           ALU_NOR = 5,
                           ALU_OR = 6,
                           ALU_SLT = 7,
                           ALU_NAND = 8 } OperationType;


    class ALU extends `archpkg::Architecture;
        
        `_public function `aluvector PerformOperation(input OperationType operation, input `rvector left_operand, input `rvector right_operand);
            unique case(operation)
                ALU_ADD: return left_operand + right_operand; // Will this correctly overflow if needed?
                ALU_SUB: return left_operand - right_operand;
                ALU_XOR: return left_operand ^ right_operand;
                ALU_AND: return left_operand & right_operand;
                ALU_NOR: return ~(left_operand | right_operand); // TODO: Check if it doesn't cause overflow here!!!
                ALU_OR: return left_operand | right_operand;
                ALU_SLT: return left_operand < right_operand ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0);
                ALU_NAND: return ~(left_operand & right_operand);
                default: ; // Do nothing
            endcase
        
        endfunction
    endclass

    class AluTransactionItem;
        `_public `rvector left_operand;
        `_public `rvector right_operand;
        `_public `aluvector outcome;
        `_public `alu_operation_type operation;
    endclass

    class AluDriver;
        `_public virtual ALUInterface aluinf;
        `_public mailbox alu_driver_mailbox;

        `_public task run();
            
        endtask
    endclass
endpackage

interface ALUInterface(input `rvtype clk);
    `rvector leftOperand;
    `rvector rightOperand;
    `aluvector outcome;
    `rvtype reset;
    `alu_operation_type operation;
    modport DUT(input clk, input reset, input leftOperand, input rightOperand, input operation, output outcome);
    modport Testbench(input clk, output reset, output leftOperand, output rightOperand, output operation, input outcome);
endinterface //ALUInterface
