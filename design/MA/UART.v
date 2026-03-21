`default_nettype wire
`timescale 1ns/1ps

module uart_tx (
    input tick, Tx_Drive,
    input [7:0] data_in,
    input [3:0] tick_div,
    input rst,
    output reg Tx_Serial, Tx_Active, Tx_Done  
);

    reg [3:0] count;
    reg [2:0] bit_indx;

    parameter s_IDLE = 3'b000, s_START = 3'b001, s_DATA = 3'b010, s_STOP = 3'b011;
    reg [2:0] state = 3'b000;

    always @(posedge tick or negedge rst) begin
        if(!rst) begin
            state       <= s_IDLE;
            count       <= 'b0;
            Tx_Serial   <= 1'b1;
            Tx_Active   <= 1'b0;
            bit_indx    <= 'b0;
            Tx_Done     <= 1'b0;
        end
        else begin 
            case (state)
            s_IDLE: begin
                count       <= 'b0;
                Tx_Serial   <= 1'b1;
                Tx_Active   <= 1'b0;
                bit_indx    <= 'b0;
                Tx_Done     <= 1'b0;
                
                if(Tx_Drive) 
                    begin 
                        state       <= s_START;
                        Tx_Active   <= 1'b1;
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
                    Tx_Active   <= 1'b1;
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
                    Tx_Active <= 1'b0;
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


module uart_rx (
    input clk, tick, rst, Rx_Serial,
    input [3:0] clk_div,
    output reg Rx_Done,
    output reg [7:0] data_out
);

    parameter s_Idle = 2'b00, s_Start = 2'b01, s_Read = 2'b10, s_Stop = 2'b11;
    reg [1:0] state = 'b0;
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
            else count = count + 1;
    end        

endmodule



module UART #(  parameter tick_div_tx = 4'd12, 
                parameter tick_div_rx = 4'd12,
                parameter dvsr = 16'd20) 
                (clk, rst, Tx_Drive, Tx_Data, Tx_Serial, Tx_Active, Rx_Serial, Tx_Done, Rx_Done, data_out);

    input clk, rst, Tx_Drive, Rx_Serial;
    input [7:0] Tx_Data;

    output Tx_Serial, Tx_Active, Tx_Done, Rx_Done;
    output [7:0] data_out;

    wire tick;
    wire Rx_Data, Tx_Serial, Tx_Active;
 
    uart_tx uart_tx (.Tx_Done(Tx_Done), .tick(clk), .Tx_Drive(Tx_Drive), .tick_div(tick_div_tx), .rst(rst), .Tx_Serial(Tx_Serial), .Tx_Active(Tx_Active), .data_in(Tx_Data));

    uart_rx uart_rx (.clk(clk), .tick(tick), .rst(rst), .Rx_Serial(Rx_Serial), .clk_div(tick_div_tx), .data_out(data_out), .Rx_Done(Rx_Done));

    baud_gen baud_gen (.clk(clk), .rst(rst), .dvsr(dvsr), .tick(tick));

endmodule //UART





// module tb;

//     reg clk, clk_rx, rst, Tx_Drive;
//     reg [3:0] tick_div_tx;
//     reg [3:0] tick_div_rx;
//     reg [7:0] data_in;
//     reg Rx_Serial;

//     wire tick, Tx_Serial, Tx_Active, Tx_Done;
//     wire [7:0] data_out;

//     UART UART0 (
//         .clk(clk),
//         .rst(rst),
//         .Tx_Drive(Tx_Drive),
//         .Tx_Data(data_in),
//         .Tx_Serial(Tx_Serial),
//         .Tx_Active(Tx_Active),
//         .Rx_Serial(Rx_Serial),
//         .Tx_Done(Tx_Done),
//         .data_out(data_out),
//         .Rx_Done(Rx_Done), .tick(tick)
//     );

//     always #5 clk = ~clk;
//     always #5 clk_rx = ~clk_rx;

//     reg [31:0] memory [0:7];

//     integer i;

//     initial begin
//         memory[0] = 32'd14;
//         memory[1] = 32'd22;
//         memory[2] = 32'd48;
//         memory[3] = 32'd12;
//         memory[4] = 32'd54;
//         memory[5] = 32'd32;
//         memory[6] = 32'd64;
//         memory[7] = 32'd78;
//     end

//     reg [8:0] data;

//     initial
//     begin
//         clk = 1'b0;
//         rst = 1'b0;
//         i = 0;
//         // data = 9'd24;
//         Rx_Serial = 1'b1;

//         #7 rst = ~rst;

//         repeat(8) begin
//             for (integer j = 0; j <= 8; j = j+1) begin
//                 Rx_Serial = memory[i][j];
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//                 @(posedge tick);
//             end
//             i = i+1; 
//             Rx_Serial = 1'b1;
//             $display("Data = %0d", data_out);
//             @(posedge tick);
//             @(posedge tick);
//             @(posedge tick);
//             @(posedge tick);
//         end 

//         Rx_Serial = 1'b1;

//         // wait(Rx_Done);
//         @(posedge tick);
//         @(posedge tick);
//         @(posedge tick);

//         $finish;
//     end

//     // initial begin
//     //     $monitor("Data = %0d", data_out);
//     // end

//     initial
//     begin
//         $dumpfile("dump.vcd");
//         $dumpvars(0, tb);
//     end

// endmodule

