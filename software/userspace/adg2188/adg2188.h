#ifndef _ADG2188_H
#define _ADG2188_H

#include <stdbool.h>

typedef struct adg2188 {
	int fd;
} adg2188_t;

int adg2188_init(adg2188_t *adg, int adapter, int A);
void adg2188_close(adg2188_t *adg);

int adg2188_set_switch(adg2188_t *adg, unsigned x, unsigned y, bool closed, bool immediate);

#endif /* _ADG2188_H */
