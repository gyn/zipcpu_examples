////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	maskbus.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Verilog design to illustrate the concept of multiple bits
//		in a vector all being operated on at once.  In this example,
//	an incoming 9-bit vector is exclusively xor'd with a fixed value.
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
module maskbus(i_sw, o_led);
	input	wire	[8:0]	i_sw;
	output	wire	[8:0]	o_led;

	wire	[8:0]	w_internal;

	assign	w_internal = 9'h87;
	assign	o_led = i_sw ^ w_internal;
endmodule
