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


package ControlUnit_Class;
    class ControlUnit extends Architecture_AClass::Architecture;
    `rvector(logic) [] Steering;
    
    function new(input `uint steering_out_num);
        this.Steering = new [steering_out_num];
    endfunction
    
    endclass
endpackage
