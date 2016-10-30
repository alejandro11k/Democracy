#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>

#define BYTE_PER_WORD 8
#define SPIDEV_SIZE 32

static void print_usage(const char *prog)
{
	printf("Usage: %s [-sbdLcPp] [-D data] [-C command]\n", prog);
	puts("  -d  device to use (default /dev/spidev0.0)\n"
	     "  -s  max speed (Hz)\n"
	     "  -b  bits per word \n"
	     "  -p  clock phase\n"
	     "  -P  clock polarity\n"
	     "  -L  least significant bit first\n"
	     "  -c  chip select active high\n"
	);
	exit(1);
}
		


int main(int argc, char *argv[]) 
{
	int fd_spi = -1;
	int i = 0;
	int ret = 0;
	unsigned char cmd_data = 0;
	uint spi_flags = 0;
	uint flag_set = 0;
	char spidev[SPIDEV_SIZE] = "/dev/spidev0.0";
	char opt;
	struct spi_ioc_transfer spiioc;

	//Now write only spi communication
	memset((void *)&spiioc, 0, sizeof(struct spi_ioc_transfer));

	//Setup default SPI Context
	spiioc.bits_per_word =  BYTE_PER_WORD;
	spiioc.delay_usecs = 500;
	spiioc.speed_hz = 575000;
	spiioc.pad = 0;
	
	/** The frame sent via spi looks like this:
		It is a 8 bits frame with:
			- 4 bits registers access
			- 4 bits value
	*/

	while ((opt = getopt(argc, argv, "C:D:d:s:lpPc")) != -1) {
		switch (opt) {
			case 'l':
				spi_flags  |= SPI_LSB_FIRST;
			break;
			case 'p':
				spi_flags |= SPI_CPHA;
			break;
			case 'P':
				spi_flags |= SPI_CPOL;
			break;
			case 'c':
				spi_flags |= SPI_CS_HIGH;
			break;
			case 'd':
				strncpy(spidev, optarg, SPIDEV_SIZE);
			break;
			case 's':
				spiioc.speed_hz =  atoi(optarg);;
				if(spiioc.speed_hz == 0)
					exit(EXIT_FAILURE);
			break;
			case 'C':
				flag_set++;	
				cmd_data |= (unsigned char) ((((uint) atoi(optarg)) << 4) & 0xFF);
			break;
			case 'D':
				flag_set++;
				cmd_data |= ((unsigned char) (((uint) atoi(optarg))) & 0xFF);
			break;
			default: /* '?' */
				if(argc < 2) {
					print_usage(argv[0]);
					exit(EXIT_FAILURE);
				}
			break;
		}	
		if(++i == argc)
			break;
	}

	if(flag_set != 2) {
		fprintf(stderr, "Must pass argument D (data) and C (command) to send\n");	
		print_usage(argv[0]);
		return -1;
	}

	fd_spi = open(spidev, O_WRONLY);
	if(fd_spi <= 0) {
		fprintf(stderr, "Error while accessing %s\n Please check device in /dev/\n", spidev);
		return -1;
	}

	spiioc.tx_buf = (unsigned long) &cmd_data;
	spiioc.rx_buf = (unsigned long) stdout;
	spiioc.len = sizeof(cmd_data);

	// Send only one message 
	ret = ioctl(fd_spi, SPI_IOC_MESSAGE(1), &spiioc);
	if(ret < 0) {
		fprintf(stderr, "Error while sending data\n");	 
		return -1;
	}

	close(fd_spi);
	
	return 0;
}

