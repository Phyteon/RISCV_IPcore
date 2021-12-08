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

`define READ_WRITE_CTRL_NUM_OF_INPUTS 2
`define MemoryIdleState(mode) // Macro purely for documentation & code readability - may be later used for debugging

//// Compilation switches - if MEMORY_MODULE_DESIGN is defined, high level OOP implementation will be used
`define MEMORY_MODULE_DESIGN
// `define MEMORY_MODULE_IMPLEMENTATION

module Memory_Module(
                    input `rvtype clk,
                    input `rvtype memwrite, // HIGH is write, LOW is inactive
                    input `rvtype memread, // HIGH is read, LOW is inactive
                    input `rvector memaddr,
                    input `rvector inbus,
                    output `rvector outbus
                    );
    `ifdef MEMORY_MODULE_DESIGN
        // Creating class for handling memory reads and writes
        `mempkg::Memory main_memory;
        // Array for switching between memory access modes
        `packed_arr(`rvtype, `READ_WRITE_CTRL_NUM_OF_INPUTS, read_write_control);
        
        always @ (`CLOCK_ACTIVE_EDGE clk) begin
            read_write_control[0] = memwrite;
            read_write_control[1] = memread;
            unique case(read_write_control)
                0: `MemoryIdleState("Default mode");
                1: main_memory.Write(memaddr, inbus, `MEMORY_CELL_SIZE_IN_BYTES);
                2: outbus = main_memory.Read(memaddr, `MEMORY_CELL_SIZE_IN_BYTES);
                3: `MemoryIdleState("Forbidden state");
            endcase
        end
    
    `elsif MEMORY_MODULE_IMPLEMENTATION
    
    `else
        `throw_compilation_error("No configuration defined for the memory module!"); 
    `endif
endmodule
