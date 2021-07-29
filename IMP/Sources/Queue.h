/*
 * File name: Queue.h (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Header file containing queue structure definition and function declarations for its manipulation
 */

#ifndef QUEUE_H
#define QUEUE_H

/* Header file containing NULL definition */
#include <stddef.h>

/* Size of the queue */
#define QUEUE_SIZE 200

/* Queue type structure */
typedef struct {
    char arr[QUEUE_SIZE];	// Size of queue
    int f_index;			// Index of front of the queue
    int b_index;			// Index of back of the queue
} tQueue;


void QueueInit (tQueue* q);
int NextIndex (int index);
int QueueEmpty (const tQueue* q);
int QueueFull (const tQueue* q);
char QueueFront (const tQueue* q);
void QueueRemove (tQueue* q);
char QueueGet (tQueue* q);
void QueueAdd (tQueue* q, char c);

#endif

