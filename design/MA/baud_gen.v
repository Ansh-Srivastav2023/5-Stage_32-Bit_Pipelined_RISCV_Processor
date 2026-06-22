`default_nettype wire
`timescale 1ns/1ps

module baud_gen(
    input wire clk, rst,
    input wire [15:0] dvsr,
    output reg tick
);

    reg [15:0] count;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin 
            count   <= 0;
            tick    <= 0;
        end
        else 
            if (count == dvsr) 
            begin
                tick    <= ~tick;
                count   <= 0;                
            end
            else count <= count + 1;
    end        

endmodule
