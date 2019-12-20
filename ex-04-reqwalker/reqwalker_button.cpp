////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	redqalker.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	This is an example Verilator test bench driver file reqwalker
//		module.
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
#include "Vreqwalker_button.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int	tickcount = 0;
Vreqwalker_button	*tb;
VerilatedVcdC	*tfp;

void	tick(void) {
	tickcount++;

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
	int	last_led, last_state = 0, state = 0;

	// Call commandArgs first!
	Verilated::commandArgs(argc, argv);

	// Instantiate our design
	tb = new Vreqwalker_button;

	// Generate a trace
	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC;
	tb->trace(tfp, 99);
	tfp->open("reqwalker_button.vcd");

	last_led = tb->o_led;

	tb->i_btn = 1;

	for(int cycle=0; cycle<(1<<16); cycle++) {
		tick();

		if (tb->o_led != last_led) {
			printf("%6d: ", tickcount);
			for(int j=0; j<6; j++) {
				if(tb->o_led & (1<<j))
					printf("O");
				else
					printf("-");
			} printf("\n");
		}

		last_led = tb->o_led;
	}

	tfp->close();
	delete tfp;
	delete tb;
}
