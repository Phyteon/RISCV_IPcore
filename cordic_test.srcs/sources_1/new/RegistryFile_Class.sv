`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2021 00:08:38
// Design Name: 
// Module Name: RegistryFile_Class
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
import Register_Class::*;

`define SIZE_OF_REGISTRY_FILE 32
`define REGISTER_INITIAL_VALUE h0000_0000

package RegistryFile_Class;
    
    class RegistryFile extends Architecture_AClass::Architecture;
        local Register_Class::Register [`SIZE_OF_REGISTRY_FILE] registers;
        
        function new();
            foreach (registers[n])
                registers[n] = `REGISTER_INITIAL_VALUE;
        endfunction
        
        function `rvector(logic)[2] ReadPair(input `uint rs1, input `uint rs2);
            `rvector(logic)[2] temporary;
            temporary[0] = this.registers[rs1];
            temporary[1] = this.registers[rs2];
            if (rs1 == 0) temporary[0] = `REGISTER_INITIAL_VALUE;
            if (rs2 == 0) temporary[1] = `REGISTER_INITIAL_VALUE; // To reduce branches and simplify code
            return temporary;
        endfunction 
        
        function Write(input `rvector(logic) val, input `uint rd);
            if (rd != 0) this.registers[rd] = val;
        endfunction
    endclass
endpackage
