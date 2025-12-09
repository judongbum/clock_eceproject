module clock(
    input clk,
    input rst,
    input adjust, up, up_ten,
    input h24, world_clock,
    input usa, england, spain,
    
    input sw_stopwatch,
    input sw_timer,
    input sw_alarm_set,
    
    input btn_stp_start,
    input btn_stp_reset,
    
    input btn_alarm_toggle,
    input btn_alarm_stop,
    
    output [7:0] seg_data, seg_com, seg7,
    output am, pm,
    output led4, led6, led8, 
    output LCD_RS, LCD_RW, LCD_E,
    output [7:0] LCD_DATA,
    output [3:0] rgb_r,
    output piezo_out 
    );

    wire tick_1hz;
    wire [1:0] adjust_mode;
    wire [3:0] cur_h_ten, cur_h_one, cur_m_ten, cur_m_one, cur_s_ten, cur_s_one;
    wire [3:0] disp_h_ten, disp_h_one; 
    wire [3:0] stp_m10, stp_m1, stp_s10, stp_s1, stp_ms10, stp_ms1;
    wire [3:0] stp_run_m10, stp_run_m1, stp_run_s10, stp_run_s1, stp_run_ms10, stp_run_ms1;
    wire [3:0] stp_lap_m10, stp_lap_m1, stp_lap_s10, stp_lap_s1, stp_lap_ms10, stp_lap_ms1;
    wire [3:0] tm_m10, tm_m1, tm_s10, tm_s1;
    wire [3:0] tm_set_m10, tm_set_m1, tm_set_s10, tm_set_s1;
    wire timer_alarm_on; 
    wire [3:0] al_h10, al_h1, al_m10, al_m1;
    wire real_alarm_trig; 
    wire alarm_is_on;     

    reg [3:0] final_h_ten, final_h_one, final_m_ten, final_m_one, final_s_ten, final_s_one;
                    // 하위모듈 
    clk_div u_clk_div( .clk(clk), .rst(rst), .tick_1hz(tick_1hz) );

    time_counter u_counter(
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .adjust( adjust & ~sw_stopwatch & ~sw_timer & ~sw_alarm_set ), 
        .up(     up     & ~sw_stopwatch & ~sw_timer & ~sw_alarm_set ), 
        .up_ten( up_ten & ~sw_stopwatch & ~sw_timer & ~sw_alarm_set ),
        .cur_h_ten(cur_h_ten), .cur_h_one(cur_h_one),
        .cur_m_ten(cur_m_ten), .cur_m_one(cur_m_one),
        .cur_s_ten(cur_s_ten), .cur_s_one(cur_s_one),
        .adjust_mode(adjust_mode),
        .led4(led4), .led6(led6), .led8(led8) 
    );

    time_converter u_converter(
        .h_ten(cur_h_ten), .h_one(cur_h_one),
        .world_clock(world_clock), .h24(h24),
        .usa(usa), .england(england), .spain(spain),
        .disp_h_ten(disp_h_ten), .disp_h_one(disp_h_one),
        .am(am), .pm(pm)
    );

    stopwatch u_stopwatch(
        .clk(clk), .rst(rst),
        .enable_mode(sw_stopwatch),
        .btn_start(btn_stp_start), .btn_reset(btn_stp_reset),
        .m_ten(stp_run_m10), .m_one(stp_run_m1),
        .s_ten(stp_run_s10), .s_one(stp_run_s1),
        .ms_ten(stp_run_ms10), .ms_one(stp_run_ms1),
        .lap_m10(stp_lap_m10), .lap_m1(stp_lap_m1),
        .lap_s10(stp_lap_s10), .lap_s1(stp_lap_s1),
        .lap_ms10(stp_lap_ms10), .lap_ms1(stp_lap_ms1)
    );

   timer u_timer(
        .clk(clk), .rst(rst),
        .enable_mode(sw_timer),
        .btn_start(adjust),
        .btn_min(up_ten),
        .btn_sec(up),
        .btn_clear(btn_stp_reset),
        .btn_stop_alarm(btn_alarm_stop),
        .tm_m10(tm_m10), .tm_m1(tm_m1), 
        .tm_s10(tm_s10), .tm_s1(tm_s1),
        .set_m10(tm_set_m10), .set_m1(tm_set_m1), 
        .set_s10(tm_set_s10),
        .set_s1(tm_set_s1),
        .alarm_on(timer_alarm_on)
    );
    
    alarm u_alarm(
        .clk(clk), .rst(rst),
        .enable_set(sw_alarm_set), 
        .btn_min(up),              
        .btn_hour(up_ten),         
        .btn_stop(btn_alarm_stop),     
        .btn_toggle(btn_alarm_toggle), 
        .btn_clear(btn_stp_reset),     
        .cur_h_ten(cur_h_ten), .cur_h_one(cur_h_one),
        .cur_m_ten(cur_m_ten), .cur_m_one(cur_m_one),
        .cur_s_ten(cur_s_ten), .cur_s_one(cur_s_one),
        .al_h_ten(al_h10), .al_h_one(al_h1),
        .al_m_ten(al_m10), .al_m_one(al_m1),
        .alarm_trigger(real_alarm_trig),
        .alarm_enabled(alarm_is_on) 
    );

    always @(*) begin
        if (sw_stopwatch) begin 
            final_h_ten = stp_run_m10;  final_h_one = stp_run_m1;
            final_m_ten = stp_run_s10;  final_m_one = stp_run_s1;
            final_s_ten = stp_run_ms10; final_s_one = stp_run_ms1;
        end
        else if (sw_timer) begin
            final_h_ten = 0;        final_h_one = 0;
            final_m_ten = tm_m10;   final_m_one = tm_m1;
            final_s_ten = tm_s10;   final_s_one = tm_s1;
        end
        else if (sw_alarm_set) begin
            final_h_ten = al_h10;   final_h_one = al_h1; 
            final_m_ten = al_m10;   final_m_one = al_m1;
            final_s_ten = 0;        final_s_one = 0;
        end
        else begin
            final_h_ten = disp_h_ten; final_h_one = disp_h_one;
            final_m_ten = cur_m_ten;  final_m_one = cur_m_one;
            final_s_ten = cur_s_ten;  final_s_one = cur_s_one;
        end
    end

                // 피에조
    reg [15:0] piezo_cnt;
    reg piezo_wave;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin piezo_cnt <= 0; piezo_wave <= 0; end
        else begin
            // 1kHz 입력 -> 매 클럭마다 토글하면 500Hz 소리 나옴
            // cnt가 필요 없음 (0일때 토글)
            piezo_wave <= ~piezo_wave; 
        end
    end
    
    assign piezo_out = (timer_alarm_on | real_alarm_trig) ? piezo_wave : 1'b0;

              // RGB
    reg [25:0] blink_cnt; 
    always @(posedge clk or posedge rst) begin
        if(rst) blink_cnt <= 0; else blink_cnt <= blink_cnt + 1;
    end
    wire blink_sig = blink_cnt[24]; 
    wire blink_red = (timer_alarm_on | real_alarm_trig) ? blink_sig : 1'b0; 
    assign rgb_r = {blink_red, blink_red, blink_red, blink_red}; 

    display_controller u_display(
        .clk(clk), .rst(rst),
        .h_ten(final_h_ten), .h_one(final_h_one),
        .m_ten(final_m_ten), .m_one(final_m_one),
        .s_ten(final_s_ten), .s_one(final_s_one),
        .world_clock(world_clock), .use_alarm(1'b0),
        .usa(usa), .england(england), .spain(spain),
        .seg_com(seg_com), .seg_data(seg_data), .seg7(seg7)
    );

    lcd_controller u_lcd(
        .clk(clk), .rst(rst),
        .h24(h24), .world_clock(world_clock),
        .sw_stopwatch(sw_stopwatch),
        .sw_timer(sw_timer),
        .sw_alarm_set(sw_alarm_set), 
        .alarm_enabled(alarm_is_on), 
        .usa(usa), .england(england), .spain(spain),
        .stp_m10(stp_lap_m10), .stp_m1(stp_lap_m1),
        .stp_s10(stp_lap_s10), .stp_s1(stp_lap_s1),
        .stp_ms10(stp_lap_ms10), .stp_ms1(stp_lap_ms1),
        .set_m10(tm_set_m10), .set_m1(tm_set_m1),
        .set_s10(tm_set_s10), .set_s1(tm_set_s1),
        .al_h10(al_h10), .al_h1(al_h1),
        .al_m10(al_m10), .al_m1(al_m1),
        .LCD_RS(LCD_RS), .LCD_RW(LCD_RW),
        .LCD_E(LCD_E), .LCD_DATA(LCD_DATA)
    );

endmodule