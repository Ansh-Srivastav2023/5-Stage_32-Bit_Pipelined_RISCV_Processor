`default_nettype wire
`timescale 1ns/1ns

module Reset_Sync(
    input async_rst,
    input clk,
    output reg sync_rst
);

    reg q1;
    always @(posedge clk or negedge async_rst) begin
        if(!async_rst) begin
            q1 <= 1'b0;
            sync_rst <= 1'b0;
        end
        
        else begin
            q1 <= 1'b1;
            sync_rst <= q1;
        end
    end

endmodule
