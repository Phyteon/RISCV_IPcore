`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2021 00:37:44
// Design Name: 
// Module Name: Multiplexer_Class
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

`define MUX_INITIAL_INPUT_STATE h0000_0000
`define MUX_INITIAL_CHOSEN_STATE 0

package Multiplexer_Class;

class Multiplexer extends Architecture_AClass::Architecture;
    local `rvector(`rvtype) [] inputs;
    local `uint chosen_input;
    
    function new (input `uint _num_of_inputs);
        this.inputs = new [_num_of_inputs];
        this.chosen_input = `MUX_INITIAL_CHOSEN_STATE;
        foreach (this.inputs[n])
            inputs[n] = `MUX_INITIAL_INPUT_STATE;
    endfunction
    
    function UpdateInputsState(input `rvector(`rvtype) [] _inputs);
        foreach (_inputs[n])
            this.inputs[n] = _inputs[n]; // TODO: dispute about assigning method
    endfunction
    
    function UpdateOneInputState(input `rvector(`rvtype) _input, input `uint _num_of_in);
        this.inputs[_num_of_in] = _input;
    endfunction
    
    function ChooseInput(input `uint num_of_in);
        this.chosen_input = num_of_in;
    endfunction
    
    function `rvector(`rvtype) GetOutput();
        return this.inputs[chosen_input];
    endfunction
    
endclass

endpackage
