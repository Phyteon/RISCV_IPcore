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

`include "CommonHeader.sv"

`define UPPER_STYPE_IMMEDIATE_STARTBIT 5
`define STYPE_IMMEDIATE_OVERALL_BITWIDTH 12
`define BTYPE_IMMEDIATE_OVERALL_BITWIDTH 12
`define JTYPE_IMMEDIATE_OVERALL_BITWIDTH 20

package SignExtender_Class;
    import Architecture_AClass::*;
    import Instruction_Classes::*;
    virtual class SignExtender extends Architecture_AClass::Architecture;
        static function `rvector ExtendSign(input `rvector imm, input `uint bitwidth, input `uint position);
            `rvector extended = imm;
            extended = extended << position;
            if ((imm[bitwidth - 1] == 1) && ((bitwidth + position) < `REGISTER_GLOBAL_BITWIDTH)) begin /**< If the MSB of IMM is 1, extend all upper bits to 1 */
                for (int index = bitwidth + position ; index < `REGISTER_GLOBAL_BITWIDTH ; index = index + 1 ) begin
                    extended[index] = 1;
                end
            end
            return extended;
        endfunction

        static function `rvector ZeroStuff(input `rvector imm, input `uint position);
            `rvector stuffed = imm;
            stuffed = stuffed << position;
            return stuffed;
        endfunction

        static function `rvector ConcatentateSTypeImmediate(input `inspkg::Instruction stypeins);
            `rvector concatentated = stypeins.Fields[1].ExtractFromInstr(stypeins.Contents);
            concatentated += (stypeins.Fields[5].ExtractFromInstr(stypeins.Contents) << `UPPER_STYPE_IMMEDIATE_STARTBIT);
            concatentated = SignExtender::ExtendSign(concatentated, `STYPE_IMMEDIATE_OVERALL_BITWIDTH, 0);
            return concatentated;
        endfunction

        static function `rvector ConcatentateBTypeImmediate(input `inspkg::Instruction btypeins);
            /**
            * Second immediate field of instruction contains the lowest bits of the immediate - 
            * those bits need to be shifted by one to the left (because conditional branch
            * instructions immediates are always a multiple of 2).
            */
            `rvector concatentated = (btypeins.Fields[2].ExtractFromInstr(btypeins.Contents) << 1);
            /**
            * The next bits are stored in the seventh field of the instruction.
            */
            concatentated += (btypeins.Fields[6].ExtractFromInstr(btypeins.Contents) << 5);
            /**
            * The oldest two bits are stored in the second and eight fields of instruction.
            */
            concatentated[11] = btypeins.Fields[1].ExtractFromInstr(btypeins.Contents);
            concatentated[12] = btypeins.Fields[7].ExtractFromInstr(btypeins.Contents);
            concatentated = SignExtender::ExtendSign(concatentated, `BTYPE_IMMEDIATE_OVERALL_BITWIDTH, 0); /**< No offset because offset was already included */
            return concatentated;
        endfunction

        static function `rvector ConcatentateJTypeImmediate(input `inspkg::Instruction jtypeins);
            /**
            * Third immediate field of instruction contains the lowest bits of the immediate - 
            * those bits need to be shifted by one to the left (because unconditional jump
            * instructions immediates are always a multiple of 2).
            */
            `rvector concatentated = (jtypeins.Fields[4].ExtractFromInstr(jtypeins.Contents) << 1);
            concatentated[11] = jtypeins.Fields[3].ExtractFromInstr(jtypeins.Contents);
            concatentated += (jtypeins.Fields[2].ExtractFromInstr(jtypeins.Contents) << 12);
            concatentated[20] = jtypeins.Fields[5].ExtractFromInstr(jtypeins.Contents);
            concatentated = SignExtender::ExtendSign(concatentated, `JTYPE_IMMEDIATE_OVERALL_BITWIDTH, 0); /**< No offset because offset was already included */
            return concatentated;
        endfunction
    endclass //SignExtender
endpackage
