#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <math.h>
#include <jack/jack.h>
#include <semaphore.h>
#define PATH_FIFO		"/tmp/pipe_ledrgb"
#define INPUT_INTEGRATOR 	0.001923077	
#define INPUT_RETURN	        -0.000013333	


typedef struct {
	int fd_pipe;
	volatile int iter;	
	int iter_max;
	float last_acc;
	float acc;
	jack_port_t *input_port;
	jack_client_t *client;
//j	sem_t sem_buf;
//	jack_default_audio_sample_t buffer[60];
	
} peak_meter_st;


int i_all = 0;

/* We do not have any output because we only have */

/* Main callback*/
static int jack_callback(jack_nframes_t nframes, void *args)
{
	int i;
	char str_float[32];
	peak_meter_st *peak_ctx = (peak_meter_st *) args;
	jack_default_audio_sample_t *in = 
                (jack_default_audio_sample_t *) 
                jack_port_get_buffer (peak_ctx->input_port, nframes);

	for(i = 0; i < nframes; i++) {
	   if(peak_ctx->acc > in[i])
		peak_ctx->acc = fabs(peak_ctx->acc + INPUT_RETURN);
	   else 
		peak_ctx->acc = fabs(peak_ctx->acc + INPUT_INTEGRATOR); 
	}
	

	if(peak_ctx->iter++ % peak_ctx->iter_max  == 0) {
		
		sprintf(str_float, "%1.5f\n", peak_ctx->acc);
		if(peak_ctx->fd_pipe <= 0)
			peak_ctx->fd_pipe = open(PATH_FIFO, O_WRONLY | O_NONBLOCK | O_ASYNC); 

		write(peak_ctx->fd_pipe, str_float,strlen(str_float));
		peak_ctx->last_acc = peak_ctx->acc; 
	}

	return 0;
}


static void error (const char *desc)
{
	fprintf (stderr, "Peak-meter error: %s\n", desc);
}

static void jack_shutdown(void *arg) {
	exit(0);
}

int main(int argc, char *argv[])
{
	/* Client Jack */
	const char **ports;		
	peak_meter_st jack_ctx = {
				.fd_pipe = 0,
				.iter = 1,
				.acc = 0,
				.last_acc = 0,
				.input_port = NULL,
				.client = NULL
				};

	/* Fifo related information*/	
	mkfifo(PATH_FIFO, 0666);
	jack_ctx.fd_pipe = open(PATH_FIFO, O_WRONLY | O_NONBLOCK | O_ASYNC); 
	jack_set_error_function(error);

	if((jack_ctx.client = jack_client_open("peak-meter",JackNullOption, NULL)) == NULL) {
		fprintf(stderr, "Could not open the jack client\ni Quitting\n");
	}
	
	jack_on_shutdown (jack_ctx.client, jack_shutdown, 0);

	jack_ctx.iter_max = 1 ;// /(float) (jack_get_buffer_size(jack_ctx.client) * 1000.0 / (float) jack_get_sample_rate(jack_ctx.client));
	jack_set_process_callback(jack_ctx.client, jack_callback, &jack_ctx);
	jack_ctx.input_port =  jack_port_register(jack_ctx.client, "audio-in", JACK_DEFAULT_AUDIO_TYPE, JackPortIsInput, 0);
	printf("value max %d", jack_ctx.iter_max);

	if(jack_activate(jack_ctx.client)) {
		fprintf(stderr, "cannot activate client");
	}

	ports = jack_get_ports(jack_ctx.client, NULL, NULL, JackPortIsPhysical|JackPortIsOutput);
	
	if(jack_connect(jack_ctx.client, ports[0], jack_port_name(jack_ctx.input_port)) < 0) {
		fprintf(stderr, "Cannot connect to physical input");
		exit(-1);
	}
		
	while(1) {
		sleep(2);	
	}
}

