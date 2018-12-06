module timer(rst, clk,
	min, sec, msec,
	enable, zero, end_sig,
	im, dm, is, ds);
	input rst, clk;
	input enable, zero;
	input im, dm, is, ds;
	
	output [6:0] min, sec;
	output [9:0] msec;
	reg [6:0] min, sec;
	reg [9:0] msec;
	
	output end_sig;
	reg end_sig;
	
	reg f_m, df_m, f_s, df_s;
	
	integer cnt;

	always @(posedge clk) begin
		if (~rst) msec = 0;
		else begin
			if (enable) begin
				if (msec == 0) begin
					if ((min > 0) || (sec > 0))
						msec = 999;
				end
				else msec = msec - 1;
			end else if (zero) begin
				msec = 0;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) sec = 0;
		else begin
			if (enable && (msec == 0)) begin
				if (sec == 0) begin
					if (min > 0)
						sec = 59;
				end
				else sec = sec - 1;
			end else if (zero) begin
				sec = 0;
			end

			if (is) f_s = 1;
			else if (f_s) begin
				f_s = 0;
				if (sec == 59) sec = 0;
				else sec = sec + 1;
			end
			else if (ds) df_s = 1;
			else if (df_s) begin
				df_s = 0;
				if (sec == 0) sec = 59;
				else sec = sec -1;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) begin
			min = 15;
			f_m = 0;
		end
		else begin
			if (enable && (sec == 0) && (msec == 0)) begin
				if (min > 0) min = min - 1;
			end else if (zero) begin
				min = 0;
			end

			if (im) f_m = 1;
			else if (f_m) begin
				f_m = 0;
				if (min < 60)
					min = min + 1;
			end
			else if (dm) df_m = 1;
			else if (df_m) begin
				df_m = 0;
				if (min > 0)
					min = min - 1;
			end
		end
	end

	always @(posedge clk) begin
		if (~rst) begin
			end_sig = 0;
			cnt = 0;
		end
		else begin
			if ((sec == 0) && (msec == 0) && (min == 0) && enable) begin
				end_sig = 1;
				if (cnt >= 9999)
					end_sig = 0;
				else cnt = cnt + 1;
			end else if (~enable)
				cnt = 0;
		end
	end
endmodule
