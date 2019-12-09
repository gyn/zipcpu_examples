////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	memtx.v
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To create a *very* simple UART test program, which can be used
//		as the top level design file of any FPGA program.
//
//	With some modifications (discussed below), this RTL should be able to
//	run as a top-level testing file, requiring only the UART and clock pin
//	to work.
//
//	Be aware, there may be some remaining bugs that I have left behind
//	in this file.  You should check it with simulation and formal
//	verification before running it in the hardware.
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
module	memtx(i_clk, i_reset,
`ifdef	VERILATOR
		o_setup,
`endif
		o_uart_tx);
	parameter	CLOCK_RATE_HZ = 100_000_000; // 100MHz clock
`ifdef	VERILATOR
	parameter	BAUD_RATE = 10_000_000; // 10 MBaud
`else
	parameter	BAUD_RATE = 115_200; // 115.2 KBaud
`endif
	parameter	MSGLEN = 1600;
	input		i_clk, i_reset;
	output	wire	o_uart_tx;

	// Here we set the number of clocks per baud to something appropriate
	// to create a 115200 Baud UART system from a 100MHz clock.
	parameter	INITIAL_UART_SETUP = (CLOCK_RATE_HZ/BAUD_RATE);
`ifdef	VERILATOR
	// Let our Verilator .cpp file know what parameter was selected for
	// the baud rate.  This output word will be read by the Verilator
	// test bench, so it knows how to match the baud rate we are using.
	output	wire	[31:0]	o_setup;
	assign	o_setup = INITIAL_UART_SETUP;
`endif

	//
	// Restart the whole process once a second
	reg		tx_restart;
	reg	[27:0]	hz_counter;

	initial	hz_counter = 28'h16;
	always @(posedge i_clk)
	if (i_reset)
		hz_counter <= 28'h16;
	else if (hz_counter == 0)
		hz_counter <= CLOCK_RATE_HZ - 1'b1;
	else
		hz_counter <= hz_counter - 1'b1;

	initial	tx_restart = 0;
	always @(posedge i_clk)
		tx_restart <= (hz_counter == 1);

	//
	// Transmit our message
	//
	wire		tx_busy;
	reg		tx_stb;
	reg	[10:0]	tx_index;
	reg	[7:0]	tx_data;

	reg	[7:0]	tx_memory	[0:2047];

	initial $readmemh("memfile.hex", tx_memory);

	initial	tx_index = 0;
	always @(posedge i_clk)
	if (i_reset)
		tx_index <= 0;
	else if ((tx_stb)&&(!tx_busy))
	begin
		if (tx_index == MSGLEN)
			tx_index <= 0;
		else
			tx_index <= tx_index + 1'b1;
	end

	always @(posedge i_clk)
		tx_data <= tx_memory[tx_index];

	// tx_stb is a request to send a character.
	initial	tx_stb = 1'b0;
	always @(posedge i_clk)
	if (i_reset)
		tx_stb <= 1'b0;
	else if ((tx_stb)&&(!tx_busy)&&(tx_index>=MSGLEN-1))
		tx_stb <= 1'b0;

	//
	// Instantiate a serial port module here
	//
`ifndef	FORMAL
	txuart #(INITIAL_UART_SETUP[23:0])
		transmitter(i_clk, tx_stb, tx_data, o_uart_tx, tx_busy);
`else
	(* anyseq *) wire serial_busy, serial_out;
	assign	o_uart_tx = serial_out;
	assign	tx_busy = serial_busy;
`endif

`ifdef	FORMAL
	reg	f_past_valid;
	initial	f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	/*
	// If the initial statements work, then assuming that the reset is
	/// asserted initially is optional
	always @(*)
	if (!f_past_valid)
		assume(i_reset);
	*/

	always @(posedge i_clk)
	if ((!f_past_valid)||($past(i_reset)))
	begin
		assert(tx_index == 0);
	end else if ($changed(tx_index))
	begin
		assert(($past(tx_stb))&&(!$past(tx_busy)));
		if (tx_index == 0)
			assert($past(tx_index)==MSGLEN);
		else
			assert(tx_index == $past(tx_index)+1);
	end else // if (f_past_valid)
		assert(($stable(tx_index))
				&&((!$past(tx_stb))||($past(tx_busy))));

	always @(posedge i_clk)
	if (tx_index != 0)
		assert(tx_stb);

	always @(posedge i_clk)
		assert(tx_index < MSGLEN);

	////////////////////////////////////////////////////////////////////////
	//
	// Create a UART transmit cutout
	//
	// This follows from the discussion in lesson 6 on txdata, showing
	// how to build a cutout for the serial port--so that we don't need
	// to formally verify both this module and the serial port
	//
	////////////////////////////////////////////////////////////////////////

	// Assumptions about tx_busy
	initial assume(!tx_busy);
	always @(posedge i_clk)
	if ($past(i_reset))
		assume(!tx_busy);
	else if (($past(tx_stb))&&(!$past(tx_busy)))
		assume(tx_busy);
	else if (!$past(tx_busy))
		assume(tx_busy);

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

	////////////////////////////////////////////////////////////////////////
	//
	// Check the memory read
	//
	////////////////////////////////////////////////////////////////////////
	(* anyconst *)	reg	[10:0]	f_const_addr;
			reg	[7:0]	f_const_value;

	always @(posedge i_clk)
	if (f_past_valid)
		f_const_value <= tx_memory[f_const_addr];
	else
		assert(f_const_value == tx_memory[f_const_addr]);

	always @(posedge i_clk)
	if ((tx_stb)&&(!tx_busy)&&(tx_index == f_const_addr-1))
		assert(tx_data == f_const_value);

	////////////////////////////////////////////////////////////////////////
	//
	// Cover properties
	//
	// It's hard to cover the entire sequence, so let's just cover the
	// first 30 characters.  The rest will need to be verified via
	// simulation
	//
	////////////////////////////////////////////////////////////////////////
	always @(posedge i_clk)
		cover(tx_index == 30);

`endif
endmodule
