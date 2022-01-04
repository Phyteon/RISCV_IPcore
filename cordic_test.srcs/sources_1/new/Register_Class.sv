`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: Filip P.
// 
// Create Date: 14.10.2021 22:48:21
// Design Name: NA
// Module Name: Register_Class
// Project Name: RISC-V IP Core
// Target Devices: NA
// Tool Versions: NA
// Description: 
// 
// This file contains package defining Register class utilised in other modules.
//
// Dependencies: 
//
// Architecture_AClass package
// 
// Revision:
// Revision 0.01 - File Created
// Revision 0.5 (26.10.2021) - Adjusted to changes from Architecture_AClass package
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "CommonHeader.sv"

package Register_Class;
    import Architecture_AClass::*;

    class Register extends Architecture_AClass::Architecture;
        `_protected `rvector contents;
        
        `_public function new(input `rvector _contents);
            this.contents = _contents;
        endfunction
        
        `_public function `rvector Read();
            return this.contents;
        endfunction
        
        `_public function Write(input `rvector writeval);
            this.contents = writeval;
        endfunction
        
    endclass
endpackage
