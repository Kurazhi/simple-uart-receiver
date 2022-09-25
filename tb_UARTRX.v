`timescale 1ns/100ps
module tb_UARTRX;
/*
    This module is to test the UART receiver by intializing it,
    testing a given input,
    check the idle state,
    then check another input,
    and repeats
*/


/* Declared input variables */
reg reset;
reg rx;
reg[7:0] INPUT;
reg tick;


/* Declared outputs */
wire[7:0] data;
wire done;

integer i; // Variable for loop

uartRX test(
    reset, 
    rx, 
    data, 
    tick, 
    done
);

/* Tick Clock */
always #1 tick = ~tick;

/* Main Testing Loop */
initial begin
    /* Initial Setup */
    tick = 0;
    rx = 1;
    reset = 1;

    #32; // 32 times for the 16x cycle that comes from the tick
    reset = 0;

    #32;
    INPUT = 8'b0011_0010;
    rx = 0;
    reset = 1;

    // put the LSB of INPUT into rx in every 32 ticks
    for (i=0; i < 8; i = i + 1) begin 
        #32 rx = INPUT[i];
    end
    #32 rx = 1; // Keep it idle by putting rx on high.
    $display("%b", data);
    #320;
    rx = 0;
    INPUT = 8'b1110_0101;

    for (i=0; i < 8; i = i + 1) begin 
        #32 rx = INPUT[i];
    end
    
    #32;
    $display("%b", data);
    rx = 1;
    INPUT = 8'b1111_1111;
    #32
    rx = 0;
    for (i=0; i < 8; i = i + 1) begin 
        #32 rx = INPUT[i];
    end

    #32;
    $display("%b", data);
    rx = 1;
    INPUT = 8'b1000_0000;

    #32;
    rx = 0;
    for (i=0; i < 8; i = i + 1) begin 
        #32 rx = INPUT[i];
    end
    
    #32;
    $display("%b", data);
    rx = 1;

    #64 $stop();

end

endmodule

