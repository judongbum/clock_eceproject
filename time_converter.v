module time_converter(
    input [3:0] h_ten, h_one, 
    input world_clock, h24,
    input usa, england, spain,
    
    output reg [3:0] disp_h_ten, disp_h_one,
    output reg am, pm
    );

    integer k_time; // 한국
    integer w_time; // 세계

    always @(*) begin
        k_time = h_ten * 10 + h_one;
        w_time = k_time; 

        // 세계 시간 계산
        if (world_clock) begin
            if (usa) begin      
                // 미국(뉴욕), -14
                w_time = k_time - 14;
                if (w_time < 0) w_time = w_time + 24; 
            end
            else if (england) begin 
                // 영국(런던), -9
                w_time = k_time - 9;
                if (w_time < 0) w_time = w_time + 24;
            end
            else if (spain) begin   
                // 스페인, -8
                w_time = k_time - 8;
                if (w_time < 0) w_time = w_time + 24;
            end
        end

        // 12H/24H 변환, AM/PM 변환 
        am = 0; 
        pm = 0;

        if (h24 || world_clock) begin
        
        end
        else begin
            // 12시간 모드
            if (w_time < 12) begin
                am = 1; pm = 0;
                if (w_time == 0) w_time = 12;
            end
            else begin
                am = 0; pm = 1;
                if (w_time > 12) w_time = w_time - 12;
            end
        end

        disp_h_ten = w_time / 10;
        disp_h_one = w_time % 10;
    end

endmodule