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
`define NULL_REG_VAL 'h0000_0000


// Global aliases macros
`define ivector `archpkg::insvector
`define rvector `archpkg::regvector
`define uint int unsigned
`define sint int signed
`define rvtype `archpkg::riscvtype // Common type for processor internals
`define _private local // Can be altered so that all private fields will become public
`define _protected protected // Can be altered so that all protected fields will become public
`define _public // Mainly to express intention


// Global utility macros or function-like macros
`define static_cast_to_uint(val) unsigned'(val)
`define dynamic_cast_to_uint(target, val) $cast(target, val)
`define static_cast_to_sint(val) signed'(val)
`define dynamic_cast_to_sint(target, val) $cast(target, val)
`define static_cast_to_regvector(val) `rvector'(val)
`define static_cast_to_insvector(val) `ivector'(val)
`define unpacked_arr(_type, _size, _identifier) _type _identifier [_size - 1 : 0]
`define unpacked_dynamic_arr(_type, _identifier) _type _identifier []
`define packed_arr(_type, _size, _identifier) _type [_size - 1 : 0] _identifier
`define packed_dynamic_arr(_type, _identifier) _type [] _identifier

package Architecture_AClass;

    typedef logic riscvtype;
    typedef `packed_arr(`rvtype, `REGISTER_GLOBAL_BITWIDTH, regvector);
    typedef `packed_arr(`rvtype, `INSTRUCTION_GLOBAL_BITWIDTH, insvector);

    virtual class Architecture;
    endclass
    
endpackage
