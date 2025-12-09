module time_counter(
    input clk,
    input rst,
    input tick_1hz,
    input adjust,   // 버튼1: 축 변경
    input up,       // 버튼2: 1 증가 
    input up_ten,   // 버튼3: 10 증가 
    
    output reg [3:0] cur_h_ten, cur_h_one,
    output reg [3:0] cur_m_ten, cur_m_one,
    output reg [3:0] cur_s_ten, cur_s_one,
    output reg [1:0] adjust_mode,
    output reg led4, led6, led8
    );
              // 버튼 엣지
    reg prev_adjust, prev_up, prev_up_ten;
    wire adjust_pulse, up_pulse, up_ten_pulse;

    always @(posedge clk) begin
        prev_adjust <= adjust;
        prev_up     <= up;
        prev_up_ten <= up_ten;
    end

    assign adjust_pulse = adjust & (~prev_adjust);
    assign up_pulse     = up & (~prev_up);
    assign up_ten_pulse = up_ten & (~prev_up_ten);

               // 수정 모드 변경
    always @(posedge clk or posedge rst) begin
        if(rst) adjust_mode <= 0;
        else if(adjust_pulse) begin
            if(adjust_mode >= 3) adjust_mode <= 0;
            else adjust_mode <= adjust_mode + 1;
        end
    end

    always @(*) begin
        case(adjust_mode)
            2'd0: {led4, led6, led8} = 3'b111; // 기본
            2'd1: {led4, led6, led8} = 3'b001; // 초
            2'd2: {led4, led6, led8} = 3'b010; // 분
            2'd3: {led4, led6, led8} = 3'b100; // 시
            default: {led4, led6, led8} = 3'b111;
        endcase
    end

               // 시간 카운트, 수정
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {cur_h_ten, cur_h_one} <= 0;
            {cur_m_ten, cur_m_one} <= 0;
            {cur_s_ten, cur_s_one} <= 0;
        end
        else begin
            if(adjust_mode == 0 && tick_1hz) begin
                if(cur_s_one == 9) begin
                    cur_s_one <= 0;
                    if(cur_s_ten == 5) begin
                        cur_s_ten <= 0;
                        if(cur_m_one == 9) begin
                            cur_m_one <= 0;
                            if(cur_m_ten == 5) begin
                                cur_m_ten <= 0;
                                if(cur_h_ten == 2 && cur_h_one == 3) begin
                                    cur_h_ten <= 0; cur_h_one <= 0;
                                end else if(cur_h_one == 9) begin
                                    cur_h_one <= 0; cur_h_ten <= cur_h_ten + 1;
                                end else begin
                                    cur_h_one <= cur_h_one + 1;
                                end
                            end else cur_m_ten <= cur_m_ten + 1;
                        end else cur_m_one <= cur_m_one + 1;
                    end else cur_s_ten <= cur_s_ten + 1;
                end else cur_s_one <= cur_s_one + 1;
            end

            else if(up_pulse) begin
                case(adjust_mode)
                    2'd1: begin // 초
                        if(cur_s_one == 9) begin
                             cur_s_one <= 0;
                             if(cur_s_ten == 5) cur_s_ten <= 0;
                              else cur_s_ten <= cur_s_ten + 1;
                        end else cur_s_one <= cur_s_one + 1;
                    end
                    2'd2: begin // 분
                        if(cur_m_one == 9) begin
                             cur_m_one <= 0;
                             if(cur_m_ten == 5) cur_m_ten <= 0; 
                             else cur_m_ten <= cur_m_ten + 1;
                        end else cur_m_one <= cur_m_one + 1;
                    end
                    2'd3: begin // 시
                        if(cur_h_ten == 2 && cur_h_one == 3) begin
                            cur_h_ten <= 0; cur_h_one <= 0;
                        end else if(cur_h_one == 9) begin
                            cur_h_one <= 0; cur_h_ten <= cur_h_ten + 1;
                        end else begin
                            cur_h_one <= cur_h_one + 1;
                        end
                    end
                endcase
            end

            else if(up_ten_pulse) begin
                case(adjust_mode)
                    // 초 +10초
                    2'd1: begin 
                        if(cur_s_ten >= 5) cur_s_ten <= 0;
                        else cur_s_ten <= cur_s_ten + 1;
                    end
                    
                    // 분 +10분 
                    2'd2: begin 
                        if(cur_m_ten >= 5) cur_m_ten <= 0;
                        else cur_m_ten <= cur_m_ten + 1;
                    end
                    
                    // 시 +10시간
                    2'd3: begin 
                        if(cur_h_ten == 2) begin
                            cur_h_ten <= 0;
                            cur_h_one <= cur_h_one + 6;
                        end
                        else if(cur_h_ten == 1 && cur_h_one >= 4) begin
                            cur_h_ten <= 0;
                            cur_h_one <= cur_h_one - 4;
                        end
                        else begin
                            cur_h_ten <= cur_h_ten + 1;
                        end
                    end
                endcase
            end
        end
    end

endmodule