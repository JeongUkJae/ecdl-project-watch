module sep4(number, a, b, c, d);
	input [14:0] number;
	output [3:0] a, b, c, d;
	
	reg [3:0] a, b, c, d;

	wire [10:0] n100;
	wire [6:0] n10;
	
	assign n100 = number - (a * 1000);
	assign n10 = number - (a * 1000) - (b * 100);

	always @(number) begin
		if (number >= 9000) a = 9;
		else if (number >= 8000) a = 8;
		else if (number >= 7000) a = 7;
		else if (number >= 6000) a = 6;
		else if (number >= 5000) a = 5;
		else if (number >= 4000) a = 4;
		else if (number >= 3000) a = 3;
		else if (number >= 2000) a = 2;
		else if (number >= 1000) a = 1;
		else a = 0;
	end
	
	always @(n100) begin
		if (n100 >= 900) b = 9;
		else if (n100 >= 800) b = 8;
		else if (n100 >= 700) b = 7;
		else if (n100 >= 600) b = 6;
		else if (n100 >= 500) b = 5;
		else if (n100 >= 400) b = 4;
		else if (n100 >= 300) b = 3;
		else if (n100 >= 200) b = 2;
		else if (n100 >= 100) b = 1;
		else b = 0;
	end

	always @(n10) begin
		if (n10 <= 9) begin
			c = 3'b0;
			d = n10[3:0];
		end else if (n10 <= 19) begin
			c = 1; d = n10 - 10;
		end else if (n10 <= 29) begin
			c = 2; d = n10 - 20;
		end else if (n10 <= 39) begin
			c = 3; d = n10 - 30;
		end else if (n10 <= 49) begin
			c = 4; d = n10 - 40;
		end else if (n10 <= 59) begin
			c = 5; d = n10 - 50;
		end else if (n10 <= 69) begin
			c = 6; d = n10 - 60;
		end else if (n10 <= 79) begin
			c = 7; d = n10 - 70;
		end else if (n10 <= 89) begin
			c = 8; d = n10 - 80;
		end else if (n10 <= 99) begin
			c = 9; d = n10 - 90;
		end else begin
			c = 0;
			d = 0;
		end
	end
endmodule
