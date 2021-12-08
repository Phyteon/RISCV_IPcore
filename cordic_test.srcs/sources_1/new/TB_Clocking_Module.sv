`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.12.2021 23:20:08
// Design Name: 
// Module Name: TB_Clocking_Module
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

`define DEFAULT_TB_CLOCK_FREQ 10 // In kHz
`define DEFAULT_TB_CLOCK_PHASE 0 // In deg
`define DEFAULT_TB_CLOCK_DUTY 50 // In %

`define to_ns(freq_in_kHz) (1000000.0/(freq_in_kHz))
`define to_frac(percentage) (percentage/100.0)
`define phase_to_frac(degrees) (degrees/360.0)


module TB_Clocking_Module#(frequency = `DEFAULT_TB_CLOCK_FREQ, phase = `DEFAULT_TB_CLOCK_PHASE, duty = `DEFAULT_TB_CLOCK_DUTY)
                        (
                            input `rvtype enable,
                            output `rvtype clk
                        );

    real period = `to_ns(frequency);
    real clk_dt_cycle_period = `to_frac(duty) * period;
    real phase_offset = `phase_to_frac(phase) * period;
    `rvtype start_clk;

    initial begin
        clk = 0;
        start_clk = 0;
    end

    always @(posedge enable or negedge enable) begin
        if (enable) #(phase_offset) start_clk = 1;
        else #(phase_offset) start_clk = 0;
    end

    always @(posedge start_clk or negedge start_clk) begin
        if (start_clk)
    end


endmodule
