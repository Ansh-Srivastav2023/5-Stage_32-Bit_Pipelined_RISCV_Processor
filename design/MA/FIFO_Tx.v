`default_nettype wire
`timescale 1ns/1ns

module FIFO_Tx #(parameter FIFO_LEN = 64)
            (input clk, rst,
            input [7:0] data_in,
            input write_en, read_en,
            output [7:0] data_out,
            output empty);


    wire full;

    
    (* ram_style = "block" *)
    reg [7:0] fifo_mem [0:(FIFO_LEN-1)];


    reg [$clog2(FIFO_LEN):0] head, tail;
    
    assign data_out = fifo_mem[head[$clog2(FIFO_LEN)-1:0]];

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            tail    <= 'b0;
            head    <= 'b0;
        end
        else begin
            if (write_en && !full) begin
                fifo_mem[tail[$clog2(FIFO_LEN)-1:0]] <= data_in;
                tail  <= tail + 1'b1;
            end

            if (read_en && !empty) begin
                head  <= head + 1'b1;
            end
        end
    end

    assign full = ((head[$clog2(FIFO_LEN)-1:0] == tail[$clog2(FIFO_LEN)-1:0]) && (head[$clog2(FIFO_LEN)] == ~tail[$clog2(FIFO_LEN)]));
    assign empty = (head == tail);

endmodule

