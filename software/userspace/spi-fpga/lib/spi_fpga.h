#ifndef __SPI_FPGA__H 
#define __SPI_FPGA__H

#define SPI_FPGA_DELAY_USEC	500
#define SPI_FPGA_SPEED_HZ	575000

typedef void* spi_fpga_ctx;

/** \brief This function will initialize the SPI communication
 *  \return a handle needed to send data
 */
spi_fpga_ctx spi_fpga_init();

/**
* \brief This function will check if passed information are correct 
* \param *cmd: A pointer on cmd to send to the FPGA.
* \param *data: A pointer on data to send to the FPGA.
* \return Return 0 upon success
*/
int spi_fpga_send(spi_fpga_ctx fpga_handle, unsigned int *cmd, unsigned int *data);

/** \brief This function will close the fpga spi file descriptor
 */
void spi_fpga_close_spi(spi_fpga_ctx fpga_handle);

#endif /* __SPI_FPGA__H */

