module Master (
	clk,
	reset,
	start,
	slaveSelect,
	masterDataToSend,
	masterDataReceived,
	sclk,
	CS,
	MOSI_0,
	MOSI_1,
	MOSI_2,
	MOSI_3,
	MISO_0,
	MISO_1,
	MISO_2,
	MISO_3
);
	input wire clk;
	input wire reset;
	input wire start;
	input wire slaveSelect;
	input wire [7:0] masterDataToSend;
	output reg [7:0] masterDataReceived;
	output wire sclk;
	output reg CS;
	output reg MOSI_0;
	output reg MOSI_1;
	output reg MOSI_2;
	output reg MOSI_3;
	input wire MISO_0;
	input wire MISO_1;
	input wire MISO_2;
	input wire MISO_3;
	reg [7:0] Register;
	assign sclk = clk;
	reg transmit = 0;
	integer maxCount = 0;
	always @(posedge start or posedge reset) begin
		if (!transmit && start) begin
			Register <= masterDataToSend;
			masterDataReceived <= 8'bxxxxxxxx;
			maxCount <= 0;
			transmit <= 1;
			if (slaveSelect == 0)
				CS <= 1'b0;
			else
				CS <= 1'b1;
		end
		if (reset)
			Register <= 0;
	end
	always @(posedge clk)
		if (transmit) begin
			Register <= Register << 4;
			MOSI_0 <= Register[4];
			MOSI_1 <= Register[5];
			MOSI_2 <= Register[6];
			MOSI_3 <= Register[7];
		end
	always @(negedge clk) begin
		if (maxCount >= 5) begin
			transmit <= 0;
			CS <= 1'b1;
		end
		if (transmit) begin
			Register[0] <= MISO_0;
			Register[1] <= MISO_1;
			Register[2] <= MISO_2;
			Register[3] <= MISO_3;
			masterDataReceived <= {masterDataReceived[3:0], MISO_3, MISO_2, MISO_1, MISO_0};
			maxCount <= maxCount + 1;
		end
	end
endmodule
module Slave (
	reset,
	slaveDataToSend,
	slaveDataReceived,
	sclk,
	CS,
	MOSI_0,
	MOSI_1,
	MOSI_2,
	MOSI_3,
	MISO_0,
	MISO_1,
	MISO_2,
	MISO_3
);
	input wire reset;
	input wire [7:0] slaveDataToSend;
	output reg [7:0] slaveDataReceived;
	input wire sclk;
	input wire CS;
	input wire MOSI_0;
	input wire MOSI_1;
	input wire MOSI_2;
	input wire MOSI_3;
	output reg MISO_0;
	output reg MISO_1;
	output reg MISO_2;
	output reg MISO_3;
	reg [7:0] Register;
	reg flag = 0;
	always @(negedge CS or posedge reset) begin
		if (CS == 0) begin
			Register <= slaveDataToSend;
			slaveDataReceived <= 8'bxxxxxxxx;
			flag <= 1;
		end
		if (reset)
			Register <= 0;
	end
	always @(posedge CS) begin
		flag <= 0;
		MISO_0 <= 1'bz;
		MISO_1 <= 1'bz;
		MISO_2 <= 1'bz;
		MISO_3 <= 1'bz;
	end
	always @(posedge sclk)
		if (flag) begin
			Register <= Register << 4;
			MISO_0 <= Register[4];
			MISO_1 <= Register[5];
			MISO_2 <= Register[6];
			MISO_3 <= Register[7];
		end
	always @(negedge sclk)
		if (flag) begin
			Register[0] = MOSI_0;
			Register[1] = MOSI_1;
			Register[2] = MOSI_2;
			Register[3] = MOSI_3;
			slaveDataReceived <= {slaveDataReceived[3:0], MOSI_3, MOSI_2, MOSI_1, MOSI_0};
		end
endmodule
module test;
	reg clk = 0;
	reg reset;
	reg start;
	reg slaveSelect;
	reg [7:0] masterDataToSend;
	wire [7:0] masterDataReceived;
	reg [7:0] slaveDataToSend;
	wire [7:0] slaveDataReceived;
	reg SCLK;
	reg CS;
	wire MOSI_0;
	wire MOSI_1;
	wire MOSI_2;
	wire MOSI_3;
	wire MISO_0;
	wire MISO_1;
	wire MISO_2;
	wire MISO_3;
	wire [1:1] sv2v_tmp_m1_sclk;
	always @(*) SCLK = sv2v_tmp_m1_sclk;
	wire [1:1] sv2v_tmp_m1_CS;
	always @(*) CS = sv2v_tmp_m1_CS;
	Master m1(
		.clk(clk),
		.reset(reset),
		.start(start),
		.slaveSelect(slaveSelect),
		.masterDataToSend(masterDataToSend),
		.masterDataReceived(masterDataReceived),
		.sclk(sv2v_tmp_m1_sclk),
		.CS(sv2v_tmp_m1_CS),
		.MOSI_0(MOSI_0),
		.MOSI_1(MOSI_1),
		.MOSI_2(MOSI_2),
		.MOSI_3(MOSI_3),
		.MISO_0(MISO_0),
		.MISO_1(MISO_1),
		.MISO_2(MISO_2),
		.MISO_3(MISO_3)
	);
	Slave flash(
		.reset(reset),
		.slaveDataToSend(slaveDataToSend),
		.slaveDataReceived(slaveDataReceived),
		.sclk(SCLK),
		.CS(CS),
		.MOSI_0(MOSI_0),
		.MOSI_1(MOSI_1),
		.MOSI_2(MOSI_2),
		.MOSI_3(MOSI_3),
		.MISO_0(MISO_0),
		.MISO_1(MISO_1),
		.MISO_2(MISO_2),
		.MISO_3(MISO_3)
	);
	always begin
		#(1) clk = ~clk;
		SCLK = clk;
	end
	initial begin
		reset = 0;
		start = 1;
		masterDataToSend = 8'hab;
		slaveDataToSend = 8'hde;
		slaveSelect = 0;
		CS = 0;
		#(2) start = 0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				#(1)
					;
		end
		masterDataToSend = 8'h22;
		slaveDataToSend = 8'h33;
		start = 1;
		CS = 0;
		#(2) start = 0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				#(1)
					;
		end
		$finish;
	end
endmodule
