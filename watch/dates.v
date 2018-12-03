module dates(rst, clk, day, month, year, day_of_week);
	// 리셋, 클럭
	input rst, clk;
	
	// 년 월 일 요일
	output [14:0] year;
	output [6:0] day, month, day_of_week;
	reg [14:0] year;
	reg [6:0] day, month, day_of_week;
	reg [22:0] total_days;
	reg is_leap_year;
	integer index;
	integer days_of_month [11:0];
	
	initial begin
		days_of_month[0] = 31;
		days_of_month[1] = 28;
		days_of_month[2] = 31;
		days_of_month[3] = 30;
		days_of_month[4] = 31;
		days_of_month[5] = 30;
		days_of_month[6] = 31;
		days_of_month[7] = 31;
		days_of_month[8] = 30;
		days_of_month[9] = 31;
		days_of_month[10] = 30;
		days_of_month[11] = 31;
	end

	always @(posedge clk or negedge rst) begin
		// 클럭에 맞추어 날 바꿔줌
		if (~rst) day = 1;
		else begin
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
	
	always @(posedge clk or negedge rst) begin
		// 클럭에 맞추어 월 바꿔줌
		if (~rst) month = 1;
		else begin
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
	end
	
	always @(posedge clk or negedge rst) begin
		// 클럭에 맞추어 년 바꿔줌
		if (~rst) year = 2000;
		else begin
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
				year = year + 1;
			end
		end
	end

	always @(posedge clk) begin
		// 클럭에 맞추어 요일 바꿔줌
		if (~rst) day_of_week = 0;
		else begin
			total_days = 365 * (year - 1) + (year / 4 - year / 100 + year / 400);
			for (index = 0;index < month;index = index + 1) 
				total_days = total_days + days_of_month[index];

			if (is_leap_year && month > 2) total_days = total_days + 1;
			total_days = total_days + day;

			day_of_week = total_days % 7;
		end
	end

	always @(posedge clk) begin
		is_leap_year = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
	end

endmodule
