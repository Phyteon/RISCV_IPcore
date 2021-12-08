`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.12.2021 20:10:57
// Design Name: 
// Module Name: Memory_Module
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

import Memory_Class::*;

//// Compilation switches - if MEMORY_MODULE_DESIGN is defined, high level OOP implementation will be used
`define MEMORY_MODULE_DESIGN
// `define MEMORY_MODULE_IMPLEMENTATION

module Memory_Module(
                    input `rvtype clk,
                    input `rvtype memwrite,
                    input `rvector inbus,
                    output `rvector outbus
                    );
    `ifdef MEMORY_MODULE_DESIGN
        `mempkg::Memory main_memory;
    
    `elsif MEMORY_MODULE_IMPLEMENTATION
    
    `else
        `throw_compilation_error("No configuration defined for the memory module!"); 
    `endif
endmodule
