////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	thedesign.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	This is the top-level design file for the txdata lesson, #6
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
module thedesign(i_clk, i_event,
`ifdef	VERILATOR
		o_setup,
`endif
		o_uart_tx);
	//
	parameter	CLOCK_RATE_HZ = 100_000_000;
	parameter	BAUD_RATE = 115_200;
	//
	input	wire	i_clk, i_event;
	output	wire	o_uart_tx;

	parameter	UART_SETUP = (CLOCK_RATE_HZ / BAUD_RATE);
`ifdef	VERILATOR
	output	wire	[31:0]	o_setup;
	assign	o_setup = UART_SETUP;
`endif

	wire	[31:0]	counterv, tx_data;
	wire		tx_busy, tx_stb;
	
	counter thecounter(i_clk, 1'b0, i_event, counterv);

	chgdetector findchanges(i_clk, counterv, tx_stb, tx_data, tx_busy);

	txdata #(UART_SETUP)
		serialword(i_clk, 1'b0, tx_stb, tx_data, tx_busy, o_uart_tx);
endmodule
