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
`define BYTE_SIZE 8
`define NULL_REG_VAL 'h0000_0000

// Clocking methodology
`define CLOCK_ACTIVE_EDGE posedge

// Global aliases macros
`define ivector `archpkg::insvector
`define rvector `archpkg::regvector
`define rvbyte `archpkg::riscvbyte
`define uint int unsigned
`define sint int signed
`define rvtype `archpkg::riscvtype // Common type for processor internals
`define class_handle_dynamic_array `archpkg::ClassHandleDA
`define rvector_dynamic_array `archpkg::RegVectorDA
`define ivector_dynamic_array `archpkg::InsVectorDA
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

// Compilation-time macros
`define throw_compilation_error(msg) SomeObviouslyWrongSyntax

package Architecture_AClass;
    //// Global type definitions ////
    
    /////////////////////////////////
    // Typedef:
    //      riscvtype
    // Info:
    //      This type represents base logic type used in all modules/packages etc.
    /////////////////////////////////
    typedef logic riscvtype;
    
    /////////////////////////////////
    // Typedef:
    //      riscvtype
    // Info:
    //      This type represents base logic type used in all modules/packages etc.
    /////////////////////////////////
    typedef `packed_arr(`rvtype, `BYTE_SIZE, riscvbyte);
    
    /////////////////////////////////
    // Typedef:
    //      regvector
    // Info:
    //      This type represents register value on the lowest level. It is a packed
    //      array of type riscvbyte and of fixed length defined by REGISTER_GLOBAL_BITWIDTH
    //      and BYTE_SIZE macros. Designed with ease of byte-addresation in mind.
    /////////////////////////////////
    typedef `packed_arr(`rvbyte, (`REGISTER_GLOBAL_BITWIDTH/`BYTE_SIZE), regvector);
    
    /////////////////////////////////
    // Typedef:
    //      insvector
    // Info:
    //      This type represents instruction value on the lowest level. It is a packed
    //      array of type riscvtype and of fixed length defined by INSTRUCTION_GLOBAL_BITWIDTH
    //      macro.
    /////////////////////////////////
    typedef `packed_arr(`rvtype, `INSTRUCTION_GLOBAL_BITWIDTH, insvector);
    
    /////////////////////////////////
    // Typedef:
    //      RegVectorDA
    // Info:
    //      This type represents dynamic unpacked array of regvector type. It may be used
    //      as a type to be returned from a function or for convenient data manipulation.
    /////////////////////////////////
    typedef regvector RegVectorDA[];
    
    /////////////////////////////////
    // Typedef:
    //      InsVectorDA
    // Info:
    //      This type represents dynamic unpacked array of insvector type. It may be used
    //      as a type to be returned from a function or for convenient data manipulation.
    /////////////////////////////////
    typedef insvector InsVectorDA[];

    virtual class Architecture;
    endclass
    
    /////////////////////////////////
    // Typedef:
    //      ClassHandleDA
    // Info:
    //      This type represents dynamic unpacked array of Architecture class handles. It may be used
    //      as a type to be returned from a function or for convenient data manipulation. As every class
    //      is derived from the Architecture class, this data type may be used to hold any class defined
    //      in the project.
    /////////////////////////////////
    typedef Architecture ClassHandleDA[];
    
endpackage
