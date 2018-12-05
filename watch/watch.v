module watch(rst, clk, buttons, switches, leds, lcd_rs, lcd_rw, lcd_e, lcd_data);
	// ë¦¬ì…‹, ´ëŸ­, ë²„íŠ¼, ë²„ìŠ¤ ¤ìœ„ì¹
	input rst, clk;
	input [7:0] buttons;
	input [7:0] switches;
	output [15:0] leds;
	wire [15:0] leds;
	
	// am/pm ë¶ì´
	wire ap;
	wire [6:0] hour, min, sec;
	wire [3:0] h10, h1, m10, m1, s10, s1;
	reg i_a, i_h, i_m, i_s; // am/pm ë¶ì´ì¦ê ´ëŸ­
	reg d_h, d_m, d_s; // am/pm ë¶ì´ê°ì†Œ ´ëŸ­
	
	wire clk_day;
	
	// alarm
	wire a_ap;
	wire [6:0] a_hour, a_min;
	wire [3:0] a_h10, a_h1, a_m10, a_m1;
	reg a_off;
	reg a_i_a, a_i_h, a_i_m, a_d_h, a_d_m;
	
	// ”ì¼
	wire [14:0] year;
	wire [6:0] month, day;
	wire [3:0] y1000, y100, y10, y1, mo10, mo1, d10, d1;
	reg i_y, i_mo, i_d; // am/pm ë¶ì´ì¦ê ´ëŸ­
	reg d_y, d_mo, d_d; // am/pm ë¶ì´ê°ì†Œ ´ëŸ­

	// vfd display
	output lcd_rs, lcd_rw, lcd_e;
	output [7:0] lcd_data;

	wire lcd_e;
	wire lcd_rs, lcd_rw;
	wire [7:0] lcd_data;
	wire clk_100hz;

	wire led_active;

	// text-vfd˜í˜ëŠ” °ì´
	reg [127:0] line1_data, line2_data;

	// mode
	reg [2:0] mode;

	// for common using
	integer index;
	
	parameter mode_display = 3'b000,
			 mode_edit_time = 3'b001,
			 mode_edit_date = 3'b010,
			 mode_alarm = 3'b011;

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			mode = mode_display;
		end
		else begin
			if (switches[0]) mode = mode_edit_time;
			else if (switches[1]) mode = mode_edit_date;
			else if (switches[2]) mode = mode_alarm;
			else mode = mode_display;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			for (index = 0; index < 127;index = index + 8) begin
				line1_data[index +: 8] = 8'b00100000;
				line2_data[index +: 8] = 8'b00100000;
			end
		end
		else begin
			for (index = 0; index < 127;index = index + 8) begin
				line1_data[index +: 8] = 8'b00100000;
				line2_data[index +: 8] = 8'b00100000;
			end

			if (mode == mode_edit_time ||
					mode == mode_edit_date || 
					mode == mode_display) begin
				if (mode == mode_edit_time) begin
					line2_data[0 +: 16] = {
							8'b00101001,
							8'b01000101
						};
				end
				else if (mode == mode_edit_date) begin
					line1_data[0 +: 16] = {
							8'b00101001,
							8'b01000101
					};
				end

				line1_data[40 +: 80] = {
					{4'b0011, d1},
					{4'b0011, d10},
					8'b00101110,
					{4'b0011, mo1},
					{4'b0011, mo10},
					8'b00101110,
					{4'b0011, y1},
					{4'b0011, y10},
					{4'b0011, y100},
					{4'b0011, y1000}
				};

				// ë¶ì´˜í´ê¸°
				line2_data[40 +: 80] = {
						{4'b0011, s1},
						{4'b0011, s10},
						8'b00111010,
						{4'b0011, m1},
						{4'b0011, m10},
						8'b00111010,
						{4'b0011, h1},
						{4'b0011, h10},
						8'b00100000,
						8'b01001101 // M
					};
				if (ap) // P
					line2_data[32 +: 8] = 8'b01010000;
				else // A
					line2_data[32 +: 8] = 8'b01000001;
			end else if (mode == mode_alarm) begin
				line1_data[80 +: 40] = {
					8'b01101101,
					8'b01110010,
					8'b01100001,
					8'b01101100,
					8'b01000001
				};
				line2_data[64 +: 56] = {
					{4'b0011, a_m1},
					{4'b0011, a_m10},
					8'b00111010,
					{4'b0011, a_h1},
					{4'b0011, a_h10},
					8'b00100000,
					8'b01001101 // M
				};
				
				if (a_ap) // P
					line2_data[56 +: 8] = 8'b01010000;
				else // A
					line2_data[56 +: 8] = 8'b01000001;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) begin
			{	i_a, i_h, i_m, i_s, d_h, d_m, d_s,
				i_y, i_mo, i_d, d_y, d_mo, d_d} = 13'b0;
			{a_i_a, a_i_h, a_i_m, a_d_h, a_d_m} = 5'b0;
		end
		else begin
			if (mode == mode_edit_time) begin
				if (buttons[0]) i_a = 1;
				else if (buttons[1]) i_h = 1;
				else if (buttons[5]) d_h = 1;
				else if (buttons[2]) i_m = 1;
				else if (buttons[6]) d_m = 1;
				else if (buttons[3]) i_s = 1;
				else if (buttons[7]) d_s = 1;
				else begin	
					{i_a, i_h, i_m, i_s, d_h, d_m, d_s} = 7'b0;
				end
			end else if(mode == mode_edit_date) begin
				if (buttons[1]) i_y = 1;
				else if (buttons[5]) d_y = 1;
				else if (buttons[2]) i_mo = 1;
				else if (buttons[6]) d_mo = 1;
				else if (buttons[3]) i_d = 1;
				else if (buttons[7]) d_d = 1;
				else
					{i_y, i_mo, i_d, d_y, d_mo, d_d} = 6'b0;
			end else if (mode == mode_alarm) begin
				if (buttons[0]) a_i_a = 1;
				else if (buttons[1]) a_i_h = 1;
				else if (buttons[5]) a_d_h = 1;
				else if (buttons[2]) a_i_m = 1;
				else if (buttons[6]) a_d_m = 1;
				else begin	
					{a_i_a, a_i_h, a_i_m, a_d_h, a_d_m} = 5'b0;
				end
			end else begin	
				{	i_a, i_h, i_m, i_s, d_h, d_m, d_s,
					i_y, i_mo, i_d, d_y, d_mo, d_d} = 13'b0;
				{a_i_a, a_i_h, a_i_m, a_d_h, a_d_m} = 5'b0;
			end
		end
	end
	
	// ë§´ëŸ­ë§ˆë‹¤ œê°„ ë°›ì•„¤ê¸°
	times hms(rst, clk,
					ap, hour, min, sec,
					i_a, i_h, i_m, i_s,
					d_h, d_m, d_s,
					clk_day);

	// ë¶ì´10/1 ˜ëˆ„ê¸
	sep s_sep(sec, s10, s1);
	sep m_sep(min, m10, m1);
	sep h_sep(hour, h10, h1);
	
	dates date_g(rst, clk_day, clk, day, month, year,
						i_y, i_mo, i_d,
						d_y, d_mo, d_d);
	sep d_sep(day, d10, d1);
	sep mo_se(month, mo10, mo1);
	sep4 y_sep(year, y1000, y100, y10, y1);
	
	// ´ëŸ­ ì„±
	ten_clk clk100hz_g(rst, clk, clk_100hz);
	
	// alarm
	times_static hms_alarm(rst, clk,
					a_ap, a_hour, a_min,
					a_i_a, a_i_h, a_i_m,
					a_d_h, a_d_m);
	alarm a(rst, clk, a_off,
			ap, hour, min,
			a_ap, a_hour, a_min,
			led_activate);
	sep a_m_sep(a_min, a_m10, a_m1);
	sep a_h_sep(a_hour, a_h10, a_h1);

	// lcd, led
	lcd_decoder lcd(rst, clk, lcd_e, lcd_rs, lcd_rw, lcd_data, line1_data, line2_data);
	led_display led(rst, clk_100hz, leds, led_active);
endmodule
