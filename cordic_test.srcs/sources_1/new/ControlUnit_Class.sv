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

`define CONTROL_UNIT_OUTPUT_TYPE int // only for development purposes, will be changed later
`define CONTROL_UNIT_INSTRUCTION_INFO_MEM_SIZE_BYTES 1000 /**< Size of memory in bytes used to store info about instructions - 
                                                            USED ONLY FOR HIGH ABSTRACTION LEVEL DEVELOPMENT IMPLEMENTATION! */
`define CONTROL_UNIT_INSTRUCTION_INFO_FILE "instructionconfig.dat"


package ControlUnit_Class;
    class ControlUnit extends Architecture_AClass::Architecture;
    `_private `unpacked_arr(`rvbyte, `CONTROL_UNIT_INSTRUCTION_INFO_MEM_SIZE_BYTES, instruction_info);
    `_private `uint type_to_address[string];

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
