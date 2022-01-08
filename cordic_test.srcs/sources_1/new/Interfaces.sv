
`include "CommonHeader.sv"

import ALU_Class::*;
import ControlUnit_Class::*;

interface ALUInterface(input `rvtype clk);
    `rvector left_operand;
    `rvector right_operand;
    `aluvector outcome;
    `rvtype reset;
    `alu_operation_type operation;
    `rvtype alubctrl;
    modport DUT(input clk, input reset, input leftOperand, input rightOperand, input operation, output alubctrl, output outcome);
    modport Testbench(input clk, output reset, output leftOperand, output rightOperand, output operation, input alubctrl, input outcome);
endinterface //ALUInterface

interface ControlUnitInterface(input `rvtype clk);
    /**
    * Input signals
    */
    `ivector INSTR; /**< Instruction to decode */
    `rvtype RESET;
    /**
    * 1 - bit controls
    */
    `rvtype CUJMPCTRL; /**< Control Unit Jump Control signal */
    `rvtype CUBCTRL; /**< Control Unit Branch Control signal */
    `rvtype MUX1; /**< Multiplexer 1 control (relative branch/ jump) */
    `rvtype MUX2; /**< Multiplexer 2 control (second operand from registry file/ immediate value) */
    `rvtype MUX4; /**< Multiplexer 4 control (for supplying current PC value to ALU) */
    `rvtype REGW; /**< Registry File Write control signal */
    `rvtype MEMW; /**< Memory Write control signal */
    `rvtype MEMR; /**< Memory Read control signal */
    `rvtype MSE; /**< Memory Sign Extention control signal */
    /**
    * 2 - bit controls
    */
    `packed_arr(`rvtype, 2, MUX3); /**< Multiplexer 3 control (Program Counter next instruction value/ Memory data out/ ALU out) */
    `packed_arr(`rvtype, 2, MBC); /**< Memory byte count control */
    /**
    * 4 - bit controls
    */
    `alupkg::OperationType ALU0; /**< Main ALU operation control */
    /**
    * 5 - bit controls
    */
    `packed_arr(`rvtype, 5, RS1); /**< Resource Register 1 control signal */
    `packed_arr(`rvtype, 5, RS2); /**< Resource Register 2 control signal */
    `packed_arr(`rvtype, 5, RD); /**< Destination Register control signal */
    /**
    * 32 - bit controls
    */
    `rvector IMM0; /**< Immediate Value 0 */
    `rvector IMM1; /**< Immediate Value 1 */

    modport DUT (
        input RESET,
        input INSTR,
        output CUJMPCTRL,
        output CUBCTRL,
        output MUX1,
        output MUX2,
        output MUX4,
        output REGW,
        output MEMW,
        output MEMR,
        output MSE,
        output MUX3,
        output MBC,
        output ALU0,
        output RS1,
        output RS2,
        output RD,
        output IMM0,
        output IMM1
    );
endinterface //ControlUnitInterface

interface MemoryInterface(input `rvtype clk);
    /**
    * 1 - bit controls
    */
    `rvtype MEMW; /**< Memory write enable */
    `rvtype MEMR; /**< Memory read enable */
    `rvtype MSE; /**< Memory sign extension unit enable */
    `rvtype RESET;
    /**
    * 2 - bit controls
    */
    `packed_arr(`rvtype, 2, MBC); /**< Memory byte count */
    /**
    * 32 - bit controls
    */
    `rvector ADDRIN; /**< Input address */
    `rvector DATAIN; /**< Input data */
    `rvector MEMOUT; /**< Data out */
    
    modport Testbench (
        output MEMW,
        output MEMR,
        output MSE,
        output RESET,
        output MBC,
        output ADDRIN,
        output DATAIN,
        input MEMOUT
    );
    modport DUT (
        input MEMW,
        input MEMR,
        input MSE,
        input RESET,
        input MBC,
        input ADDRIN,
        input DATAIN,
        output MEMOUT
    );
endinterface //MemoryInterface