module dates(rst, clk, day, month, year, day_of_week);
	// 리셋, 클럭
	input rst, clk;
	
	// 년 월 일 요일
	output [14:0] year;
	output [6:0] day, month, day_of_week;
	reg [14:0] year;
	reg [6:0] day, month, day_of_week;
	
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
						day == 28) ||
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
			day_of_week = 0;
		end
	end

endmodule
