////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	linetest.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To test that the txuart and rxuart modules work properly, by
//		buffering one line's worth of input, and then piping that line
//	to the transmitter while (possibly) receiving a new line.
//
//	With some modifications (discussed below), this RTL should be able to
//	run as a top-level testing file, requiring only the transmit and receive
//	UART pins and the clock to work.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Written and distributed by Gisselquist Technology, LLC
//
// This program is hereby granted to the public domain.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.
//
////////////////////////////////////////////////////////////////////////////////
//
//
`default_nettype	none
//
module	linetest(i_clk, i_uart_rx, o_uart_tx,
		o_led
`ifdef	VERILATOR
		,		o_setup
`endif
		);
	// 115200 Baud, if clk @ 100MHz
`ifdef	VERILATOR
	parameter 		CLOCKS_PER_BAUD = 24;
`else
	parameter 		CLOCKS_PER_BAUD = 868;
`endif
	//
	input	wire		i_clk;
	input	wire		i_uart_rx;
	output	wire		o_uart_tx;
`ifdef	VERILATOR
	output	wire	[30:0]	o_setup;
`endif

`ifdef	VERILATOR
	assign		o_setup = CLOCKS_PER_BAUD;
`endif


	wire		rx_stb, tx_busy, fifo_empty, fifo_valid,
			fifo_full;
	wire	[7:0]	rx_data, tx_data;
	wire	[8:0]	fifo_fill;
	reg	[7:0]	line_count;
	reg		run_tx, tx_stb, fifo_rd;


	rxuart	#(.CLOCKS_PER_BAUD(CLOCKS_PER_BAUD))
		receiver(i_clk, i_uart_rx, rx_stb, rx_data);

	sfifo	#(.BW(8), .LGFLEN(8))
		fifo(i_clk, rx_stb, rx_data, fifo_full, fifo_fill,
			fifo_rd, tx_data, fifo_empty);

	assign	fifo_valid = !fifo_empty;

	// Here's the guts of the algorithm--setting run_tx.  Once set, the
	// buffer will flush.  Here, we set it on one of two conditions: 1)
	// a newline is received, or 2) the line is now longer than 80
	// characters.
	//
	// Once the line has ben transmitted (separate from emptying the buffer)
	// we stop transmitting.
	initial	run_tx = 0;
	initial	line_count = 0;
	always @(posedge i_clk)
	if (rx_stb && (rx_data == 8'ha || rx_data == 8'hd))
	begin
		run_tx <= 1'b1;
		line_count <= fifo_fill[7:0];
	end else if (!run_tx)
	begin
		if (fifo_fill >= 9'd80)
		begin
			run_tx <= 1'b1;
			line_count <= 80;
		end else if (fifo_valid && (tx_data == 8'ha || tx_data == 8'hd))
		begin
			run_tx <= 1'b1;
			line_count <= 1;
		end
	end else if (!fifo_empty && !tx_busy) begin // if (run_tx)
		line_count <= line_count - 1;
		if (line_count == 1)
			run_tx <= 0;
	end

	always @(*)
		fifo_rd = (tx_stb && !tx_busy);

	// When do we wish to transmit?
	//
	// Any time run_tx is true--but we'll give it an extra clock.
	always @(*)
		tx_stb = (run_tx && fifo_valid);

	txuart	#(.CLOCKS_PER_BAUD(CLOCKS_PER_BAUD))
		transmitter(i_clk, tx_stb, tx_data, o_uart_tx, tx_busy);

	// Make Verilator happy
	// Verilator lint_off UNUSED
	wire	unused;
	assign	unused = fifo_full;
	// Verilator lint_on UNUSED

endmodule
