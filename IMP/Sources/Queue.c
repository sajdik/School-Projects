/*
 * File name: Queue.c (Original)
 * Author: Ondrej Šajdík
 * Login: xsajdi01
 * Last changed on: 19.12.2019
 * Source file containing function definitions for queue structure manipulation
 */

/* Header file with function declarations, macros and queue type definition */
#include "Queue.h"


/* Function initialize queue q with 0 values */
void QueueInit (tQueue* q) {
	if (q == NULL){
		return;
	}

	for(int i= 0; i < QUEUE_SIZE; i++){
		q->arr[i] = 0;
	}
	q->f_index = 0;
	q->b_index = 0;
}


/* Function returns next index aligned with queue size */
int NextIndex (int index) {
	return (index + 1) % QUEUE_SIZE;

}


/* Function checks if queue q is empty and returns result */
int QueueEmpty (const tQueue* q) {
	return q->f_index == q->b_index;
}


/* Function checks if queue q is full and returns result */
int QueueFull (const tQueue* q) {
	return NextIndex(q->b_index) == q->f_index;
}


/* Function returns value from front of the queue q */
char QueueFront (const tQueue* q) {
	if(QueueEmpty(q)){
		return 0;
	}
	return q->arr[q->f_index];
}


/* Function removes value from front of the queue q */
void QueueRemove (tQueue* q) {
	if(QueueEmpty(q)){
		return;
	}
	q->f_index = NextIndex(q->f_index);
}


/* Function returns value from front of the queue and then removes it from queue q */
char QueueGet (tQueue* q) {
	if(QueueEmpty(q)){
		return 0;
	}
	char c = QueueFront(q);
	QueueRemove(q);
	return c;
}


/* Function add value c to end of the queue q */
void QueueAdd (tQueue* q, char c) {
	if(QueueFull(q)){
		return;
	}

	q->arr[q->b_index] = c;
	q->b_index = NextIndex(q->b_index);
}
