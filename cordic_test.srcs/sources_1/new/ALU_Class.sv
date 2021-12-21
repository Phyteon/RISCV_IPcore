`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2021 22:29:46
// Design Name: 
// Module Name: ALU_Class
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

import Architecture_AClass::*;

/**
* Global package alias
*/
`define alupkg ALU_Class

`define OPERATION_ENUM_VEC_BITWIDTH 4
`define ALU_INTERNALS_INITIAL_STATE `NULL_REG_VAL
`define ALUVECTOR_BITWIDTH (`REGISTER_GLOBAL_BITWIDTH + 1)

/**
* Testbench macros.
*/
`define ALU_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS 50

/**
* Global type aliases macros.
* Used throughout the project, aliases to all types in this file.
*/
`define aluvector `alupkg::riscv_aluvector
`define alu_operation_vector `alupkg::riscv_alu_operation_vector
`define alu_operation_type `alupkg::OperationType

/**
* Diagnostic log trace adapter macros and ERROR macros.
* They are aliases to the main DLT_LOG macro. ERROR macros
* provide self-documented error record.
*/
`define DLT_ALU_TITEM_VARDUMP(logging_entity) `DLT_LOG(logging_entity, \
                                                         " Transaction Item vars dump: ", \
                                                         {"left_operand=0x%0h ", \
                                                         "right_operand=0x%0h ", \
                                                         "operation=0x%0h ", \
                                                         "outcome=0x%0h"}, \
                                                         {this.left_operand, \
                                                         this.right_operand, \
                                                         this.operation, \
                                                         this.outcome}) /**< This macro is to be used ONLY from within the transaction item class. */

`define DLT_ALU_INFO(logging_entity, info) `DLT_LOG(logging_entity, info, {}, {}) /**< This macro can be used anywhere within this file. */

`define DLT_ALU_SCOREBOARD(message) `DLT_LOG("ALU Scoreboard", message, \
                                                         {"left_operand=0x%0h ", \
                                                         "right_operand=0x%0h ", \
                                                         "operation=0x%0h ", \
                                                         "outcome=0x%0h ", \
                                                         {this.monitor_item.left_operand, \
                                                         this.monitor_item.right_operand, \
                                                         this.monitor_item.operation, \
                                                         this.monitor_item.outcome}) /**< This macro to be used ONLY from within the scoreboard class. */

`define ERROR_OO_ALU_INTERNAL_TRANSACTION_FAILURE " |ERROR 0x00| "

package ALU_Class;
    /**
    * This type represents output of ALU unit.
    * It has one extra bit for indicating overflow.
    */
    typedef `packed_arr(`rvtype, `ALUVECTOR_BITWIDTH, riscv_aluvector);

    /**
    * This enum contains operations that ALU can perform.
    */
    typedef enum `rvtype [`OPERATION_ENUM_VEC_BITWIDTH - 1 : 0]
                        {  ALU_ADD = 1,
                           ALU_SUB = 2,
                           ALU_XOR = 3,
                           ALU_AND = 4,
                           ALU_NOR = 5,
                           ALU_OR = 6,
                           ALU_SLT = 7,
                           ALU_NAND = 8 } OperationType;


    class ALU extends `archpkg::Architecture;
        
        `_public function `aluvector PerformOperation(input OperationType operation, input `rvector left_operand, input `rvector right_operand);
            unique case(operation)
                ALU_ADD: return left_operand + right_operand; // Will this correctly overflow if needed?
                ALU_SUB: return left_operand - right_operand;
                ALU_XOR: return left_operand ^ right_operand;
                ALU_AND: return left_operand & right_operand;
                ALU_NOR: return ~(left_operand | right_operand); // TODO: Check if it doesn't cause overflow here!!!
                ALU_OR: return left_operand | right_operand;
                ALU_SLT: return left_operand < right_operand ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0);
                ALU_NAND: return ~(left_operand & right_operand);
                default: ; // Do nothing
            endcase
        
        endfunction
    endclass

    class AluTransactionItem;
        `_public rand `rvector left_operand;
        `_public rand `rvector right_operand;
        `_public `aluvector outcome;
        `_public rand `alu_operation_type operation;
        /** No constraints needed here. */
        `_public task log(input string tag="");
            `DLT_ALU_TITEM_VARDUMP(tag);
        endtask
    endclass

    class AluDriver;
        `_public virtual ALUInterface aluinf;
        `_public mailbox alu_driver_mailbox;
        `_public mailbox alu_scoreboard_mailbox;
        `_private AluTransactionItem item;

        `_public task run();
            `DLT_ALU_INFO("ALU Driver", " Starting ALU Driver... ");
            forever begin
                `DLT_ALU_INFO("ALU Driver", " Waiting for item... ");
                this.alu_driver_mailbox.get(this.item);
                this.item.log("ALU Driver");
                /**
                * Drive the interface
                */
                this.aluinf.left_operand <= this.item.left_operand;
                this.aluinf.right_operand <= this.item.right_operand;
                this.aluinf.operation <= this.item.operation;

                this.alu_scoreboard_mailbox.put(this.item); /**< Put transaction item in mailbox for scoreboard to read. */
            end // forever loop
        endtask
    endclass

    class AluMonitor;
        `_public virtual ALUInterface aluinf;
        `_public mailbox alu_scoreboard_mailbox;
        `_private AluTransactionItem item;

        `_public task run();
            `DLT_ALU_INFO("ALU Monitor", " Starting ALU Monitor... ");
            forever begin
                this.item = new;
                `DLT_ALU_INFO("ALU Monitor", " Waiting for valid transaction... ");
                @(`CLOCK_ACTIVE_EDGE this.aluinf.clk); /**< Valid transaction occurs at active clock edge. */
                /**
                * Take a snapshot of interface signals and send them to Scoreboard.
                */
                this.item.left_operand = this.aluinf.left_operand;
                this.item.right_operand = this.aluinf.right_operand;
                this.item.operation = this.aluinf.operation;
                this.item.outcome = this.aluinf.outcome;
                this.alu_scoreboard_mailbox.put(this.item);
                this.item.log("ALU Monitor");
            end
        endtask
    endclass

    class AluScoreborad;
        `_public mailbox alu_driver_mailbox;
        `_public mailbox alu_monitor_mailbox;
        `_private AluTransactionItem driver_item;
        `_private AluTransactionItem monitor_item;

        `_public task run();
            `DLT_ALU_INFO("ALU Scoreboard", " Starting ALU Scoreboard... ");
            forever begin
                this.alu_driver_mailbox.get(this.driver_item); /**< Wait for the driver to initialise transaction. */
                this.alu_monitor_mailbox.get(this.monitor_item); /**< Wait for monitor to register transaction. */

                /**
                * Check if transaction was correct
                */
                if(this.driver_item.left_operand != this.monitor_item.left_operand)
                    `DLT_ALU_SCOREBOARD(`ERROR_OO_ALU_INTERNAL_TRANSACTION_FAILURE);
                if(this.driver_item.right_operand != this.monitor_item.right_operand)
                    `DLT_ALU_SCOREBOARD(`ERROR_OO_ALU_INTERNAL_TRANSACTION_FAILURE);
                if(this.driver_item.operation != this.monitor_item.operation)
                    `DLT_ALU_SCOREBOARD(`ERROR_OO_ALU_INTERNAL_TRANSACTION_FAILURE);

                unique case (this.monitor_item.operation)
                    ALU_ADD:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand + this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |ADD FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |ADD PASS| ");
                    ALU_SUB:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand - this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |SUB FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SUB PASS| ");
                    ALU_XOR:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand ^ this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |XOR FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |XOR PASS| ");
                    ALU_AND:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand & this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |AND FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |AND PASS| ");
                    ALU_NOR:
                        if(this.monitor_item.outcome != ~(this.monitor_item.left_operand | this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |NOR FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |NOR PASS| ");
                    ALU_OR:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand | this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |OR FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |OR PASS| ");
                    ALU_SLT:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand < this.monitor_item.right_operand ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0)))
                            `DLT_ALU_SCOREBOARD(" |SLT FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SLT PASS| ");
                    ALU_NAND:
                        if(this.monitor_item.outcome != ~(this.monitor_item.left_operand & this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |NAND FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |NAND PASS| ");
                    default:
                        `DLT_ALU_SCOREBOARD(" |INVALID OPERATION| ");
                endcase
            end // forever loop
        endtask
    endclass

    class AluEnvironment;
        `_public virtual ALUInterface aluinf;
        `_private AluDriver driver;
        `_private AluMonitor monitor;
        `_private AluScoreborad scoreboard;
        `_private mailbox driver_mailbox; /**< Mailbox for communication generator->driver */
        `_private mailbox scoreboard_drv_mailbox; /**< Mailbox for communication driver->scoreboard */
        `_private mailbox scoreboard_mnt_mailbox; /**< Mailbox for communication monitor->scoreboard */

        function new();
            this.driver = new;
            this.monitor = new;
            this.scoreboard = new;
            this.driver_mailbox = new;
            this.scoreboard_drv_mailbox = new;
            this.scoreboard_mnt_mailbox = new;
            /**
            * Setting up the mailboxes.
            */
            this.driver.alu_driver_mailbox = this.driver_mailbox;
            this.driver.alu_driver_scoreboard = this.scoreboard_drv_mailbox;
            this.monitor.alu_scoreboard_mailbox = this.scoreboard_mnt_mailbox;
        endfunction

        `_private task stimulate();
            AluTransactionItem item = new;
            `DLT_ALU_INFO("ALU Verification Environment", " Starting stimulus... ");
            repeat(`ALU_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS) begin
                item.randomize();
                @(`CLOCK_ACTIVE_EDGE this.aluinf.clk); /**< Transactions only on active edge of clock signal. */
                this.driver_mailbox.put(item);
            end
        endtask

        `_public task run();
            this.driver.aluinf = this.aluinf;
            this.monitor.aluinf = this.aluinf;
            fork
                this.driver.run();
                this.monitor.run();
                this.scoreboard.run();
            join_none /**< Do not wait for any task to finish */

            this.stimulate(); /**< Apply stimulus */
        endtask
    endclass

    class AluTest;
        `_public virtual ALUInterface aluinf;
        `_private AluEnvironment environment;

        function new();
            this.environment = new;
        endfunction

        `_public task run();
            this.environment.aluinf = this.aluinf;
            fork
                this.environment.run();
            join_none
        endtask
    endclass
endpackage

interface ALUInterface(input `rvtype clk);
    `rvector left_operand;
    `rvector right_operand;
    `aluvector outcome;
    `rvtype reset;
    `alu_operation_type operation;
    modport DUT(input clk, input reset, input leftOperand, input rightOperand, input operation, output outcome);
    modport Testbench(input clk, output reset, output leftOperand, output rightOperand, output operation, input outcome);
endinterface //ALUInterface
