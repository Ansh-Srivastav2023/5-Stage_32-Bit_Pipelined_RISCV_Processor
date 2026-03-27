`default_nettype wire
`timescale 1fs/1fs

// dvsr = 434

module Testbench;

    reg clk, rst;

    wire Carry;
    wire Tx_Serial;
    wire [15:0] IO_OUT;

    wire tickx, Tx_Donex, Tx_Serialx, Tx_Activex;
    reg Tx_Drivex;
    reg [7:0] data_inx;


    Top_Module uut(.clk(clk), .async_rst(rst), .Rx_Serial(Tx_Serialx), .Carry(Carry), .Tx_Serial(Tx_Serial), .IO_OUT(IO_OUT));

    uart_tx_in_tb utit (.tick(tickx), 
                        .rst(rst),
                        .Tx_Drive(Tx_Drivex),
                        .data_in(data_inx),
                        .tick_div(4'd12),
                        .Tx_Serial(Tx_Serialx), 
                        .Tx_Active(Tx_Activex), 
                        .Tx_Done(Tx_Donex));

    baud_genx bgx ( .clk(clk), .rst(rst),
                    .dvsr(16'd20),
                    .tick(tickx));

    always #5 clk = ~clk;

    reg [31:0] instr_mem [0:511];
    reg [31:0] data_temp;

    initial begin
        $readmemh("instr_mem.mem", instr_mem);
    end


    wire signed [7:0] tx_data = uut.fifo_uart.uart.uart_tx.data_in;

    initial begin
        clk = 1'b1;
        rst = 1'b1;
        Tx_Drivex = 0;
        // data_inx = 8'h03;

        #2 rst = !rst;
        #2 rst = ~rst;


        repeat(50) begin
            @(posedge clk);
        end

        Tx_Drivex = 1'b1;
        for(integer i = 0; i <= instr_mem[0]; i= i+1) begin
            for (integer j = 0; j <= 24; j = j+8) begin
                data_temp = instr_mem[i] >> j;
                data_inx = data_temp[7:0];
                #5 @(posedge uut.fifo_uart.uart.uart_rx.Rx_Done);
                @(posedge tickx);
            end
        end

        Tx_Drivex = 1'b0;

        repeat(100) begin
            @(posedge clk);
        end


        wait (uut.instruction_IF == 32'h0000006f)
        wait (uut.fifo_uart.empty_Tx);
        
        @(posedge clk);
        @(posedge clk);

        // #20000;
        
        // rst = !rst;
        
        // #20 rst = !rst;

        // @(posedge clk);
        // @(posedge clk);
        // @(posedge clk);

        // Tx_Drivex = 1'b1;
        // for(integer i = 0; i <= instr_mem[0]; i= i+1) begin
        //     for (integer j = 0; j <= 24; j = j+8) begin
        //         data_temp = instr_mem[i] >> j;
        //         data_inx = data_temp[7:0];
        //         #5 @(posedge uut.fifo_uart.uart.uart_rx.Rx_Done);
        //         @(posedge tickx);
        //     end
        // end

        // Tx_Drivex = 1'b0;
        
        // wait (uut.instruction_IF == 32'h0000006f)
        // wait (uut.fifo_uart.empty_Tx);
        
        // @(posedge clk);
        // @(posedge clk);

        // #2000;

        $finish;
    end

    initial begin
        $monitor(//"instr = %h", uut.IDEX.instruction_ID,
    //             // "    x0 = %0d", uut.Register.register[0],
    //             "    x1 = %0d", uut.Register.register[1],
    //             "    x2 = %0d", uut.Register.register[2],
    //             "    x3 = %0d", uut.Register.register[3],
    //             // "    x4 = %0d", uut.Register.register[4],
    //             // "    x10 = %0d", uut.Register.register[10]
    //             // "Time = [%0t]" , $time,
                // "Tx Data = %c", $signed(uut.fifo_uart.uart.uart_tx.data_in)
                "Time = [%0t] | IO_OUT = %c", $time, IO_OUT[7:0]
    //             "    x10 = %0d", uut.Register.register[10]
    //             // "    x12 = %0d", uut.Register.register[12],  
    //             // "    x13 = %0d", uut.Register.register[13],  
    //             // "    x15 = %0d", uut.Register.register[15], 
    //             // "    LED = %0d",  uut.Data_Memory.main_ram[8192]
    //             // "    m1022 = %0d",  uut.Data_Memory.mem[1022], 
    //             // "    m1023 = %0d", uut.Data_Memory.mem[1023]
                );        
    end 


    initial begin
        $dumpfile("RISCV.vcd");
        $dumpvars(0);
    end

endmodule



module uart_tx_in_tb (
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
                if(count == tick_div -1) begin
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
            end
            endcase
        end
    end

endmodule



module baud_genx(
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
