module piezo(rst, clk, piezo, enable);
	input rst, clk;
	input enable;

	output piezo;
	wire piezo;
	reg buff;

	reg [10:0] cnt_sound;
	reg [10:0] tone;
	reg [5:0] tone_cnt;
	reg [19:0] clk_cnt;
	
	assign piezo = buff;

	always @(tone_cnt)
		case (tone_cnt)
			0: tone = 957;
			1: tone = 957;
			2: tone = 1136;
			3: tone = 1436;
			4: tone = 1436;
			5: tone = 1923;
			6: tone = 1923;
			7: tone = 1923;

			8: tone = 1712;
			9: tone = 1436;
			10: tone = 1016;
			11: tone = 856;
			12: tone = 957;
			13: tone = 957;
			14: tone = 0;
			15: tone = 1136;
			
			16: tone = 1016;
			17: tone = 1282;
			18: tone = 1282;
			19: tone = 1016;
			20: tone = 1136;
			21: tone = 1436;
			22: tone = 0;
			23: tone = 1136;
			
			24: tone = 1282;
			25: tone = 1712;
			26: tone = 1524;
			27: tone = 1436;
			28: tone = 1282;
			29: tone = 1282;
			30: tone = 1282;
			31: tone = 1282;
			default: tone = 0;
		endcase 
	
	always @(posedge clk) begin
		if (~rst) begin
			tone_cnt = 0;
			clk_cnt = 0;
		end else begin
			if (enable) begin
				if (clk_cnt >= 200000) begin
					clk_cnt = 0;
					if (tone_cnt == 31) tone_cnt = 0;
					else tone_cnt = tone_cnt + 1;
				end
				else clk_cnt = clk_cnt + 1;
			end else begin
				clk_cnt = 0;
				tone_cnt = 0;
			end
		end
	end

	always @(posedge clk) begin
		if (~rst) begin
			buff = 0;
			cnt_sound = 0;
		end else begin
			if (enable) begin
				if (cnt_sound >= tone) begin
					cnt_sound = 0;
					buff = ~buff;
				end
				else cnt_sound = cnt_sound + 1;
			end else begin
				cnt_sound = 0;
				buff = 0;
			end
		end
	end
endmodule
