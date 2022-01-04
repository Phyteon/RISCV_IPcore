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

`include "CommonHeader.sv"

`define SIZE_OF_REGISTRY_FILE 32
`define REGISTER_INITIAL_VALUE 'h0000_0000

package RegistryFile_Class;
    import Architecture_AClass::*;
    import Register_Class::*;

    class RegistryFile extends Architecture_AClass::Architecture;
        `_private `unpacked_arr(`regpkg::Register, `SIZE_OF_REGISTRY_FILE, registers); // Only unpacked array of class is allowed
        
        function new();
            foreach (registers[n])
                registers[n] = `regpkg::Register::new(`REGISTER_INITIAL_VALUE);
        endfunction
        
        function `rvector_dynamic_array ReadPair(input `uint rs1, input `uint rs2);
            `rvector_dynamic_array temporary;
            temporary = new [2];
            temporary[0] = this.registers[rs1].Read();
            temporary[1] = this.registers[rs2].Read();
            return temporary;
        endfunction 
        
        function Write(input `rvector val, input `uint rd);
            if (rd != 0) this.registers[rd].Write(val);
        endfunction
    endclass
endpackage
