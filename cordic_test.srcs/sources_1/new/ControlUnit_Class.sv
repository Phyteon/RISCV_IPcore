`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2021 23:16:20
// Design Name: 
// Module Name: ControlUnit_Class
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
import Instruction_Classes::*;
import ALU_Class::*;
import SignExtender_Class::*;

`define CONTROL_UNIT_OUTPUT_TYPE void
`define CONTROL_UNIT_INSTRUCTION_INFO_MEM_SIZE_BYTES 1000 /**< Size of memory in bytes used to store info about instructions - 
                                                            USED ONLY FOR HIGH ABSTRACTION LEVEL DEVELOPMENT IMPLEMENTATION! */
`define CONTROL_UNIT_INSTRUCTION_INFO_FILE "instructionconfig.dat"


package ControlUnit_Class;
    class ControlUnit extends Architecture_AClass::Architecture;
    `_private `unpacked_arr(`rvbyte, `CONTROL_UNIT_INSTRUCTION_INFO_MEM_SIZE_BYTES, instruction_info);
    `_private `uint type_to_address[string];
    `_public virtual ControlUnitInterface cuinf;

    `_public function new();
        this.type_to_address["R_TYPE"] = 0;
        this.type_to_address["I_TYPE"] = 'h12C;
        this.type_to_address["S_TYPE"] = 'h21C;
        this.type_to_address["B_TYPE"] = 'h258;
        this.type_to_address["U_TYPE"] = 'h2D0;
        this.type_to_address["J_TYPE"] = 'h2E4;
    endfunction

    /**
    * Task for reading instruction configuration from memory file.
    * Since functions cannot invoke tasks, this task must be called manually after initialising the object of
    * Control Unit class.
    */
    `_public task init();
        $readmemb(`CONTROL_UNIT_INSTRUCTION_INFO_FILE, this.instruction_info);
    endtask

    `_private function `inspkg::Instruction DecodeType(input `insvector instruction_raw);
        /**
        * Find first memory address at which this opcode occurs
        */
        `uint idx = this.instruction_info.find_first_index(x) with (x == instruction_raw[`OPCODE_field_BitWidth - 1 + `OPCODE_field_BeginIdx : `OPCODE_field_BeginIdx]);
        inspkg::Instruction ret_obj;
        if (idx < this.type_to_address["I_TYPE"])
            ret_obj = inspkg::RTypeInstruction::new(instruction_raw);
        else if ((idx >= this.type_to_address["I_TYPE"]) && (idx < this.type_to_address["S_TYPE"]))
            ret_obj = inspkg::ITypeInstruction::new(instruction_raw);
        else if ((idx >= this.type_to_address["S_TYPE"]) && (idx < this.type_to_address["B_TYPE"]))
            ret_obj = inspkg::STypeInstruction::new(instruction_raw);
        else if ((idx >= this.type_to_address["B_TYPE"]) && (idx < this.type_to_address["U_TYPE"]))
            ret_obj = inspkg::BTypeInstruction::new(instruction_raw);
        else if ((idx >= this.type_to_address["U_TYPE"]) && (idx < this.type_to_address["J_TYPE"]))
            ret_obj = inspkg::UTypeInstruction::new(instruction_raw);
        else if (idx >= this.type_to_address["J_TYPE"])
            ret_obj = inspkg::JTypeInstruction::new(instruction_raw);
        else
            ret_obj = null;
        
        return ret_obj;
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeRtype(input `inspkg::RTypeInstruction rtypeins);
        `uint steering_sum = rtypeins.Fields[2].ExtractFromInstr(rtypeins.Contents) + rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents); /**< Add FUNCT3 and FUNCT7 field */
        unique case (steering_sum)
            0: begin /**< ADD */
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
            end
            32: begin /**< SUB */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SUB;
            end
            1: begin /**< SLL */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SLL;
            end
            2: begin /**< SLT */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SLT;
            end
            3: begin /**< SLTU */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SLTU;
            end
            4: begin /**< XOR */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_XOR;
            end
            5: begin /**< SLR */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SRL;
            end
            37: begin /** SRA */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SRA;
            end
            6: begin /**< OR */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_OR;
            end
            7: begin /**< AND */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 1;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.RD <= rtypeins.Fields[1].ExtractFromInstr(rtypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_AND;
            end
            default: ; /**< Do nothing */
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeItype(input `inspkg::ITypeInstruction itypeins);
        `uint steering_sum = itypeins.Fields[2].ExtractFromInstr(itypeins.Contents) + itypeins.Fields[0].ExtractFromInstr(itypeins.Contents); /**< Add FUNCT3 and OPCODE field */
        unique case (steering_sum)
            103: begin /**< JALR */
                this.cuinf.CUJMPCTRL <= 1;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX1 <= 1;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 1;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
            end
            3: begin /**< LB */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 2;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MSE <= 1; /**< Extend the sign of the loaded value in the memory controller */
                this.cuinf.MBC <= 1; /**< Only one byte from the given addres shall be read and sign-extended */
            end
            4: begin /**< LH */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 2;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MSE <= 1; /**< Extend the sign of the loaded value in the memory controller */
                this.cuinf.MBC <= 2; /**< Only two bytes from the given addres shall be read and sign-extended */
            end
            5: begin /**< LW */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 2;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MSE <= 0; /**< Do not extend the sign of the loaded value in the memory controller */
                this.cuinf.MBC <= 3; /**< Read the whole word */
            end
            7: begin /**< LBU */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 2;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MSE <= 0; /**< Do not extend the sign of the loaded value in the memory controller */
                this.cuinf.MBC <= 1; /**< Only one bytee from the given addres shall be read */
            end
            8: begin /**< LHU */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 2;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MSE <= 0; /**< Do not extend the sign of the loaded value in the memory controller */
                this.cuinf.MBC <= 2; /**< Only two bytes from the given addres shall be read */
            end
            19: begin /**< ADDI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
            end
            21: begin /**< SLTI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_SLT;
            end
            22: begin /**< SLTIU */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ZeroStuff(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
            end
            23: begin /**< XORI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_XOR;
            end
            25: begin /**< ORI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_OR;
            end
            26: begin /**< ANDI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtactFromInstr(itypeins.Contents), itypeins.Fields[4].ImmBitWidth, 0);
                this.cuinf.RS1 <= itypeins.Fields[3].ExtractFromInstr(itypeins.Contents);
                this.cuinf.RD <= itypeins.Fields[1].ExtractFromInstr(itypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_AND;
            end
            default: ; /**< Do nothing */
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeStype(input `inspkg::STypeInstruction stypeins);
        `uint switch = stypeins.Fields[2].ExtractFromInstr(stypeins.Contents);
        unique case (switch)
            0: begin /**< SB */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ConcatentateSTypeImmediate(stypeins);
                this.cuinf.RS1 <= stypeins.Fields[3].ExtractFromInstr(stypeins.Contents);
                this.cuinf.RS2 <= stypeins.Fields[4].ExtractFromInstr(stypeins.Contents);
                this.cuinf.REGW <= 0;
                this.cuinf.MEMW <= 1;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MBC <= 1;
            end 
            1: begin /**< SH */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ConcatentateSTypeImmediate(stypeins);
                this.cuinf.RS1 <= stypeins.Fields[3].ExtractFromInstr(stypeins.Contents);
                this.cuinf.RS2 <= stypeins.Fields[4].ExtractFromInstr(stypeins.Contents);
                this.cuinf.REGW <= 0;
                this.cuinf.MEMW <= 1;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MBC <= 2;
            end
            2: begin /**< SW */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ConcatentateSTypeImmediate(stypeins);
                this.cuinf.RS1 <= stypeins.Fields[3].ExtractFromInstr(stypeins.Contents);
                this.cuinf.RS2 <= stypeins.Fields[4].ExtractFromInstr(stypeins.Contents);
                this.cuinf.REGW <= 0;
                this.cuinf.MEMW <= 1;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
                this.cuinf.MBC <= 3;
            end
            default: ; /**< Do nothing */
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeBtype(input `inspkg::BTypeInstruction btypeins);
        `uint steering = btypeins.Fields[3].ExtractFromInstr(btypeins.Contents);
        unique case (steering)
            0: begin /**< BEQ */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BEQ; /**< Choose operation of ALU */
            end
            1: begin /**< BNE */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BNE; /**< Choose operation of ALU */
            end
            4: begin /**< BLT */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BLT; /**< Choose operation of ALU */
            end
            5: begin /**< BGE */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BGE; /**< Choose operation of ALU */
            end
            6: begin /**< BLTU */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BLTU; /**< Choose operation of ALU */
            end
            7: begin /**< BGEU */
                this.cuinf.CUJMPCTRL <= 0; /**< Disable unconditional jump flag */
                this.cuinf.CUBCTRL <= 1; /**< Indicate that branch can be taken */
                this.cuinf.MUX1 <= 0; /**< Choose current program counter value */
                this.cuinf.MUX2 <= 1; /**< Choose register as second operand for ALU */
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM0 <= `sepkg::SignExtender::ConcatentateBTypeImmediate(btypeins); /**< Retrieve immediate from instruction */
                this.cuinf.RS1 <= btypeins.Fields[4].ExtractFromInstr(btypeins.Contents);
                this.cuinf.RS2 <= btypeins.Fields[5].ExtractFromInstr(btypeins.Contents);
                this.cuinf.REGW <= 0; /**< Disable register write signal */
                this.cuinf.MEMW <= 0; /**< Disable memory write signal */
                this.cuinf.MEMR <= 0; /**< Disable memory read signal */
                this.cuinf.ALU0 <= ALU_BGEU; /**< Choose operation of ALU */
            end

            default: ; /**< Do nothing */
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeUtype(input `inspkg::UTypeInstruction utypeins);
        `uint steering = utypeins.Fields[0].ExtractFromInstr(utypeins.Contents);
        unique case (steering)
            55: begin /**< LUI */
                
            end 
            default: 
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeJtype(input `inspkg::JTypeInstruction jtypeins);

    endfunction
    
    endclass
endpackage

interface ControlUnitInterface(input `rvtype clk);
    /**
    * Input signals
    */
    `ivector INSTR; /**< Instruction to decode */
    /**
    * 1 - bit controls
    */
    `rvtype CUJMPCTRL; /**< Control Unit Jump Control signal */
    `rvtype CUBCTRL; /**< Control Unit Branch Control signal */
    `rvtype MUX1; /**< Multiplexer 1 control (relative branch/ jump) */
    `rvtype MUX2; /**< Multiplexer 2 control (second operand from registry file/ immediate value) */
    `rvtype MUX4; /**< Multiplexer 4 control (for supplying current PC value to ALU) */
    `rvtype REGW; /**< Registry File Write control signal */
    `rvtype MEMW; /**< Memory Write control signal */
    `rvtype MEMR; /**< Memory Read control signal */
    `rvtype MSE; /**< Memory Sign Extention control signal */
    /**
    * 2 - bit controls
    */
    `packed_arr(`rvtype, 2, MUX3); /**< Multiplexer 3 control (Program Counter next instruction value/ Memory data out/ ALU out) */
    `packed_arr(`rvtype, 2, MBC); /**< Memory byte count control */
    /**
    * 4 - bit controls
    */
    `alupkg::OperationType ALU0; /**< Main ALU operation control */
    /**
    * 5 - bit controls
    */
    `packed_arr(`rvtype, 5, RS1); /**< Resource Register 1 control signal */
    `packed_arr(`rvtype, 5, RS2); /**< Resource Register 2 control signal */
    `packed_arr(`rvtype, 5, RD); /**< Destination Register control signal */
    /**
    * 32 - bit controls
    */
    `rvector IMM0; /**< Immediate Value 0 */
    `rvector IMM1; /**< Immediate Value 1 */

    modport DUT (
        input INSTR,
        output CUJMPCTRL,
        output CUBCTRL,
        output MUX1,
        output MUX2,
        output MUX4,
        output REGW,
        output MEMW,
        output MEMR,
        output MSE,
        output MUX3,
        output MBC,
        output ALU0,
        output RS1,
        output RS2,
        output RD,
        output IMM0,
        output IMM1
    );
endinterface
