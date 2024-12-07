`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clean_reminder_display
// Description: Display "CLEN" with blinking effect when cleaning is needed
// Author: Kong Yifan
// Create Date: 2024/12/07
//////////////////////////////////////////////////////////////////////////////////

module clean_reminder_display(
    input clk_500Hz,          // 500Hz clock for display scanning
    input rst_n,              // Active low reset
    input warning,            // Warning signal from clean_reminder
    output reg [3:0] seg_en,  // Segment enable signals
    output reg [7:0] seg_out  // Segment output signals
);

    // Internal registers
    reg [1:0] scan_cnt;       // Counter for display scanning
    reg [3:0] display_data;   // Current digit to display
    reg blink_state;          // Blinking state (on/off)
    reg [8:0] blink_counter;  // Counter for blinking effect

    // Character definitions for C, L, E, N
    localparam C = 4'b1100;   // Display pattern for 'C'
    localparam L = 4'b1101;   // Display pattern for 'L'
    localparam E = 4'b1110;   // Display pattern for 'E'
    localparam N = 4'b1111;   // Display pattern for 'N'

    // Blinking effect counter
    always @(posedge clk_500Hz or negedge rst_n) begin
        if (~rst_n) begin
            blink_counter <= 0;
            blink_state <= 0;
        end
        else if (warning) begin
            if (blink_counter == 9'd499) begin  // Toggle every 1 second (500Hz clock)
                blink_counter <= 0;
                blink_state <= ~blink_state;
            end
            else begin
                blink_counter <= blink_counter + 1;
            end
        end
        else begin
            blink_state <= 1;  // Always on when no warning
        end
    end

    // Display scanning counter
    always @(posedge clk_500Hz or negedge rst_n) begin
        if (~rst_n)
            scan_cnt <= 0;
        else
            scan_cnt <= scan_cnt + 1;
    end

    // Segment enable control
    always @(*) begin
        if (~rst_n)
            seg_en = 4'b1111;
        else if (warning && blink_state)
            case(scan_cnt)
                2'b00: seg_en = 4'b1110;
                2'b01: seg_en = 4'b1101;
                2'b10: seg_en = 4'b1011;
                2'b11: seg_en = 4'b0111;
            endcase
        else
            seg_en = 4'b1111;  // All segments off during blink
    end

    // Display content control
    always @(*) begin
        case(scan_cnt)
            2'b00: display_data = C;  // Display 'C'
            2'b01: display_data = L;  // Display 'L'
            2'b10: display_data = E;  // Display 'E'
            2'b11: display_data = N;  // Display 'N'
        endcase
    end

    // Seven-segment display decoder
    always @(*) begin
        if (~rst_n)
            seg_out = 8'b1111_1111;
        else if (warning && blink_state) begin
            case(display_data)
                C: seg_out = 8'b1100_0110;  // Pattern for 'C'
                L: seg_out = 8'b1110_0111;  // Pattern for 'L'
                E: seg_out = 8'b1000_0110;  // Pattern for 'E'
                N: seg_out = 8'b1101_0101;  // Pattern for 'N'
                default: seg_out = 8'b1111_1111;
            endcase
        end
        else
            seg_out = 8'b1111_1111;  // All segments off
    end

endmodule