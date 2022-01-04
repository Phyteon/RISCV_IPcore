`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 22.10.2021 00:37:44
// Design Name: NA
// Module Name: Multiplexer_Class
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
// 
// This file contains package defining Multiplexer class.
//
// Dependencies: 
//
// Architecture_AClass package
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

`define MUX_INITIAL_INPUT_STATE `NULL_REG_VAL
`define MUX_INITIAL_CHOSEN_STATE 0

package Multiplexer_Class;
    import Architecture_AClass::*;

    class Multiplexer extends `archpkg::Architecture;
        `_private `unpacked_dynamic_arr(`rvector, inputs);
        `_private `uint chosen_input;
        
        `_public function new (input `uint _num_of_inputs);
            this.inputs = new [_num_of_inputs];
            this.chosen_input = `MUX_INITIAL_CHOSEN_STATE;
            foreach (this.inputs[n])
                inputs[n] = `MUX_INITIAL_INPUT_STATE;
        endfunction
        
        `_public function UpdateInputsState(input `unpacked_dynamic_arr(`rvector, _inputs));
            foreach (_inputs[n])
                this.inputs[n] = _inputs[n]; // TODO: dispute about assigning method
        endfunction
        
        `_public function UpdateOneInputState(input `rvector _input, input `uint _num_of_in);
            this.inputs[_num_of_in] = _input;
        endfunction
        
        `_public function ChooseInput(input `uint num_of_in);
            this.chosen_input = num_of_in;
        endfunction
        
        `_public function `rvector GetOutput();
            return this.inputs[chosen_input];
        endfunction
        
    endclass

endpackage
