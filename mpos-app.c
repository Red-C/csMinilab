#include "mpos-app.h"
#include "lib.h"

/*****************************************************************************
 * mpos-app
 *
 *   This application simply starts a child process and then waits for it
 *   to exit.  Both processes print messages to the screen.
 *
 *****************************************************************************/

void run_child2(void);

void
start2(void);
void run_child(void);

void
start(void)
{
	volatile int checker = 0; /* This variable checks that you correctly
				     gave the child process a new stack. */
	pid_t p;
	int status;

	app_printf("About to start a new process...\n");

	p = sys_fork();
	if (p == 0)
		run_child();
	else if (p > 0) {
		app_printf("Main process %d!\n", sys_getpid());
		p = sys_newthread(start2);
		do {
			status = sys_wait(p);
			app_printf("W");
		} while (status == WAIT_TRYAGAIN);
		app_printf("Child %d exited with status %d!\n", p, status);

		// Check whether the child process corrupted our stack.
		// (This check doesn't find all errors, but it helps.)
		if (checker != 0) {
			app_printf("Error: stack collision!\n");
			sys_exit(1);
		} else
			sys_exit(0);

	} else {
		app_printf("Error!\n");
		sys_exit(1);
	}
}

void
run_child(void)
{
	int i;
	volatile int checker = 1; /* This variable checks that you correctly
				     gave this process a new stack.
				     If the parent's 'checker' changed value
				     after the child ran, there's a problem! */

	app_printf("Child process %d!\n", sys_getpid());

	// Yield a couple times to help people test Exercise 3
	for (i = 0; i < 20; i++)
		sys_yield();

	sys_exit(1000);
}
volatile int counter;


void
start2(void)
{
	pid_t p;
	int status;

	counter = 0;

	while (counter < 5) {
		int n_started = 0;

		// Start as many processes as possible, until we fail to start
		// a process or we have started 1025 processes total.
		while (counter + n_started < 5) {
			p = sys_fork();
			if (p == 0)
				run_child();
			else if (p > 0)
				n_started++;
			else
				break;
		}

		// If we could not start any new processes, give up!
		if (n_started == 0)
			break;

		// We started at least one process, but then could not start
		// any more.
		// That means we ran out of room to start processes.
		// Retrieve old processes' exit status with sys_wait(),
		// to make room for new processes.
		for (p = 2; p < NPROCS; p++)
			(void) sys_wait(p);
	}

	sys_exit(0);
}

void
run_child2(void)
{
	int input_counter = counter;

	pid_t pid = sys_getpid();
	if(pid % 2 == 0 && pid != 0){
		sys_kill(pid+1);
		counter++;		/* Note that all "processes" share an address
				   space, so this change to 'counter' will be
				   visible to all processes. */
	}

	app_printf("Process %d lives, counter %d!\n",
	   sys_getpid(), input_counter);
	sys_exit(input_counter);
}
