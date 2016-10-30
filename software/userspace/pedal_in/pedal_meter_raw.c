/************************************************************************************
 * \brief this is a example on how to use a c programmed pedal in controller having
 *	different ouput behaviour (In this example just putting a linear proportional
 *	value to the potentiometer.
 *	The User just need to modify process_samples to adjust how he want to use it.
  **********************************************************************************/

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iio/iio.h>

/************************************ USER MACRO DEFINITION **************************************/
/* Sampling frequency */
#define SAMPLING_FREQUENCY		100.0 //Hz
/* Sampling period */
#define SAMPLING_PERIOD_MS		1.0 / SAMPLING_FREQUENCY * 1000.0



/************************************ PRIVATE MACRO DEFINITION ***********************************/
/* Below are the name of the ADC and digipot. Those
 * are values from the iio drivers*/
#define DIGIPOT_10K_DEVICE_NAME		"mcp4561-103"
#define DIGIPOT_10K_NUM_POS		256
#define DIGIPOT_50K_DEVICE_NAME		"mcp4561-503"
#define DIGIPOT_50K_NUM_POS		256
#define PEDAL_IN_DEVICE_NAME		"max11644"

/* Those are the kind of device we have. It follows 
 * the drivers scheme */
#define DIGIPOT_CHANNEL_NAME		"resistance"
#define PEDAL_IN_CHANNEL_NAME		"voltage"

/*This is the name human readable name of the 
 * devices we are using */
#define DIGIPOT_10K_PHY_NAME		"Digipot 10k"
#define DIGIPOT_50K_PHY_NAME		"Digipot 50k"
#define PEDAL_IN_PHY_NAME		"Pedal In"



/* ADC related information */
#define ADC_BITS			12
#define ADC_MAX_VALUE			(1 << ADC_BITS) -1


/* Now we are not using buffer (errors issues) We use the raw read.
 * If one  want to use the buffer and link it with the 
 * hight resolution timer to define the sampling time*/

/* Path to configs to create the hr timer */
#define PATH_TO_CONFIGS_HRTIMER		"/sys/kernel/config/iio/triggers/hrtimer"
/* Size temp string */
#define SIZE_TEMP_STRING		64

/* static scratch mem for strings */
static char tmpstr[SIZE_TEMP_STRING];

/** Giving information about data direection */
typedef enum {
	E_OUTPUT,
	E_INPUT
} dev_dir_e;

/* This is the device's context */
typedef struct {
	/** IIO channel context */
	struct iio_channel	*dev_channel;
	/** IIO device context */
	struct iio_device	*dev_iio_device;
	/** Trigger device context */
	struct iio_device	*trigger;
	/** Device name gottent from iio */
	char			*dev_name;
	/** Physical device */
	char			*phy_name;
	/** name of the channel either resistance or voltage in our case */
	char 			*channel_name;
	/** Channel id number */
	int			dev_channelid;
	/** Data direction regarding the raspberry */
	dev_dir_e		dev_direction;
} iio_dev_ctx;

/**
 * \brief This function allow the user to find the device context by giving its name 
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \param *phy_namefind is the string pointer onto a 
 * \return A pointer onto the context we were looking for 
 */
static iio_dev_ctx *get_ctx_by_phy_name(iio_dev_ctx *dev_ctx[], const char *phy_namefind )
{
	while(*dev_ctx != NULL) {
		if(strstr((*dev_ctx)->phy_name, phy_namefind) != NULL) {
			return *dev_ctx;
		}

		dev_ctx++;
	}
}

/**
 * \brief  This is the function has to modify if one wants to modify the 
 *		behaviour of the ouput depending on the pedal_in
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \return true if sucesss false otherwise
 */
static bool process_samples(iio_dev_ctx *dev_ctx[])
{
	/* Here we are retrieving the context of all the different iios devices (not mandatory if 
	 * you know the order and what is in the dev ctx*/
	iio_dev_ctx *in_pedal = get_ctx_by_phy_name(dev_ctx, PEDAL_IN_PHY_NAME);
	iio_dev_ctx *out_digipot10k_ctx = get_ctx_by_phy_name(dev_ctx, DIGIPOT_10K_PHY_NAME);
	iio_dev_ctx *out_digipot50k_ctx = get_ctx_by_phy_name(dev_ctx, DIGIPOT_50K_PHY_NAME);

	unsigned long value_pdata = 0;
	float value_pos = 0;

	/* Retrieving value from the raw channel value */
	iio_channel_attr_read_longlong(in_pedal->dev_channel,"raw" , (long long *)&value_pdata);
	/* As an example we calculate the 50K value*/
	value_pos= ((float)(value_pdata & ADC_MAX_VALUE) * (float)DIGIPOT_50K_NUM_POS / (float)(1 << ADC_BITS));
	/** Here we write to the digipot 50k output*/
	iio_channel_attr_write_longlong(out_digipot50k_ctx->dev_channel, "raw",(long long) value_pos);
	/* As an example we calculate the 10K value*/
	value_pos= ((float)(value_pdata & ADC_MAX_VALUE) * (float)DIGIPOT_10K_NUM_POS / (float)(1 << ADC_BITS));
	/** Here we write to the digipot 10k output*/
	iio_channel_attr_write_longlong(out_digipot10k_ctx->dev_channel, "raw",(long long) value_pos);

	return true;
}


