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
//////////////////////////////////////////////////////////////////////////////////

import Architecture_AClass::*;

// Global package alias
`define mempkg Memory_Class

// Memory sizes defines
`define DATA_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory
`define PROGRAM_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory

`define memorycell `mempkg::MemoryCell

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
    endclass
endpackage
