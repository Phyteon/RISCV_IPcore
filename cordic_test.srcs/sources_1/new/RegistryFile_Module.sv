//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: RegistryFile_Module
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

module RegistryFile_Module (
    RegistryFileInterface.DUT reginf
    );
    import `regfilepkg::*;

    `regfilepkg::RegistryFile regfile;
    initial begin
        regfile = new;
    end

    always_comb begin
        if(reginf.RESET == 1) begin
            reginf.OP1 <= 0;
            reginf.OP2 <= 0;
        end else begin
            reginf.OP1 <= regfile.ReadPair(reginf.RS1, reginf.RS2)[0];
            reginf.OP2 <= regfile.ReadPair(reginf.RS1, reginf.RS2)[1];
            if(reginf.REGW == 1)
                regfile.Write(reginf.REGDATIN, reginf.RD);
        end
    end
    
endmodule