module ten_clk(rst, clk, output_clk);
	input rst, clk;
	output output_clk;
	
	reg output_clk;
	integer cnt;
	
	always @(posedge clk) begin
		if (~rst) begin
			cnt = 0;
			output_clk = 0;
		end
		else begin
			if (cnt == 9) begin
				output_clk = ~output_clk;
				cnt = 0;
			end
			else begin
				cnt = cnt + 1;
			end
		end
	end
endmodule
