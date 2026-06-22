`timescale 1ns/1ns
`default_nettype wire

module UART #(  parameter tick_div_tx = 4'd12, 
                parameter tick_div_rx = 4'd12,
                parameter dvsr = 16'd20) 
                (clk, rst, Tx_Drive, Tx_Data, Tx_Serial, Rx_Serial, Tx_Done, Rx_Done, data_out);

    input clk, rst, Tx_Drive, Rx_Serial;
    input [7:0] Tx_Data;

    output Tx_Serial, Tx_Done, Rx_Done;
    output [7:0] data_out;

    wire tick, Tx_Serial;
 
    uart_tx uart_tx (.Tx_Done(Tx_Done), .tick(clk), .Tx_Drive(Tx_Drive), .tick_div(tick_div_tx), .rst(rst), .Tx_Serial(Tx_Serial), .data_in(Tx_Data));

    uart_rx uart_rx (.tick(tick), .rst(rst), .Rx_Serial(Rx_Serial), .clk_div(tick_div_rx), .data_out(data_out), .Rx_Done(Rx_Done));

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

