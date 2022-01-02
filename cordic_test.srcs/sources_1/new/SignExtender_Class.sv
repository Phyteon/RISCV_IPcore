`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2022 21:19:12
// Design Name: 
// Module Name: SignExtender_Class
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

`define sepkg SignExtender_Class

import Architecture_AClass::*;

package SignExtender_Class;
    virtual class SignExtender extends Architecture_AClass::Architecture;
        static function `rvector ExtendSign(input `rvector imm, input `uint bitwidth, input `uint position);
            `rvector extended = imm;
            extended = extended << position;
            if (imm[bitwidth - 1] == 1) begin /**< If the MSB of IMM is 1, extend all upper bits to 1 */
                for (int index = bitwidth + position ; index < `REGISTER_GLOBAL_BITWIDTH ; index = index + 1 ) begin
                    extended[index] = 1;
                end
            end
            return extended;
        endfunction
    endclass //SignExtender
endpackage
