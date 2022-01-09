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
// Misaligned address access supported, but highly discouraged
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"


/**
* Diagnostic log trace adapter macros and ERROR macros.
* They are aliases to the main DLT_LOG macro. ERROR macros
* provide self-documented error record.
*/
`define DLT_MEMORY_TITEM_VARDUMP(logging_entity) `DLT_LOG(logging_entity, \
                                                         " Transaction Item vars dump: ", \
                                                         {"MEMW=0x%0h ", \
                                                         "MEMR=0x%0h ", \
                                                         "MSE=0x%0h ", \
                                                         "MBC=0x%0h ", \
                                                         "ADDRIN=0x%0h", \
                                                         "DATAIN=0x%0h", \
                                                         "MEMOUT=0x%0h"}, \
                                                         {this.MEMW, \
                                                         this.MEMR, \
                                                         this.MSE, \
                                                         this.MBC, \
                                                         this.ADDRIN,\
                                                         this.DATAIN, \
                                                         this.MEMOUT}) /**< This macro is to be used ONLY from within the transaction item class. */

`define DLT_MEMORY_INFO(logging_entity, info) `DLT_LOG(logging_entity, info, {}, {}) /**< This macro can be used anywhere within this file. */

`define DLT_MEMORY_SCOREBOARD(message) `DLT_LOG("Memory Scoreboard", message, \
                                                         {"MEMW=0x%0h ", \
                                                         "MEMR=0x%0h ", \
                                                         "MSE=0x%0h ", \
                                                         "MBC=0x%0h ", \
                                                         "ADDRIN=0x%0h", \
                                                         "DATAIN=0x%0h", \
                                                         "MEMOUT=0x%0h"}, \
                                                         {this.MEMW, \
                                                         this.MEMR, \
                                                         this.MSE, \
                                                         this.MBC, \
                                                         this.ADDRIN,\
                                                         this.DATAIN, \
                                                         this.MEMOUT}) /**< This macro to be used ONLY from within the scoreboard class. */

`define ERROR_00_MEMORY_READ_VALUE_DIFFERENT_FROM_STORED " |ERROR 0x00| "

/**
* Compilation switch - misaligned memory access support.
* If ALIGNED_MEM_ACCESS is defined, only aligned access to memory is supported.
*/
`define ALIGNED_MEM_ACCESS
// `define MISALIGNED_MEM_ACCESS

