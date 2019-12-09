////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ppsii.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Verilator driver for ppsii.cpp.  Should be almost word for word
//		identical to ppsi.cpp.
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
#include <stdio.h>
#include <stdlib.h>
#include "Vppsii.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

void	tick(int tickcount, Vppsii *tb, VerilatedVcdC* tfp) {
	tb->eval();
	if (tfp)
		tfp->dump(tickcount * 10 - 2);
	tb->i_clk = 1;
	tb->eval();
	if (tfp)
		tfp->dump(tickcount * 10);
	tb->i_clk = 0;
	tb->eval();
	if (tfp) {
		tfp->dump(tickcount * 10 + 5);
		tfp->flush();
	}
}

int main(int argc, char **argv) {
	int	last_led;
	unsigned tickcount = 0;

	// Call commandArgs first!
	Verilated::commandArgs(argc, argv);

	// Instantiate our design
	Vppsii *tb = new Vppsii;

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb->trace(tfp, 99);
	tfp->open("ppsii.vcd");

	last_led = tb->o_led;
	for(int k=0; k<(1<<20); k++) {
		tick(++tickcount, tb, tfp);

		// Now let's print our results
		if (last_led != tb->o_led) {
			printf("k = %7d, ", k);
			printf("led = %d\n", tb->o_led);
		} last_led = tb->o_led;
	}
}
