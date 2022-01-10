`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 25.10.2021 00:08:38
// Design Name: 
// Module Name: RV_core_TB
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

`include "cordic_test.srcs\\sources_1\\new\\CommonHeader.sv"

import Memory_Class::*;
import ALU_Class::*;

`define TESBENCH_CLOCK_FREQUENCY_KHZ 50000
`define CLK_PERIOD_NS (1000000.0/(`TESBENCH_CLOCK_FREQUENCY_KHZ))
`define CLK_CYCLES_TO_SIMULATE `ALU_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS

module RV_core_TB();
    // Internal signals/variables/object handles
    `rvtype clk;
    `rvtype enable;
    //MemoryTest memtest;
    `alupkg::AluTest alutest;
    
    // Interfaces
    //MemoryInterface memif(clk);
    ALUInterface aluinf(clk);
    
    // Clock
    TB_Clocking_Module#(.frequency(50000)) clock(enable, clk); // Creating default clock
    
    // DUTs
    //Memory_Module memory(.memif(memif)); // Initialising module with top-level interface
    ALU_Module alu(.aluinf(aluinf));
    
    /* Test body */
    initial begin
        `INIT_TASK;
        $dumpfile("alutest.dump");
        enable <= 0;
        alutest = new;
        alutest.aluinf = aluinf;
        aluinf.reset = 1;
        #(`CLK_PERIOD_NS/2) enable = 1; // Enabling the clock module
        #(`CLK_PERIOD_NS) aluinf.reset = 0; // Reset state revoked
    end //initial
    
    always @(posedge enable) begin
        alutest.run();
        $dumpvars;
        #(`CLK_CYCLES_TO_SIMULATE * `CLK_PERIOD_NS) $finish;
    end // always

endmodule