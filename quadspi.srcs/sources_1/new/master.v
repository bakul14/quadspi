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
