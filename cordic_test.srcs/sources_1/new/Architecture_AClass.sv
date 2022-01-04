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
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

/**
* Init task macros
* They contain parameters for the task and manage the execution
* flow.
*/
`define TIME_LOGGING_UNITS_NS -9 // -9 for nanoseconds
`define TIME_LOGGING_PRECISION_DIGITS 2
`define TIME_LOGGING_SUFFIX_STRING " ns"
`define TIME_LOGGING_MIN_FIELD_WIDTH 6

/**
* Diagnostic Log Trace macros.
* They manage the setup of the task that performs logging.
*/
`define DIAGNOSTIC_LOG_TRACE_EXTENDED 0 /**< When set to 1, DLT will also log line number and file name from where it is called. */

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
    * Type defining a packed array of bits - for representing registers.
    */
    typedef `packed_arr(`rvtype, `REGISTER_GLOBAL_BITWIDTH, regvector);
    
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
    * from where the message is logged BUT the task must be invoked via DLT_LOG macro or its alias.
    * @param file from which the logging task is invoked
    * @param line in which the logging task is invoked
    * @param logging_entity will indicate what entity called the logging function, i.e. "Memory Driver"
    * @param info any additional information to be displayed after logging entity
    * @param format string containing description and formatting of data to be logged.
    *        If no values are to be logged must be an empty string. If the string is equal
    *        to "default", then the task will display provided values in the hexadecimal
    *        format separated by semicolons.
    * @param params that must be representable in integer format, to be parsed by provided
    *        format. If no values are to be displayed, must be an empty queue.
    */
    task DiagnosticLogTrace(input string file, input int line, input string logging_entity, input string info, input string format [], input int params []);
        automatic string parsed = "T=%t "; /**< Timestamp. */
        automatic string temporary = ""; /**< For parsing arguments. */
        if(`DIAGNOSTIC_LOG_TRACE_EXTENDED)
            parsed = {parsed, "file: %s, line: %0d"};
        parsed = {parsed, " [%s] %s "}; /**< Logging entity and info string. */
        if(format.size() != 0) begin
            if(format[0] == "default") begin
                foreach(params[iter]) begin
                    $sformat(temporary, "d%0d=0x%0h; ", iter, params[iter]);
                    parsed = {parsed, temporary};
                    temporary = "";
                end // foreach
            end
            else begin
                foreach(format[iter]) begin
                    $sformat(temporary, format[iter], params[iter]);
                    parsed = {parsed, temporary};
                    temporary = "";
                end // foreach
            end
        end
        
        if(`DIAGNOSTIC_LOG_TRACE_EXTENDED)
            $sformat(parsed, parsed, $time, file, line, logging_entity, info);
        else
            $sformat(parsed, parsed, $time, logging_entity, info); /**< The rest of data, if it exists, is already parsed */
        $display(parsed);

        
    endtask

    /**
    * Init task. All the setup should be done here. That mostly consists of one-time call tasks/functions.
    */
    task Init();
        $timeformat(`TIME_LOGGING_UNITS_NS, `TIME_LOGGING_PRECISION_DIGITS, `TIME_LOGGING_SUFFIX_STRING, `TIME_LOGGING_MIN_FIELD_WIDTH);
        $monitoroff;
    endtask
    
endpackage
