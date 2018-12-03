module times(rst, clk,
					ap, hour, min, sec,
					i_a, i_h, i_m, i_s,
					d_h, d_m, d_s, 
					clk_day);
	// 리셋, 클럭
	input rst, clk;

	// cnt -> 클럭을 세기위한 변수
	integer cnt;
	
	// 시 분 초 변수
	output ap;
	output [6:0] hour, min, sec;
	reg ap;
	reg [6:0] hour, min, sec;

	// 시 분 초 ap 증가 신호
	input i_a, i_h, i_m, i_s;
	reg f_a, f_h, f_m, f_s;

	// 시 분 초 ap 감소 신호
	input d_h, d_m, d_s;
	reg df_h, df_m, df_s;
	
	// 날짜 클럭
	output clk_day;
	reg clk_day;

	always @(posedge clk) begin
		// 1k라 1초를 계신하기 위해 이렇게 0~999로 돌게 함
		if (~rst) cnt = 0;
		else begin
			if (cnt >= 999) cnt = 0;
			else cnt = cnt + 1;
		end
	end
	
	always @(posedge clk) begin
		// 클럭에 맞추어 초 바꿔줌
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
		// 클럭에 맞추어 분 바꿔줌
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
		// 클럭에 맞추어 시간 바꿔줌
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
		// 클럭에 맞추어 ap/pm 바꿔줌
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
		if (~rst) clk_day = 0;
		else begin
			if ( (cnt == 999) && (ap == 1) && (hour == 11) && (min == 59) && (sec == 59) ) begin
				clk_day = 1;
			end else clk_day = 0;
		end
	end
endmodule
