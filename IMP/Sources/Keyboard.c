/*
 * File name: Keyboard.c (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Source file containing function definitions reading keyboard and parsing input
 */

#include "Keyboard.h"

const int Cols[3] = {PTA26, PTA7, PTA29};			// Pins that are columns
const int Rows[4] = {PTA27, PTA25, PTA28, PTA24};	// Pins that are rows

/* Keyboard buttons definition */
const int Keyboard[4][3] = {{'1', '2', '3'},
							{'4', '5', '6'},
							{'7', '8', '9'},
							{'*', '0', '#'}};

int pressed = 0;	// Whether is any key pressed


/* Function clears all pins in output register */
void KeyBoardClear(){
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA7);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA24);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA25);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA26);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA27);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA28);
    PTA->PDOR &= GPIO_PDOR_PDO(~PTA29);
}


/* Function initialize keyboard pins*/
void KeyboardInit(){
	/* Keyboard pins for GPIO */
	for(int i=24; i<=29; i++) {
		PORTA->PCR[i] = ( PORT_PCR_MUX(0x01)
						| PORT_PCR_PE(0x00)
						| PORT_PCR_PS(0x00)
						);
	}
	PORTA->PCR[7] = (PORT_PCR_MUX(0x01)
					| PORT_PCR_PE(0x00)
					| PORT_PCR_PS(0x00)
					);


    /* Change keyboard pins as outputs */
    PTA->PDDR |= GPIO_PDDR_PDD(PTA7)
			 |  GPIO_PDDR_PDD(PTA24)
			 |  GPIO_PDDR_PDD(PTA25)
			 |  GPIO_PDDR_PDD(PTA26)
			 |  GPIO_PDDR_PDD(PTA27)
			 |  GPIO_PDDR_PDD(PTA28)
			 |  GPIO_PDDR_PDD(PTA29);

    KeyBoardClear();
}


/* Function returns pressed button */
int GetKey(){
	for(int i = 0; i < COL_COUNT; i++){
    	KeyBoardClear();
		PTA->PDOR |= GPIO_PDOR_PDO(Cols[i]);
		delay(5);
        if (!(GPIOA_PDIR & Cols[i]))
        {
    		for (int j = 0; j < ROW_COUNT; j++){
    			KeyBoardClear();
    			PTA->PDOR |= GPIO_PDOR_PDO(Rows[j]);
    			delay(5);
    	        if (!(GPIOA_PDIR & Rows[j]))
    	        {
    	        	return Keyboard[j][i];
    	        }
    		}
        }
	}
	return 0;
}


/* Function sends letter to coder */
int pushLetter(int letter){
	if(letter != 0){
		ParseLetter(letter);
	}
	return 0;
}


/* Function chooses next state based on pressed key and proccess current state */
int nextState(int key, int state){
	pushLetter(state);

	switch(key){
		case '1': return 0; // placeholder
		case '2': return 'A';
		case '3': return 'D';
		case '4': return 'G';
		case '5': return 'J';
		case '6': return 'M';
		case '7': return 'P';
		case '8': return 'T';
		case '9': return 'W';
		case '0': return pushLetter('@');
		case '*': return speedDown();
		case '#': return speedUp();
	}
	return 0;
}


/* Function reads keyboard and handles input */
void KeyboardRead(){
	int key = GetKey();
	if(!pressed && key != 0){
		pressed = 1;
		static int state = 0;
			switch(state){
				case 'A':
					if(key == '2') state = 'B';
					else state = nextState(key, state);
					break;
				case 'B':
					if(key == '2') {
						nextState(key, 'C');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'D':
					if(key == '3') state = 'E';
					else state = nextState(key, state);
					break;
				case 'E':
					if(key == '3') {
						nextState(key, 'F');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'G':
					if(key == '4') state = 'H';
					else state = nextState(key, state);
					break;
				case 'H':
					if(key == '4'){
						nextState(key, 'I');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'J':
					if(key == '5') state = 'K';
					else state = nextState(key, state);
					break;
				case 'K':
					if(key == '5') {
						nextState(key, 'L');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'M':
					if(key == '6') state = 'N';
					else state = nextState(key, state);
					break;
				case 'N':
					if(key == '6') {
						nextState(key, 'O');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'P':
					if(key == '7') state = 'Q';
					else state = nextState(key, state);
					break;
				case 'Q':
					if(key == '7') state = 'R';
					else state = nextState(key, state);
					break;
				case 'R':
					if(key == '7'){
						nextState(key, 'S');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'T':
					if(key == '8') state = 'U';
					else state = nextState(key, state);
					break;
				case 'U':
					if(key == '8'){
						nextState(key, 'V');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				case 'W':
					if(key == '9') state = 'X';
					else state = nextState(key, state);
					break;
				case 'X':
					if(key == '9') state = 'Y';
					else state = nextState(key, state);
					break;
				case 'Y':
					if(key == '9'){
						nextState(key, 'Z');
						state = 0;
					}
					else state = nextState(key, state);
					break;
				default:
					state = nextState(key, state);
					break;
			}

	}else if(key == 0){
		pressed = 0;
	}
}
