////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	dimmer.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	LED project to adjust the brightness of an LED.
//
//	Unlike the other projects in this directory, this one does not contain
//	a Verilator script, nor a Makefile.  Hopefully you have learned by this
//	point in time to create them yourself.  If not, please look back
//	at the other similar files and copy and paste as necessary to do so.
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
module dimmer(i_clk, o_led);
	input	wire	i_clk;
	output	wire	o_led;

	reg	[27:0]	counter;

	always @(posedge i_clk)
		counter <= counter + 1;

	assign	o_led = (counter[7:0]
		         < counter[27:20]);
endmodule
