////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	genhex.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	To turn a (text) file of 8-bit characters into a hex file that
//		can be included via $readmemh.
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
#include <unistd.h>
#include <string.h>

/*
* endswith
*
* Real simple: returns true if the given string ends with the given ending.
* Useful for determining if a file ends with the extension .txt.
*
*/
bool	endswith(const char *str, const char *ending) {
	int	slen = strlen(str), send = strlen(ending);
	if (slen < send)
		return false;
	if (strcmp(&str[slen-send], ".txt")!=0)
		return false;
	return true;
}

/*
* usage()
*
* Tell the user the calling conventions of this program, and what the program
* can be used to accomplish.
*/
void	usage(void) {
	fprintf(stderr, "USAGE:\tgenhex [-x] <filename>.txt [-o <outfile>]\n");
	fprintf(stderr, "\n"
"\tConverts a text file to a file such as can be included in a Verilog\n"
"\tprogram.  Without the -x argument, the genhex program defaults\n"
"\tto converting the text file to a hex file, whose output name defaults\n"
"\tto \'memfile.hex\'.  With the -x argument, genhex converts the file\n"
"\tinto an include file such as might be used in a Verilog program\n"
"\tif and when the synthesis tool doesn\'t support hex files (Xilinx\'s\n"
"\tISE).  In this case, the output filename defaults to \'memfile.inc\'.\n"
"\n\n");
}

int main(int argc, char **argv) {
	FILE	*fp, *fout;
	const	char	*input_filename = NULL, *output_filename = NULL;
	bool	xise_file = false;

	for(int argn=1; argn < argc; argn++) {
		if (argv[argn][0] == '-') {
			if (argv[argn][2] == '\0') {
				if (argv[argn][1] == 'x')
					xise_file = true;
				else if (argv[argn][1] == 'o') {
					if (argn+1<argc)
						output_filename = argv[++argn];
					else  {
					fprintf(stderr, "ERR: -o given, but no filename given");
						usage();
						exit(EXIT_FAILURE);
					}
				} else {
					fprintf(stderr, "ERR: Unknown argument, %s\n", argv[argn]);
					usage();
					exit(EXIT_FAILURE);
				}
			} else {
				fprintf(stderr, "ERR: Unknown argument, %s\n", argv[argn]);
				usage();
				exit(EXIT_FAILURE);
			}
		} else if (input_filename == NULL) {
			input_filename = argv[argn];
		} else {
			fprintf(stderr, "ERR: Too many file names given, %s when I already have %s\n", argv[argn], input_filename);
			usage();
			exit(EXIT_FAILURE);
		}
	}

	if (input_filename== NULL) {
		fprintf(stderr, "No filename given\n");
		usage();
		exit(EXIT_FAILURE);
	}

	if (!endswith(input_filename, ".txt")) {
		fprintf(stderr, "Err: %s is an invalid text file name\n", input_filename);
		exit(EXIT_FAILURE);
	}

	if (access(input_filename, F_OK)!=0) {
		fprintf(stderr, "Err: %s is not a file\n", input_filename);
		exit(EXIT_FAILURE);
	} else if (access(input_filename, R_OK)!=0) {
		fprintf(stderr, "Err: Cannot read %s\n", input_filename);
		exit(EXIT_FAILURE);
	}

	fp = fopen(input_filename, "r");
	if (fp == NULL) {
		fprintf(stderr, "Err: Cannot read %s\n", input_filename);
		exit(EXIT_FAILURE);
	}

	if (output_filename == NULL)
		output_filename = (xise_file) ? "memfile.inc" : "memfile.hex";

	fout = fopen(output_filename, "w");
	if (fout == NULL) {
		fprintf(stderr, "Err: Cannot write %s\n", output_filename);
		exit(EXIT_FAILURE);
	}

	const	int	nbits = 8;

	if (xise_file) {
		// Build an include file
		int	ch, addr = 0;
		while((ch = fgetc(fp))!=EOF) {
			if (ch == '\n')
				fprintf(fout, "\t\tmessage[%4d] = %d\'h%0*x;\n",
					nbits, (nbits+3)/4,
					addr++, '\n');
			fprintf(fout, "\t\tmessage[%4d] = %d\'h%0*x;\n",
				nbits, (nbits+3)/4,
				addr++, ch & ((1<<nbits)-1));
		}

		for(; addr<2048; addr++)
			// Fill the rest of the memory array with spaces
			// Other applications might with to fill everything
			// with zeros or something else instead
			fprintf(fout, "\t\tmessage[%4d] = %d'h%0*x;\n",
					nbits, (nbits+3)/4,
					addr, ' ');
	} else {
		// Bulid a proper hex file
		int	linelen = 0;
		int	ch, addr = 0;

		fprintf(fout, "@%08x ", addr);
		linelen = 10;
		while((ch = fgetc(fp))!=EOF) {
			// Add a carriage return prior to every newline
			// Some terminals require this
			if (ch == '\n') {
				fprintf(fout, "%02x ", '\r' & 0x0ff);
				linelen += 3;
				addr++;
				if (linelen >= 56) {
					fprintf(fout, "\n");
					linelen = 0;
					fprintf(fout, "\n@%08x ", addr);
					linelen += 10;
				}
			}
			fprintf(fout, "%02x ", ch & ((1<<nbits)-1));
			linelen += 3;
			addr++;

			if (linelen >= 56) {
				fprintf(fout, "\n");
				linelen = 0;
				fprintf(fout, "@%08x ", addr); linelen += 4+6;
			}
		} fprintf(fout, "\n");
	}
	fclose(fp);
	fclose(fout);
}
