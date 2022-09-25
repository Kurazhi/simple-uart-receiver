module uartRX(
    reset,
    rx,
    data,
    tick,
    done
);
/*
    UART Receiver Module for 8 data bits with a start and stop bit.
    This module expects an input for the tick at the baud rate frequency x16.
    The data is kept until the next input begins
*/

input reset; // Input Reset to initalize receiver
input tick; // Baud Rate cycle with x16 oversampling
input rx; // Input RX


/* Output Registers for Module */
output reg[7:0] data;
output reg done;

/* Declared States for the FSM */ 
localparam[2:0]
    RESET = 3'd0,
    IDLE = 3'd1, // RX hasn't activated
    WORKING = 3'd2, // Data is being inputted
    DONE = 3'd3; // Data has finished calculating


reg [2:0] state; // Current state of FSM
reg [3:0] counter; // To keep track of the baudrate oversampling by 16x
reg [2:0] bits_read; // Count the number of bits that have been read

/* Next Registers*/
reg [2:0] next_state; 
reg [2:0] next_bits_read;
reg [7:0] next_data;

/* State Machine Logic */
always@(rx, counter) begin
    case(state)
        IDLE: begin
            //done = 1'b0;
            if(rx == 0 && counter == 4'd7) begin // Move the counter to the middle of a bit
                counter = 0;
                done = 1'b0;
                next_data = 7'd0;
                next_bits_read = 3'd0;
                next_state = WORKING;
            end
        end
        WORKING:
            if(counter == 4'd15) begin
                next_data = {rx, data[7:1]}; // Shift over the existing data we have and add the newest bit to the MSB
                next_bits_read = bits_read + 1;
                next_state = WORKING;
                if (bits_read + 1 == 4'b1000) begin
                    next_state = DONE;
                    next_bits_read = 3'd0;
                end
            end
        DONE: begin
            done = 1'b1;
            if(counter == 4'd15) begin
                //done = 1'b1;
                next_state = IDLE;
            end
        end
    endcase
end

/* DFF Next State logic */
always@(posedge tick) begin
    counter <= counter + 1;
    bits_read <= next_bits_read;
    state <= next_state;
    data <= next_data;
end


/* ASync Reset for the Receiver */
always@(negedge reset) begin // Didn't use clock to keep logic simple to the Baud Rate Tick
    next_state <= IDLE;
    counter <= 4'd0;
    next_data = 0;
    done <= 1;
end




endmodule