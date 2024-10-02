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
	wire sv2v_tmp_m1_CS;
	always @(*) CS = sv2v_tmp_m1_CS;
	Master master(
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
	Slave slave(
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
		/// Test 1
		reset = 0;
		start = 1;
		masterDataToSend = 8'hab;
		slaveDataToSend = 8'hde;
		slaveSelect = 0;
		CS = 0;
		#(2) start = 0;
		begin : test1
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				#(1);
		end

		/// Test 2
		masterDataToSend = 8'h22;
		slaveDataToSend = 8'h33;
		start = 1;
		CS = 0;
		#(2) start = 0;
		begin : test2
			reg signed [31:0] i;
			for (i = 0; i < 16; i = i + 1)
				#(1);
		end


		$finish;
	end
endmodule
