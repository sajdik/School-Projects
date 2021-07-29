/*
 * File name: Coder.h (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Header file containing function declarations and macros
 */

#ifndef SOURCES_CODER_H_
#define SOURCES_CODER_H_

/* Header file containing memset function*/
#include <string.h>

/* Header files necessary to parse Morse code to speaker */
#include "Speaker.h"
#include "Queue.h"

#define MAXSIZE 20 //Maximum size of letter coded in Morse code

void ParseLetter(int letter);
void getMorseCodeFromLetter(int letter, char *m, int* length);
void putMorseCodeToQueue(char *morseCode, int length);

#endif /* SOURCES_CODER_H_ */
