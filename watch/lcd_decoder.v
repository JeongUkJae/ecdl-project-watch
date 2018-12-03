module lcd_decoder(rst, clk, lcd_e, lcd_rs, lcd_rw, lcd_data, line1_data, line2_data);
	input rst, clk;
	input [127:0] line1_data, line2_data;
	
	output lcd_e, lcd_rs, lcd_rw;
	output [7:0] lcd_data;

	reg [2:0] state;
	reg lcd_rs, lcd_rw;
	reg [7:0] lcd_data;
	wire lcd_e;

	parameter delay = 3'b000,
             function_set = 3'b001,
             entry_mode = 3'b010,
             disp_onoff = 3'b011,
             line1 = 3'b100,
             line2 = 3'b101,
             delay_t = 3'b110,
             clear_disp = 3'b111;
	
	integer cnt;
	
	always @(negedge rst or posedge clk) begin
		if (~rst)
			state = delay;
		else begin
			case (state)
			  delay: if (cnt == 70) state = function_set;
			  function_set: if (cnt == 30) state = disp_onoff;
			  disp_onoff: if (cnt == 30) state = entry_mode;
			  entry_mode: if (cnt == 30) state = clear_disp;
			  clear_disp: if (cnt == 20) state = line1;
			  line1: if (cnt == 20) state = line2;
			  line2: if (cnt == 20) state = delay_t;
			  delay_t: if (cnt == 60) state = line1;
			  default: state = delay;
			endcase
		end
	end

	always @(negedge rst or posedge clk) begin
		if (~rst) cnt = 0;
		else
			case (state)
				delay:
					if (cnt >= 70) cnt = 0;
					else cnt = cnt + 1;
				function_set:
					if (cnt >= 30) cnt = 0;
					else cnt = cnt + 1;
				disp_onoff:
					if (cnt >= 30) cnt = 0;
					else cnt = cnt + 1;
				entry_mode:
					if (cnt >= 30) cnt = 0;
					else cnt = cnt + 1;
				line1:
					if (cnt >= 20) cnt = 0;
					else cnt = cnt + 1;
				line2:
					if (cnt >= 20) cnt = 0;
					else cnt = cnt + 1;
				delay_t:
					if (cnt >= 60) cnt = 0;
					else cnt = cnt + 1;
				clear_disp:
					if (cnt >= 20) cnt = 0;
					else cnt = cnt + 1;
				default: cnt = 0;
			endcase
	end
	
	always @(negedge rst or posedge clk) begin
		if (~rst) begin
			lcd_rs = 1;
			lcd_rw = 1;
			lcd_data = 0;
		end
		else begin
			case (state)
				function_set: begin
					lcd_rs = 0;
					lcd_rw = 0;
					lcd_data = 8'b00111100;
				end
				disp_onoff: begin
					lcd_rs = 0;
					lcd_rw = 0;
					lcd_data = 8'b00001100;
				end
				entry_mode: begin
					lcd_rs = 0;
					lcd_rw = 0;
					lcd_data = 8'b00001100;
				end
				line1: begin
					lcd_rw = 0;
					case (cnt)
						0: begin
							lcd_rs = 0;
							lcd_data = 8'b10000000;
						end
						1: begin
							lcd_rs = 1;
							lcd_data = line1_data[7:0];
						end
						2: begin
							lcd_rs = 1;
							lcd_data = line1_data[15:8];
						end
						3: begin
							lcd_rs = 1;
							lcd_data = line1_data[23:16];
						end
						4: begin
							lcd_rs = 1;
							lcd_data = line1_data[31:24];
						end
						5: begin
							lcd_rs = 1;
							lcd_data = line1_data[39:32];
						end
						6: begin
							lcd_rs = 1;
							lcd_data = line1_data[47:40];
						end
						7: begin
							lcd_rs = 1;
							lcd_data = line1_data[55:48];
						end
						8: begin
							lcd_rs = 1;
							lcd_data = line1_data[63:56];
						end
						9: begin
							lcd_rs = 1;
							lcd_data = line1_data[71:64];
						end
						10: begin
							lcd_rs = 1;
							lcd_data = line1_data[79:72];
						end
						11: begin
							lcd_rs = 1;
							lcd_data = line1_data[87:80];
						end
						12: begin
							lcd_rs = 1;
							lcd_data = line1_data[95:88];
						end
						13: begin
							lcd_rs = 1;
							lcd_data = line1_data[103:96];
						end
						14: begin
							lcd_rs = 1;
							lcd_data = line1_data[111:104];
						end
						15: begin
							lcd_rs = 1;
							lcd_data = line1_data[119:112];
						end
						16: begin
							lcd_rs = 1;
							lcd_data = line1_data[127:120];
						end
						default: begin
							lcd_rs = 1;
							lcd_data = 8'b00100000;
						end
					endcase
				end
				line2: begin
					lcd_rw = 0;
					lcd_rw = 0;
					case (cnt)
						0: begin
							lcd_rs = 0;
							lcd_data = 8'b11000000;
						end
						1: begin
							lcd_rs = 1;
							lcd_data = line2_data[7:0];
						end
						2: begin
							lcd_rs = 1;
							lcd_data = line2_data[15:8];
						end
						3: begin
							lcd_rs = 1;
							lcd_data = line2_data[23:16];
						end
						4: begin
							lcd_rs = 1;
							lcd_data = line2_data[31:24];
						end
						5: begin
							lcd_rs = 1;
							lcd_data = line2_data[39:32];
						end
						6: begin
							lcd_rs = 1;
							lcd_data = line2_data[47:40];
						end
						7: begin
							lcd_rs = 1;
							lcd_data = line2_data[55:48];
						end
						8: begin
							lcd_rs = 1;
							lcd_data = line2_data[63:56];
						end
						9: begin
							lcd_rs = 1;
							lcd_data = line2_data[71:64];
						end
						10: begin
							lcd_rs = 1;
							lcd_data = line2_data[79:72];
						end
						11: begin
							lcd_rs = 1;
							lcd_data = line2_data[87:80];
						end
						12: begin
							lcd_rs = 1;
							lcd_data = line2_data[95:88];
						end
						13: begin
							lcd_rs = 1;
							lcd_data = line2_data[103:96];
						end
						14: begin
							lcd_rs = 1;
							lcd_data = line2_data[111:104];
						end
						15: begin
							lcd_rs = 1;
							lcd_data = line2_data[119:112];
						end
						16: begin
							lcd_rs = 1;
							lcd_data = line2_data[127:120];
						end
						default: begin
							lcd_rs = 1;
							lcd_data = 8'b00100000;
						end
					endcase
				end
				delay_t: begin
					lcd_rs = 0;
					lcd_rw = 0;
					lcd_data = 8'b00000010;
				end
				clear_disp: begin
					lcd_rs = 0;
					lcd_rw = 0;
					lcd_data = 8'b00000001;
				end
				default: begin
					lcd_rs = 1'b1;
					lcd_rw = 1'b1;
					lcd_data = 8'b00000000;
				end
			endcase
		end
	end
	
	assign lcd_e = clk;

endmodule
