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
	always @(posedge sclk) begin
		if (flag) begin
			Register <= Register << 4;
			MISO_0 <= Register[4];
			MISO_1 <= Register[5];
			MISO_2 <= Register[6];
			MISO_3 <= Register[7];
		end
	end
	always @(negedge sclk) begin
		if (flag) begin
			Register[0] = MOSI_0;
			Register[1] = MOSI_1;
			Register[2] = MOSI_2;
			Register[3] = MOSI_3;
			slaveDataReceived <= {slaveDataReceived[3:0], MOSI_3, MOSI_2, MOSI_1, MOSI_0};
		end
	end
endmodule
