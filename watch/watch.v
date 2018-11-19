module watch(rst, clk, seg_com, seg_data);
	input rst, clk;
	output [3:0] seg_com;
	output [7:0] seg_data;
	
	reg [3:0] seg_com;
	wire [7:0] seg_data;
	
	integer cnt, cnt_scan;
	
	reg [6:0] min, sec;
	
	wire [3:0] m10, m1, s10, s1;
	reg [3:0] num;
	
	reg seg_dot;
	
	always @(posedge clk) begin
		if (~rst) cnt = 0;
		else begin
			if (cnt >= 999) cnt = 0;
			else cnt = cnt + 1;
		end
	end
	
	
	always @(posedge clk) begin
		if (~rst) sec = 0;
		else begin
			if (cnt == 999) begin
				if (sec >= 59) sec = 0;
				else sec = sec + 1;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) min = 0;
		else begin
			if ( (cnt == 999) && (sec == 59) ) begin
				if (min >= 59) min = 0;
				else min = min + 1;
			end
		end
	end
	
	
	always @(posedge clk) begin
		if (~rst) begin
			seg_dot = 0;
			seg_com = 8'b0;
			num = 0;
			cnt_scan = 0;
		end
		else begin
			if (cnt_scan >= 3) cnt_scan = 0;
			else cnt_scan = cnt_scan + 1;
			
			case (cnt_scan)
				0: begin
					num = m10;
					seg_dot = 1'b0;
					seg_com = 4'b0111;
				end
				1: begin
					num = m1;
					seg_dot = 1'b1;
					seg_com = 4'b1011;
				end
				2: begin
					num = s10;
					seg_dot = 1'b0;
					seg_com = 4'b1101;
				end
				3: begin
					num = s1;
					seg_dot = 1'b1;
					seg_com = 4'b1110;
				end
				default: begin
					num = 0;
					seg_dot = 1'b0;
					seg_com = 4'b1111;
				end
			endcase
		end
	end
	
	sep s_sep(sec, s10, s1);
	sep m_sep(min, m10, m1);
	
	decoder dec(num, seg_dot, seg_data);
endmodule