/* Create trigger if doesnt exists */
static bool create_trigger_hrtimer() {
	
	struct stat st = {0};
	
	if(stat(PATH_TO_CONFIGS_HRTIMER, &st) == -1) {
		if( -1 == mkdir(PATH_TO_CONFIGS_HRTIMER, 0700))
			return false;
	}

	printf("Path to configs ok!");
	return true;
}


/**
 * \brief Function setting parameter using bool format 
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \return true if sucesss false otherwise
 */
static bool set_param_bool(struct iio_channel *chn, const char *attrs, bool value)
{
	iio_channel_attr_write_bool(chn, attrs, value);	
}


/**
 * \brief Function setting parameter using bool format 
 * \param This is the type of channel as a string 
 * \param 
 * \return Return back the full formated string
 */
static char* get_ch_name(const char* type, int id)
{
	snprintf(tmpstr, sizeof(tmpstr), "%s%d", type, id);
	printf("looking for channel %s \n", tmpstr);
	return tmpstr;
}

/**
 * \brief This is to get the device physical name
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \return true if sucesss false otherwise
 */
static struct iio_device* get_dev_phy(struct iio_context *ctx, iio_dev_ctx *ctx_dev)
{
	ctx_dev->dev_iio_device = iio_context_find_device(ctx, ctx_dev->dev_name);
	return ctx_dev->dev_iio_device;
}

/**
 * \brief This is to get the device physical name
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \return true if sucesss false otherwise
 */
static bool get_stream_device(iio_dev_ctx *dev_ctx[], struct iio_context *ctx)
{
	int i = 0;
	while(dev_ctx[i] != NULL) {
		printf("* Acquiring %s stream\n" , dev_ctx[i]->dev_name);
		dev_ctx[i]->dev_iio_device = iio_context_find_device(ctx, dev_ctx[i]->dev_name);

		if(NULL == dev_ctx[i]->dev_iio_device)
			return false;
		i++;
	}

	return true;
}

/**
 * \brief This function will retrieve information for a stream channel from a device name and the device channel ID number
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \param *ctx This is the context of the current iios available on the raspberry pi
 * \return true if sucesss false otherwise
 */
static bool get_stream_channel(iio_dev_ctx *dev_ctx[], struct iio_context *ctx)
{
	int i = 0;
	while(NULL != dev_ctx[i]) {
		printf("* Acquiring %s channel : %d\n" , dev_ctx[i]->dev_name, dev_ctx[i]->dev_channelid);
		dev_ctx[i]->dev_channel = iio_device_find_channel(dev_ctx[i]->dev_iio_device, get_ch_name(dev_ctx[i]->channel_name, dev_ctx[i]->dev_channelid),\
			 E_OUTPUT == dev_ctx[i]->dev_direction ? true : false);

		if(NULL ==  dev_ctx[i]->dev_channel )
			return false;
		i++;
	}
	
	return true;
}

/**
 * \brief This function will start streaming a channel given in the context 
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \param *ctx This is the context of the current iios available on the raspberry pi
 * \return true if sucesss false otherwise
 */
static bool set_config_channel_streaming(iio_dev_ctx *dev_ctx[], struct iio_context *ctx)
{
	int i = 0;
	while(NULL != dev_ctx[i])  {
	//apply different information regarding the driversoi
		printf("Setting parameters to device %s \n", dev_ctx[i]->dev_name);
		if(!strcmp(dev_ctx[i]->dev_name,PEDAL_IN_DEVICE_NAME)) 
			set_param_bool(dev_ctx[i]->dev_channel, "en", true);

		i++;
	}

	return true;
}

/**
 * \brief This function will enable channels
 * \param *ctx This is the context of the current iios available on the raspberry pi
 * \return true if sucesss false otherwise
 */
