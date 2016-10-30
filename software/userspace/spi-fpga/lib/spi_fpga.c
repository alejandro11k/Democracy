#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <morpheus/spi_fpga.h>

#define BYTE_PER_WORD 8
#define SPIDEV_SIZE 32

typedef struct {
	struct spi_ioc_transfer spi_ctx;
	int	 fd_spi;
	unsigned int mask_size;
} spi_fpga_t;

/* Global context to avoid heap allocation*/
spi_fpga_t tbl_spi_fpga_ctx[1];


static spi_fpga_send_data(spi_fpga_t *fpga_handle, unsigned char data, size_t size)
{
	int ret = 0;

	fpga_handle->spi_ctx.tx_buf = (unsigned long) &data;
	fpga_handle->spi_ctx.rx_buf = (unsigned long) NULL;
	fpga_handle->spi_ctx.len = sizeof(data);
	// Send only one message 
	ret = ioctl(fpga_handle->fd_spi, SPI_IOC_MESSAGE(1), &fpga_handle->spi_ctx);
	if(ret < 0) {

		fprintf(stderr, "Error while sending data\n");	 
		return -1;
	}

	return 0;
}

spi_fpga_ctx spi_fpga_init() 
{
	char spidev[SPIDEV_SIZE] = "/dev/spidev0.0";
	char opt;

	//Now write only spi communication
	memset((void *)&tbl_spi_fpga_ctx[0].spi_ctx, 0, sizeof(struct spi_ioc_transfer));

	//Setup default SPI Context
	tbl_spi_fpga_ctx[0].spi_ctx.bits_per_word =  BYTE_PER_WORD;
	tbl_spi_fpga_ctx[0].spi_ctx.delay_usecs = SPI_FPGA_DELAY_USEC;
	tbl_spi_fpga_ctx[0].spi_ctx.speed_hz = SPI_FPGA_SPEED_HZ;
	tbl_spi_fpga_ctx[0].spi_ctx.pad = 0;
	
	/** The frame sent via spi looks like this:
		It is a 8 bits frame with:
			- 4 bits registers access
			- 4 bits value
	*/
	tbl_spi_fpga_ctx[0].mask_size =  0xFFFFFF00;

	tbl_spi_fpga_ctx[0].fd_spi = open(spidev, O_WRONLY);

	if(tbl_spi_fpga_ctx[0].fd_spi <= 0) {
		fprintf(stderr, "Error while accessing %s\n Please check device in /dev/\n", spidev);
		return NULL;
	}
	
	return (spi_fpga_ctx*) &tbl_spi_fpga_ctx[0];
}


int spi_fpga_send(spi_fpga_ctx fpga_handle, unsigned int *cmd, unsigned int *data)
{
	spi_fpga_t *fpga_ctx = (spi_fpga_t *) fpga_handle;
	unsigned short cmd_data = 0;

	if(cmd == NULL)
		return -1;

	if(data == NULL)
		return -1;

	if(*cmd & fpga_ctx->mask_size) {
		fprintf(stderr, "Size of cmd: %d > max size: %d", *cmd, ~fpga_ctx->mask_size);
		return -1;
	}

	if(*data & fpga_ctx->mask_size) {
		fprintf(stderr, "Size of cmd: %d > max size: %d", *cmd, ~fpga_ctx->mask_size);
		return -1;
	}

	cmd_data |= ((unsigned char) (*cmd << 4) & 0xFF);
	cmd_data |= ((unsigned char) *data & 0xFF);

	if(spi_fpga_send_data(fpga_ctx, cmd_data, 4) < 0)
		return -1;

	return 0;
}

void spi_fpga_close_spi(spi_fpga_ctx fpga_handle)
{
	spi_fpga_t *fpga_ctx = (spi_fpga_t *) fpga_handle;
	close(fpga_ctx->fd_spi);

}

