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

module ControlUnit(
    ControlUnitInterface.DUT cuinf
);
    import ControlUnit_Class::*;
    `cupkg::ControlUnit cntrl;

    initial begin
        cntrl = new;
        cntrl.cuinf = cuinf;
    end

    always @(`CLOCK_ACTIVE_EDGE cuinf.clk) begin
        cntrl.ControlUnitMainFunction(cuinf.INSTR);
    end
    
endmodule