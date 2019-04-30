/**
* @File proj2.c
* @brief IOS 2. project
* @author xsajdi01
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <semaphore.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <time.h>
#include <signal.h>
#include <stdbool.h>

//Macros
#define ERROR fprintf(stderr,"Failed to initialize!\n"); exit(1)

#define LOCKED 0
#define UNLOCKED 1
#define FILENAME "proj2.out"
//SEMAPHORES
#define SEMAPHORE_ENTER_NAME "/xsajdi01_semaphore_enter"
#define SEMAPHORE_BOARD_NAME "/xsajdi01_semaphore_board"
#define SEMAPHORE_PRINT_NAME "/xsajdi01_semaphore_print"
#define SEMAPHORE_DEPART_NAME "/xsajdi01_semaphore_depart"
#define SEMAPHORE_FINISH_NAME "/xsajdi01_semaphore_finish"




sem_t *enter = NULL;
sem_t *board = NULL;
sem_t *print = NULL;
sem_t *depart = NULL;
sem_t *finish = NULL;



//OUTPUTFILE
FILE *file = NULL;
///SHARED MEMORY
//count of riders on bus station
int stationCounterID = 0;
int *stationCounter = NULL;
//count of riders currently in bus
int currentCapacityID = 0;
int *curentCapacity = NULL;
//count of transported riders
int transportedCounterID = 0;
int *transportedCounter = NULL;
//count of printed Messages
int *printCounter = NULL;
int printCounterID = 0;

/**
* @brief Check arguments
* @param[in] argc Argument count
* @param[in] argv Array of arguments
* @param[out] errMsg ErrorMessage
* @return result of check (true or false)
*/

bool argCheck(int argc, char *argv[],char **errMsg)
{
  if(argc != 5){
    *errMsg = "Wrong number of arguments!\n";
    return false;
  }
  if(atoi(argv[1]) <= 0){
    *errMsg = "Number of riders has to be > 0! (1. argument)\n";
    return false;
  }
  if(atoi(argv[2]) <= 0){
    *errMsg = "Number of buses has to be > 0! (2. argument)\n";
    return false;
  }
  if(atoi(argv[3]) < 0 || atoi(argv[3]) > 1000){
    *errMsg = "ART value has to be >= 0 and <= 1000! (3. argument)\n";
    return false;
  }
  if(atoi(argv[4]) < 0 || atoi(argv[4]) > 1000){
    *errMsg = "ABT value has to be >= 0 and <= 1000! (4. argument)\n";
    return false;
  }
  return true;
}

/**
*@brief Process Rider
*@param[in] i Rider index
*@param[in] MaxCapacity Maximum bus capacity
*/
void Rider(const int i,const int MaxCapacity)
{

  sem_wait(print);
  fprintf(file,"%d: RID %d: start\n",(*printCounter)++,i);
  sem_post(print);

  sem_wait(enter); //Enter bus station

  sem_wait(print);
  fprintf(file,"%d: RID %d: enter: %d\n",(*printCounter)++,i,(*stationCounter));
  sem_post(print);
  (*stationCounter)++;

  sem_post(enter);
  sem_wait(board); //board to bus

  sem_wait(print);
  fprintf(file,"%d: RID %d: boarding\n",(*printCounter)++,i);
  sem_post(print);

  (*stationCounter)--;
  (*curentCapacity)++;
  if ((*stationCounter) == 0 || (*curentCapacity) == MaxCapacity){
    sem_post(depart);
  }
  else{
    sem_post(board);
  }

  sem_wait(finish); //bus has reached final destination

  sem_wait(print);
  fprintf(file,"%d: RID %d: finish\n",(*printCounter)++,i);
  sem_post(print);
  exit(EXIT_SUCCESS);
}

/**
*@brief Creator of riders
*@param[in] RidersTotal Total number  of riders that needs to be transported
*@param[in] MaxCapacity Maximum transportable riders at at one moment
*/
void riderCreator(const int RidersTotal,const int MaxCapacity,const int ART)
{
  for(int i = 1;i<=RidersTotal;i++){
    if(ART) usleep(rand()%(ART+1));
    if(fork() == 0){ //child
      Rider(i,MaxCapacity);
    }
  }
  for(int i =0;i<RidersTotal;i++){
    wait(NULL);
  }
  exit(EXIT_SUCCESS);
}

