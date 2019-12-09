////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ledwalker.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To walk an active LED back and forth across a set of 8 LEDs.
// 		This is a demo design.  It should be easy enough to adjust
// 	it to "N" LED's.
//
// 	This demo design is also broken in several ways.  This is on purpose.
// 	Follow the coursework, and we'll find and fix the bugs in this design.
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
module	ledwalker(i_clk, o_led);
	input	wire		i_clk;
	output	reg	[7:0]	o_led;

	reg	[3:0]	led_index;
	initial	led_index = 0;
	always @(posedge i_clk)
	if (led_index > 4'd13)
		led_index <= 0;
	else
		led_index <= led_index + 1'b1;

	always @(posedge i_clk)
	case(led_index)
	4'h0: o_led <= 8'h01;
	4'h1: o_led <= 8'h02;
	4'h2: o_led <= 8'h04;
	4'h3: o_led <= 8'h08;
	//
	4'h4: o_led <= 8'h10;
	4'h5: o_led <= 8'h20;
	4'h6: o_led <= 8'h40;
	4'h7: o_led <= 8'h80;
	//
	4'h8: o_led <= 8'h40;
	4'h9: o_led <= 8'h20;
	4'ha: o_led <= 8'h10;
	4'hb: o_led <= 8'h08;
	//
	4'hc: o_led <= 8'h04;
	4'hd: o_led <= 8'h02;
	default: o_leed <= 8'h01;
	endcase

// To keep our formal verification logic from being synthesized
// and placed on an actual FPGA, we place this within an ifdef FORMAL
// block
`ifdef	FORMAL
	always @(*)
		assert(led_state <= 4'd13);

	// I prefix all of the registers (or wires) I use in formal
	// verification with f_, to distinguish them from the rest of the
	// project.
	reg	f_valid_output;
	always @(*)
	begin
		// Determining if the output is valid or not is a rather
		// complex task--unusual for a typical assertion.  Here, we'll
		// use f_valid_output and a series of _blocking_ statements
		// to determine if the output is one of our valid outputs.
		f_valid_output = 0;

		case(o_led)
		8'h01: f_valid_output = 1'b1;
		8'h02: f_valid_output = 1'b1;
		8'h04: f_valid_output = 1'b1;
		8'h08: f_valid_output = 1'b1;
		8'h10: f_valid_output = 1'b1;
		8'h20: f_valid_output = 1'b1;
		8'h40: f_valid_output = 1'b1;
		8'h80: f_valid_output = 1'b1;
		endcase

		assert(f_valid_output);

		// SV supports a $onehot function which we could've also used
		// depending upon your version of Yosys.  This function will
		// be true if one, and only one, bit in the argument is true.
		// Hence we might have said
		// assert($onehot(o_led));
		// and avoided this case statement entirely.
	end
`endif
endmodule
