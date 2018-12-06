module word_time(rst, change, name, 
			in_year, in_month, in_day, in_ap, in_hour, is_leap_year,
			year, month, day, ap, hour);
	input change;
	input rst;
	input [14:0] in_year;
	input [6:0] in_month, in_day, in_hour;
	input is_leap_year;
	input in_ap;
	
	output [47:0] name;
	output [14:0] year;
	output [6:0] month, day, hour;
	output ap;
	
	reg [47:0] name;
	reg [14:0] year;
	reg [6:0] month, day, hour;
	reg ap;
	
	integer diff;
	integer cnt;
	
	always @(diff, in_hour) begin
		if (diff < 0) begin
			if  (diff + in_hour >= 0) hour = in_hour + diff;
			else if (diff + in_hour + 12 >= 0) hour = in_hour + diff + 12;
			else hour = in_hour + diff + 24;
		end else begin
			if (diff + in_hour - 12 > 0) begin
				hour = in_hour + diff - 12;
			end else begin
				hour = in_hour + diff;
			end
		end
	end
	
	always @(diff, in_hour, in_ap) begin
		if (diff < 0) begin
			if (diff + in_hour >= 0) ap = in_ap;
			else if (diff + in_hour + 12 >= 0) ap = ~in_ap;
			else ap = in_ap;
		end else begin
			if (diff + in_hour - 12 > 0) ap = ~in_ap;
			else ap = in_ap;
		end
	end
	
	always @(diff, in_hour, in_ap, in_day, in_month, is_leap_year) begin
		if (diff < 0) begin
			if (diff + in_hour >= 0) day = in_day;
			else if (diff + in_hour + 12 >= 0) begin
				if (in_ap == 1) day = in_day;
				else begin
					if (in_day == 1) begin
						if (
							in_month == 1 ||
							in_month == 2 ||
							in_month == 4 ||
							in_month == 6 ||
							in_month == 8 ||
							in_month == 9 ||
							in_month == 11
						) day = 31;
						else if (
							month == 3
						) begin
							if (is_leap_year) day = 29;
							else day = 28;
						end else day = 30;
					end else day = in_day - 1;
				end
			end else begin
				if (in_day == 1) begin
					if (
						in_month == 1 ||
						in_month == 2 ||
						in_month == 4 ||
						in_month == 6 ||
						in_month == 8 ||
						in_month == 9 ||
						in_month == 11
					) day = 31;
					else if (
						month == 3
					) begin
						if (is_leap_year) day = 29;
						else day = 28;
					end
				end else day = in_day - 1;
			end
		end else begin
			if (diff + in_hour < 12) day = in_day;
			else begin
				if (in_ap == 0) day = in_day;
				else begin
					if (
						(
							(in_month == 1 ||
							in_month == 3  ||
							in_month == 5  ||
							in_month == 7  ||
							in_month == 8  ||
							in_month == 10  ||
							in_month == 12
							) && in_day == 31
						) ||
						(
							(
								in_month == 2
							) && (
								(is_leap_year && in_day == 29) ||
								(!is_leap_year && in_day == 28)
							)
						) ||
						(
							(
								in_month == 4 ||
								in_month == 6 ||
								in_month == 9 ||
								in_month == 11
							) && in_day == 30
						)
					) day = 1;
					else day = in_day + 1;
				end
			end
		end
	end
	
	always @(diff, in_hour, in_ap, in_day, in_month, is_leap_year) begin
		if (diff < 0) begin
			if (diff + in_hour >= 0) month = in_month;
			else if (diff + in_hour + 12 >= 0) begin
				if (in_ap == 1) month = in_month;
				else begin
					if (in_day == 1) begin
						if (in_month == 1) month = 12;
						else month = in_month - 1;
					end else month = in_month;
				end
			end else begin
				if (in_day == 1) begin
					if (in_month == 1) month = 12;
					else month = in_month - 1;
				end else month = in_month;
			end
		end else begin
			if (diff + in_hour < 12) month = in_month;
			else begin
				if (in_ap == 0) month = in_month;
				else begin
					if (
						(
							(in_month == 1 ||
							in_month == 3  ||
							in_month == 5  ||
							in_month == 7  ||
							in_month == 8  ||
							in_month == 10  ||
							in_month == 12
							) && in_day == 31
						) ||
						(
							(
								in_month == 2
							) && (
								(is_leap_year && in_day == 29) ||
								(!is_leap_year && in_day == 28)
							)
						) ||
						(
							(
								in_month == 4 ||
								in_month == 6 ||
								in_month == 9 ||
								in_month == 11
							) && in_day == 30
						)
					) begin
						if (in_month == 12) month = 1;
						else month = in_month + 1;
					end
					else month = in_month;
				end
			end
		end
	end
	
	always @(in_year, in_month, month) begin
		if (month == 1 && in_month == 12) begin
			year = in_year + 1;
		end else if (month == 12 & in_month == 1) begin
			year = in_year - 1;
		end else year = in_year;
	end
	
	always @(posedge change or negedge rst) begin
		if (~rst) begin
			cnt = 0;
		end else begin
			if (cnt == 6) cnt = 0;
			else cnt = cnt + 1;
		end
	end
	
	always @(cnt) begin
		case (cnt)
			// London
			0: begin
				name = {
					8'h6E,
					8'h6F,
					8'h64,
					8'h6E,
					8'h6F,
					8'h4C
				};
				diff = -9;
			end
			// Paris
			1: begin
				name = {
					8'h20,
					8'h73,
					8'h69,
					8'h72,
					8'h61,
					8'h50
				};
				diff = -8;
			end
			// Moscow
			2: begin
				name = {
					8'h77,
					8'h6F,
					8'h63,
					8'h73,
					8'h6F,
					8'h4D
				};
				diff = -6;
			end
			// Dubai
			3: begin
				name = {
					8'h20,
					8'h69,
					8'h61,
					8'h62,
					8'h75,
					8'h44
				};
				diff = -5;
			end
			// Seoul
			4: begin
				name = {
					8'h20,
					8'h6c,
					8'h75,
					8'h6f,
					8'h65,
					8'h53
				};
				diff = 0;
			end
			// Tokyo
			5: begin
				name = {
					8'h20,
					8'h6F,
					8'h79,
					8'h6b,
					8'h6f,
					8'h54
				};
				diff = 0;
			end
			// 
			default: begin
				name = {
					8'h79,
					8'h65,
					8'h6e,
					8'h64,
					8'h79,
					8'h53
				};
				diff = 2;
			end
		endcase
	end
	
endmodule
