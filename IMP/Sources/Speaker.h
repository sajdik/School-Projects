/*
 * File name: Speaker.h (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Header file containing macros, globals and function declaration for speaker functionality
 */

#ifndef SPEAKER_H_
#define SPEAKER_H_

/* Header files */
#include "MK60D10.h"	// Definitions for MCU
#include "Queue.h"		// Queue type definition and functions

#define SPK 0x10        // Speaker is on PTA4

#define DEFAULT_TIME_UNIT 0x80
#define MAX_TIME_UNIT (DEFAULT_TIME_UNIT * 3)
#define MIN_TIME_UNIT (DEFAULT_TIME_UNIT / 3)

tQueue queue;			// Morse code queue
int beep_flag;			// Beep or not
unsigned int timeUnit;	// Length of time unit (one dot in morse code)

void delay(long long bound);
void beep(void);
void SpeakerInit();
int speedDown();
int speedUp();

#endif
