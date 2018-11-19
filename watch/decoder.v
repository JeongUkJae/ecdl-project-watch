module decoder(bcd, dot, data);
	input [3:0] bcd;
	input dot;
	
	output [7:0] data;
	wire [7:0] data;
	
	reg [6:0] buffer;
	
	always @(bcd) begin
		case (bcd)
			4'b0000: buffer = 7'b1111110;
			4'b0001: buffer = 7'b0110000;
			4'b0010: buffer = 7'b1101101;
			4'b0011: buffer = 7'b1111001;
			4'b0100: buffer = 7'b0110011;
			4'b0101: buffer = 7'b1011011;
			4'b0110: buffer = 7'b1011111;
			4'b0111: buffer = 7'b1110000;
			4'b1000: buffer = 7'b1111111;
			4'b1001: buffer = 7'b1111011;
			default: buffer = 0;
		endcase
	end
	
	assign data = {buffer, dot};
endmodule
