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

import Architecture_AClass::*;

// Global package alias
`define mempkg Memory_Class

/**
* Memory size macros.
*/
`define DATA_MEMORY_SIZE_IN_CELLS 1024 /**< When MemoryCell is 32 bits wide, this translates to 4kB of memory. */
`define PROGRAM_MEMORY_SIZE_IN_CELLS 1024 /**< When MemoryCell is 32 bits wide, this translates to 4kB of memory. */

`define memorycell `mempkg::MemoryCell
`define MEMORY_INITIAL_VALUE `REGISTER_GLOBAL_BITWIDTH'h0
`define MEMORY_CELL_SIZE_IN_BYTES (`REGISTER_GLOBAL_BITWIDTH/`BYTE_SIZE)
`define BYTE_MASK `REGISTER_GLOBAL_BITWIDTH'h0000_00FF
`define WORD_MASK `REGISTER_GLOBAL_BITWIDTH'h0000_FFFF
`define MEMORY_TESTBENCH_SCOREBOARD_SIZE (`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES
`define MEMORY_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS 50
`define MEMORY_TESTBENCH_CONSTRAINT_ADDRESS_SPAN 10

/**
* Diagnostic log trace adapter macros and ERROR macros.
* They are aliases to the main DLT_LOG macro. ERROR macros
* provide self-documented error record.
*/
`define DLT_MEMORY_TITEM_VARDUMP(logging_entity) `DLT_LOG(logging_entity, \
                                                         " Transaction Item vars dump: ", \
                                                         {"memaddr=0x%0h ", \
                                                         "memwrite=0x%0h ", \
                                                         "memread=0x%0h ", \
                                                         "inbus=0x%0h ", \
                                                         "outbus=0x%0h"}, \
                                                         {this.memaddr, \
                                                         this.memwrite, \
                                                         this.memread, \
                                                         this.inbus, \
                                                         this.outbus}) /**< This macro is to be used ONLY from within the transaction item class. */

`define DLT_MEMORY_INFO(logging_entity, info) `DLT_LOG(logging_entity, info, {}, {}) /**< This macro can be used anywhere within this file. */

`define DLT_MEMORY_SCOREBOARD(message) `DLT_LOG("Memory Scoreboard", message, \
                                                         {"memaddr=0x%0h ", \
                                                         "memwrite=0x%0h ", \
                                                         "memread=0x%0h ", \
                                                         "inbus=0x%0h ", \
                                                         "outbus=0x%0h"}, \
                                                         {item.memaddr, \
                                                         item.memwrite, \
                                                         item.memread, \
                                                         item.inbus, \
                                                         item.outbus}) /**< This macro to be used ONLY from within the scoreboard class. */

`define ERROR_00_MEMORY_READ_VALUE_DIFFERENT_FROM_STORED " |ERROR 0x00| "

/**
* Compilation switch - misaligned memory access support.
* If ALIGNED_MEM_ACCESS is defined, only aligned access to memory is supported.
*/
`define ALIGNED_MEM_ACCESS
// `define MISALIGNED_MEM_ACCESS

