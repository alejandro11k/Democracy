#include "adg2188.h"

#include <stdio.h>
#include <stdlib.h>

#define I2C_ADAPTER	1
#define A_PINS		0b000

void usage(int argc, char** argv)
{
	(void)argc;

	printf("Usage:\n"
		"\t%s <X> <Y> <closed>\n", argv[0]);
	printf("\n"
		"\tX:      row number\n"
		"\tY:      column number\n"
		"\tclosed: 1 to close the switch, 0 to open it\n"
		);
}

int main(int argc, char** argv)
{
	adg2188_t adg;
	int err;
	int x, y, closed;

	if (argc != 4) {
		usage(argc, argv);
		return EXIT_FAILURE;
	}

	err = adg2188_init(&adg, I2C_ADAPTER, A_PINS);
	if (err) {
		fprintf(stderr, "adg2188_init failed (%d)\n", err);
		return err;
	}

	x = atoi(argv[1]);
	y = atoi(argv[2]);
	closed = atoi(argv[3]);

	err = adg2188_set_switch(&adg, x, y, (closed == 1), true);
	if (err) {
		fprintf(stderr, "adg2188_set_switch failed (%d)\n", err);
		return err;
	}

	adg2188_close(&adg);

	return EXIT_SUCCESS;
}

