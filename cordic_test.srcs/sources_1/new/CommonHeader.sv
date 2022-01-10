//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 14.10.2021 22:51:51
// Design Name: NA
// Module Name: NA
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description:
// 
// This is the common header file, where all globally needed macros are defined.
//
// Dependencies: 
// 
// None (Global-inherited)
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
* Package alias macros.
* Used instead of the whole package name (wherever it is possible).
*/
`define archpkg Architecture_AClass
`define alupkg ALU_Class
`define sepkg SignExtender_Class
`define cupkg ControlUnit_Class
`define mempkg Memory_Class
`define fieldpkg Field_Classes
`define inspkg Instruction_Classes
`define progcntpkg ProgramCounter_class
`define regfilepkg RegistryFile_Class
`define regpkg Register_Class
`define muxpkg Multiplexer_Class

/**
* Global constants.
* They define constant values used throughout the whole project.
* They allow easier architecture adjustment if needed.
*/
`define INSTRUCTION_GLOBAL_BITWIDTH 32
`define REGISTER_GLOBAL_BITWIDTH 32 /**< Must be a multiple of BYTE_SIZE! */
`define BYTE_SIZE 8
`define NULL_REG_VAL `REGISTER_GLOBAL_BITWIDTH'h0

/**
* Clocking methodology macros.
* They define the active and trailing edge of clock signal.
*/
`define CLOCK_ACTIVE_EDGE posedge
`define CLOCK_TRAILING_EDGE negedge

/**
* Global type aliases macros.
* Used throughout the project, aliases to all types in this file.
*/
`define uint int unsigned
`define sint int signed

/**
* Global utility and readability macros.
* They allow for self-documenting, more readable code.
*/
`define static_cast_to_uint(val) unsigned'(val)
`define dynamic_cast_to_uint(val) $unsigned(val)
`define static_cast_to_sint(val) signed'(val)
`define dynamic_cast_to_sint(val) $signed(val)
`define static_cast_to_regvector(val) `rvector'(val)
`define static_cast_to_insvector(val) `ivector'(val)
`define unpacked_arr(_type, _size, _identifier) _type _identifier [(_size) - 1 : 0]
`define unpacked_dynamic_arr(_type, _identifier) _type _identifier []
`define packed_arr(_type, _size, _identifier) _type [(_size) - 1 : 0] _identifier
`define packed_dynamic_arr(_type, _identifier) _type [] _identifier
`define _private local /**< Can be altered so that all private fields will become public - for debug and readability purposes. */
`define _protected protected /**< Can be altered so that all protected fields will become public - for debug and readability purposes. */
`define _public /**< Mainly to express intent - for readability purposes. */

/**
* Compilation-time macros.
* They only affect the compilation phase.
*/
`define throw_compilation_error(msg) SomeObviouslyWrongSyntax /**< Since there is no compilation-time assertions in SV, this is a makeshift way to imitate them. */



/**
* ********************************************************* PACKAGE MACROS SECTION *********************************************************
* Below macros are divided by packages that they relate to / in which they are needed (but they are also required globally)
*/

/**
* Architecture_AClass macros.
* BEGIN
*/
`define rvtype `archpkg::riscvtype /**< Common type for processor internals. */
`define class_handle_dynamic_array `archpkg::ClassHandleDA
`define rvector_dynamic_array `archpkg::RegVectorDA
`define ivector_dynamic_array `archpkg::InsVectorDA
`define ivector `archpkg::insvector
`define rvector `archpkg::regvector
`define rvbyte `archpkg::riscvbyte
`define uintlist `archpkg::uint_list
`define dict_uintKey_uintlistVal `archpkg::dictionary_uintKey_uintlistVal
`define DLT_LOG(logging_entity, info, format, params) `archpkg::DiagnosticLogTrace(`__FILE__, `__LINE__, logging_entity, info, format, params)
`define INIT_TASK `archpkg::Init()

/**< **** END **** >**/

