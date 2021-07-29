/*
 * File name: Keyboard.h (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Header file containing function declarations and macros for reading keyboard
 */

#ifndef Keyboard_h
#define Keyboard_h

#include "MK60D10.h"
#include "Coder.h"
#include "Speaker.h"

#define COL_COUNT 3	// Number of columns on keyboard
#define ROW_COUNT 4	// Number of rows on keyboard

// Pin definitions
#define PTA24 0x1000000
#define PTA25 0x2000000
#define PTA26 0x4000000
#define PTA27 0x8000000
#define PTA28 0x10000000
#define PTA29 0x20000000
#define PTA7 0x80

#define SPK 0x10          // Speaker is on PTA4

int nextState();
int pushLetter(int letter);
int speedUp();
int speedDown();
void KeyboardInit();
void KeyboardRead();
void KeyBoardClear();

#endif
