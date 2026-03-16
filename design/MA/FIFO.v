module FIFO #(parameter FIFO_LEN = 64)
            (input clk, rst,
            input [7:0] data_in,
            input write_en, read_en,
            output [7:0] data_out,
            output full, empty);

    
    (* ram_style = "block" *)
    reg [7:0] fifo_mem [0:(FIFO_LEN-1)];


    reg [$clog2(FIFO_LEN):0] head, tail;
    reg [$clog2(FIFO_LEN):0] count;

    assign data_out = fifo_mem[head[$clog2(FIFO_LEN)-1:0]];

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            tail    <= 'b0;
            head    <= 'b0;
            count   <= 'b0;
        end
        else begin
            // Write Logic
            if (write_en && !full) begin
                fifo_mem[tail[$clog2(FIFO_LEN)-1:0]] <= data_in;
                tail  <= tail + 1'b1;
            end

            // Read Logic
            if (read_en && !empty) begin
                head  <= head + 1'b1;
            end

            case ({ (write_en && !full), (read_en && !empty) })
                2'b10: count <= count + 1'b1; 
                2'b01: count <= count - 1'b1; 
                2'b11: count <= count;
                default: count <= count;
            endcase
        end
    end

    assign full = ((head[$clog2(FIFO_LEN)-1:0] == tail[$clog2(FIFO_LEN)-1:0]) && (head[$clog2(FIFO_LEN)] == ~tail[$clog2(FIFO_LEN)]));
    assign empty = (head == tail);

endmodule
