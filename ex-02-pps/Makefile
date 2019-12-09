################################################################################
##
## Filename: 	Makefile
##
## Project:	Verilog Tutorial Example file
##
## Purpose:	Builds the examples in the PPS (1Hz led) directory
##
## Targets:
##
##	The (default) or all target will build two verilator based simulations,
##	 one for ppsi (integer divide to 1Hz), and one for ppsii (fractional
##	 divide)
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
all: ppsi ppsii

VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include

obj_dir/Vppsi.cpp: ppsi.v
	$(VERILATOR) --trace -Wall -cc ppsi.v

obj_dir/Vppsii.cpp: ppsii.v
	$(VERILATOR) --trace -Wall -cc ppsii.v

obj_dir/Vppsi__ALL.a: obj_dir/Vppsi.cpp
	make --no-print-directory -C obj_dir -f Vppsi.mk

obj_dir/Vppsii__ALL.a: obj_dir/Vppsii.cpp
	make --no-print-directory -C obj_dir -f Vppsii.mk

ppsi: ppsi.cpp obj_dir/Vppsi__ALL.a
	g++ -I$(VINC) -I obj_dir $(VINC)/verilated.cpp	\
		$(VINC)/verilated_vcd_c.cpp ppsi.cpp	\
		obj_dir/Vppsi__ALL.a -o ppsi

ppsii: ppsii.cpp obj_dir/Vppsii__ALL.a
	g++ -I$(VINC) -I obj_dir $(VINC)/verilated.cpp	\
		$(VINC)/verilated_vcd_c.cpp ppsii.cpp	\
		obj_dir/Vppsii__ALL.a -o ppsii

.PHONY: clean
clean:
	rm -rf obj_dir/ ppsi ppsi.vcd ppsii ppsii.vcd
