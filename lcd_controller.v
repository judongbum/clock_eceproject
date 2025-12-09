module lcd_controller(
    input clk, rst,     
    input h24, world_clock,
    input sw_stopwatch, sw_timer, sw_alarm_set,
    input alarm_enabled,
    input usa, england, spain, 
    input [3:0] stp_m10, stp_m1, stp_s10, stp_s1, stp_ms10, stp_ms1,
    input [3:0] set_m10, set_m1, set_s10, set_s1,
    input [3:0] al_h10, al_h1, al_m10, al_m1,

    output reg LCD_RS, LCD_RW, LCD_E,
    output reg [7:0] LCD_DATA
    );

    reg [31:0] lcd_clk_div = 0;
    wire lcd_tick;
    assign lcd_tick = (lcd_clk_div == 3 - 1);

    always @(posedge clk or posedge rst) begin
        if (rst) lcd_clk_div <= 0;
        else if (lcd_tick) lcd_clk_div <= 0;
        else lcd_clk_div <= lcd_clk_div + 1;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) LCD_E <= 0;
        else if (lcd_clk_div < 1) LCD_E <= 1; 
        else LCD_E <= 0;
    end

     // FSM
    reg [7:0] lcd_state = 0;
    reg [7:0] lcd_data_reg;
    reg lcd_rs_reg;
    reg [4:0] char_idx; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_state <= 0;
            LCD_RW <= 0; LCD_RS <= 0; LCD_DATA <= 8'h00;
            char_idx <= 0;
        end 
        else begin
            if (lcd_tick) begin 
                case (lcd_state)
                    0:  begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h38; lcd_state <= 1; end 
                    1:  begin lcd_state <= 2; end 
                    2:  begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h38; lcd_state <= 3; end 
                    3:  begin lcd_state <= 4; end
                    4:  begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h0C; lcd_state <= 5; end 
                    5:  begin lcd_state <= 6; end
                    6:  begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h01; lcd_state <= 7; end 
                    7:  begin lcd_state <= 8; end
                    8:  begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h06; lcd_state <= 9; end 
                    9:  begin lcd_state <= 10; end
                    
                    // Line 1
                    10: begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h80; char_idx <= 0; lcd_state <= 11; end 
                    
                    // Line 1 글자 쓰기
                    11: begin 
                        lcd_rs_reg <= 1;
                        if (sw_stopwatch) begin
                            case(char_idx)
                                0: lcd_data_reg <= "M"; 1: lcd_data_reg <= "O"; 2: lcd_data_reg <= "D"; 3: lcd_data_reg <= "E";
                                4: lcd_data_reg <= " "; 5: lcd_data_reg <= ":"; 6: lcd_data_reg <= " ";
                                7: lcd_data_reg <= "S"; 8: lcd_data_reg <= "T"; 9: lcd_data_reg <= "O"; 10: lcd_data_reg <= "P"; 
                                11: lcd_data_reg <= "W"; 12: lcd_data_reg <= "A"; 13: lcd_data_reg <= "T"; 14: lcd_data_reg <= "C"; 15: lcd_data_reg <= "H";
                            endcase
                        end
                        else if (sw_timer) begin
                            case(char_idx)
                                0: lcd_data_reg <= "M"; 1: lcd_data_reg <= "O"; 2: lcd_data_reg <= "D"; 3: lcd_data_reg <= "E";
                                4: lcd_data_reg <= " "; 5: lcd_data_reg <= ":"; 6: lcd_data_reg <= " ";
                                7: lcd_data_reg <= "T"; 8: lcd_data_reg <= "I"; 9: lcd_data_reg <= "M"; 10: lcd_data_reg <= "E"; 
                                11: lcd_data_reg <= "R"; 12: lcd_data_reg <= " "; 13: lcd_data_reg <= " "; 14: lcd_data_reg <= " "; 15: lcd_data_reg <= " ";
                            endcase
                        end
                        else if (sw_alarm_set) begin
                            case(char_idx)
                                0: lcd_data_reg <= "A"; 1: lcd_data_reg <= "L"; 2: lcd_data_reg <= "A"; 3: lcd_data_reg <= "R"; 
                                4: lcd_data_reg <= "M"; 5: lcd_data_reg <= " "; 6: lcd_data_reg <= "S"; 7: lcd_data_reg <= "E"; 
                                8: lcd_data_reg <= "T"; 9: lcd_data_reg <= " "; 10: lcd_data_reg <= ":"; 11: lcd_data_reg <= " "; 
                                12: lcd_data_reg <= (alarm_enabled) ? "O" : "O";
                                13: lcd_data_reg <= (alarm_enabled) ? "N" : "F";
                                14: lcd_data_reg <= (alarm_enabled) ? " " : "F";
                                15: lcd_data_reg <= " ";
                            endcase
                        end
                        else begin
                            case(char_idx)
                                0: lcd_data_reg <= "M"; 1: lcd_data_reg <= "O"; 2: lcd_data_reg <= "D"; 3: lcd_data_reg <= "E";
                                4: lcd_data_reg <= " "; 5: lcd_data_reg <= ":"; 6: lcd_data_reg <= " ";
                                7: lcd_data_reg <= (h24) ? "2" : "1";
                                8: lcd_data_reg <= (h24) ? "4" : "2"; 
                                9: lcd_data_reg <= "H"; 
                                10: lcd_data_reg <= " "; 11: lcd_data_reg <= "T"; 12: lcd_data_reg <= "Y"; 13: lcd_data_reg <= "P"; 14: lcd_data_reg <= "E"; 15: lcd_data_reg <= " ";
                            endcase
                        end
                        
                        if(char_idx < 15) char_idx <= char_idx + 1;
                        else lcd_state <= 12;
                    end

                    // Line 2
                    12: begin lcd_rs_reg <= 0; lcd_data_reg <= 8'hC0; char_idx <= 0; lcd_state <= 13; end 

                    // Line 2 글자 쓰기
                    13: begin
                        lcd_rs_reg <= 1;
                        
                        if (sw_stopwatch) begin
                            case(char_idx)
                                0: lcd_data_reg <= "L"; 1: lcd_data_reg <= "A"; 2: lcd_data_reg <= "P"; 
                                3: lcd_data_reg <= " "; 4: lcd_data_reg <= ":"; 5: lcd_data_reg <= " ";
                                
                                6: lcd_data_reg <= stp_m10 + "0"; 7: lcd_data_reg <= stp_m1 + "0";
                                8: lcd_data_reg <= ":"; // (.) -> (:)
                                9: lcd_data_reg <= stp_s10 + "0"; 10: lcd_data_reg <= stp_s1 + "0";
                                11: lcd_data_reg <= ":"; // (.) -> (:)
                                12: lcd_data_reg <= stp_ms10 + "0"; 13: lcd_data_reg <= stp_ms1 + "0";
                                14: lcd_data_reg <= " "; 15: lcd_data_reg <= " ";
                            endcase
                        end
                        else if (sw_timer) begin
                            case(char_idx)
                                0: lcd_data_reg <= "S"; 1: lcd_data_reg <= "E"; 2: lcd_data_reg <= "T"; 
                                3: lcd_data_reg <= " "; 4: lcd_data_reg <= ":"; 5: lcd_data_reg <= " ";
                                
                                6: lcd_data_reg <= set_m10 + "0"; 7: lcd_data_reg <= set_m1 + "0";
                                8: lcd_data_reg <= ":";
                                9: lcd_data_reg <= set_s10 + "0"; 10: lcd_data_reg <= set_s1 + "0";
                                
                                default: lcd_data_reg <= " "; 
                            endcase
                        end
                        else if (sw_alarm_set) begin
                            case(char_idx)
                                0: lcd_data_reg <= "T"; 1: lcd_data_reg <= "I"; 2: lcd_data_reg <= "M"; 3: lcd_data_reg <= "E"; 
                                4: lcd_data_reg <= " "; 5: lcd_data_reg <= ":"; 6: lcd_data_reg <= " ";
                                
                                7: lcd_data_reg <= al_h10 + "0"; 8: lcd_data_reg <= al_h1 + "0";
                                9: lcd_data_reg <= ":";
                                10: lcd_data_reg <= al_m10 + "0"; 11: lcd_data_reg <= al_m1 + "0";
                                
                                default: lcd_data_reg <= " ";
                            endcase
                        end
                        else begin
                            // 국가 표시
                            case(char_idx)
                                0: lcd_data_reg <= "Z"; 1: lcd_data_reg <= "O"; 2: lcd_data_reg <= "N"; 3: lcd_data_reg <= "E";
                                4: lcd_data_reg <= " "; 5: lcd_data_reg <= ":"; 6: lcd_data_reg <= " ";
                                default: begin
                                    if (world_clock && usa) begin
                                        case(char_idx)
                                            7: lcd_data_reg <= "U"; 8: lcd_data_reg <= "S"; 9: lcd_data_reg <= "A"; 10: lcd_data_reg <= " "; 
                                            11: lcd_data_reg <= "("; 12: lcd_data_reg <= "N"; 13: lcd_data_reg <= "Y"; 14: lcd_data_reg <= ")"; 15: lcd_data_reg <= " ";
                                        endcase
                                    end
                                    else if (world_clock && england) begin
                                        case(char_idx)
                                            7: lcd_data_reg <= "U"; 8: lcd_data_reg <= "K"; 9: lcd_data_reg <= " "; 10: lcd_data_reg <= "("; 
                                            11: lcd_data_reg <= "L"; 12: lcd_data_reg <= "O"; 13: lcd_data_reg <= "N"; 14: lcd_data_reg <= ")"; 15: lcd_data_reg <= " ";
                                        endcase
                                    end
                                    else if (world_clock && spain) begin
                                        case(char_idx)
                                            7: lcd_data_reg <= "S"; 8: lcd_data_reg <= "P"; 9: lcd_data_reg <= "A"; 10: lcd_data_reg <= "I"; 
                                            11: lcd_data_reg <= "N"; 12: lcd_data_reg <= " "; 13: lcd_data_reg <= " "; 14: lcd_data_reg <= " "; 15: lcd_data_reg <= " ";
                                        endcase
                                    end
                                    else begin
                                        case(char_idx)
                                            7: lcd_data_reg <= "K"; 8: lcd_data_reg <= "O"; 9: lcd_data_reg <= "R"; 10: lcd_data_reg <= "E"; 
                                            11: lcd_data_reg <= "A"; 12: lcd_data_reg <= " "; 13: lcd_data_reg <= " "; 14: lcd_data_reg <= " "; 15: lcd_data_reg <= " ";
                                        endcase
                                    end
                                end
                            endcase
                        end

                        if(char_idx < 15) char_idx <= char_idx + 1; 
                        else lcd_state <= 14; 
                    end

                    14: begin lcd_rs_reg <= 0; lcd_data_reg <= 8'h02; lcd_state <= 15; end 
                    15: begin lcd_state <= 10; end 
                    default: lcd_state <= 0;
                endcase
                
                LCD_RS <= lcd_rs_reg;
                LCD_DATA <= lcd_data_reg;
                LCD_RW <= 0; 
            end
        end
    end
endmodule