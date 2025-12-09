module stopwatch(
    input clk, rst,
    input enable_mode, 
    input btn_start,
    input btn_reset,
    
    output reg [3:0] m_ten, m_one,
    output reg [3:0] s_ten, s_one,
    output reg [3:0] ms_ten, ms_one,
    output reg [3:0] lap_m10, lap_m1,
    output reg [3:0] lap_s10, lap_s1,
    output reg [3:0] lap_ms10, lap_ms1
    );
    
reg [18:0] cnt_div;
    wire tick_10ms;
    assign tick_10ms = (cnt_div == 10 - 1);

    always @(posedge clk or posedge rst) begin
        if(rst) cnt_div <= 0;
        else if(tick_10ms) cnt_div <= 0;
        else cnt_div <= cnt_div + 1;
    end

    // 버튼 원샷
    reg prev_start, prev_reset;
    wire start_pulse = btn_start & ~prev_start;
    wire reset_pulse = btn_reset & ~prev_reset;
    always @(posedge clk) begin
        prev_start <= btn_start;
        prev_reset <= btn_reset;
    end

    // 카운트
    reg running; 

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {m_ten, m_one, s_ten, s_one, ms_ten, ms_one} <= 0;
            {lap_m10, lap_m1, lap_s10, lap_s1, lap_ms10, lap_ms1} <= 0;
            running <= 0;
        end
        else if(enable_mode) begin 
            if(start_pulse) begin
                running <= ~running;
                if (running) begin
                    lap_m10 <= m_ten; lap_m1 <= m_one;
                    lap_s10 <= s_ten; lap_s1 <= s_one;
                    lap_ms10 <= ms_ten; lap_ms1 <= ms_one;
                end
            end
            
            // 리셋
            if(reset_pulse) begin
                running <= 0;
                {m_ten, m_one, s_ten, s_one, ms_ten, ms_one} <= 0;
                {lap_m10, lap_m1, lap_s10, lap_s1, lap_ms10, lap_ms1} <= 0;
            end
            
            // 시간 증가
            if(running && tick_10ms) begin
                if(ms_one == 9) begin
                    ms_one <= 0;
                    if(ms_ten == 9) begin
                        ms_ten <= 0;
                        if(s_one == 9) begin
                            s_one <= 0;
                            if(s_ten == 5) begin
                                s_ten <= 0;
                                if(m_one == 9) begin
                                    m_one <= 0;
                                    if(m_ten == 5) m_ten <= 0;
                                    else m_ten <= m_ten + 1;
                                end else m_one <= m_one + 1;
                            end else s_ten <= s_ten + 1;
                        end else s_one <= s_one + 1;
                    end else ms_ten <= ms_ten + 1;
                end else ms_one <= ms_one + 1;
            end
        end
    end
endmodule