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
    `rvector_dynamic_array temp_value;
    initial begin
        regfile = new;
        temp_value = new[2];
    end

    always @(`CLOCK_ACTIVE_EDGE reginf.clk) begin
        if(reginf.RESET == 1) begin
            reginf.OP1 <= 0;
            reginf.OP2 <= 0;
        end else begin
            temp_value = regfile.ReadPair(reginf.RS1, reginf.RS2);
            reginf.OP1 <= temp_value[0];
            reginf.OP2 <= temp_value[1];
            if(reginf.REGW == 1)
                regfile.Write(reginf.REGDATIN, reginf.RD);
        end
    end
    
endmodule