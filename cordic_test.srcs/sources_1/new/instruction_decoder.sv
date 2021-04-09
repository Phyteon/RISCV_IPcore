`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH University of Science and Technology
// Engineer: 
// 
// Create Date: 22.03.2021 20:34:16
// Design Name: 
// Module Name: instruction_decoder
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
// This module is part of RISC-V IP core project
//////////////////////////////////////////////////////////////////////////////////



module instruction_decoder(
    input [31:0] inst,
    input clk,
    input reset
    );
    
    class Decoder;
        function int decode(bit [31:0] instruction);
            if(instruction[6:0] == 7'b0110011) // R-type instruction format
                    begin
                        case (instruction[14:12])
                            3'b111: if(instruction[25:31] == 7'h0) // AND
                                    begin
                                        $display("AND instruction, destination: R%0d, src1: R%0d, src2: R%0d", instruction[7:11], instruction[15:19], instruction[20:24]);
                                        return 1;
                                    end
                            3'b110: if(instruction[25:31] == 7'h0) // OR
                                    begin
                                        $display("OR instruction, destination: R%0d, src1: R%0d, src2: R%0d", instruction[7:11], instruction[15:19], instruction[20:24]);
                                        return 1;
                                    end
                            
                            endcase;
                    end else if(instruction[6:0] == 7'b0010011) // I-type instruction format
                    begin
                        case (instruction[14:12])
                            3'b000: // Implement ADDI (NOP) instruction
                                begin
                                    $display("ADDI instruction, destination: R%0d, source: R%0d, immediate: %0h", instruction[7:11], instruction[15:19], instruction[20:31]);
                                    return 2;
                                end
                        endcase
                    end
        endfunction
    endclass
    
    Decoder decoder;
    
    always @(posedge clk or posedge reset)
    begin
        if(reset == 1)
        begin
            // Handle the reset
            $display("Reset signal received");
        end else begin    
            $display("Format of the function: %0d", decoder.decode(inst));
        end
    end     
   
// IMPORTANT! No explicit MOV instruction specified in RISC-V ISA. Same operation can be achieved by:
// AND x2, x0, x2    <- Suppose we want to copy register x3 into register x2. First we make sure that x2 is empty. (can be done in a multiple of ways)
// ADD x2, x2, x3    <- Add x3 to x2    
        
    
endmodule
