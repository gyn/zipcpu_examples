////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	counter.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Count a number of events given to it
//
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
module	counter(i_clk, i_reset, i_event, o_count);
	input	wire		i_clk, i_reset;
	input	wire		i_event;
	output	reg	[31:0]	o_count;

	initial	o_count = 0;
	always @(posedge i_clk)
	if (i_reset)
		o_count <= 0;
	else if (i_event)
		o_count <= o_count + 1'b1;

endmodule
