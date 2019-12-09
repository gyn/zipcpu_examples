////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	txdata.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To transmit a given number, in 0x%08x format, out the serial
//		port.
//
// This file has been lifted from exercise #6.  If you have done exercise #6,
// you might wish to consider replacing this file with your updated file.
// Why?  Because this file has known bugs for you to fix, and you fixed them
// when doing exercise 6 ... right?  Hence the disclaimer below.
//
// Be aware: I have left bugs left within this design, and kept the formal
// verification from being complete.  The purpose of this file is not to give
// you the solution, but to give you enough of it that you don't need to spend
// all your time writing.
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
module	txdata(i_clk, i_reset, i_stb, i_data, o_busy, o_uart_tx);
	parameter	UART_SETUP = 868;
	input	wire		i_clk, i_reset;
	input	wire		i_stb;
	input	wire	[31:0]	i_data;
	output	wire		o_busy;
	output	wire		o_uart_tx;

	reg	[31:0]	sreg;
	reg	[7:0]	hex, tx_data;
	reg	[3:0]	state;
	reg		tx_stb;
	wire		tx_busy;

	initial	tx_stb = 1'b0;
	initial	state  = 0;

	always @(posedge i_clk)
	if (i_reset)
	begin
		state      <= 0;
		tx_stb     <= 1'b0;
	end else if (!o_busy)
	begin
		// state <= 0;
		if (i_stb)
		begin
			state <= 1;
			tx_stb <= 1;
		end
	end else if ((tx_stb)&&(!tx_busy)) begin
		state <= state + 1;

		if (state >= 4'hd)
		begin
			tx_stb <= 1'b0;
			state <= 0;
		end
	end

	assign	o_busy = tx_stb;

	initial	sreg = 0;
	always @(posedge i_clk)
	if (!o_busy) // && (i_stb)
		sreg <= i_data;
	else if ((!tx_busy)&&(state > 4'h1))
		sreg <= { sreg[27:0], 4'h0 };

	always @(posedge i_clk)
	case(sreg[31:28])
	4'h0: hex <= "0";
	4'h1: hex <= "1";
	4'h2: hex <= "2";
	4'h3: hex <= "3";
	4'h4: hex <= "4";
	4'h5: hex <= "5";
	4'h6: hex <= "6";
	4'h7: hex <= "7";
	4'h8: hex <= "8";
	4'h9: hex <= "9";
	4'ha: hex <= "a";
	4'hb: hex <= "b";
	4'hc: hex <= "c";
	4'hd: hex <= "d";
	4'he: hex <= "e";
	4'hf: hex <= "f";
	default: begin end
	endcase

	always @(posedge i_clk)
	if (!tx_busy)
		case(state)
		4'h1: tx_data <= "0";
		4'h2: tx_data <= "y";
		4'h3: tx_data <= hex;
		4'h4: tx_data <= hex;
		4'h5: tx_data <= hex;
		4'h6: tx_data <= hex;
		4'h7: tx_data <= hex;
		4'h8: tx_data <= hex;
		4'h9: tx_data <= hex;
		4'ha: tx_data <= hex;
		4'hb: tx_data <= "\r";
		4'hc: tx_data <= "\n";
		default: tx_data <= "Q";
		endcase

`ifndef	FORMAL
	txuart	#(UART_SETUP[23:0])
		txuarti(i_clk, tx_stb, tx_data, o_uart_tx, tx_busy);
`else
	(* anyseq *) wire serial_busy, serial_out;
	assign	o_uart_tx = serial_out;
	assign	tx_busy = serial_busy;
`endif

`ifdef	FORMAL
	initial	assume(i_reset);

	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid = 1'b1;

	//
	// Make some assumptions about tx_busy
	//
	// it needs to become busy upon a request given to it
	// but not before.  Upon a request, it needs to stay
	// busy for a minimum period of time
	initial	assume(!tx_busy);
	always @(posedge i_clk)
	if ($past(i_reset))
		assume(!tx_busy);
	else if (($past(tx_stb))&&(!$past(tx_busy)))
		assume(tx_busy);
	else if (!$past(tx_busy))
		assume(!tx_busy);

	reg	[1:0]	f_minbusy;
	initial	f_minbusy = 0;
	always @(posedge i_clk)
	if ((tx_stb)&&(!tx_busy))
		f_minbusy <= 2'b01;
	else if (f_minbusy != 2'b00)
		f_minbusy <= f_minbusy + 1'b1;

	always @(*)
	if (f_minbusy != 0)
		assume(tx_busy);


	//
	// Some cover statements
	//
	// You should be able to "see" your design working from these
	// If not ... modify them until you can.
	//
	always @(posedge i_clk)
	if (f_past_valid)
		cover($fell(o_busy));

	always @(posedge i_clk)
	if ((f_past_valid)&&(!$past(i_reset))
		cover($fell(o_busy));

	//
	// Some assertions about our sequence of states
	//
	reg	[15:0]	p1reg;
	initial	p1reg = 0;
	always @(posedge i_clk)
	if ((i_stb)&&(!o_busy))
	begin
		p1reg <= 1;
		assert(p1reg[11:0] == 0);
	end else if (p1reg) begin
		if (p1reg != 1)
			assert($stable(fv_data));
		if (!tx_busy)
			p1reg <= { p1reg[14:0], 1'b0 };
		if ((!tx_busy)||(f_minbusy==0))
		begin
			if (p1reg[0])
			begin
				assert((tx_data == "0")&&(state == 1));
				assert((sreg == i_data));
			end
			if (p1reg[1])
				assert((tx_data == "x")&&(state == 2));

			// You'll need to add some other assertions
			// here
		end
	end else
		assert(state == 0);

`endif
endmodule
