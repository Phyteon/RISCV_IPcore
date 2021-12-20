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

/**
* Package alias macro.
* Used instead of the whole package name (wherever it is possible).
*/
`define archpkg Architecture_AClass

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
`define ivector `archpkg::insvector
`define rvector `archpkg::regvector
`define rvbyte `archpkg::riscvbyte
`define uint int unsigned
`define sint int signed
`define rvtype `archpkg::riscvtype /**< Common type for processor internals. */
`define class_handle_dynamic_array `archpkg::ClassHandleDA
`define rvector_dynamic_array `archpkg::RegVectorDA
`define ivector_dynamic_array `archpkg::InsVectorDA

/**
* Utility and readability macros.
* They allow self-documenting, more readable code.
*/
`define static_cast_to_uint(val) unsigned'(val)
`define dynamic_cast_to_uint(target, val) $cast(target, val)
`define static_cast_to_sint(val) signed'(val)
`define dynamic_cast_to_sint(target, val) $cast(target, val)
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
* Diagnostic Log Trace macros.
* They either manage the setup of the task that performs logging,
* or they are some sort of alias to the task.
*/
`define DIAGNOSTIC_LOG_TRACE_EXTENDED 0 /**< When set to 1, DLT will also log line number and file name from where it is called. */
`define LOG_INFO(logging_entity, )
`define LOG_WARN
`define LOG_ERROR

/**
* Init task macros
* They contain parameters for the task and manage the execution
* flow.
*/
`define TIME_LOGGING_UNITS_NS -9 // -9 for nanoseconds
`define TIME_LOGGING_PRECISION_DIGITS 2
`define TIME_LOGGING_SUFFIX_STRING " ns"
`define TIME_LOGGING_MIN_FIELD_WIDTH 6

package Architecture_AClass;
    //// Global type definitions ////

    /**
    * Type used as a basic type for everything in project.
    */
    typedef logic riscvtype;
    
    /**
    * Type defining a byte using riscvtype as base.
    */
    typedef `packed_arr(`rvtype, `BYTE_SIZE, riscvbyte);
    
    /**
    * Type defining a packed array of bytes - mainly for register representation.
    */
    typedef `packed_arr(`rvbyte, (`REGISTER_GLOBAL_BITWIDTH/`BYTE_SIZE), regvector);
    
    /**
    * Type defining a packed array of riscvtype - mainly for representing instructions.
    */
    typedef `packed_arr(`rvtype, `INSTRUCTION_GLOBAL_BITWIDTH, insvector);
    
    /**
    * Type defining a dynamic array of regvector type variables. Created so that it
    * functions can use it as a return value.
    */
    typedef regvector RegVectorDA[];
    
    /**
    * Type defining a dynamic array of insvector type variables. Created so that it
    * functions can use it as a return value.
    */
    typedef insvector InsVectorDA[];

    /**
    * Abstract empty class, used only as a parent for other classes.
    */
    virtual class Architecture;
    endclass
    
    /**
    * Type defining a dynamic array of Architecture class handles. It allows
    * for storing handles for objects of all classes that inherit after Architecture class.
    */
    typedef Architecture ClassHandleDA[];
    
    /**
    * Task used for logging debug information. Always displays timestamp of the message.
    * If DIAGNOSTIC_LOG_TRACE_EXTENDED is set to 1, will also log the line number and file name
    * from where the message is logged.
    * @param logging_entity will indicate what entity called the logging function, i.e. "Memory Driver"
    * @param info any additional information to be displayed after logging entity
    * @param format string containing description and formatting of data to be logged.
    *        If no values are to be logged must be an empty string. If the string is equal
    *        to "default", then the task will display provided values in the hexadecimal
    *        format separated by semicolons.
    * @param params that must be representable in integer format, to be parsed by provided
    *        format. If no values are to be displayed, must be an empty queue.
    */
    task DiagnosticLogTrace(input string logging_entity, input string info, input string format, input int params [$]);
        string temporary = "T=%t "; /**< Timestamp. */
        if(`DIAGNOSTIC_LOG_TRACE_EXTENDED)
            temporary = {temporary, "file: %s, line: %d"};
        temporary = {temporary, " [%s] %s "}; /**< Logging entity and info string. */
        if((format == "default") && (params.size() != 0)) begin
            repeat(params.size())
                temporary = {temporary, "0x%h;"};
        end else if(params.size() != 0) begin
            temporary = {temporary, format};
        end
        
    endtask

    /**
    * Init task. All the setup should be done here. That mostly consists of one-time call tasks/functions.
    */
    task Init()
        $timeformat(`TIME_LOGGING_UNITS_NS, `TIME_LOGGING_PRECISION_DIGITS, `TIME_LOGGING_SUFFIX_STRING, `TIME_LOGGING_MIN_FIELD_WIDTH);
        $monitoroff();
    endtask
    
endpackage
