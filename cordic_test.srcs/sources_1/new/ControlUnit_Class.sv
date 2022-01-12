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

`include "CommonHeader.sv"

`define CONTROL_UNIT_OUTPUT_TYPE void
`define CONTROL_UNIT_INSTRUCTION_INFO_MEM_SIZE_BYTES 1000 /**< Size of memory in bytes used to store info about instructions - 
                                                            USED ONLY FOR HIGH ABSTRACTION LEVEL DEVELOPMENT IMPLEMENTATION! */
`define CONTROL_UNIT_INSTRUCTION_INFO_FILE "instructionconfig.dat"


package ControlUnit_Class;
    import Architecture_AClass::*;
    import Instruction_Classes::*;
    import ALU_Class::*;
    import SignExtender_Class::*;

    class ControlUnit extends Architecture_AClass::Architecture;
    `_private `dict_uintKey_uintlistVal opcode_mapping[`uint];
    `_public virtual ControlUnitInterface cuinf;
    `_private `insformat indexer;

    `_public function new();
        /**
        * Mapping instruction formats to opcode and list of FUNCT3 field
        * values associated with a given format.
        * Format numbers (as keys of associative array within) are taken from
        * InstructionFormat enumerated type.
        */
        this.opcode_mapping[51] = '{0 : {0, 1, 2, 3, 4, 5, 6, 7}}; /**< Only R-type format */
        this.opcode_mapping[19] = '{0 : {1, 5}, 
                                    1 : {0, 2, 3, 4, 6, 7}}; /**< R-type and I-type format */
        this.opcode_mapping[35] = '{2 : {0, 1, 2}}; /**< Only S-type format */
        this.opcode_mapping[103] = '{1 : {0}}; /**< Only I-type format */
        this.opcode_mapping[3] = '{1 : {0, 1, 2, 4, 5}}; /**< Only I-type format */
        this.opcode_mapping[99] = '{3 : {0, 1, 4, 5, 6, 7}}; /**< Only B-type format */
        this.opcode_mapping[55] = '{4: {0}}; /**< Only U-type format */
        this.opcode_mapping[23] = '{4: {0}}; /**< Only U-type format */
        this.opcode_mapping[111] = '{5: {0}}; /**< Only J-type format */
    endfunction

    `_public function `CONTROL_UNIT_OUTPUT_TYPE ControlUnitMainFunction(input `ivector instruction_raw);
        `inspkg::Instruction known_type_instruction = this.DecodeType(instruction_raw);
        if (known_type_instruction != null) begin
            unique case (known_type_instruction.Format)
                Rtype: this.DecodeRtype(known_type_instruction);
                Itype: this.DecodeItype(known_type_instruction);
                Stype: this.DecodeStype(known_type_instruction);
                Btype: this.DecodeBtype(known_type_instruction);
                Utype: this.DecodeUtype(known_type_instruction);
                Jtype: this.DecodeJtype(known_type_instruction); 
                default: ; /**< Do nothing */
            endcase
        end else $error("Unknown instruction format!");
    endfunction

    `_private function `inspkg::Instruction DecodeType(input `ivector instruction_raw);
        `insformat format = format.first();
        `inspkg::Instruction ret_obj;
        `uint opcode = instruction_raw[`OPCODE_field_BitWidth - 1 + `OPCODE_field_BeginIdx : `OPCODE_field_BeginIdx];
        if(this.opcode_mapping.exists(opcode) != 1)
            $error("No such opcode is implemented!");
        else begin
            if(this.opcode_mapping[opcode].size() == 1) begin /**< If this opcode is present in only one format, immediately return associated object */
                while (this.opcode_mapping[opcode].exists(unsigned'(format)) != 1) begin
                    format = format.next(); /**< Find the format */
                end
                unique case (format)
                    Rtype: ret_obj = `inspkg::RTypeInstruction::new(instruction_raw);
                    Stype: ret_obj = `inspkg::STypeInstruction::new(instruction_raw);
                    Btype: ret_obj = `inspkg::BTypeInstruction::new(instruction_raw);
                    Itype: ret_obj = `inspkg::ITypeInstruction::new(instruction_raw);
                    Utype: ret_obj = `inspkg::UTypeInstruction::new(instruction_raw);
                    Jtype: ret_obj = `inspkg::JTypeInstruction::new(instruction_raw); 
                    default: ; /**< Do nothing */
                endcase
            end else begin /**< If opcode present in more than one format, check FUNCT3 field */
                `uint funct3 = instruction_raw[`FUNCT3_field_BitWidth - 1 + `FUNCT3_field_BeginIdx : `FUNCT3_field_BeginIdx];
                `uint query_hits[$]; /**< Create a queue for holding found FUNCT3 fields */
                `uint temp_array[];
                repeat(format.num()) begin /**< Check all formats */
                    if (this.opcode_mapping[opcode].exists(unsigned'(format))) begin /**< If entry for a given format exists, begin further checks */
                        temp_array = this.opcode_mapping[opcode][unsigned'(format)];
                        query_hits = temp_array.find(x) with (x == funct3); /**< Find FUNCT3 field in associated values */
                        if(query_hits.size() != 0) begin /**< If any value has been found, that means this is the encoding type */
                            unique case (format)
                                Rtype: ret_obj = `inspkg::RTypeInstruction::new(instruction_raw);
                                Itype: ret_obj = `inspkg::ITypeInstruction::new(instruction_raw);
                                Stype: ret_obj = `inspkg::STypeInstruction::new(instruction_raw);
                                Btype: ret_obj = `inspkg::BTypeInstruction::new(instruction_raw);
                                Utype: ret_obj = `inspkg::UTypeInstruction::new(instruction_raw);
                                Jtype: ret_obj = `inspkg::JTypeInstruction::new(instruction_raw); 
                                default: ; /**< Do nothing */
                            endcase
                        end
                    end
                    format = format.next(); /**< Increment the enumerated type */
                end 
            end
        end
        return ret_obj;
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeRtype(input `inspkg::Instruction rtypeins);
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

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeItype(input `inspkg::Instruction itypeins);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ZeroStuff(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(itypeins.Fields[4].ExtractFromInstr(itypeins.Contents), 12, 0);
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

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeStype(input `inspkg::Instruction stypeins);
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

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeBtype(input `inspkg::Instruction btypeins);
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

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeUtype(input `inspkg::Instruction utypeins);
        `uint steering = utypeins.Fields[0].ExtractFromInstr(utypeins.Contents);
        unique case (steering)
            55: begin /**< LUI */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(utypeins.Fields[2].ExtractFromInstr(utypeins.Contents), 20, 12);
                this.cuinf.RS1 <= 0; /**< To ensure that zeros are added to extended immediate value */
                this.cuinf.RD <= utypeins.Fields[1].ExtractFromInstr(utypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
            end 
            23: begin /**< AUIPC */
                this.cuinf.CUJMPCTRL <= 0;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 0;
                this.cuinf.MUX4 <= 1; /**< Selecting current PC counter value as a left operand */
                this.cuinf.IMM1 <= `sepkg::SignExtender::ExtendSign(utypeins.Fields[2].ExtractFromInstr(utypeins.Contents), 20, 12);
                this.cuinf.RD <= utypeins.Fields[1].ExtractFromInstr(utypeins.Contents);
                this.cuinf.REGW <= 1;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 1;
                this.cuinf.ALU0 <= ALU_ADD;
            end
            default: ; /**< Do nothing */
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeJtype(input `inspkg::Instruction jtypeins);
        `uint steering = jtypeins.Fields[0].ExtractFromInstr(jtypeins.Contents);
        unique case (steering)
            111: begin /**< JAL */
                this.cuinf.CUJMPCTRL <= 1;
                this.cuinf.CUBCTRL <= 0;
                this.cuinf.MUX1 <= 1;
                this.cuinf.MUX2 <= 0;
                this.cuinf.MUX3 <= 1;
                this.cuinf.MUX4 <= 1;
                this.cuinf.IMM0 <= 0;
                this.cuinf.IMM1 <= `sepkg::SignExtender::ConcatentateJTypeImmediate(jtypeins);
                this.cuinf.RD <= jtypeins.Fields[1].ExtractFromInstr(jtypeins.Contents);
                this.cuinf.REGW <= 0;
                this.cuinf.MEMW <= 0;
                this.cuinf.MEMR <= 0;
                this.cuinf.ALU0 <= ALU_ADD;
            end 
            default: ; /**< Do nothing */
        endcase
    endfunction
    
    endclass

endpackage

