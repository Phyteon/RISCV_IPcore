`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 14.10.2021 22:51:51
// Design Name: NA
// Module Name: Architecture_AClass
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description:
// 
// This package provides typedefs utilised throughout testbench classes/packages/
// modules. There is also a virtual (abstract) class meant to be the parent of
// all other classes. As this is the highest class in hierarchy, this file also
// contains, among others, two very important macros: INSTRUCTION_GLOBAL_BITWIDTH
// and REGISTER_GLOBAL_BITWIDTH which should not be tinkered with without reason.
//
// Dependencies: 
// 
// None (Global-inherited)
//
// Revision:
// Revision 0.01 - File Created
// Revision 0.5 (26.10.2021) - Major overhaul (check VCS)
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////1

// Package alias macro
`define archpkg Architecture_AClass

// Constant-value representing macros meant for global usage
`define INSTRUCTION_GLOBAL_BITWIDTH 32
`define REGISTER_GLOBAL_BITWIDTH 32

// Global aliases macros
`define ivector `archpkg::insvector
`define rvector `archpkg::regvector
`define uint int unsigned
`define sint int signed
`define rvtype `archpkg::riscvtype // Common type for processor internals

// Global utility macros or function-like macros
`define static_cast_to_uint(val) unsigned'(val)
`define static_cast_to_sint(val) signed'(val)
`define static_cast_to_regvector(val) `rvector'(val)
`define static_cast_to_insvector(val) `ivector'(val)

package Architecture_AClass;

    typedef logic riscvtype;
    typedef `rvtype [`REGISTER_GLOBAL_BITWIDTH - 1 : 0] regvector;
    typedef `rvtype [`INSTRUCTION_GLOBAL_BITWIDTH - 1 : 0] insvector;

    virtual class Architecture;
    endclass
    
endpackage
