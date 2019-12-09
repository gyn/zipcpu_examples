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
module ppsi(i_clk, o_led);
`ifdef	VERILATOR
	parameter CLOCK_RATE_HZ = 300_000;
`else
	parameter CLOCK_RATE_HZ = 100_000_000;
`endif
	input	wire	i_clk;
	output	reg	o_led;

	reg	[31:0]	counter;

	initial	counter = 0;
	always @(posedge i_clk)
	if (counter < CLOCK_RATE_HZ/2-1)
		counter <= counter + 1'b1;
	else begin
		counter <= 0;
		o_led <= !o_led;
	end

`ifdef	FORMAL
	always @(*)
		assert(counter < CLOCK_RATE_HZ/2);
`endif
endmodule
