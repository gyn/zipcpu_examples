################################################################################
##
## Filename: 	Makefile
##
## Project:	Verilog Tutorial Example file
##
## Purpose:	Builds the Verilator LEDWalker example
##
## Targets:
##
##	The (default) or all target will build a verilator simulation for the
##	LED Walker.
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
all: ledwalker_tb

VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

obj_dir/Vledwalker.cpp: ledwalker.v
	$(VERILATOR) --trace -Wall -cc ledwalker.v

obj_dir/Vledwalker__ALL.a: obj_dir/Vledwalker.cpp
	make --no-print-directory -C obj_dir -f Vledwalker.mk

ledwalker_tb: ledwalker.cpp obj_dir/Vledwalker__ALL.a
	g++ -I$(VINC) -I obj_dir $(VINC)/verilated.cpp		\
		$(VINC)/verilated_vcd_c.cpp ledwalker.cpp	\
		obj_dir/Vledwalker__ALL.a -o ledwalker_tb

.PHONY: clean
clean:
	rm -rf obj_dir/ ledwalker/ ledwalker_tb ledwalker.vcd
