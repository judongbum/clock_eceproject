module display_controller(
    input clk,
    input rst, 
    input [3:0] h_ten, h_one, 
    input [3:0] m_ten, m_one, 
    input [3:0] s_ten, s_one,
    input world_clock, use_alarm,
    input usa, england, spain,
    
    output reg [7:0] seg_com,  
    output reg [7:0] seg_data, 
    output reg [7:0] seg7
    );

    reg [19:0] seg_clk_div = 0;
    wire seg_scan_clk;
    
    assign seg_scan_clk = seg_clk_div[1]; 
    
    always @(posedge clk or posedge rst) begin
        if (rst) seg_clk_div <= 0;
        else seg_clk_div <= seg_clk_div + 1;
    end
    
    // 스캔 카운터
    reg [2:0] seg_scan_cnt = 0;
    
    always @(posedge seg_scan_clk or posedge rst) begin
        if (rst) seg_scan_cnt <= 0;
        else if (seg_scan_cnt == 5) seg_scan_cnt <= 0;
        else seg_scan_cnt <= seg_scan_cnt + 1;
    end

    reg [3:0] current_digit;

    always @(*) begin
        // 기본
        seg_data = 8'b1111_1111; 
        
        case (seg_scan_cnt)
            3'd0: begin
                seg_com = 8'b1101_1111; 
                current_digit = h_ten;
            end
            3'd1: begin
                seg_com = 8'b1110_1111;
                current_digit = h_one;
            end
            3'd2: begin
                seg_com = 8'b1111_0111;
                current_digit = m_ten;
            end
            3'd3: begin
                seg_com = 8'b1111_1011; 
                current_digit = m_one;
            end
            3'd4: begin
                seg_com = 8'b1111_1101; 
                current_digit = s_ten;
            end
            3'd5: begin
                seg_com = 8'b1111_1110; 
                current_digit = s_one;
            end
            default: begin
                seg_com = 8'b1111_1111;
                current_digit = 4'd0;
            end
        endcase
        
        // 숫자 디코딩
        case (current_digit)
            4'h0: seg_data[6:0] = ~7'b100_0000;
            4'h1: seg_data[6:0] = ~7'b111_1001;
            4'h2: seg_data[6:0] = ~7'b010_0100;
            4'h3: seg_data[6:0] = ~7'b011_0000;
            4'h4: seg_data[6:0] = ~7'b001_1001;
            4'h5: seg_data[6:0] = ~7'b001_0010;
            4'h6: seg_data[6:0] = ~7'b000_0010;
            4'h7: seg_data[6:0] = ~7'b111_1000;
            4'h8: seg_data[6:0] = ~7'b000_0000;
            4'h9: seg_data[6:0] = ~7'b001_0000;
            default: seg_data[6:0] = 7'b000_0000;
        endcase
        
        if (seg_scan_cnt == 3'd1 || seg_scan_cnt == 3'd3) 
             seg_data[7] = 1'b1;
        else 
             seg_data[7] = 1'b0;
             
    end 

    // 상태 LED (U, E, S)
    always @(posedge clk or posedge rst) begin
        if(rst) seg7 <= 8'b0000_0000; 
        else begin
            if(world_clock) begin
                if(usa)      
                    seg7 <= 8'b0011_1110; 
                else if(england) 
                    seg7 <= 8'b0111_1001; 
                else if(spain)   
                    seg7 <= 8'b0110_1101; 
                else 
                    seg7 <= 8'b0000_0000; 
            end
            else 
                seg7 <= 8'b0000_0000;
        end
    end

endmodule