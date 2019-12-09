################################################################################
##
## Filename: 	Makefile
##
## Project:	Verilog Tutorial Example file
##
## Purpose:	Builds a verilator simulation of the LED blinking
##		example in Verilator
##
## Targets:
##
##	The (default) or all target will a verilator based simulation of
##	blinky.
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
all: blinky

VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

# Ideally, we'd want -GWIDTH=12
# This requires a newer version of Verilator than I have with my distro
# Hence we have the `ifdef inside blinky.v
obj_dir/Vblinky.cpp: blinky.v
	$(VERILATOR) --trace -Wall -cc blinky.v

obj_dir/Vblinky__ALL.a: obj_dir/Vblinky.cpp
	make --no-print-directory -C obj_dir -f Vblinky.mk

blinky: blinky.cpp obj_dir/Vblinky__ALL.a
	g++ -I$(VINC) -I obj_dir            \
		$(VINC)/verilated.cpp       \
		$(VINC)/verilated_vcd_c.cpp \
		blinky.cpp obj_dir/Vblinky__ALL.a                \
		-o blinky

.PHONY: clean
clean:
	rm -rf obj_dir/ blinky blinkytrace.vcd
