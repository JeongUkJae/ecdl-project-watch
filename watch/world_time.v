module word_time(change, name, diff);
	input change;
	output [47:0] name;
	output [6:0] diff;
	
	reg [47:0] name;
	reg [6:0] diff;
	
	integer cnt;
	
	always @(posedge change) begin
		if (cnt == 10) cnt = 0;
		else cnt = cnt + 1;
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
			// Paris
			default: begin
				name = {
					8'h20,
					8'h73,
					8'h69,
					8'h72,
					8'h61,
					8'h50
				};
				diff = 0;
			end
		endcase
	end
	
endmodule
