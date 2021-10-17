`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2021 22:51:51
// Design Name: 
// Module Name: Architecture_AClass
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

`define ivector(dtype) dtype [``InstructionBitWidth - 1 : 0]
`define rvector(dtype) dtype [``RegisterBitWidth - 1 : 0]
`define uint int unsigned
`define sint int signed
`define to_uint(expr) unsigned' (expr)
`define to_sint(expr) signed' (expr)
`define fields_mod ``Field_Classes // TODO: Check how to utilise macros for packages import

package Architecture_AClass;

    virtual class Architecture #(parameter InstructionBitWidth = 32, parameter RegisterBitWidth = 32);
    endclass
    
endpackage
