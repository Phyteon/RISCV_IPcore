`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2021 22:48:21
// Design Name: 
// Module Name: Register_Class
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
package Register_Class;
    class Register extends Architecture_AClass::Architecture;
        local `rvector(`rvtype) contents;
        
        function new(input `rvector(`rvtype) _contents);
            this.contents = _contents;
        endfunction
        
        function `rvector(`rvtype) Read();
            return this.contents;
        endfunction
        
        function Write(input `rvector(`rvtype) writeval);
            this.contents = writeval;
        endfunction
        
    endclass
endpackage
