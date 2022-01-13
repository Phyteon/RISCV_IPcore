//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 
// Design Name: NA
// Module Name: Multiplexer_Module
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
// 
// This file contains package defining Multiplexer Module.
//
// Dependencies: 
//
// Architecture_AClass package
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "CommonHeader.sv"

module MUX (
    MUXInterface muxinf
);
    assign muxinf.mux_output = muxinf.inputs[muxinf.steering];
    
endmodule