////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	debouncer.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To "debounce", or remove the initial toggles from, any button
// 		bounce, returning instead the buttons steady state.
//
// As with the other cores in this tutorial, this one has one or more subtle
// bug(s) in it.  This is on purpose.  You should be able to simulate this core
// and find and fix the bugs, before trying to use this core within an actual
// FPGA.
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
module	debouncer(i_clk, i_btn, o_debounced);
	parameter	TIME_PERIOD = 75000;
	input	wire	i_clk, i_btn;
	output	reg	o_debounced;

	reg	r_btn, r_aux;
	reg	[15:0]	timer;

	// Our 2FF synchronizer
	initial	{ r_btn, r_aux } = 2'b00;
	always @(posedge i_clk)
		{ r_btn, r_aux } <= { r_aux, i_btn };

	// The count-down timer
	initial	timer = 0;
	always @(posedge i_clk)
	if (timer != 0)
		timer <= timer - 1;
	else if (r_btn != o_debounced)
		timer <= TIME_PERIOD[15:0] - 1;

	// Finally, set our output value
	initial	o_debounced = 0;
	always @(posedge i_clk)
	if (timer == 0)
		o_debounced <= r_btn;

`ifdef	FORMAL
	//
	// What properties would you place here?
	//
`endif	// FORMAL
endmodule
