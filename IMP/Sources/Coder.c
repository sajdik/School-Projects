/*
 * File name: Coder.c (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Source file containing function definitions for coding letters into Morse code and passing it to speaker
 */

/* Header file with function declarations, global variables and macros */
#include "Coder.h"

/* Function code letter and returns Morse code in par m and length of code in par length*/
void getMorseCodeFromLetter(int letter, char *m, int* length){
	switch(letter){
		case 'A':
			m[0] = m[2] = m[3] = m[4] = 1;
			*length = 8;
			break;
		case 'B':
			m[0] = m[1] = m[2] = m[4] = m[6] = m[8] = 1;
			*length = 12;
			break;
		case 'C':
			m[0] = m[1] = m[2] = m[4] = m[6] = m[7] = m[8] = m[10] = 1;
			*length = 14;
			break;
		case 'D':
			m[0] = m[1] = m[2] = m[4] = m[6] = 1;
			*length = 10;
			break;
		case 'E':
			m[0] = 1;
			*length = 4;
			break;
		case 'F':
			m[0] = m[2] = m[4] = m[5] = m[6] = m[8] = 1;
			*length = 12;
			break;
		case 'G':
			m[0] = m[1] = m[2] = m[4] = m[5] = m[6] = m[8] = 1;
			*length = 12;
			break;
		case 'H':
			m[0] = m[2] = m[4] = m[6] = 1;
			*length = 10;
			break;
		case 'I':
			m[0] = m[2] = 1;
			*length = 6;
			break;
		case 'J':
			m[0] = m[2] = m[3] = m[4] = m[6] = m[7] = m[8] = m[10] = m[11] = m[12] = 1;
			*length = 16;
			break;
		case 'K':
			m[0] = m[1] = m[2] = m[4] = m[6] = m[7] = m[8] = 1;
			*length = 12;
			break;
		case 'L':
			m[0] = m[2] = m[3] = m[4] = m[6] = m[8] = 1;
			*length = 12;
			break;
		case 'M':
			m[0] = m[1] = m[2] = m[4] = m[5] = m[6]= 1;
			*length = 10;
			break;
		case 'N':
			m[0] = m[1] = m[2] = m[4] = 1;
			*length = 8;
			break;
		case 'O':
			m[0] = m[1] = m[2] = m[4] = m[5] = m[6] = m[8] = m[9] = m[10] = 1;
			*length = 14;
			break;
		case 'P':
			m[0] = m[2] = m[3] = m[4] = m[6] = m[7] = m[8] = m[10] = 1;
			*length = 14;
			break;
		case 'Q':
			m[0] = m[1] = m[2] = m[4] = m[5] = m[6] = m[8] = m[10] = m[11] = m[12]= 1;
			*length = 16;
			break;
		case 'R':
			m[0] = m[2] = m[3] = m[4]  = m[6] = 1;
			*length = 10;
			break;
		case 'S':
			m[0] = m[2] = m[4] = 1;
			*length = 8;
			break;
		case 'T':
			m[0] = m[1] = m[2] = 1;
			*length = 6;
			break;
		case 'U':
			m[0] = m[2] = m[4] = m[5] = m[6] = 1;
			*length = 10;
			break;
		case 'V':
			m[0] = m[2] = m[4] = m[6] = m[7] = m[8] = 1;
			*length = 12;
			break;
		case 'W':
			m[0] = m[2] = m[3] = m[4] = m[6] = m[7] = m[8] = 1;
			*length = 12;
			break;
		case 'X':
			m[0] = m[1] = m[2] = m[4] = m[6] = m[8] = m[9] = m[10] = 1;
			*length = 14;
			break;
		case 'Y':
			m[0] = m[1] = m[2] = m[4] = m[6] = m[7] = m[8] = m[10] = m[11] = m[12] = 1;
			*length = 16;
			break;
		case 'Z':
			m[0] = m[1] = m[2] = m[4]  = m[5] = m[6] = m[8] = m[10] = 1;
			*length = 14;
			break;
		case '@':
			*length = 7;
			break;
		default: *length = 0; break;
	}
}


/* Function takes morseCode of the length and puts it to the end of speaker queue */
void putMorseCodeToQueue(char *morseCode, int length){
	for(int i = 0; i < length; i++){
		QueueAdd(&queue, morseCode[i]);
	}
}


/* Function code letter to Morse code and parse it to speaker*/
void ParseLetter(int letter){
	char morseCodeBuff[MAXSIZE];
	int morseCodeLength;

	memset(morseCodeBuff, 0, MAXSIZE);

	getMorseCodeFromLetter(letter, morseCodeBuff, &morseCodeLength);
	putMorseCodeToQueue(morseCodeBuff, morseCodeLength);
}