package Memory_Class;
    import Architecture_AClass::*;
    import SignExtender_Class::*;

    /**
    * MemoryCell typedef.
    * Defines a single cell of memory, which is a packed array of bytes.
    */
    typedef `packed_arr(`rvbyte, (`REGISTER_GLOBAL_BITWIDTH/`BYTE_SIZE), MemoryCell);
    
    /**
    * MemoryType typedef.
    * Defines a memory array.
    */
    typedef `unpacked_arr(`memorycell, (`MEMORY_SIZE_IN_CELLS), MemoryType);
    
    class Memory extends Architecture_AClass::Architecture;
        `_protected MemoryType main_memory;
        
        function new();
            foreach(main_memory[icell])
                main_memory[icell] = `MEMORY_INITIAL_VALUE;
        endfunction
        
        `_public function `memorycell Read(input `uint address, input `uint bytes, input `rvtype extend_sign);
            `uint memcell_remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            `memorycell intermediate_val = `MEMORY_INITIAL_VALUE;
            unique case(bytes)
                1: intermediate_val[0] = this.main_memory[address - memcell_remainder][memcell_remainder];
                2: 
                    if(memcell_remainder == 0) 
                        intermediate_val[1:0] = this.main_memory[address - memcell_remainder][1:0];
                    else if(memcell_remainder == 2)
                        intermediate_val[1:0] = this.main_memory[address - memcell_remainder][3:2];
                    else
                        $error("Misalingned address!");
                4:
                    if(memcell_remainder != 0) $error("Misaligned address!");
                    else intermediate_val = this.main_memory[address];
                
                default:
                    $error("Unimplemented address range used!");
            endcase
            /**
            * Sign - extension performed by abstract class static method
            */
            if(extend_sign == 1)
                intermediate_val = `sepkg::SignExtender::ExtendSign(intermediate_val, bytes * `BYTE_SIZE, 0);
            
            return intermediate_val;
        endfunction
        
        `_public function Write(input `uint address, input `memorycell data, input `uint bytes);
            `uint memcell_remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            unique case(bytes)
                1: this.main_memory[address - memcell_remainder][memcell_remainder] = data;
                2:
                    if(memcell_remainder == 0) 
                        this.main_memory[address - memcell_remainder][1:0] = data[1:0];
                    else if(memcell_remainder == 2)
                        this.main_memory[address - memcell_remainder][3:2] = data[1:0];
                    else
                        $error("Misalingned address!");
                4:
                    if(memcell_remainder != 0) $error("Misaligned address!");
                    else this.main_memory[address] = data;
                default:
                    $error("Unimplemented address range used!");
            endcase
        endfunction
    endclass
    
    class MemoryTransactionItem;
        `_public rand `rvtype MEMW;
        `_public rand `rvtype MEMR;
        `_public rand `rvtype MSE;
        `_public rand `packed_arr(`rvtype, 2, MBC);
        `_public rand `rvector ADDRIN;
        `_public rand `rvector DATAIN;
        `_public `rvector MEMOUT;
        
        constraint c_memaddr {
            this.ADDRIN < ((`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES);
            this.ADDRIN > ((`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES) - `MEMORY_TESTBENCH_CONSTRAINT_ADDRESS_SPAN;
        };
        constraint c_memreadwrite {
            (MEMW & MEMR) != 1;
        };
        constraint c_bytecount {
            this.MBC == 3 -> this.ADDRIN % `MEMORY_CELL_SIZE_IN_BYTES == 0;
            this.MBC == 2 -> this.ADDRIN % 2 == 0;
        };
        
        `_public task log(input string tag="");
            `DLT_MEMORY_TITEM_VARDUMP(tag);
        endtask

        `_public function `rvtype Compare(input MemoryTransactionItem item);
            if((this.MEMW == item.MEMW) &&
            (this.MEMR == item.MEMR) &&
            (this.MSE == item.MSE) &&
            (this.MBC == item.MBC) &&
            (this.ADDRIN == item.ADDRIN) &&
            (this.DATAIN == item.DATAIN)) 
                return 1;
            else
                return 0;
        endfunction
    endclass
    
    class MemoryVerificationDriver;
        `_public virtual MemoryInterface memif;
        `_public mailbox memory_driver_mailbox;
        `_public mailbox memory_scoreboard_mailbox;
        `_private MemoryTransactionItem item;
        
        `_public task run();
            `DLT_MEMORY_INFO("Memory Driver", " Starting...");
            
            forever begin
                `DLT_MEMORY_INFO("Memory Driver", "Waiting for item...");
                
                this.memory_driver_mailbox.get(this.item); /**< Wait for message from generator */
                this.item.log("Memory Driver");
                
                /**
                * Drive the interface.
                */
                this.memif.MEMW <= item.MEMW;
                this.memif.MEMR <= item.MEMR;
                this.memif.MSE <= item.MSE;
                this.memif.MBC <= item.MBC;
                this.memif.ADDRIN <= item.ADDRIN;
                this.memif.DATAIN <= item.DATAIN;

                /**
                * After driving the interface, forward the item to scoreboard.
                */
                this.memory_scoreboard_mailbox.put(this.item);                
            end // forever loop
        endtask
    endclass
    
    class MemoryMonitor;
        `_public virtual MemoryInterface memif;
        `_public mailbox memory_scoreboard_mailbox;
        `_private MemoryTransactionItem item;
        
        `_public task run();
            `DLT_MEMORY_INFO("Memory Monitor", " Starting...");
            
            forever begin
                this.item = new;
                @(`CLOCK_ACTIVE_EDGE memif.clk); /**< Valid transaction occurs at every active clock edge */
                    
                this.item.MEMW = this.memif.MEMW;
                this.item.MEMR = this.memif.MEMR;
                this.item.MSE = this.memif.MSE;
                this.item.MBC = this.memif.MBC;
                this.item.ADDRIN = this.memif.ADDRIN;
                this.item.DATAIN = this.memif.DATAIN;
                this.item.MEMOUT = this.memif.MEMOUT;
                
                this.item.log("Memory Monitor"); /**< Log transaction item from generator perspective */
                this.memory_scoreboard_mailbox.put(this.item); /**< Put item in scoreboard mailbox */
            end // forever loop
        endtask
    endclass
    
    class MemoryScoreboard;
        `_public mailbox memory_driver_mailbox;
        `_public mailbox memory_monitor_mailbox;
        `_private MemoryTransactionItem driver_item;
        `_private MemoryTransactionItem monitor_item;
        `_private MemoryTransactionItem database[`rvector]; /**< Associative array for checking the results */
        
        `_public task run();
            forever begin
                this.memory_driver_mailbox.get(this.driver_item); /**< Wait for driver to initialise transaction */
                this.memory_monitor_mailbox.get(this.monitor_item); /**< Wait for monitor to register transaction */
                `rvector aligned_address = this.monitor_item.ADDRIN >> 2; /**< Address aligned to 4 for correct database handling */

                /**
                * Check if transaction was correct.
                */
                if(this.driver_item.Compare(this.monitor_item) != 1)
                    `DLT_MEMORY_SCOREBOARD(" |Transaction failure| ");
                
                /**
                * Scenario 1: memory write
                */
                if ((this.monitor_item.MEMW == 1) && (this.monitor_item.MEMR == 0))
                    if (this.database.exists(aligned_address) == 0)
                        this.database[aligned_address] = this.monitor_item;
                    else begin
                        /////////////// TODO
                    end
                
                /**
                * Scenario 2: memory read
                */
                if ((this.monitor_item.MEMW == 0) && (this.monitor_item.MEMR == 1)) begin
                    if (this.database.exists(aligned_address) != 1)
                        `DLT_MEMORY_SCOREBOARD(" |Uninitialised addr read| ");
                    else begin
                        if (this.monitor_item.MSE == 1) begin /**< Load instruction */
                            case (this.monitor_item.MBC)
                                1: if(this.monitor_item.MEMOUT != `sepkg::ExtendSign(this.database[this.monitor_item.ADDRIN].DATAIN, `BYTE_SIZE, 0))
                                    `DLT_MEMORY_SCOREBOARD(" |Invalid output value - byte read| ");
                                    else `DLT_MEMORY_SCOREBOARD(" |Successfull signed byte read| ");
                                2: if(this.monitor_item.MEMOUT != `sepkg::ExtendSign(this.database[this.monitor_item.ADDRIN].DATAIN, 2 * `BYTE_SIZE, 0))
                                    `DLT_MEMORY_SCOREBOARD(" |Invalid output value - halfword read| ");
                                    else `DLT_MEMORY_SCOREBOARD(" |Successfull signed halfword read| ");
                                3: if(this.monitor_item.MEMOUT != this.database[this.monitor_item.ADDRIN].DATAIN)
                                    `DLT_MEMORY_SCOREBOARD(" |Invalid output value - word read| ");
                                    else `DLT_MEMORY_SCOREBOARD(" |Successfull word read| ");
                                default: `DLT_MEMORY_SCOREBOARD(" |Unknown byte count| "); 
                            endcase
                        end else begin /**< Load unsigned instruction */
                            case (this.monitor_item.MBC)
                                1: if(this.monitor_item.MEMOUT != this.database[this.monitor_item.ADDRIN].DATAIN) 
                                default: /////////// TODO
                            endcase
                        end
                    end
                end
                
                // Scenario 3: memory idle state 1
                if (~(item.memwrite || item.memread)) begin
                    `DLT_MEMORY_SCOREBOARD(" |Memory idle| ");
                end
               
                
            end // forever loop
        endtask
    endclass
    
    class MemoryVerificationEnvironment;
        `_public MemoryVerificationDriver driver; // Public because of the mailbox handling in the class above
        `_private MemoryMonitor monitor;
        `_private MemoryScoreboard scoreboard;
        `_public mailbox scoreboard_mailbox; // Top level mailbox for scoreboard <-> monitor transactions
        `_public virtual MemoryInterface memif;
        
        function new();
            this.driver = new;
            this.monitor = new;
            this.scoreboard = new;
            this.scoreboard_mailbox = new;
        endfunction
        
        `_public virtual task run();
            this.driver.memif = this.memif;
            this.monitor.memif = this.memif;
            this.monitor.scoreboard_mailbox = this.scoreboard_mailbox;
            this.scoreboard.scoreboard_mailbox = this.scoreboard_mailbox;
            fork
                this.scoreboard.run();
                this.driver.run(); // mailbox for driver <-> generator exchange is initialised on test class level
                this.monitor.run();
            join_any // If any task finishes, continue execution
        endtask
    endclass
    
    class MemoryTest;
        `_private MemoryVerificationEnvironment environment;
        `_private mailbox driver_mailbox;
        `_public virtual MemoryInterface memif;
        
        function new();
            this.driver_mailbox = new;
            this.environment = new;
        endfunction
        
        `_public virtual task run();
            this.environment.memif = this.memif;
            this.environment.driver.driver_mailbox = this.driver_mailbox;
            
            fork
                this.environment.run(); // Start environment in background
                this.stimulate(); // Apply stimulus
            join_none
        endtask
        
        `_public virtual task stimulate();
            MemoryTransactionItem item;
            
            `DLT_MEMORY_INFO("Memory Test", " Starting stimulus... ");
            for (int i = 0; i < `MEMORY_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS; i = i + 1) begin
                item = new;
                item.randomize(); // Builtin constraints inside transaction item class
                @(`CLOCK_ACTIVE_EDGE this.memif.clk);
                driver_mailbox.put(item);
            end // for loop
        endtask
    endclass
    
endpackage

