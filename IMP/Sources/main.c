/*
 * File name: main.c (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Source file containing main function, starting point for program and MCUInit function
 */


/* Header files */
#include "MK60D10.h" 	// MCU definitions
#include "Keyboard.h"	// Header file with functions for handling keyboard
#include "Speaker.h"	// Header file with functions for handling speaker


/* Function initializing the MCU */
void MCUInit(void)  {
    WDOG_STCTRLH &= ~WDOG_STCTRLH_WDOGEN_MASK;

    SIM_CLKDIV1 |= SIM_CLKDIV1_OUTDIV1(0x00);
    MCG_C4 |= ( MCG_C4_DMX32_MASK | MCG_C4_DRST_DRS(0x01) );

    SIM->SCGC5 = SIM_SCGC5_PORTA_MASK;
}


int main(void)
{
	/* Initialize components */
    MCUInit();
    KeyboardInit();
    SpeakerInit();

    /* Signal that program is loaded and ready to use */
    beep();

    /* Program loop */
    while (1) {
    	KeyboardRead();
    	if(beep_flag){
    		beep();
    	}
    }
    return 0;
}
