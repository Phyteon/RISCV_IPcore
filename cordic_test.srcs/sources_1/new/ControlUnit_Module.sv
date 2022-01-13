//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2021 23:16:20
// Design Name: 
// Module Name: ControlUnit_Class
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

module ControlUnit_Module (
    ControlUnitInterface cuinf
);
    import ControlUnit_Class::*;
    `cupkg::ControlUnit cntrl;

    initial begin
        cntrl = new;
        cntrl.cuinf = cuinf;
    end

    always @(`CLOCK_ACTIVE_EDGE cuinf.clk) begin
        if (cuinf.cu_clk.RESET == 1) begin
            cuinf.cu_clk.CUJMPCTRL <= 0;
            cuinf.cu_clk.CUBCTRL <= 0;
            cuinf.cu_clk.MUX2 <= 1; /**< Choosing output of registry file */
            cuinf.cu_clk.MUX3 <= 0; /**< Choosing the main ALU output */
            cuinf.cu_clk.MUX4 <= 0; /**< Choosing output of registry file */
            cuinf.cu_clk.RS1 <= 0; /**< Choosing the zero register */
            cuinf.cu_clk.RS2 <= 0; /**< Choosing the zero register */
            cuinf.cu_clk.RD <= 0; /**< Choosing the zero register */
            cuinf.cu_clk.REGW <= 0; /**< Disable registry file write */
            cuinf.cu_clk.MEMW <= 0; /**< Disable data memory write */
            cuinf.cu_clk.MEMR <= 0; /**< Disable memory read */
            cuinf.cu_clk.ALU0 <= `alupkg::OperationType'(0); /**< Choose addition operation for main ALU */
        end else
            cntrl.ControlUnitMainFunction(cuinf.INSTR);
    end
    
endmodule