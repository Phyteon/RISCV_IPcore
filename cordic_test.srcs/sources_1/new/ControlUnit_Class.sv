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
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_ADD;
            end
            32: begin /**< SUB */
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SUB;
            end
            1: begin /**< SLL */
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SLL;
            end
            2: begin /**< SLT */
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SLT;
            end
            3: begin /**< SLTU */
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SLTU;
            end
            4: begin /**< */
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_XOR;
            end
            5: begin
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SRL;
            end
            37: begin
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_SRA;
            end
            6: begin
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_OR;
            end
            7: begin
                cuinf.CUJMPCTRL <= 0;
                cuinf.CUBCTRL <= 0;
                cuinf.MUX2 <= 1;
                cuinf.MUX3 <= 0;
                cuinf.RS1 <= rtypeins.Fields[3].ExtractFromInstr(rtypeins.Contents);
                cuinf.RS2 <= rtypeins.Fields[4].ExtractFromInstr(rtypeins.Contents);
                cuinf.RD <= rtypeins.Fields[5].ExtractFromInstr(rtypeins.Contents);
                cuinf.REGW <= 1;
                cuinf.MEMW <= 0;
                cuinf.MEMR <= 0;
                cuinf.ALU0 <= ALU_AND;
            end
            default: 
        endcase
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeItype(input `inspkg::ITypeInstruction itypeins);
        
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeStype(input `inspkg::STypeInstruction stypeins);
        
    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeBtype(input `inspkg::BTypeInstruction btypeins);

    endfunction

    `_private function `CONTROL_UNIT_OUTPUT_TYPE DecodeUtype(input `inspkg::UTypeInstruction utypeins);
        
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
    `rvtype REGW; /**< Registry File Write control signal */
    `rvtype MEMW; /**< Memory Write control signal */
    `rvtype MEMR; /**< Memory Read control signal */
    `rvtype MSE; /**< Memory Sign Extention control signal */
    /**
    * 2 - bit controls
    */
    `packed_arr(`rvtpe, 2, MUX3); /**< Multiplexer 3 control (Program Counter next instruction value/ Memory data out/ ALU out) */
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
        output REGW,
        output MEMW,
        output MEMR,
        output MSE,
        output MUX3,
        output ALU0,
        output RS1,
        output RS2,
        output RD,
        output IMM0,
        output IMM1
    );
endinterface
