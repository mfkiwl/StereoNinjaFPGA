#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <signal.h>
#include "verilated.h"
#include "VSERIAL"
#include "testb.h"

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	TESTB<VSERIAL>	*tb
		= new TESTB<VSERIAL>;
	tb->opentrace("blinky.vcd");
	//tb->m_core->btn= 0;

	for (int i=0; i < 1000; i++) {
		tb->m_core->state=2;
		tb->m_core->pix_data=57;
	    tb->tick();
	}
	printf("\n\nSimulation complete\n");
}