/**
* @brief Process Buss
* @param[in] RidersTotal Total number of riders
* @param[in] ABT Maximum lenght of bus ride
*/
void Buss(const int RidersTotal,const int ABT)
{

  do{
  sem_wait(print);
  fprintf(file,"%d: BUS: start\n",(*printCounter)++);
  sem_post(print);

  sem_wait(enter); //enter bus stop

  sem_wait(print);
  fprintf(file,"%d: BUS: arrival\n",(*printCounter)++);
  sem_post(print);

  if((*stationCounter ) > 0){
    sem_wait(print);
    fprintf(file,"%d: BUS: start boarding: %d\n",(*printCounter)++,(*stationCounter));
    sem_post(print);

    sem_post(board);
    sem_wait(depart);
  }
   //leave bus stop

  sem_wait(print);
  fprintf(file,"%d: BUS: end boarding: %d\n",(*printCounter)++,(*stationCounter));
  sem_post(print);

  sem_wait(print);
  fprintf(file,"%d: BUS: depart\n",(*printCounter)++);
  sem_post(print);

  sem_post(enter);
  if(ABT) usleep(rand()%(ABT+1));

  sem_wait(print);
  fprintf(file,"%d: BUS: end\n",(*printCounter)++);
  sem_post(print);
  (*transportedCounter)+=(*curentCapacity);
  for(;(*curentCapacity)>0;(*curentCapacity)--){ //vylozit
    sem_post(finish);
  }
} while ((*transportedCounter) < RidersTotal);


  sem_wait(print);
  fprintf(file,"%d: BUS: finish\n",(*printCounter)++);
  sem_post(print);
  exit(EXIT_SUCCESS);
}

/**
*@brief Creates Semaphores
*@return 1 in succes 2 in failure
*/
bool CreateSemaphores(){

  if ((enter = sem_open(SEMAPHORE_ENTER_NAME, O_CREAT | O_EXCL, 0666, UNLOCKED)) == SEM_FAILED){
    return false;
  }
  if ((board = sem_open(SEMAPHORE_BOARD_NAME, O_CREAT | O_EXCL, 0666, LOCKED)) == SEM_FAILED){
    return false;
  }
  if ((print = sem_open(SEMAPHORE_PRINT_NAME, O_CREAT | O_EXCL, 0666, UNLOCKED)) == SEM_FAILED){
    return false;
  }
  if ((depart = sem_open(SEMAPHORE_DEPART_NAME, O_CREAT | O_EXCL, 0666, LOCKED)) == SEM_FAILED){
    return false;
  }
  if ((finish = sem_open(SEMAPHORE_FINISH_NAME, O_CREAT | O_EXCL, 0666, LOCKED)) == SEM_FAILED){
    return false;
  }

  return true;
}
/**
*@brief Destroy All Semaphores
*/
void DestroySemaphores(){
  //close
  sem_close(enter);
  sem_close(board);
  sem_close(print);
  sem_close(depart);
  sem_close(finish);

  //remove
  sem_unlink(SEMAPHORE_ENTER_NAME);
  sem_unlink(SEMAPHORE_BOARD_NAME);
  sem_unlink(SEMAPHORE_PRINT_NAME);
  sem_unlink(SEMAPHORE_DEPART_NAME);
  sem_unlink(SEMAPHORE_FINISH_NAME);

}

/**
*@ Create shared memory
*/
bool createMemory()
{
  if ((printCounterID = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | 0666)) == -1) return false;
  if ((printCounter = shmat(printCounterID,NULL,0)) == NULL) return false;
  if ((stationCounterID = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | 0666)) == -1) return false;
  if ((stationCounter = shmat(stationCounterID,NULL,0)) == NULL) return false;
  if ((currentCapacityID = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | 0666)) == -1) return false;
  if ((curentCapacity = shmat(currentCapacityID,NULL,0)) == NULL) return false;
  if ((transportedCounterID = shmget(IPC_PRIVATE, sizeof(int),IPC_CREAT | 0666)) == -1) return false;
  if ((transportedCounter = shmat(transportedCounterID,NULL,0)) == NULL) return false;
  return true;
}

/**
*@ Clear shared memory
*/
void clearMemory()
{
  shmctl(printCounterID, IPC_RMID,NULL);
  shmctl(stationCounterID, IPC_RMID,NULL);
  shmctl(currentCapacityID, IPC_RMID,NULL);
  shmctl(transportedCounterID, IPC_RMID,NULL);
}

/*
* Starting point
*/
int main(int argc,char *argv[])
{
  setbuf(stderr,NULL);

  srand(time(NULL));
  // Argument check
  char *errMsg;
  if(!argCheck(argc,argv,&errMsg)){
    fprintf(stderr,"%s",errMsg);
    return EXIT_FAILURE;
  }
  //create semaphores and memory
  if(!CreateSemaphores() || !createMemory()){
      ERROR;
  }
  //open file
    file = fopen(FILENAME,"w");
    if(file == NULL){
    fprintf(stderr, "Failed to open file...\n");
    return EXIT_FAILURE;
  }
  setbuf(file,NULL);
  //initialize shared memory
  (*transportedCounter) = 0;
  (*stationCounter) = 0;
  (*curentCapacity) = 0;
  (*printCounter) = 1;

  //create processes
  pid_t processPid = fork();
  if(processPid == 0){ //child
    Buss(atoi(argv[1]),atoi(argv[4]));
  }
  processPid = fork();
  if(processPid == 0){
    riderCreator(atoi(argv[1]),atoi(argv[2]),atoi(argv[3]));
  }
  //Wait for 2 childrens ended
  wait(NULL);
  wait(NULL);
  fclose(file);
  //Clean stuff
  clearMemory();
  DestroySemaphores();

  return EXIT_SUCCESS;
}
