////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	ledwalker.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	This is an example Verilator test bench driver file ledwalker
//		module.
//
//	Heads up: I may have left a bug or two in this design for you to fix.
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
#include "Vledwalker.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

void	tick(int tickcount, Vledwalker *tb, VerilatedVcdC* tfp) {
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
	Vledwalker *tb = new Vledwalker;

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb->trace(tfp, 99);
	tfp->open("ledwalker.vcd");

	last_led = tb->o_led;
	for(int k=0; k<(1<<10); k++) {
		tick(++tickcount, tb, tfp);

		// Now let's print our results
		if (last_led != tb->o_led) {
			printf("k = %7d, ", k);
			printf("led = %02x:", tb->o_led);
			for(int j=0; j<8; j++) {
				if(tb->o_led & (1<<j))
					printf("O");
				else
					printf("-");
			} printf("\n");
		} last_led = tb->o_led;
	}
}
