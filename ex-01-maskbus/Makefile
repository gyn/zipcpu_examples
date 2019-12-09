################################################################################
##
## Filename: 	Makefile
##
## Project:	Verilog Tutorial Example file
##
## Purpose:	Builds the maskbus Verilator simulationo
##
## Targets:
##
##	The (default) or all target will build the maskbus verilator
##	simulation.
##
##	clean	Removes all build products
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Technology, LLC
##
################################################################################
##
## Written and distributed by Gisselquist Technology, LLC
##
## This program is hereby granted to the public domain.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.
##
################################################################################
##
##
.PHONY: all
all: maskbus

obj_dir/Vmaskbus.cpp: maskbus.v
	verilator -Wall -cc maskbus.v

obj_dir/Vmaskbus__ALL.a: obj_dir/Vmaskbus.cpp
	make -C obj_dir -f Vmaskbus.mk

maskbus: maskbus.cpp obj_dir/Vmaskbus__ALL.a
	g++ -I/usr/share/verilator/include -I obj_dir \
		/usr/share/verilator/include/verilated.cpp \
		maskbus.cpp obj_dir/Vmaskbus__ALL.a	\
		-o maskbus

.PHONY: clean
clean:
	rm -rf obj_dir/ maskbus
