module alarm(
    input clk, rst,
    input enable_set,
    input btn_min,
    input btn_hour,
    input btn_stop,
    input btn_toggle,
    input btn_clear,
    input [3:0] cur_h_ten, cur_h_one,
    input [3:0] cur_m_ten, cur_m_one,
    input [3:0] cur_s_ten, cur_s_one,
    
    output reg [3:0] al_h_ten, al_h_one,
    output reg [3:0] al_m_ten, al_m_one,
    output reg alarm_trigger, 
    output reg alarm_enabled  
    );

    // 버튼 원샷
    reg prev_min, prev_hour, prev_stop, prev_toggle, prev_clear;
    wire min_pulse    = btn_min    & ~prev_min;
    wire hour_pulse   = btn_hour   & ~prev_hour;
    wire stop_pulse   = btn_stop   & ~prev_stop;
    wire toggle_pulse = btn_toggle & ~prev_toggle;
    wire clear_pulse  = btn_clear  & ~prev_clear;

    always @(posedge clk) begin
        prev_min    <= btn_min;
        prev_hour   <= btn_hour;
        prev_stop   <= btn_stop;
        prev_toggle <= btn_toggle;
        prev_clear  <= btn_clear;
    end

    // 알람 시간 설정
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {al_h_ten, al_h_one, al_m_ten, al_m_one} <= 0;
            alarm_enabled <= 0; 
        end
        else begin
            if (toggle_pulse) alarm_enabled <= ~alarm_enabled;
            if(enable_set) begin
                if(clear_pulse) begin
                    {al_h_ten, al_h_one, al_m_ten, al_m_one} <= 0;
                end
                if(min_pulse) begin 
                    if(al_m_one == 9) begin al_m_one <= 0;
                    if(al_m_ten == 5) al_m_ten <= 0; 
                    else al_m_ten <= al_m_ten + 1; end 
                    else al_m_one <= al_m_one + 1;
                end
                if(hour_pulse) begin 
                     if(al_h_ten == 2 && al_h_one == 3) begin al_h_ten <= 0;
                     al_h_one <= 0; end 
                     else if(al_h_one == 9) begin al_h_one <= 0;
                     al_h_ten <= al_h_ten + 1; end 
                     else al_h_one <= al_h_one + 1;
                end
            end
        end
    end

    // 알람 울림
    reg is_ringing; 
    always @(posedge clk or posedge rst) begin
        if (rst) is_ringing <= 0;
        else begin
            if (!alarm_enabled || (is_ringing && stop_pulse)) is_ringing <= 0;
            else if (alarm_enabled && !enable_set && !is_ringing) begin
                if ({cur_h_ten, cur_h_one, cur_m_ten, cur_m_one} == {al_h_ten, al_h_one, al_m_ten, al_m_one} &&
                    cur_s_ten == 0 && cur_s_one == 0) is_ringing <= 1; 
            end
        end
    end
    always @(*) alarm_trigger = is_ringing;

endmodule