static bool enable_channels(iio_dev_ctx *dev_ctx[])
{
	int i = 0;
	while(NULL != dev_ctx[i]) {
		iio_channel_enable(dev_ctx[i]->dev_channel);
		i++;
	}

	return true;
}

/**
 * \brief In debug mode , it allows the user to have more information about the devices
 * \param *dev_ctx[] is an Array of device context, in our case we have 3 devices, so 3 contextes
 * \return true if sucesss false otherwise
 */
static bool retrieve_attributes(iio_dev_ctx *dev_ctx[])
{
	int i=0, j, k;
	printf("*Retrieving parameters list\n");
	while( NULL != dev_ctx[i]) {
		printf("**Parameters for device %s\n", dev_ctx[i]->dev_name);
		for(j=0; j < iio_device_get_attrs_count(dev_ctx[i]->dev_iio_device); j++)
		{
			printf("***Device attribute%d. %s, \n", j, iio_device_get_attr(dev_ctx[i]->dev_iio_device, j));
		}

		for ( k = 0; k < iio_device_get_channels_count(dev_ctx[i]->dev_iio_device); k++) 
		{	
			for(j=0; j < iio_channel_get_attrs_count(iio_device_get_channel(dev_ctx[i]->dev_iio_device,k)); j++) 
			{
				printf("***Channel attribute, %s,\n", iio_channel_get_attr(dev_ctx[i]->dev_channel, j));
			}
		}

		i++;
	}
	
	return true;
}


int main (int argc,char *argv[]) 
{
	struct iio_context	*ctx = NULL;
	iio_dev_ctx		in_pedal_ctx;
	iio_dev_ctx		out_digipot10k_ctx;
	iio_dev_ctx		out_digipot50k_ctx;
	struct timeval 		sampling_freq;
	int			usec_value = 0;
	

	/* Definition of the 3 iios devices we are going to use */
	in_pedal_ctx.dev_direction = E_INPUT;
	in_pedal_ctx.dev_name = PEDAL_IN_DEVICE_NAME;
	in_pedal_ctx.dev_channelid = 0;
	in_pedal_ctx.channel_name = PEDAL_IN_CHANNEL_NAME;

	out_digipot10k_ctx.dev_direction = E_OUTPUT;
	out_digipot10k_ctx.dev_name =   DIGIPOT_10K_DEVICE_NAME;
	out_digipot10k_ctx.dev_channelid = 0;
	out_digipot10k_ctx.channel_name = DIGIPOT_CHANNEL_NAME;

	out_digipot50k_ctx.dev_direction = E_OUTPUT;
	out_digipot50k_ctx.dev_name =   DIGIPOT_50K_DEVICE_NAME;
	out_digipot50k_ctx.dev_channelid = 0;
	out_digipot50k_ctx.channel_name = DIGIPOT_CHANNEL_NAME;

	in_pedal_ctx.phy_name = "Pedal In";
	out_digipot10k_ctx.phy_name = "Digipot 10k";
	out_digipot50k_ctx.phy_name = "Digipot 50k";

	//Warning if you want to use more iio add them here and add NULL in the end
	iio_dev_ctx	*all_ctx[] = {&in_pedal_ctx, &out_digipot10k_ctx, &out_digipot50k_ctx ,NULL};

	/*Create hr timer trigger*/
	if( true != create_trigger_hrtimer()) {
		printf("Could not create trigger");
	}

	printf("* Acquiring IIO context\n");
	assert((ctx = iio_create_default_context()) && "No context");
	assert(iio_context_get_devices_count(ctx) > 0 && "No devices");

	if(get_stream_device(all_ctx, ctx) != true) {
		printf("Could not get stream device");
		return -1;
	}

	if(get_stream_channel(all_ctx, ctx) != true) {
		printf("Coud not get channel stream\n");
		return -1;
	}

	if(enable_channels(all_ctx) != true) {
		printf("Could not enable channels\n");
		return -1;
	}
#ifdef DEBUG
	retrieve_attributes(all_ctx);
#endif

	set_config_channel_streaming(all_ctx,ctx);

	while(1) {
		sampling_freq.tv_sec = (int) (SAMPLING_PERIOD_MS / 1000);
		usec_value = ((int)SAMPLING_PERIOD_MS);
		usec_value = usec_value % 1000;
		sampling_freq.tv_usec = usec_value;
		select(0,NULL, NULL, NULL, &sampling_freq);
		process_samples(all_ctx);
	}
}
