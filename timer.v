module timer(
    input clk, rst,
    input enable_mode,
    input btn_start,
    input btn_min,
    input btn_sec,
    input btn_clear,
    input btn_stop_alarm,
    
    output reg [3:0] tm_m10, tm_m1,
    output reg [3:0] tm_s10, tm_s1,
    output reg [3:0] set_m10, set_m1,
    output reg [3:0] set_s10, set_s1,
    output reg alarm_on
    );

    // 1초 클럭 생성
    reg [31:0] cnt;
    wire tick_1hz;
    parameter CLK_FREQ = 1000;
    assign tick_1hz = (cnt == CLK_FREQ - 1);

    always @(posedge clk or posedge rst) begin
        if(rst) cnt <= 0;
        else if(cnt >= CLK_FREQ - 1) cnt <= 0; 
        else cnt <= cnt + 1;
    end

    // 버튼 원샷
    reg prev_start, prev_min, prev_sec, prev_clear, prev_stop;
    wire start_pulse = btn_start & ~prev_start;
    wire min_pulse   = btn_min   & ~prev_min;
    wire sec_pulse   = btn_sec   & ~prev_sec;
    wire clear_pulse = btn_clear & ~prev_clear;
    wire stop_pulse  = btn_stop_alarm & ~prev_stop;

    always @(posedge clk) begin
        prev_start <= btn_start; prev_min <= btn_min; prev_sec <= btn_sec;
        prev_clear <= btn_clear; prev_stop <= btn_stop_alarm;
    end

    // 타이머
    reg running; 
    wire is_zero = (tm_m10==0 && tm_m1==0 && tm_s10==0 && tm_s1==0);

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {tm_m10, tm_m1, tm_s10, tm_s1} <= 0;
            {set_m10, set_m1, set_s10, set_s1} <= 0;
            running <= 0; alarm_on <= 0;
        end
        else if(enable_mode) begin
            
            // 1 알람 끄기
            if (alarm_on && stop_pulse) begin 
                alarm_on <= 0; 
                running <= 0; 
            end
            // 2 리셋 (모두 0으로)
            else if (clear_pulse) begin
                {tm_m10, tm_m1, tm_s10, tm_s1} <= 0;
                {set_m10, set_m1, set_s10, set_s1} <= 0;
                running <= 0; alarm_on <= 0;
            end
            // 3 시간 설정 (멈춰있을 때)
            else if(!running && !alarm_on) begin
                
                // 분 증가
                if(min_pulse) begin 
                    if(tm_m1 == 9) begin 
                        tm_m1<=0; tm_m10<=tm_m10+1; 
                        set_m1<=0; set_m10<=set_m10+1; 
                    end 
                    else begin 
                        tm_m1 <= tm_m1 + 1;
                        set_m1 <= set_m1 + 1;          
                    end
                end
                
                // 10초 증가
                if(sec_pulse) begin 
                    if(tm_s10 == 5) begin
                        tm_s10 <= 0; 
                        set_s10 <= 0;                  
                    end 
                    else begin
                        tm_s10 <= tm_s10 + 1;
                        set_s10 <= set_s10 + 1;        
                    end
                    tm_s1 <= 0; set_s1 <= 0; 
                end
            end
            
            // 4 시작/정지 토글
            if(start_pulse && !alarm_on && !is_zero) running <= ~running;
            
            // 5 카운트다운
            if(running && tick_1hz) begin
                if(is_zero) begin 
                    running <= 0; 
                    alarm_on <= 1; 
                end
                else begin
                    if(tm_s1 == 0) begin
                        tm_s1 <= 9;
                        if(tm_s10 == 0) begin
                            tm_s10 <= 5;
                            if(tm_m1 == 0) begin
                                tm_m1 <= 9;
                                if(tm_m10 > 0) tm_m10 <= tm_m10 - 1;
                            end else tm_m1 <= tm_m1 - 1;
                        end else tm_s10 <= tm_s10 - 1;
                    end else tm_s1 <= tm_s1 - 1;
                end
            end
        end
        else begin 
            alarm_on <= 0; 
            running <= 0; 
        end
    end
endmodule