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
    ControlUnitInterface.DUT cuinf
);
    import ControlUnit_Class::*;
    `cupkg::ControlUnit cntrl;

    initial begin
        cntrl = new;
        cntrl.cuinf = cuinf;
    end

    always @(`CLOCK_ACTIVE_EDGE cuinf.clk) begin
        if (cuinf.RESET == 1) begin
            cuinf.CUJMPCTRL <= 0;
            cuinf.CUBCTRL <= 0;
            cuinf.MUX2 <= 1; /**< Choosing output of registry file */
            cuinf.MUX3 <= 0; /**< Choosing the main ALU output */
            cuinf.MUX4 <= 0; /**< Choosing output of registry file */
            cuinf.RS1 <= 0; /**< Choosing the zero register */
            cuinf.RS2 <= 0; /**< Choosing the zero register */
            cuinf.RD <= 0; /**< Choosing the zero register */
            cuinf.REGW <= 0; /**< Disable registry file write */
            cuinf.MEMW <= 0; /**< Disable data memory write */
            cuinf.MEMR <= 0; /**< Disable memory read */
            cuinf.ALU0 <= `alupkg::OperationType'(0); /**< Choose addition operation for main ALU */
        end else
            cntrl.ControlUnitMainFunction(cuinf.INSTR);
    end
    
endmodule