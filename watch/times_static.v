module times_static(rst, clk,
					ap, hour, min,
					i_a, i_h, i_m,
					d_h, d_m);
	// 리셋, �럭
	input rst, clk;

	// cnt -> �럭�기�한 변
	integer cnt;
	
	// ��변
	output ap;
	output [6:0] hour, min;
	reg ap;
	reg [6:0] hour, min;

	// ��ap 증� �호
	input i_a, i_h, i_m;
	reg f_a, f_h, f_m;

	// ��ap 감소 �호
	input d_h, d_m;
	reg df_h, df_m;

	always @(posedge clk) begin
		// �럭맞추�바꿔�
		if (~rst) min = 0;
		else begin
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
	
	always @(posedge clk) begin
		// �럭맞추�간 바꿔�
		if (~rst) hour = 0;
		else begin
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

	always @(posedge clk) begin
		// �럭맞추ap/pm 바꿔�
		if (~rst) ap = 0;
		else begin
			if (i_a) f_a = 1;
			else if (f_a) begin
				f_a = 0;
				ap = ~ap;
			end
		end
	end
endmodule
