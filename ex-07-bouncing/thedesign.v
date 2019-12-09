////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	thedesign.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	This is the top-level design file for the debouncing lesson, #7.
//		It is designed to do the same things as the top level design
//	from lesson 6, but with the addition of a 2FF synchronizer and debouncer
//	found in debouncer.v.  A companion file, thedesign_tb.cpp, should help
//	you simulate this (de)bouncing button test from within Verilator.
//
//	It may or may not have bugs within it.
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
`default_nettype none
//
module thedesign(i_clk, i_btn,
`ifdef	VERILATOR
		o_setup,
`endif
		o_uart_tx);
	//
	parameter	CLOCK_RATE_HZ = 100_000_000;
	parameter	BAUD_RATE = 115_200;
	//
	input	wire	i_clk, i_btn;
	output	wire	o_uart_tx;

	reg	last_debounced, btn_event;
	wire	debounced;

	parameter	UART_SETUP = (CLOCK_RATE_HZ / BAUD_RATE);
`ifdef	VERILATOR
	output	wire	[31:0]	o_setup;
	assign	o_setup = UART_SETUP;
`endif

	debouncer thedebouncer(i_clk, i_btn, debounced);

	initial	last_debounced = 0;
	always @(posedge i_clk)
		last_debounced <= debounced;

	initial	btn_event = 0;
	always @(posedge i_clk)
		btn_event <= ((debounced)&&(!last_debounced));
		

	wire	[31:0]	counterv, tx_data;
	wire		tx_busy, tx_stb;
	
	counter thecounter(i_clk, 1'b0, btn_event, counterv);

	chgdetector findchanges(i_clk, counterv, tx_stb, tx_data, tx_busy);

	txdata #(UART_SETUP)
		serialword(i_clk, 1'b0, tx_stb, tx_data, tx_busy, o_uart_tx);
endmodule
