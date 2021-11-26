`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 20.11.2021 17:33:38
// Design Name: NA
// Module Name: Memory_Class
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
// 
// This package contains typedefs and class definitions for emulating and handling
// memory.
//
// Dependencies: 
//
// Architecture_AClass package
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// Misaligned address access supported, but highly discouraged
//////////////////////////////////////////////////////////////////////////////////

import Architecture_AClass::*;

// Global package alias
`define mempkg Memory_Class

// Memory sizes defines
`define DATA_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory
`define PROGRAM_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory

`define memorycell `mempkg::MemoryCell
`define MEMORY_INITIAL_VALUE 'h0000_0000
`define MEMORY_CELL_SIZE_IN_BYTES (($bits(`memorycell))/`BYTE_SIZE)
`define BYTE_MASK 'h0000_00FF
`define WORD_MASK 'h0000_FFFF

//// Compilation switch - misaligned memory access support
`define ALIGNED_MEM_ACCESS // If ALIGNED_MEM_ACCESS is defined, only aligned access to memory is supported

package Memory_Class;

    /////////////////////////////////
    // Typedef:
    //      MemoryCell
    // Info:
    //      This type represents memory cell size used in the project. It is created
    //      so that if ever there was a need to change memory cell size, it would only
    //      require changing this define. IMPORTANT INFORMATION!: If this define would
    //      be ever changed author assumes that the type would still support byte-addressing.
    /////////////////////////////////
    typedef `rvector MemoryCell;
    
    /////////////////////////////////
    // Typedef:
    //      MemoryType
    // Info:
    //      This type represents memory. Fixed in size, dependent on MemoryCell type.
    //      To be used when constructing "soft" Harvard architecture.
    /////////////////////////////////
    typedef `packed_arr(`memorycell, (`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS), MemoryType);
    
    class Memory extends Architecture_AClass::Architecture;
        `_protected MemoryType main_memory;
        
        `_public function new();
            // Does nothing, as in real processors memory is not cleared on startup
        endfunction
        
        `_public function `memorycell Read(input `uint address, input `uint bytes);
            `uint memcell_remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            `memorycell intermediate_val = `MEMORY_INITIAL_VALUE;
            unique case(bytes)
                1: intermediate_val[0] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][memcell_remainder];
                2: 
                    if(memcell_remainder == 0) 
                        intermediate_val[0:1] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][0:1];
                    else if(memcell_remainder == 2)
                        intermediate_val[0:1] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][2:3];
                    else
                        $error("Misalingned address!");
                4:
                    if(memcell_remainder != 0) $error("Misaligned address!");
                    else intermediate_val = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES];
                
                default:
                    $error("Unimplemented address range used!");
            endcase
            // Sign extention / zero-padding will be performed by other function
            return intermediate_val;
        endfunction
        
        `_public function Write(input `uint address, input `memorycell data);
            `uint remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            unique case(remainder)
                0: this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES] = data;
                
            endcase
        endfunction
    endclass
endpackage
