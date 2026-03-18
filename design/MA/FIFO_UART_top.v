`include "/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/FIFO.v"
`include "/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/UART.v"


module FIFO_UART_top(
    input clk, rst,
    input write_en,
    input [7:0] Tx_Din,
    input Rx_read_en,
    input Rx_Serial,

    output Tx_Serial, 
    output full_Rx, empty_Rx,
    output [7:0] FIFO_Rx_Dout
);

    wire Tx_Active;
    wire Tx_Done, Rx_Done, full_Tx, empty_Tx;
    wire [7:0] FIFO_Tx_Dout, Rx_Data;

    FIFO fifo_tx  (.clk(clk), .rst(rst), 
                    .data_in(Tx_Din), 
                    .write_en(write_en), 
                    .read_en(Tx_Done), 
                    .data_out(FIFO_Tx_Dout), 
                    .full(full_Tx), 
                    .empty(empty_Tx));
    
    
    FIFO fifo_rx  (.clk(clk), .rst(rst), 
                    .data_in(Rx_Data), 
                    .write_en(Rx_Done), 
                    .read_en(Rx_read_en), 
                    .data_out(FIFO_Rx_Dout), 
                    .full(full_Rx), 
                    .empty(empty_Rx));


    UART uart  (.clk(clk), .rst(rst), 

                .Tx_Drive(~empty_Tx), 
                .Tx_Data(FIFO_Tx_Dout),
                .Tx_Serial(Tx_Serial),
                .Tx_Active(Tx_Active),
                .Tx_Done(Tx_Done),

                .Rx_Serial(Rx_Serial),
                .Rx_Done(Rx_Done),
                .data_out(Rx_Data));

endmodule
