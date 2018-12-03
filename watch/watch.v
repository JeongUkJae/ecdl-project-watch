module watch(rst, clk, buttons, switches, lcd_rs, lcd_rw, lcd_e, lcd_data);
	// 리셋, 클럭, 버튼, 버스 스위치
	input rst, clk;
	input [7:0] buttons;
	input [7:0] switches;
	
	// am/pm 시 분 초
	wire ap;
	wire [6:0] hour, min, sec;
	wire [3:0] h10, h1, m10, m1, s10, s1;
	reg i_a, i_h, i_m, i_s; // am/pm 시 분 초 증가 클럭
	reg d_h, d_m, d_s; // am/pm 시 분 초 감소 클럭
	
	wire clk_day;
	
	// 년 월 일 요일
	wire [14:0] year;
	wire [6:0] month, day;
	wire [3:0] y1000, y100, y10, y1, mo10, mo1, d10, d1;

	// vfd display
	output lcd_rs, lcd_rw, lcd_e;
	output [7:0] lcd_data;

	wire lcd_e;
	wire lcd_rs, lcd_rw;
	wire [7:0] lcd_data;
	wire clk_100hz;

	// text-vfd에 나타나는 데이터
	reg [127:0] line1_data, line2_data;

	// for common using
	integer index;

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			for (index = 0; index < 127;index = index + 8) begin
				line1_data[index +: 8] = 8'b00100000;
				line2_data[index +: 8] = 8'b00100000;
			end
		end
		else begin
			if (switches[0])
				line2_data[0 +: 16] = {
						8'b00101001,
						8'b01000101
					};
			else
				line2_data[0 +: 16] = {
						8'b00100000,
						8'b00100000
					};

			line1_data[24 +: 80] = {
				{4'b0011, d1},
				{4'b0011, d10},
				8'b00101110,
				{4'b0011, mo1},
				{4'b0011, mo10},
				8'b00101110,
				{4'b0011, y1},
				{4'b0011, y10},
				{4'b0011, y100},
				{4'b0011, y1000}
			};

			// 시 분 초 나타내기
			line2_data[40 +: 80] = {
					{4'b0011, s1},
					{4'b0011, s10},
					8'b00111010,
					{4'b0011, m1},
					{4'b0011, m10},
					8'b00111010,
					{4'b0011, h1},
					{4'b0011, h10},
					8'b00100000,
					8'b01001101 // M
				};
			if (ap) // P
				line2_data[32 +: 8] = 8'b01010000;
			else // A
				line2_data[32 +: 8] = 8'b01000001;
		end
	end
	
	always @(posedge clk) begin
		if (~rst) begin
			{i_a, i_h, i_m, i_s, d_h, d_m, d_s} = 7'b0;
		end
		else begin
			if (switches[0]) begin
				if (buttons[0]) i_a = 1;
				else if (buttons[1]) i_h = 1;
				else if (buttons[5]) d_h = 1;
				else if (buttons[2]) i_m = 1;
				else if (buttons[6]) d_m = 1;
				else if (buttons[3]) i_s = 1;
				else if (buttons[7]) d_s = 1;
				else begin	
					{i_a, i_h, i_m, i_s, d_h, d_m, d_s} = 7'b0;
				end
			end
			else begin	
				{i_a, i_h, i_m, i_s, d_h, d_m, d_s} = 7'b0;
			end
		end
	end

	// 매 클럭마다 시간 받아오기
	times hms(rst, clk,
					ap, hour, min, sec,
					i_a, i_h, i_m, i_s,
					d_h, d_m, d_s,
					clk_day);

	// 시 분 초 10/1 나누기
	sep s_sep(sec, s10, s1);
	sep m_sep(min, m10, m1);
	sep h_sep(hour, h10, h1);
	
	dates date_g(rst, clk_day, day, month, year, day_of_week);
	sep d_sep(day, d10, d1);
	sep mo_se(month, mo10, mo1);
	sep4 y_sep(year, y1000, y100, y10, y1);
	
	// 클럭 생성
	ten_clk clk100hz_g(rst, clk, clk_100hz);
	
	// lcd
	lcd_decoder lcd(rst, clk_100hz, lcd_e, lcd_rs, lcd_rw, lcd_data, line1_data, line2_data);
endmodule
