module dates(rst, clk, clk1000,
					day, month, year,
					i_y, i_mo, i_d,
					d_y, d_mo, d_d);
	// 리셋, �럭
	input rst, clk, clk1000;

	input i_y, i_mo, i_d, d_y, d_mo, d_d;
	reg f_y, f_mo, f_d;
	reg df_y, df_mo, df_d;
	
	reg flag1,flag2,flag3,flag4;
	
	// �일
	output [14:0] year;
	output [6:0] day, month;
	reg [14:0] year;
	reg [6:0] day, month;
	reg is_leap_year;

	wire [3:0] y1000, y100, y10, y1;

	always @(posedge clk or negedge rst or posedge clk1000) begin
		// �럭맞추바꿔�
		if (~rst)  begin
			day = 5;
			f_d = 0;
			df_d = 0;
			flag1 = 0;
		end
		else begin
			if (clk) begin
				if (flag1 == 0) begin
					flag1 = 1;
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
			end
			else begin
				flag1 = 0;

				if (i_d) f_d = 1;
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
				
				if (d_d) df_d = 1;
				else if (df_d) begin
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
	
	always @(posedge clk or negedge rst or posedge clk1000) begin
		// �럭맞추바꿔�
		if (~rst) begin
			month = 12;
			f_mo = 0;
			df_mo = 0;
		end
		else begin
			if(clk) begin
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
							day == 28) ||
						((month == 4 ||
							month == 6 ||
							month == 9 ||
							month == 11) &&
							day == 30)
					) begin
					if (month == 12) month = 1;
					else month = month + 1;
				end
			end
			else begin
				if (i_mo) f_mo = 1;
				else if (f_mo) begin
					f_mo = 0;
					
					if (month == 12) month = 1;
					else month = month + 1;
				end
				
				if (d_mo) df_mo = 1;
				else if (df_mo) begin
					df_mo = 0;
					
					if (month == 1) month = 12;
					else month = month - 1;
				end
			end
		end
	end
	
	always @(posedge clk or negedge rst or posedge clk1000) begin
		// �럭맞추바꿔�
		if (~rst)  begin
			year = 2018;
			f_y = 0;
			df_y = 0;
		end
		else begin
			if (clk) begin
				if ( (month == 12) && (
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
					)) begin
					if (year == 9999) year = 1;
					else year = year + 1;
				end
			end
			else begin
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

	always @(year) begin
		if (year % 4 == 0 && (!(y10 == 0 && y1 == 0) || ((y1000 * 10 + y100) % 4 == 0))) begin
			is_leap_year = 1;
		end else is_leap_year = 0;
	end
	
	sep4 y_sep(year, y1000, y100, y10, y1);

endmodule
