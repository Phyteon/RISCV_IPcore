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

`include "CommonHeader.sv"

`define OPERATION_ENUM_VEC_BITWIDTH 4
`define ALU_INTERNALS_INITIAL_STATE `NULL_REG_VAL

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
                                                         "outcome=0x%0h "}, \
                                                         {this.monitor_item.left_operand, \
                                                         this.monitor_item.right_operand, \
                                                         this.monitor_item.operation, \
                                                         this.monitor_item.outcome}) /**< This macro to be used ONLY from within the scoreboard class. */

`define ERROR_OO_ALU_INTERNAL_TRANSACTION_FAILURE " |ERROR 0x00| "

package ALU_Class;
    import Architecture_AClass::*;
    /**
    * This type represents output of ALU unit.
    * It has one extra bit for indicating overflow.
    */
    typedef `packed_arr(`rvtype, `ALUVECTOR_BITWIDTH, riscv_aluvector);

    /**
    * This enum contains operations that ALU can perform.
    */
    typedef enum `rvtype [`OPERATION_ENUM_VEC_BITWIDTH - 1 : 0]
                        {  ALU_ADD = 0,
                           ALU_SUB = 1,
                           ALU_XOR = 2,
                           ALU_AND = 3,
                           ALU_OR = 4,
                           ALU_SLT = 5,
                           ALU_SLTU = 6,
                           ALU_SLL = 7,
                           ALU_SRL = 8,
                           ALU_SRA = 9,
                           ALU_BEQ = 10,
                           ALU_BNE = 11,
                           ALU_BLT = 12,
                           ALU_BGE = 13,
                           ALU_BLTU = 14,
                           ALU_BGEU = 15} OperationType;


    class ALU extends `archpkg::Architecture;
        `_public `rvtype branchctrl;
        `_public function `aluvector PerformOperation(input OperationType operation, input `rvector left_operand, input `rvector right_operand);
            unique case(operation)
                ALU_ADD: return left_operand + right_operand;
                ALU_SUB: return left_operand - right_operand;
                ALU_XOR: return left_operand ^ right_operand;
                ALU_AND: return left_operand & right_operand;
                ALU_OR: return left_operand | right_operand;
                ALU_SLT: return `dynamic_cast_to_sint(left_operand) < `dynamic_cast_to_sint(right_operand) ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0);
                ALU_SLTU: return left_operand < right_operand ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0);
                ALU_SLL: return (left_operand << right_operand);
                ALU_SRL: return (left_operand >> right_operand);
                ALU_SRA: return (left_operand >>> right_operand);
                ALU_BEQ: begin
                    if (left_operand == right_operand) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                ALU_BNE: begin
                    if (left_operand != right_operand) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                ALU_BLT: begin
                    if (`dynamic_cast_to_sint(left_operand) < `dynamic_cast_to_sint(right_operand)) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                ALU_BGE: begin
                    if (`dynamic_cast_to_sint(left_operand) > `dynamic_cast_to_sint(right_operand)) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                ALU_BLTU: begin
                    if (left_operand < right_operand) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                ALU_BGEU: begin
                    if (left_operand > right_operand) this.branchctrl = 1;
                    else this.branchctrl = 0;
                    return 0;
                end
                default: ; // Do nothing
            endcase
        
        endfunction
    endclass

    class AluTransactionItem;
        `_public rand `rvector left_operand;
        `_public rand `rvector right_operand;
        `_public `aluvector outcome;
        `_public `rvtype alubctrl;
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
                this.item.alubctrl = this.aluinf.alubctrl;
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

                unique case (this.monitor_item.operation) /**< TODO: Add other cases */
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
                    ALU_OR:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand | this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |OR FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |OR PASS| ");
                    ALU_SLT:
                        if(this.monitor_item.outcome != (`static_cast_to_sint(this.monitor_item.left_operand) < `static_cast_to_sint(this.monitor_item.right_operand) ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0)))
                            `DLT_ALU_SCOREBOARD(" |SLT FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SLT PASS| ");
                    ALU_SLTU:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand < this.monitor_item.right_operand ? `static_cast_to_regvector(1) : `static_cast_to_regvector(0)))
                            `DLT_ALU_SCOREBOARD(" |SLTU FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SLTU PASS| ");
                    ALU_SLL:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand << this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |SLL FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SLL PASS| ");
                    ALU_SRL:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand >> this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |SRL FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SRL PASS| ");
                    ALU_SRA:
                        if(this.monitor_item.outcome != (this.monitor_item.left_operand >>> this.monitor_item.right_operand))
                            `DLT_ALU_SCOREBOARD(" |SRA FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |SRA PASS| ");
                    ALU_BEQ:
                        if(this.monitor_item.alubctrl != (this.monitor_item.left_operand == this.monitor_item.right_operand ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BEQ FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BEQ PASS| ");
                    ALU_BNE:
                        if(this.monitor_item.alubctrl != (this.monitor_item.left_operand != this.monitor_item.right_operand ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BNE FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BNE PASS| ");
                    ALU_BLT:
                        if(this.monitor_item.alubctrl != (`dynamic_cast_to_sint(this.monitor_item.left_operand) < `dynamic_cast_to_sint(this.monitor_item.right_operand) ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BLT FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BLT PASS| ");
                    ALU_BGE:
                        if(this.monitor_item.alubctrl != (`dynamic_cast_to_sint(this.monitor_item.left_operand) > `dynamic_cast_to_sint(this.monitor_item.right_operand) ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BGE FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BGE PASS| ");
                    ALU_BLTU:
                        if(this.monitor_item.alubctrl != (this.monitor_item.left_operand < this.monitor_item.right_operand ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BLTU FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BLTU PASS| ");
                    ALU_BGEU:
                        if(this.monitor_item.alubctrl != (this.monitor_item.left_operand > this.monitor_item.right_operand ? 1 : 0))
                            `DLT_ALU_SCOREBOARD(" |BGEU FAIL| ");
                        else `DLT_ALU_SCOREBOARD(" |BGEU PASS| ");
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
            this.driver.alu_scoreboard_mailbox = this.scoreboard_drv_mailbox;
            this.monitor.alu_scoreboard_mailbox = this.scoreboard_mnt_mailbox;
            this.scoreboard.alu_driver_mailbox = this.scoreboard_drv_mailbox;
            this.scoreboard.alu_monitor_mailbox = this.scoreboard_mnt_mailbox;
        endfunction

        `_private task stimulate();
            AluTransactionItem item = new;
            `DLT_ALU_INFO("ALU Verification Environment", " Starting stimulus... ");
            repeat(`ALU_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS) begin
                void'(item.randomize());
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

