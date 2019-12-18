////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ppsi.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Demonstrate a design that will turn an LED on and off at 1Hz.
//		This particular version uses a integer divide approach, to
//	divide the clock rate down by an integer factor until the logic
//	reaches 1Hz.
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
//
//
`define	BLINK_SHORTER
//
module ppsi(i_clk, o_led);
`ifdef	VERILATOR
	parameter CLOCK_RATE_HZ = 300_000;
`else
	parameter CLOCK_RATE_HZ = 50_000_000;
`endif
	input	wire	i_clk;
	output	reg	o_led;

	reg	[31:0]	counter;

	initial	counter = 0;
	always @(posedge i_clk)
	if (counter == CLOCK_RATE_HZ-1)
		counter <= 0;
	else begin
		counter <= counter + 1'b1;
	end

	initial	o_led = 0;
	always @(posedge i_clk)
	if (counter == CLOCK_RATE_HZ-1)
		o_led <= 0;
`ifdef BLINK_SHORTER
	else if (counter == 3*CLOCK_RATE_HZ/4-1)
`else
	else if (counter == CLOCK_RATE_HZ/2-1)
`endif
		o_led <= 1;

`ifdef	FORMAL
	always @(*)
		assert(counter < CLOCK_RATE_HZ);
`endif
endmodule
