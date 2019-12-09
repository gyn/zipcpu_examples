////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ppsii.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Demonstrate a design that will turn an LED on and off at 1Hz.
//		This particular version uses a fracttional divide approach, to
//	divide the clock rate down by an integer factor until the logic
//	reaches 1Hz.  It isn't nearly as exact as the integer divide in
//	ppsi, but it has some nice features to it.
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
module ppsii(i_clk, o_led);
`ifdef	VERILATOR
	parameter CLOCK_RATE_HZ = 300_000;
`else
	parameter CLOCK_RATE_HZ = 100_000_000;
`endif
	parameter [31:0] INCREMENT
		    = (1<<30)/(CLOCK_RATE_HZ/4);
	input	wire	i_clk;
	output	wire	o_led;

	reg	[31:0]	counter;

	initial	counter = 0;
	always @(posedge i_clk)
		counter <= counter + INCREMENT;

	assign	o_led = counter[31];
endmodule
