module sep(number, a, b);
	input [6:0] number;
	output [3:0] a, b;
	
	reg [3:0] a, b;

	always @(number) begin
		if (number <= 9) begin
			a = 3'b0;
			b = number[3:0];
		end else if (number <= 19) begin
			a = 1; b = number - 10;
		end else if (number <= 29) begin
			a = 2; b = number - 20;
		end else if (number <= 39) begin
			a = 3; b = number - 30;
		end else if (number <= 49) begin
			a = 4; b = number - 40;
		end else if (number <= 59) begin
			a = 5; b = number - 50;
		end else if (number <= 69) begin
			a = 6; b = number - 60;
		end else if (number <= 79) begin
			a = 7; b = number - 70;
		end else if (number <= 89) begin
			a = 8; b = number - 80;
		end else if (number <= 99) begin
			a = 9; b = number - 90;
		end else begin
			a = 0;
			b = 0;
		end
	end
endmodule
