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

`include "D:\\VivadoProjects\\cordic_test\\RISCV_IPcore\\cordic_test.srcs\\sources_1\\new\\CommonHeader.sv"

import Memory_Class::*;
import ALU_Class::*;

`define TESBENCH_CLOCK_FREQUENCY_KHZ 500000
`define CLK_PERIOD_NS (1000000.0/(`TESBENCH_CLOCK_FREQUENCY_KHZ))
`define CLK_CYCLES_TO_SIMULATE `ALU_TESTBENCH_STIMULUS_NUMBER_OF_TRANSACTIONS

module RV_core_TB();
    // Internal signals/variables/object handles
    `rvtype clk;
    `rvtype reset;
    `rvtype enable;
    ControlUnitInterface cuinf(clk);
    ALUInterface aluinf(clk);
    MemoryInterface memif(clk);
    
    // Clock
    TB_Clocking_Module#(.frequency(`TESBENCH_CLOCK_FREQUENCY_KHZ)) clock(.enable(enable),
                                                .clk(clk)); // Creating default clock
    
    // DUTs
    RV_core core(clk, reset);
    
    /* Test body */
    initial begin
        `INIT_TASK;
        $dumpfile("coretest.dump");
        enable <= 0;
        reset <= 1;
        #(`CLK_PERIOD_NS/2) enable <= 1; // Enabling the clock module
        #(`CLK_PERIOD_NS) reset <= 0; // Reset state revoked
        $dumpvars;
        #(`CLK_CYCLES_TO_SIMULATE * `CLK_PERIOD_NS) $finish;
    end // inital

    
    
endmodule