/**
* ALU_Class macros.
* BEGIN
*/
`define aluvector `alupkg::riscv_aluvector
`define alu_operation_vector `alupkg::riscv_alu_operation_vector
`define alu_operation_type `alupkg::OperationType
`define ALUVECTOR_BITWIDTH `REGISTER_GLOBAL_BITWIDTH

/**< **** END **** >**/

/**
* Field_Classes macros.
* BEGIN
*/
`define RD_field_BeginIdx 7
`define RD_field_BitWidth 5
`define OPCODE_field_BeginIdx 0
`define OPCODE_field_BitWidth 7
`define FUNCT3_field_BeginIdx 12
`define FUNCT3_field_BitWidth 3
`define FUNCT7_field_BeginIdx 25
`define FUNCT7_field_BitWidth 7
`define RS1_field_BeginIdx 15
`define RS1_field_BitWidth 5
`define RS2_field_BeginIdx 20
`define RS2_field_BitWidth 5

/**< **** END **** >**/

/**
* Instruction_Classes macros.
* BEGIN
*/

`define insformat `inspkg::InstructionFormat

//// Macro definitions - number of fields ////
`define RTypeInstruction_NumOfFields 6
`define ITypeInstruction_NumOfFields 5
`define STypeInstruction_NumOfFields 6
`define BTypeInstruction_NumOfFields 8
`define UTypeInstruction_NumOfFields 3
`define JTypeInstruction_NumOfFields 6

// ITypeInstruction macros //
`define ITypeInstruction_IMM1_field_BeginIdx 20
`define ITypeInstruction_IMM1_field_BitWidth 12

// STypeInstruction macros //
`define STypeInstruction_IMM1_field_BeginIdx 7
`define STypeInstruction_IMM1_field_BitWidth 5
`define STypeInstruction_IMM2_field_BeginIdx 25
`define STypeInstruction_IMM2_field_BitWidth 7

// BTypeInstruction macros //
`define BTypeInstruction_IMM1_field_BeginIdx 7
`define BTypeInstruction_IMM1_field_BitWidth 1
`define BTypeInstruction_IMM2_field_BeginIdx 8
`define BTypeInstruction_IMM2_field_BitWidth 4
`define BTypeInstruction_IMM3_field_BeginIdx 25
`define BTypeInstruction_IMM3_field_BitWidth 6
`define BTypeInstruction_IMM4_field_BeginIdx 31
`define BTypeInstruction_IMM4_field_BitWidth 1

// UTypeInstruction macros //
`define UTypeInstruction_IMM1_field_BeginIdx 12
`define UTypeInstruction_IMM1_field_BitWidth 20

// JTypeInstruction macros //
`define JTypeInstruction_IMM1_field_BeginIdx 12
`define JTypeInstruction_IMM1_field_BitWidth 8
`define JTypeInstruction_IMM2_field_BeginIdx 20
`define JTypeInstruction_IMM2_field_BitWidth 1
`define JTypeInstruction_IMM3_field_BeginIdx 21
`define JTypeInstruction_IMM3_field_BitWidth 10
`define JTypeInstruction_IMM4_field_BeginIdx 31
`define JTypeInstruction_IMM4_field_BitWidth 1

/**< **** END **** >**/

/**
* Memory_Class macros.
* BEGIN
*/

`define MEMORY_SIZE_IN_CELLS 2048 /**< When MemoryCell is 32 bits wide, this translates to 8kB of memory. */
`define memorycell `mempkg::MemoryCell
`define MEMORY_INITIAL_VALUE `REGISTER_GLOBAL_BITWIDTH'h0
`define MEMORY_CELL_SIZE_IN_BYTES (`REGISTER_GLOBAL_BITWIDTH/`BYTE_SIZE)

/**< **** END **** >**/

/**
* ********************************************************* PACKAGE MACROS SECTION END *****************************************************
* Below macros might be dependent on package macros.
*/


/**
* Testbenches macros.
* They define number of transactions and other test-related variables.
*/
`define MEMORY_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS 50
`define MEMORY_TESTBENCH_CONSTRAINT_ADDRESS_SPAN 10