module alarm(rst, clk, off,
			ap, hour, min,
			a_ap, a_hour, a_min,
			active);
	input rst, off, clk;

	input ap, a_ap;
	input [6:0] hour, min, a_hour, a_min;

	output active;
	reg active;

	always @(clk) begin
		if (~rst)
			active = 0;
		else begin
			if (ap == a_ap && hour == a_hour && min == a_min) begin
				active = 1;
			end else if (off) begin
				active = 0;
			end
		end
	end
endmodule
