module watch(rst, clk, clk1m,
		buttons, switches,
		leds, piezo,
		lcd_rs, lcd_rw, lcd_e, lcd_data);
	// Î¶¨ÏÖã, ¥Îü≠, Î≤ÑÌäº, Î≤ÑÏä§ §ÏúÑÏπ
	input rst, clk, clk1m;
	input [7:0] buttons;
	input [7:0] switches;
	output [15:0] leds;
	wire [15:0] leds;
	output piezo;
	wire piezo;
	
	// am/pm Î∂Ï¥
	wire ap;
	wire [6:0] hour, min, sec;
	wire [3:0] h10, h1, m10, m1, s10, s1;
	reg i_a, i_h, i_m, i_s; // am/pm Î∂Ï¥Ï¶ùÍ ¥Îü≠
	reg d_h, d_m, d_s; // am/pm Î∂Ï¥Í∞êÏÜå ¥Îü≠
	
	// alarm
	wire a_ap;
	wire [6:0] a_hour, a_min;
	wire [3:0] a_h10, a_h1, a_m10, a_m1;
	reg a_i_a, a_i_h, a_i_m, a_d_h, a_d_m;
	
	// îÏùº
	wire is_leap_year;
	wire [14:0] year;
	wire [6:0] month, day;
	wire [3:0] y1000, y100, y10, y1, mo10, mo1, d10, d1;
	reg i_y, i_mo, i_d; // am/pm Î∂Ï¥Ï¶ùÍ ¥Îü≠
	reg d_y, d_mo, d_d; // am/pm Î∂Ï¥Í∞êÏÜå ¥Îü≠

	// stop watch
	wire [6:0] stop_watch_min, stop_watch_sec;
	wire [14:0] stop_watch_msec;
	wire [3:0] stop_watch_m10, stop_watch_m1, stop_watch_s10, stop_watch_s1,
					stop_watch_ms1000, stop_watch_ms100, stop_watch_ms10, stop_watch_ms1;
	reg stop_watch_zero, stop_watch_enable;
	reg stop_watch_enable_flag;
	
	// timer
	reg timer_im, timer_is, timer_dm, timer_ds;
	wire [6:0] timer_min, timer_sec;
	wire [14:0] timer_msec;
	wire [3:0] timer_m10, timer_m1, timer_s10, timer_s1,
					timer_ms1000, timer_ms100, timer_ms10, timer_ms1;
	reg timer_zero, timer_enable, timer_enable_flag;
	wire timer_end_sig;

	// world time
	wire [47:0] world_time_name;
	wire [14:0] wt_year;
	wire [3:0] wy1000, wy100, wy10, wy1, wmo10, wmo1, wd10, wd1;
	wire [3:0] wh10, wh1;
	wire [6:0] wt_month, wt_day;
	wire wt_ap;
	wire [6:0] wt_hour;
	reg world_time_change;

	// vfd display
	output lcd_rs, lcd_rw, lcd_e;
	output [7:0] lcd_data;

	wire lcd_e;
	wire lcd_rs, lcd_rw;
	wire [7:0] lcd_data;
	wire clk_100hz;

	wire led_active;

	// text-vfdòÌòÎäî ∞Ïù¥
	reg [127:0] line1_data, line2_data;

	// mode
	reg [2:0] mode;

	// for common using
	integer index;
	
	parameter mode_display = 3'b000,
			 mode_edit_time = 3'b001,
			 mode_edit_date = 3'b010,
			 mode_alarm = 3'b011,
			 mode_stop_watch = 3'b100,
			 mode_timer = 3'b101,
			 mode_world_time = 3'b110;
			 
	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			mode = mode_display;
		end
		else begin
			if (switches[0]) mode = mode_edit_time;
			else if (switches[1]) mode = mode_edit_date;
			else if (switches[2]) mode = mode_alarm;
			else if (switches[3]) mode = mode_stop_watch;
			else if (switches[4]) mode = mode_timer;
			else if (switches[5]) mode = mode_world_time;
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

				// Î∂Ï¥òÌ¥Í∏∞
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
			end else if (mode == mode_stop_watch) begin
				line1_data[40 +: 80] = {
					8'h68,
					8'h63,
					8'h74,
					8'h61,
					8'h57,
					8'h20,
					8'h70,
					8'h6f,
					8'h74,
					8'h53
				};
				line2_data[48 +: 72] = {
					{4'b0011, stop_watch_ms1},
					{4'b0011, stop_watch_ms10},
					{4'b0011, stop_watch_ms100},
					8'b00111010,
					{4'b0011, stop_watch_s1},
					{4'b0011, stop_watch_s10},
					8'b00111010,
					{4'b0011, stop_watch_m1},
					{4'b0011, stop_watch_m10}
				};
			end else if (mode == mode_timer) begin
				line1_data[80 +: 40] = {
					8'h72,
					8'h65,
					8'h6D,
					8'h69,
					8'h54
				};
				line2_data[48 +: 72] = {
					{4'b0011, timer_ms1},
					{4'b0011, timer_ms10},
					{4'b0011, timer_ms100},
					8'b00111010,
					{4'b0011, timer_s1},
					{4'b0011, timer_s10},
					8'b00111010,
					{4'b0011, timer_m1},
					{4'b0011, timer_m10}
				};
			end else if (mode == mode_world_time) begin
				line1_data[0 +: 48] = {world_time_name};
				line1_data[56 +: 64] = {
					{4'b0011, wd1},
					{4'b0011, wd10},
					8'b00101110,
					{4'b0011, wmo1},
					{4'b0011, wmo10},
					8'b00101110,
					{4'b0011, wy1},
					{4'b0011, wy10}
				};

				// Î∂Ï¥òÌ¥Í∏∞
				line2_data[40 +: 80] = {
						{4'b0011, s1},
						{4'b0011, s10},
						8'b00111010,
						{4'b0011, m1},
						{4'b0011, m10},
						8'b00111010,
						{4'b0011, wh1},
						{4'b0011, wh10},
						8'b00100000,
						8'b01001101 // M
					};
				if (wt_ap) // P
					line2_data[32 +: 8] = 8'b01010000;
				else // A
					line2_data[32 +: 8] = 8'b01000001;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) begin
			{	i_a, i_h, i_m, i_s, d_h, d_m, d_s,
				i_y, i_mo, i_d, d_y, d_mo, d_d} = 13'b0;
			{a_i_a, a_i_h, a_i_m, a_d_h, a_d_m} = 5'b0;
			{stop_watch_zero, stop_watch_enable} = 2'b0;
			stop_watch_enable_flag = 0;
			{timer_zero, timer_enable} = 2'b0;
			timer_enable_flag = 0;
			{ timer_im, timer_dm, timer_is, timer_ds } = 4'b0;
			world_time_change = 0;
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
			end else if (mode == mode_stop_watch) begin
				if (buttons[0]) begin
					if (~stop_watch_enable_flag) begin
						stop_watch_enable_flag = 1;
						stop_watch_enable = ~stop_watch_enable;
					end
				end
				else if (buttons[1]) stop_watch_zero = 1;
				else begin
					stop_watch_zero = 0;
					stop_watch_enable_flag = 0;
				end
			end else if (mode == mode_timer) begin
				if (buttons[0]) begin
					if (~timer_enable_flag) begin
						timer_enable_flag = 1;
						timer_enable = ~timer_enable;
					end
				end
				else if (buttons[1]) begin
					timer_zero = 1;
					timer_enable = 0;
					timer_enable_flag = 0;
				end
				else if (buttons[4]) timer_im = 1;
				else if (buttons[5]) timer_dm = 1;
				else if (buttons[6]) timer_is = 1;
				else if (buttons[7])	timer_ds = 1;
				else begin
					timer_zero = 0;
					timer_enable_flag = 0;
					{ timer_im, timer_dm, timer_is, timer_ds } = 4'b0;
				end
			end else if (mode == mode_world_time) begin
				world_time_change = buttons[0];
			end else begin
				{	i_a, i_h, i_m, i_s, d_h, d_m, d_s,
					i_y, i_mo, i_d, d_y, d_mo, d_d} = 13'b0;
				{a_i_a, a_i_h, a_i_m, a_d_h, a_d_m} = 5'b0;
				{stop_watch_zero, stop_watch_enable} = 2'b0;
				stop_watch_enable_flag = 0;
				{timer_zero, timer_enable} = 2'b0;
				timer_enable_flag = 0;
				{ timer_im, timer_dm, timer_is, timer_ds } = 4'b0;
				world_time_change = 0;
			end
		end
	end
	
	// Îß¥Îü≠ÎßàÎã§ úÍ∞Ñ Î∞õÏïÑ§Í∏∞
	datetimes dates_and_times(rst, clk,
					is_leap_year, year, month, day, ap, hour, min, sec,
					i_y, i_mo, i_d, i_a, i_h, i_m, i_s,
					d_y, d_mo, d_d, d_h, d_m, d_s);

	// Î∂Ï¥10/1 òÎàÑÍ∏
	sep s_sep(sec, s10, s1);
	sep m_sep(min, m10, m1);
	sep h_sep(hour, h10, h1);

	sep d_sep(day, d10, d1);
	sep mo_se(month, mo10, mo1);
	sep4 y_sep(year, y1000, y100, y10, y1);
	
	// ¥Îü≠ ùÏÑ±
	ten_clk clk100hz_g(rst, clk, clk_100hz);
	
	// alarm
	times_static hms_alarm(rst, clk,
					a_ap, a_hour, a_min,
					a_i_a, a_i_h, a_i_m,
					a_d_h, a_d_m);
	alarm a(rst, clk, switches[7],
			ap, hour, min,
			a_ap, a_hour, a_min,
			led_activate);
	sep a_m_sep(a_min, a_m10, a_m1);
	sep a_h_sep(a_hour, a_h10, a_h1);
	
	// stop watch
	stop_watch stop_watch1(rst, clk, stop_watch_enable, stop_watch_zero, stop_watch_min, stop_watch_sec, stop_watch_msec);
	sep s_m_sep(stop_watch_min, stop_watch_m10, stop_watch_m1);
	sep s_s_sep(stop_watch_sec, stop_watch_s10, stop_watch_s1);
	sep4 s_ms_sep(stop_watch_msec, stop_watch_ms1000, stop_watch_ms100, stop_watch_ms10, stop_watch_ms1);

	// timer
	timer timer1(rst, clk, timer_min, timer_sec, timer_msec, timer_enable, timer_zero, timer_end_sig, timer_im, timer_dm, timer_is, timer_ds);
	sep t_m_sep(timer_min, timer_m10, timer_m1);
	sep t_s_sep(timer_sec, timer_s10, timer_s1);
	sep4 t_ms_sep(timer_msec, timer_ms1000, timer_ms100, timer_ms10, timer_ms1);
	
	// world time
	word_time wt(rst, world_time_change, world_time_name,
				year, month, day, ap, hour, is_leap_year,
				wt_year, wt_month, wt_day, wt_ap, wt_hour);
	sep w_sep(wt_hour, wh10, wh1);
	sep4 wy_sep(wt_year, wy1000, wy100, wy10, wy1);
	sep wd_sep(wt_day, wd10, wd1);
	sep wmo_se(wt_month, wmo10, wmo1);

	// lcd, led
	lcd_decoder lcd(rst, clk, lcd_e, lcd_rs, lcd_rw, lcd_data, line1_data, line2_data);
	led_display led(rst, clk_100hz, leds, led_activate || timer_end_sig);
	piezo p(rst, clk1m, piezo, switches[6]);
endmodule
