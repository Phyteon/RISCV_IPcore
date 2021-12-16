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

// Memory sizes defines
`define DATA_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory
`define PROGRAM_MEMORY_SIZE_IN_CELLS 1024 // When MemoryCell is 32 bits wide, this translates to 4kB of memory

`define memorycell `mempkg::MemoryCell
`define MEMORY_INITIAL_VALUE 'h0000_0000
`define MEMORY_CELL_SIZE_IN_BYTES (($bits(`memorycell))/`BYTE_SIZE)
`define BYTE_MASK 'h0000_00FF
`define WORD_MASK 'h0000_FFFF
`define MEMORY_TESTBENCH_SCOREBOARD_SIZE (`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES
`define MEMORY_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS 50

//// Compilation switch - misaligned memory access support
`define ALIGNED_MEM_ACCESS // If ALIGNED_MEM_ACCESS is defined, only aligned access to memory is supported

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
        
        `_public function new();
            // Does nothing, as in real processors memory is not cleared on startup
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
            memaddr < (`PROGRAM_MEMORY_SIZE_IN_CELLS + `DATA_MEMORY_SIZE_IN_CELLS) * `MEMORY_CELL_SIZE_IN_BYTES;
            memaddr[0][1:0] == 2'b0; // Only testing aligned addresses
        };
        constraint c_memreadwrite {
            (memwrite & memread) != 1; 
        };
        
        `_public function void log(input string tag="");
            $display("Timestamp=%0t [%s] memaddr=0x%0h memwrite=%0d memread=%0d inbus=%0d outbus=0x%0h",
                      $time,        tag, memaddr,      memwrite,    memread,    inbus,    outbus);
        endfunction
    endclass
    
    class MemoryVerificationDriver;
        `_public virtual MemoryInterface memif;
        `_public mailbox driver_mailbox;
        event driver_done;
        
        
        `_public task run();
            $display("Timestamp=%0t [Memory Driver] starting ...", $time);
            // Synchronise task to clock signal
            @(`CLOCK_ACTIVE_EDGE memif.clk);
            
            forever begin
                MemoryTransactionItem item;
                $display("Timestamp=%0t [Memory Driver] waiting for item...", $time);
                
                driver_mailbox.get(item); // Wait for message from generator
                item.log("Memory Driver"); // Log transaction item from driver perspective
                
                // Driving the pins
                memif.memwrite <= item.memwrite;
                memif.memread <= item.memread;
                memif.memaddr <= item.memaddr;
                memif.inbus <= item.inbus;
                
                // Transaction is done on the next active clock edge
                @(`CLOCK_ACTIVE_EDGE memif.clk);
                ->driver_done;
                
            end // forever loop
        endtask
    endclass
    
    class MemoryMonitor;
        `_public virtual MemoryInterface memif;
        `_public mailbox scoreboard_mailbox;
        
        `_public task run();
            $display("Timestamp=%0t [Memory Monitor] starting ...", $time);
            
            forever begin
                @(`CLOCK_ACTIVE_EDGE memif.clk);
                // Wait for valid transaction
                if ((memif.memwrite ^ memif.memread) || ~(memif.memwrite || memif.memread)) begin
                    MemoryTransactionItem item = new;
                    item.memaddr = memif.memaddr;
                    item.memwrite = memif.memwrite;
                    item.memread = memif.memread;
                    item.inbus = memif.inbus;
                    if(memif.memread) begin
                        @(`CLOCK_ACTIVE_EDGE memif.clk); // Wait for second active edge to properly register read operation outcome
                    end //if
                    item.outbus = memif.outbus;
                    
                    item.log("Memory Monitor"); // Log transaction item from generator perspective
                    scoreboard_mailbox.put(item); // Put item in scorebox
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
                scoreboard_mailbox.get(item); // wait for transaction item from monitor
                item.log("Memory scoreboard");
                
                // Scenario 1: memory write
                if ((item.memwrite == 1) && (item.memread == 0)) begin
                    if (database[item.memaddr] == null)
                        database[item.memaddr] = new;
                    database[item.memaddr] = item;
                    $display("Timestamp=%0t [Memory Scoreboard] Store memaddr=0x%0h memwrite=0x%0h inbus=0x%0h",
                              $time,                                  item.memaddr, item.memwrite, item.inbus);
                end //if
                
                // Scenario 2: memory read
                if ((item.memwrite == 0) && (item.memread == 1)) begin
                    if (database[item.memaddr] == null)
                        $display("Timestamp=%0t [Memory Scoreboard] Uninitialised addr read memaddr=0x%0h memread=0x%0h outbus=0x%0h",
                                 $time,                                                     item.memaddr, item.memread, item.outbus);
                    else
                        if (item.outbus != database[item.memaddr].outbus)
                            $display("Timestamp=%0t [Memory Scoreboard] ERROR 0x01! memaddr=0x%0h memread=0x%0h outbus=0x%0h",
                                     $time,                                         item.memaddr, item.memread, item.outbus);
                        else
                            $display("Timestamp=%0t [Memory Scoreboard] PASS memaddr=0x%0h memread=0x%0h outbus=0x%0h",
                                     $time,                                  item.memaddr, item.memread, item.outbus); 
                end //if
                
                // Scenario 3: memory idle state 1
                if (~(item.memwrite || item.memread)) begin
                    $display("Timestamp=%0t [Memory Scoreboard] Info - idle memaddr=0x%0h memwrite=0x%0h memread=0x%0h outbus=0x%0h",
                             $time,                                         item.memaddr, item.memwrite, item.memread, item.outbus);
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
            driver = new;
            monitor = new;
            scoreboard = new;
            scoreboard_mailbox = new;
        endfunction
        
        `_public virtual task run();
            driver.memif = this.memif;
            monitor.memif = this.memif;
            monitor.scoreboard_mailbox = this.scoreboard_mailbox;
            scoreboard.scoreboard_mailbox = this.scoreboard_mailbox;
            fork
                scoreboard.run();
                driver.run(); // mailbox for driver <-> generator exchange is initialised on test class level
                monitor.run();
            join_any // If any task finishes, continue execution
        endtask
    endclass
    
    class MemoryTest;
        `_private MemoryVerificationEnvironment environment;
        `_private mailbox driver_mailbox;
        `_public virtual MemoryInterface memif;
        
        function new();
            driver_mailbox = new;
            environment = new;
        endfunction
        
        `_public virtual task run();
            environment.memif = this.memif;
            environment.driver.driver_mailbox = this.driver_mailbox;
            
            fork
                environment.run(); // Start environment in background
            join_none
            
            this.stimulate(); // Apply stimulus
        endtask
        
        `_public virtual task stimulate();
            MemoryTransactionItem item;
            
            $display("Timestamp=%0t [Memory Test] Starting stimulus ...", $time);
            for (int i = 0; i < `MEMORY_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS; i = i + 1) begin
                item = new;
                item.randomize(); // Builtin constraints inside transaction item class
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
