////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	maskbus.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Verilator script for the maskbus demo, illustrating the use
//		of a series of connected wires.
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
#include "Vmaskbus.h"
#include "verilated.h"

int main(int argc, char **argv) {
	// Call commandArgs first!
	Verilated::commandArgs(argc, argv);

	// Instantiate our design
	Vmaskbus *tb = new Vmaskbus;

	tb->i_sw = 0;
	for(int k=0; k<20; k++) {
		// We'll set the switch input
		// to the LSB of our counter
		tb->i_sw = k&0x1ff;

		tb->eval();

		// Now let's print our results
		printf("k = %2d, ", k);
		printf("sw = %3x, ", tb->i_sw);
		printf("led = %3x\n", tb->o_led);
	}
}
