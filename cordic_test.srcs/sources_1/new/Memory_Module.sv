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

`include "CommonHeader.sv"

`define READ_WRITE_CTRL_NUM_OF_INPUTS 2
`define MemoryIdleState(mode) // Macro purely for documentation & code readability - may be later used for debugging
`define RESET_REG_VAL `REGISTER_GLOBAL_BITWIDTH'h0

//// Compilation switches - if MEMORY_MODULE_DESIGN is defined, high level OOP implementation will be used
`define MEMORY_MODULE_DESIGN
// `define MEMORY_MODULE_IMPLEMENTATION

module Memory_Module #(string memfilepath = "")(
    MemoryInterface.DUT memif
);
    import Memory_Class::*;
    `ifdef MEMORY_MODULE_DESIGN
        // Creating class for handling memory reads and writes
        `mempkg::Memory main_memory;
        // Array for switching between memory access modes
        `packed_arr(`rvtype, `READ_WRITE_CTRL_NUM_OF_INPUTS, read_write_control);
        initial begin
            main_memory = new;
            main_memory.LoadData(memfilepath);
        end
        
        always_comb begin
            if (memif.RESET)
                memif.MEMOUT = `RESET_REG_VAL;
            else begin
                read_write_control[0] = memif.MEMW;
                read_write_control[1] = memif.MEMR;
                unique case(read_write_control)
                    0: `MemoryIdleState("Default mode");
                    1: main_memory.Write(memif.ADDRIN, memif.DATAIN, memif.MBC);
                    2: memif.MEMOUT = main_memory.Read(memif.ADDRIN, memif.MBC, memif.MSE);
                    3: `MemoryIdleState("Forbidden state");
                endcase
            end // else
        end
        
    
    `elsif MEMORY_MODULE_IMPLEMENTATION
    
    `else
        `throw_compilation_error("No configuration defined for the memory module!"); 
    `endif
endmodule
