`include "/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/FIFO.v"
`include "/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/UART.v"


module FIFO_UART_top(
    input clk, rst,
    input write_en,
    input [7:0] data_in,

    output Tx_Serial, 
    output Tx_Done, Rx_Done,
    output full, empty
);

    wire Tx_Active;
    wire [7:0] FIFO_data_out, Rx_Data;

    FIFO fifo  (.clk(clk), .rst(rst), 
                .data_in(data_in), 
                .write_en(write_en), 
                .read_en(Tx_Done), 
                .data_out(FIFO_data_out), 
                .full(full), .empty(empty));

    UART uart  (.clk(clk), .rst(rst), 
                .Tx_Drive(~empty), 
                .Tx_Data(FIFO_data_out),
                .Tx_Serial(Tx_Serial),
                .Tx_Active(Tx_Active), 
                .Rx_Serial(1'b1), 
                .Tx_Done(Tx_Done), 
                .Rx_Done(Rx_Done),
                .data_out(Rx_Data));

endmodule