package Memory_Class;

    /////////////////////////////////
    // Typedef:
    //      MemoryCell
    // Info:
    //      This type represents memory cell size used in the project. It is created
    //      so that if ever there was a need to change memory cell size, it would only
    //      require changing this define. IMPORTANT INFORMATION!: If this define would
    //      be ever changed author assumes that the type would still support byte-addressing.
    /////////////////////////////////
    typedef `rvector MemoryCell;
    
    /////////////////////////////////
    // Typedef:
    //      MemoryType
    // Info:
    //      This type represents memory. Fixed in size, dependent on MemoryCell type.
    //      To be used when constructing "soft" Harvard architecture.
    /////////////////////////////////
    typedef `packed_arr(`memorycell, (`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS), MemoryType);
    
    class Memory extends Architecture_AClass::Architecture;
        `_protected MemoryType main_memory;
        
        function new();
            foreach(main_memory[icell])
                main_memory[icell] = `MEMORY_INITIAL_VALUE;
        endfunction
        
        `_public function `memorycell Read(input `uint address, input `uint bytes);
            `uint memcell_remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            `memorycell intermediate_val = `MEMORY_INITIAL_VALUE;
            unique case(bytes)
                1: intermediate_val[0] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][memcell_remainder];
                2: 
                    if(memcell_remainder == 0) 
                        intermediate_val[1:0] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][1:0];
                    else if(memcell_remainder == 2)
                        intermediate_val[1:0] = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][3:2];
                    else
                        $error("Misalingned address!");
                4:
                    if(memcell_remainder != 0) $error("Misaligned address!");
                    else intermediate_val = this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES];
                
                default:
                    $error("Unimplemented address range used!");
            endcase
            // Sign extention / zero-padding will be performed by other function
            return intermediate_val;
        endfunction
        
        `_public function Write(input `uint address, input `memorycell data, input `uint bytes);
            `uint memcell_remainder = address % `MEMORY_CELL_SIZE_IN_BYTES;
            unique case(bytes)
                1: this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][memcell_remainder] = data;
                2:
                    if(memcell_remainder == 0) 
                        this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][1:0] = data[1:0];
                    else if(memcell_remainder == 2)
                        this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES][3:2] = data[1:0];
                    else
                        $error("Misalingned address!");
                4:
                    if(memcell_remainder != 0) $error("Misaligned address!");
                    else this.main_memory[address/`MEMORY_CELL_SIZE_IN_BYTES] = data;
                default:
                    $error("Unimplemented address range used!");
            endcase
        endfunction
    endclass
    
    class MemoryTransactionItem;
        `_public rand `rvector memaddr;
        `_public rand `rvector inbus;
        `_public rand `rvtype memwrite;
        `_public rand `rvtype memread;
        `_public `rvector outbus;
        
        constraint c_memaddr {
            memaddr < ((`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES);
            memaddr > ((`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES) - `MEMORY_TESTBENCH_CONSTRAINT_ADDRESS_SPAN;
            memaddr % `MEMORY_CELL_SIZE_IN_BYTES == 0;
        };
        constraint c_memreadwrite {
            (memwrite & memread) != 1; 
        };
        
        `_public task log(input string tag="");
            `DLT_MEMORY_TITEM_VARDUMP(tag);
        endtask
    endclass
    
    class MemoryVerificationDriver;
        `_public virtual MemoryInterface memif;
        `_public mailbox driver_mailbox;
        
        `_public task run();
            `DLT_MEMORY_INFO("Memory Driver", " Starting...");
            
            forever begin
                MemoryTransactionItem item;
                `DLT_MEMORY_INFO("Memory Driver", "Waiting for item...");
                
                driver_mailbox.get(item); // Wait for message from generator
                item.log("Memory Driver"); // Log transaction item from driver perspective
                
                // Driving the pins
                memif.memwrite <= item.memwrite;
                memif.memread <= item.memread;
                memif.memaddr <= item.memaddr;
                memif.inbus <= item.inbus;
                
            end // forever loop
        endtask
    endclass
    
    class MemoryMonitor;
        `_public virtual MemoryInterface memif;
        `_public mailbox scoreboard_mailbox;
        
        `_public task run();
            `DLT_MEMORY_INFO("Memory Monitor", " Starting...");
            
            forever begin
                @(`CLOCK_ACTIVE_EDGE memif.clk);
                // Wait for valid transaction
                if ((memif.memwrite ^ memif.memread) || ~(memif.memwrite || memif.memread)) begin
                    MemoryTransactionItem item = new;
                    item.memaddr = memif.memaddr;
                    item.memwrite = memif.memwrite;
                    item.memread = memif.memread;
                    item.inbus = memif.inbus;
                    item.outbus = memif.outbus;
                    
                    item.log("Memory Monitor"); // Log transaction item from generator perspective
                    this.scoreboard_mailbox.put(item); // Put item in scoreboard mailbox
                end //if
            end // forever loop
        endtask
    endclass
    
    class MemoryScoreboard;
        `_public mailbox scoreboard_mailbox;
        `_private `unpacked_arr(MemoryTransactionItem, `MEMORY_TESTBENCH_SCOREBOARD_SIZE, database); // Lookup table
        
        `_public task run();
            forever begin
                MemoryTransactionItem item; // Handle for objects from mailbox
                this.scoreboard_mailbox.get(item); // wait for transaction item from monitor
                item.log("Memory Scoreboard");
                
                // Scenario 1: memory write
                if ((item.memwrite == 1) && (item.memread == 0)) begin
                    if (database[item.memaddr] == null)
                        database[item.memaddr] = new;
                    database[item.memaddr] = item;
                    `DLT_MEMORY_SCOREBOARD(" |Store| ");
                end //if
                
                // Scenario 2: memory read
                if ((item.memwrite == 0) && (item.memread == 1)) begin
                    if (database[item.memaddr] == null)
                        `DLT_MEMORY_SCOREBOARD(" |Uninitialised addr read| ");
                    else
                        if (item.outbus != this.database[item.memaddr].inbus)
                            `DLT_MEMORY_SCOREBOARD(`ERROR_00_MEMORY_READ_VALUE_DIFFERENT_FROM_STORED);
                        else
                            `DLT_MEMORY_SCOREBOARD(" |Read PASS| ");
                end //if
                
                // Scenario 3: memory idle state 1
                if (~(item.memwrite || item.memread)) begin
                    `DLT_MEMORY_SCOREBOARD(" |Memory idle| ");
                end //if
               
                
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


interface MemoryInterface(input `rvtype clk);
    `rvtype memwrite;
    `rvtype memread;
    `rvector memaddr;
    `rvector inbus;
    `rvtype reset;
    `rvector outbus;
    // TODO: Add clocking blocks
    modport Testbench (input clk, output memwrite, output memread, output memaddr, output inbus, output reset, input outbus);
    modport DUT (input clk, input memwrite, input memread, input memaddr, input inbus, input reset, output outbus);
endinterface
