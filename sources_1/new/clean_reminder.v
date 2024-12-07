`timescale 1ns / 1ps
//  Module name: clean_reminder
//  Description: This module is used to detect if working time is over threshold, only works in standby state
//  Author: Kong Yifan
//  Create Date: 2024/12/06

module clean_reminder #(
    //hour threshold
    parameter [5:0] defalut_hour_threshold = 6'd10,
    parameter [5:0] defalut_min_threshold = 6'd0,
    parameter [5:0] defalut_sec_threshold = 6'd0
) (
    // Input ports
    input            clk,
    input is_standby,
    input            rst_n,
    input reg [5:0]      hour_threshold,
    input reg [5:0]      min_threshold,
    input reg [5:0]      sec_threshold,
    input [5:0]      working_hour,
    input [5:0]      working_min,
    input [5:0]      working_sec,
    // Output ports
    // Warning signal, 1 means warning, 0 means no warning
    output reg       warning
);

    // If no threshold is provided, use default values
    assign hour_threshold = (hour_threshold == 0) ? defalut_hour_threshold : hour_threshold;
    assign min_threshold = (min_threshold == 0) ? defalut_min_threshold : min_threshold;
    assign sec_threshold = (sec_threshold == 0) ? defalut_sec_threshold : sec_threshold;

    // Main logic
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            warning <= 0;
        end
        else begin
            // Check if at standby state (3'b001)
            if (is_standby) begin
                // Compare working time with threshold
                if ((working_hour > hour_threshold) ||
                    (working_hour == hour_threshold && working_min > min_threshold) ||
                    (working_hour == hour_threshold && working_min == min_threshold && working_sec > sec_threshold)) begin
                    warning <= 1;
                end
                else begin
                    warning <= 0;
                end
            end
            else begin
                warning <= 0;
            end
        end
    end

endmodule