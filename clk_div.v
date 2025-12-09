module clk_div(
    input clk,
    input rst,
    output reg tick_1hz
    );
    parameter CLK_FREQ = 1000; 
    reg [31:0] cnt; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0;
            tick_1hz <= 0;
        end 
        else begin
            if (cnt >= CLK_FREQ - 1) begin
                cnt <= 0;
                tick_1hz <= 1;
            end 
            else begin
                cnt <= cnt + 1;
                tick_1hz <= 0; 
            end
        end
    end

endmodule