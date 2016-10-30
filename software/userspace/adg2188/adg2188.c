#include "adg2188.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>

#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define ADG2188_DATA_SHIFT	7
#define ADG2188_X_SHIFT		3
#define ADG2188_Y_SHIFT		0

static const uint8_t x_lookup[] = {
	0b0000,	/* X = 0 */
	0b0001,
	0b0010,
	0b0011,
	0b0100,
	0b0101, /* 5 */
	0b1000, /* 6 */
	0b1001, /* X = 7 */
};

#define GET_X_CODE(x)		(x_lookup[x])
#define GET_Y_CODE(y)		(y)

#define MAX_X			7
#define MAX_Y			7

static inline int adg2188_read(adg2188_t *adg, uint8_t data[], int size)
{
	return (read(adg->fd, data, size) == size) ? 0 : -EIO;
}

static inline int adg2188_write(adg2188_t *adg, uint8_t data[], int size)
{
	return (write(adg->fd, data, size) == size) ? 0 : -EIO;
}

int adg2188_init(adg2188_t *adg, int adapter, int A)
{
	int fd;
	char filename[40];
	int addr = (0b1110 << 3) | (A & 0x7);

	printf("adg2188: open chip on adapter %d at address 0x%x\n", adapter, addr);

	snprintf(filename, 39, "/dev/i2c-%d", adapter);
	if ((fd = open(filename, O_RDWR)) < 0) {
		fprintf(stderr, "adg2188: failed to open the bus\n");
		return errno;
	}

	adg->fd = fd;

	if (ioctl(fd, I2C_SLAVE, addr) < 0) {
		fprintf(stderr, "adg2188: failed to acquire bus access and/or talk to slave\n");
		adg2188_close(adg);
		return errno;
	}

	return 0;
}

void adg2188_close(adg2188_t *adg)
{
	close(adg->fd);
}

int adg2188_set_switch(adg2188_t *adg, unsigned x, unsigned y, bool closed, bool immediate)
{
	uint8_t data[2];

	if (x > MAX_X)
		return -EINVAL;
	if (y > MAX_Y)
		return -EINVAL;

	data[0] = (closed == true ? 1 : 0) << ADG2188_DATA_SHIFT;
	data[0] |= GET_X_CODE(x) << ADG2188_X_SHIFT;
	data[0] |= GET_Y_CODE(y) << ADG2188_Y_SHIFT;

	data[1] = (immediate == true ? 1 : 0);

	return adg2188_write(adg, data, 2);
}

