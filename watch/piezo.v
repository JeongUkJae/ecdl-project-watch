module piezo(rst, clk, piezo, enable);
	input rst, clk;
	input enable;

	output piezo;
	reg piezo;

	integer cnt_sound;
	integer cnt;
	integer tone;
	integer tone_cnt;
	integer clk_cnt;
	
	/* initial begin
		tones[0] = 1915; C
		tones[1] = 2032; D
		tones[2] = 2272; E
		tones[3] = 2564; F
		tones[4] = 2873; G
		tones[5] = 3048; A
		tones[6] = 3424; B
		tones[7] = 3846; C
		
		cnt = 0;
	end*/
	
	always @(posedge clk) begin
		if (~rst) begin
			tone = 0;
			tone_cnt = 0;
			clk_cnt = 0;
		end else begin
			if (enable) begin
				case (tone_cnt)
					0: tone = 3846;
					1: tone = 3846;
					2: tone = 3048;
					3: tone = 2564;
					4: tone = 2564;
					5: tone = 1915;
					6: tone = 1915;
					7: tone = 1915;
					default: tone = 0;
				endcase
			
				if (clk_cnt == 62500) begin
					clk_cnt = 0;
					tone_cnt = tone_cnt + 1;
				end
				else clk_cnt = clk_cnt + 1;
			end
		end
	end
	
	always @(posedge clk) begin
		if (~rst) begin
			piezo = 0;
			cnt_sound = 0;
		end else begin
			if (enable) begin
				if (cnt_sound >= tone) begin
					piezo = ~piezo;
					cnt_sound = 0;
				end
				else cnt_sound = cnt_sound + 1;
			end
		end
	end
endmodule
