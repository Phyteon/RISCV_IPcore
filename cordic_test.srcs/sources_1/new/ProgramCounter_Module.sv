`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 
// Design Name: NA
// Module Name: ProgramCounter_Module
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
//
// 
// Dependencies: 
// 
// Architecture_AClass package
// Register_Class package
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

module ProgramCounter (
    ProgramCounterInterface.DUT pcinf
    );
    import `pcpkg::*;
    `pcpkg::ProgramCounter pc;

    initial begin
        pc = new(`NULL_REG_VAL);
    end

    always @(`CLOCK_ACTIVE_EDGE pcinf.clk) begin
        if(pcinf.RESET == 1)
            pcinf.ADDROUT <= 0;
        else begin
            pcinf.ADDROUT <= pc.Read();
            pc.Write(pcinf.ADDRIN);
        end
    end

endmodule