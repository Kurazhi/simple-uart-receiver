`timescale 1ns/100ps
module tb_UARTRX;

reg reset;
reg rx;
wire[7:0] data;


reg[7:0] INPUT;

wire[2:0] state;

reg tick;
wire done;

integer i;

uartRX test(
    reset, 
    rx, 
    data, 
    tick, 
    done,
    state
);

always #1 tick = ~tick;

initial begin
    tick = 0;
    rx = 1;
    reset = 1;

    #32;
    reset = 0;

    #32;
    INPUT = 8'b1010_1010;
    rx = 0;
    reset = 1;

    for (i=0; i < 8; i = i + 1) begin
        #32 rx = INPUT[i];
    end
    #32 rx = 1;

    #64 $stop();

end



endmodule