////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	chgdetector.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Determine when the incoming data has changed
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
module	chgdetector(i_clk, i_data, o_stb, o_data, i_busy);
	input	wire		i_clk;
	input	wire	[31:0]	i_data;
	output	reg		o_stb;
	output	reg	[31:0]	o_data;
	input	wire		i_busy;

	initial	{ o_stb, o_data } = 0;
	always @(posedge i_clk)
	if (!i_busy)
	begin
		o_stb <= 0;
		if (o_data != i_data)
		begin
			o_data <= i_data;
			o_stb <= 1'b1;
		end
	end

`ifdef	FORMAL
	reg	f_past_valid;
	initial	f_past_valid = 0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	always @(posedge i_clk)
	if ((f_past_valid)&&($past(o_stb))&&($past(i_busy)))
		assert($stable(o_data));

	always @(posedge i_clk)
	if ((f_past_valid)&&($rose(o_stb)))
		assert(o_data == $past(i_data));
`endif
endmodule
