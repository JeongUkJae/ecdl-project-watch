module datetimes(rst, clk,
					is_leap_year, year, month, day, ap, hour, min, sec,
					i_y, i_mo, i_d, i_a, i_h, i_m, i_s,
					d_y, d_mo, d_d, d_h, d_m, d_s);
	// ë¦¬ì…‹, ´ëŸ­
	input rst, clk;

	// cnt -> ´ëŸ­¸ê¸°„í•œ ë³€
	integer cnt;
	
	// ë¶ì´ë³€
	output ap;
	output [6:0] hour, min, sec;
	output [14:0] year;
	output [6:0] day, month;
	output is_leap_year;
	reg [14:0] year;
	reg [6:0] day, month;
	reg is_leap_year;
	
	reg ap;
	reg [6:0] hour, min, sec;

	// ë¶ì´ap ì¦ê  í˜¸
	input i_a, i_h, i_m, i_s;
	reg f_a, f_h, f_m, f_s;

	// ë¶ì´ap ê°ì†Œ  í˜¸
	input d_h, d_m, d_s;
	reg df_h, df_m, df_s;
	
	input i_y, i_mo, i_d;
	input d_y, d_mo, d_d;
	reg f_y, f_mo, f_d;
	reg df_y, df_mo, df_d;

	wire [3:0] y1000, y100, y10, y1;

	always @(posedge clk) begin
		// 1k1ì´ˆë ê³„ì‹ ˜ê¸° „í•´ ´ë ‡ê²0~999ë¡Œê²Œ 
		if (~rst) cnt = 0;
		else begin
			if (cnt >= 999) cnt = 0;
			else cnt = cnt + 1;
		end
	end
	
	always @(posedge clk) begin
		// ´ëŸ­ë§žì¶”ì´ë°”ê¿”ì¤
		if (~rst) sec = 0;
		else begin
			if (cnt == 999) begin
				if (sec >= 59) sec = 0;
				else sec = sec + 1;
			end else begin
				if (i_s) f_s = 1;
				else if (d_s) df_s = 1;
				else if (f_s) begin
					f_s = 0;
					if (sec >= 59) sec = 0;
					else sec = sec + 1;
				end
				else if (df_s) begin
					df_s = 0;
					if (sec == 0) sec = 59;
					else sec = sec - 1;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		// ´ëŸ­ë§žì¶”ë¶ë°”ê¿”ì¤
		if (~rst) min = 0;
		else begin
			if ( (cnt == 999) && (sec == 59) ) begin
				if (min >= 59) min = 0;
				else min = min + 1;
			end else begin
				if (i_m) f_m = 1;
				else if (d_m) df_m = 1;
				else if (f_m) begin
					f_m = 0;
					if (min >= 59) min = 0;
					else min = min + 1;
				end
				else if (df_m) begin
					df_m = 0;
					if (min == 0) min = 59;
					else min = min - 1;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		// ´ëŸ­ë§žì¶”œê°„ ë°”ê¿”ì¤
		if (~rst) hour = 0;
		else begin
			if ( (cnt == 999) && (min == 59) && (sec == 59) ) begin
				if (hour >= 11) hour = 0;
				else hour = hour + 1;
			end else begin
				if (i_h) f_h = 1;
				else if (d_h) df_h = 1;
				else if (f_h) begin
					f_h = 0;
					if (hour >= 11) hour = 0;
					else hour = hour + 1;
				end
				else if(df_h) begin
					df_h = 0;
					if (hour == 0) hour = 11;
					else hour = hour - 1;
				end
			end
		end
	end

	always @(posedge clk) begin
		// ´ëŸ­ë§žì¶”ap/pm ë°”ê¿”ì¤
		if (~rst) ap = 0;
		else begin
			if ( (cnt == 999) && (hour == 11) && (min == 59) && (sec == 59) ) begin
				ap = ~ap;
			end else begin
				if (i_a) f_a = 1;
				else if (f_a) begin
					f_a = 0;
					ap = ~ap;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) day = 7;
		else begin
			if ( (cnt == 999) && (ap == 1) && (hour == 11) && (min == 59) && (sec == 59) ) begin
				if (
						((month == 1 ||
							month == 3 ||
							month == 5 ||
							month == 7 ||
							month == 8 ||
							month == 10 ||
							month == 12) &&
							day == 31) ||
						((month == 2) &&
							(
								(day == 28 && !is_leap_year)||
								(day == 29)
							)) ||
						((month == 4 ||
							month == 6 ||
							month == 9 ||
							month == 11) &&
							day == 30)
					)
					day = 1;
				else day = day + 1;
			end else begin
				if (i_d) f_d = 1;
				else if (d_d) df_d = 1;
				else if (f_d) begin
					f_d = 0;

					if (
							((month == 1 ||
								month == 3 ||
								month == 5 ||
								month == 7 ||
								month == 8 ||
								month == 10 ||
								month == 12) &&
								day == 31) ||
							((month == 2) &&
								(
									(day == 28 && !is_leap_year)||
									(day == 29)
								)) ||
							((month == 4 ||
								month == 6 ||
								month == 9 ||
								month == 11) &&
								day == 30)
						)
						day = 1;
					else day = day + 1;
				end
				else if(df_d) begin
					df_d = 0;

					if ((month == 1 ||
								month == 3 ||
								month == 5 ||
								month == 7 ||
								month == 8 ||
								month == 10 ||
								month == 12) &&
								day == 1)
						day = 31;
					else if ((month == 2) &&
								(day == 1)) begin
						if (is_leap_year) day = 29;
						else day = 28;
					end 
					else if ((month == 4 ||
								month == 6 ||
								month == 9 ||
								month == 11) &&
								day == 1)
						day = 30;
					else day = day - 1;
				end
			end
		end
	end
	
	
	always @(posedge clk) begin
		if (~rst) month = 12;
		else begin
			if ( (cnt == 999) && (
						((month == 1 ||
							month == 3 ||
							month == 5 ||
							month == 7 ||
							month == 8 ||
							month == 10 ||
							month == 12) &&
							day == 31) ||
						((month == 2) &&
							((is_leap_year && day == 29) || 
								(!is_leap_year && day == 28))) ||
						((month == 4 ||
							month == 6 ||
							month == 9 ||
							month == 11) &&
							day == 30)
					) && (ap == 1) && (hour == 11) && (min == 59) && (sec == 59) ) begin
				if (month == 12) month = 1;
				else month = month + 1;
			end else begin
				if (i_mo) f_mo = 1;
				else if (d_mo) df_mo = 1;
				else if (f_mo) begin
					f_mo = 0;

					if (month == 12) month = 1;
					else month = month + 1;
				end
				else if(df_mo) begin
					df_mo = 0;

					if (month == 1) month = 12;
					else month = month - 1;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) year = 2018;
		else begin
			if ( (cnt == 999) && (month == 12) && (
						((month == 1 ||
							month == 3 ||
							month == 5 ||
							month == 7 ||
							month == 8 ||
							month == 10 ||
							month == 12) &&
							day == 31) ||
						((month == 2) &&
							day == 28) ||
						((month == 4 ||
							month == 6 ||
							month == 9 ||
							month == 11) &&
							day == 30)
					) && (ap == 1) && (hour == 11) && (min == 59) && (sec == 59) ) begin
				if (year == 9999) year = 0;
				else year = year + 1;
			end else begin
				if (i_y) f_y = 1;
				else if (f_y) begin
					f_y = 0;
					
					if (year == 9999) year = 1;
					else year = year + 1;
				end
				if (d_y) df_y = 1;
				else if (df_y) begin
					df_y = 0;
					
					if (year == 0) year = 9999;
					else year = year - 1;
				end
			end
		end
	end
	
	always @(year, y1000, y100, y10, y1) begin
		if (year % 4 == 0 && (!(y10 == 0 && y1 == 0) || ((y1000 * 10 + y100) % 4 == 0))) begin
			is_leap_year = 1;
		end else is_leap_year = 0;
	end
	
	sep4 y_sep(year, y1000, y100, y10, y1);
endmodule
