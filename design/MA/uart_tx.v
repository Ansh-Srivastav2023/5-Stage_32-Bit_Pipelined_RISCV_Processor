`default_nettype wire
`timescale 1ns/1ps

module uart_tx (
    input tick, Tx_Drive,
    input [7:0] data_in,
    input [3:0] tick_div,
    input rst,
    output reg Tx_Serial, Tx_Done  
);

    reg [3:0] count;
    reg [2:0] bit_indx;

    parameter s_IDLE = 3'b000, s_START = 3'b001, s_DATA = 3'b010, s_STOP = 3'b011;
    reg [2:0] state;

    always @(posedge tick or negedge rst) begin
        if(!rst) begin
            state       <= s_IDLE;
            count       <= 'b0;
            Tx_Serial   <= 1'b1;
            bit_indx    <= 'b0;
            Tx_Done     <= 1'b0;
        end
        else begin 
            case (state)
            s_IDLE: begin
                count       <= 'b0;
                Tx_Serial   <= 1'b1;
                bit_indx    <= 'b0;
                Tx_Done     <= 1'b0;
                
                if(Tx_Drive) 
                    begin 
                        state       <= s_START;
                    end
                else 
                    state <= s_IDLE;
                
            end

            s_START: begin
                count <= count + 1'b1;
                Tx_Serial <= 1'b0;
                if (count == tick_div - 1'b1) begin
                    state       <= s_DATA;
                    count       <= 'b0;
                    bit_indx    <= 'b0;
                end
                else 
                    state       <= s_START;
            end

            s_DATA: begin
                count           <= count + 1'b1;
                Tx_Serial       <= data_in[bit_indx];
                
                if (count == tick_div - 1'b1) begin
                    count        <= 'b0;
                    if (bit_indx < 3'b111) begin
                        bit_indx <= bit_indx + 1'b1;
                        state    <= s_DATA;
                    end else begin
                        state    <= s_STOP;
                    end
                end
            end


            s_STOP: begin
                Tx_Serial <= 1'b1;
                if(count == tick_div - 1'b1) begin
                    count     <= 'b0;
                    state     <= s_IDLE;
                    Tx_Done   <= 1'b1;
                end
                else begin
                    count <= count + 1'b1;
                end
            end

            default: begin
                state <= s_IDLE;
                Tx_Serial <= 1'b1;
            end
            endcase
        end
    end

endmodule //uart_tx
