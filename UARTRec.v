module uartRX(
    reset,
    rx,
    data,
    tick,
    done, state
);
/*
    UART Reciever Module for 8 data bits without parity.
    DataFrame = 1 start bit + 8 data bits + 1 stop bit.


*/
input reset;
input tick;
input rx;

output reg[7:0] data;
output reg done;

// Declared States for the FSM 
localparam[2:0]
    RESET = 3'd0,
    IDLE = 3'd1, 
    WORKING = 3'd2, 
    DONE = 3'd3;


output reg [2:0] state;
reg [3:0] counter; // To keep track of the sampling times
reg [2:0] bits_read; // Count the number of bits that have been read


/* Next Registers*/
reg [2:0] next_state; 
reg [2:0] next_bits_read;
reg [7:0] next_data;
//reg [3:0] next_counter;

// State Machine
always@(rx, counter) begin
    case(state)
        IDLE:
            if(rx == 0 && counter == 4'd7) begin
                counter = 0;
                done = 1'b0;
                next_data = 7'd0;
                next_bits_read = 3'd0;
                next_state = WORKING;
            end
        WORKING:
            if(counter == 4'd15) begin
                next_data = {rx, data[7:1]}; // Shift over the existing data we have and add the newest bit to the MSB
                next_bits_read = bits_read + 1;
                next_state = WORKING;
                if (bits_read + 1 == 4'b1000) begin
                    next_state = DONE;
                    next_bits_read = 3'd0;
                    done = 1'b0;
                end
            end
        DONE:
            if(counter == 4'd15) begin
                done = 1'b1;
                next_state = IDLE;
            end
    endcase
end

always@(posedge tick) begin
    counter <= counter + 1;
    bits_read <= next_bits_read;
    state <= next_state;
    data <= next_data;
end

always@(negedge reset) begin
    next_state <= IDLE;
    counter <= 4'd0;
    next_data = 0;
    done <= 1;
end




endmodule