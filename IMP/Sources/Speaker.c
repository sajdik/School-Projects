/*
 * File name: Speaker.c (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Source file containing function definitions for speaker manipulation
 */


/* Header file with function declarations, global variables and macros */
#include "Speaker.h"


/* Function for LPTMR clocking initialization */
void LPTMR0Init()
{
    SIM_SCGC5 |= SIM_SCGC5_LPTIMER_MASK;	// Enable clock
    LPTMR0_CSR &= ~LPTMR_CSR_TEN_MASK; 	 	// Turn OFF before setup
    LPTMR0_PSR = ( LPTMR_PSR_PRESCALE(0)
                 | LPTMR_PSR_PBYP_MASK
                 | LPTMR_PSR_PCS(1)) ;
    LPTMR0_CMR = timeUnit;
    LPTMR0_CSR =(  LPTMR_CSR_TCF_MASK
                 | LPTMR_CSR_TIE_MASK
                );
    NVIC_EnableIRQ(LPTMR0_IRQn);			// Enable interrupts
    LPTMR0_CSR |= LPTMR_CSR_TEN_MASK;		// Turn ON to start counting
}

/* Function for interrupt handling */
void LPTMR0_IRQHandler(void)
{
	char state = QueueGet(&queue);
	if(state == 1){
		beep_flag = 1;
	}else{
		beep_flag = 0;
	}
    LPTMR0_CMR = timeUnit;
    LPTMR0_CSR |=  LPTMR_CSR_TCF_MASK;
}

/* Function for speaker initialization */
void SpeakerInit()
{
	timeUnit = DEFAULT_TIME_UNIT;	// Set length of time unit (one dot in morse code)
	LPTMR0Init();
	QueueInit(&queue);				// Init queue - morse code container
	beep_flag = 0;					// Speaker off

    PORTA->PCR[4] = PORT_PCR_MUX(0x01);
    // Speaker as output
    PTA->PDDR |= GPIO_PDDR_PDD(SPK);
    // Speaker off
    PTA->PDOR &= GPIO_PDOR_PDO(~SPK);
}


/* A delay function */
void delay(long long bound) {

  long long i;
  for(i=0;i<bound;i++);
}


/* A beep function */
void beep(void) {
	GPIOA_PDOR |=  SPK;
	delay(1200);
	GPIOA_PDOR &= ~SPK;
	delay(1200);
}

/* Function increases speed of speaker */
int speedUp(){
	timeUnit = timeUnit < MIN_TIME_UNIT + 0x40 ? MIN_TIME_UNIT : timeUnit - 0x40;
	return 0;
}

/* Function decreases speed of speaker */
int speedDown(){
	timeUnit = timeUnit > MAX_TIME_UNIT- 0x40 ? MAX_TIME_UNIT : timeUnit + 0x40;
	return 0;
}

