`default_nettype wire
`timescale 1ns/1ps

module uart_rx (
    input tick, rst, Rx_Serial,
    input [3:0] clk_div,
    output reg Rx_Done,
    output reg [7:0] data_out
);

    parameter s_Idle = 2'b00, s_Start = 2'b01, s_Read = 2'b10, s_Stop = 2'b11;
    reg [1:0] state;
    reg [2:0] bit_indx;
    reg [3:0] count;

    integer i;

    reg [7:0] mem;

    always @(posedge tick or negedge rst) begin
        if (~rst) begin
            for(i=0; i<=7; i=i+1) begin
                mem[i]  <= 1'b0;
            end
            state       <= s_Idle;
            bit_indx    <= 'b0;
            count       <= 'b0;
            Rx_Done     <= 1'b0;
        end

        else begin
            case (state)
                s_Idle:
                begin
                    bit_indx    <= 'b0;
                    count       <= 'b0;
                    Rx_Done     <= 1'b0;
                    if(Rx_Serial == 1'b0) begin                    
                        state   <= s_Start;
                    end 
                    else begin
                        state   <= s_Idle;
                    end              
                end

                s_Start: begin
                    Rx_Done <= 1'b0;
                    count <= count + 1'b1;
                    if(count == (clk_div/2 - 1'b1)) begin
                        if (Rx_Serial == 1'b0) begin
                            state <= s_Read;
                            count <= 'b0;
                        end
                        else
                            state <= s_Idle;
                    end
                    else 
                        state     <= s_Start;
                end

                s_Read: begin
                    Rx_Done <= 1'b0;
                if (count == clk_div - 1'b1) begin
                    count   <= 'b0;

                    mem[bit_indx] <= Rx_Serial;

                    if (bit_indx == 3'd7) begin
                    state       <= s_Stop;         // all 8 data bits captured
                    end else begin
                    bit_indx    <= bit_indx + 1'b1;
                    state       <= s_Read;
                    end

                end else begin
                    count       <= count + 1'b1;     // keep counting toward the next baud edge
                    state       <= s_Read;
                end
                end

                s_Stop: begin 
                    // if(count == clk_div - 1'b1) begin
                        state   <= s_Idle;
                        Rx_Done <= 1'b1;
                        count <= 0;
                        data_out <= mem;
                    // end

                    // else begin
                    //     state <= s_Stop;
                    //     count <= count + 1'b1;
                    // end
                end
                default : state <= s_Idle;
                    
            endcase
        end      
    end
endmodule //uart_rx

