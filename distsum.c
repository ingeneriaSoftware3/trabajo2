/*****************************************************
 *
 * distsum.c : distributed sum of n integer numbers
 *             whose range is between 0 and 255
 * 
 *
 *
 ****************************************************/ 


#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>
#include "mpi.h"


#define SILENT  0
#define VERBOSE 1
#define MAX     256
#define TAG1    1
#define TAG2    2
#define TAG3    3
#define MASTER  0


unsigned int whoami, hmaw;

MPI_Status status;


/*
 * Shows the usage of the program
 */
void Usage(char *message) {
  
   printf("\nUsage : %s n [-V|-S]\nn : amount of numbers",message); 
   printf("\n    -V: Verbose mode\n    -S: Silent mode\n\n");
   fflush(stdout);
   MPI_Finalize();
}


/*
 * 
 */
void PrintData(unsigned int me, unsigned char *a, unsigned int n) {
  
   unsigned int i;
   
   for (i = 0; i < n; i = i + 1) {
      printf("From[ %d ] data[%d] = %d\n",me,i,a[i]);
      fflush(stdout);
   }
   printf("\n\n");
   fflush(stdout);
}
      

/*
 * 
 */
unsigned char *GenData(unsigned int n, unsigned int modop, unsigned int me) {
  
   unsigned char *a;
   unsigned int i;
   
   srand48(getpid());
   a = calloc(n,sizeof(unsigned char));
   for (i = 0; i < n; i = i + 1)
      a[i] = (int)((drand48() * n)) % MAX;
   if (modop == VERBOSE)
      PrintData(me,a,n);
   return a;
}


/*
 *
 */
void Process(unsigned char *a, unsigned int n, unsigned int modop) {

   unsigned int i, j, k, notyet, sum, rsum, *mess, *prev, work, rem;
   unsigned char *data;
   float E_cpu;
   clock_t cs, ce;
   long E_wall;
   time_t  ts, te; 
  
   
   sum = 0;
   prev = calloc(3,sizeof(unsigned int));
   if (whoami == MASTER) {
      mess = calloc(hmaw,sizeof(unsigned int));
      work = n / hmaw;
      rem = n % hmaw;
      for (i = 0; i < hmaw; i = i + 1)
         if (rem != 0) {
	           mess[i] = work + 1;
               rem = rem - 1;
         }
         else
	        mess[i] = work;

      data = calloc(mess[0],sizeof(unsigned char));

      for (i = 1; i < hmaw; i = i + 1) {
           prev[0] = modop;
	        prev[1] = mess[0];
	        prev[2] = mess[i];
	        MPI_Send(prev,3,MPI_UNSIGNED,i,TAG1,MPI_COMM_WORLD);
      }

      if (modop == VERBOSE) {

         printf("\nStarting ...\n\n");
         fflush(stdout);
      }

      ts = time(NULL);
      cs = clock();


      for (i = 1, j = mess[0]; i < hmaw; i = i + 1) {
         
	     for (k = 0; k < mess[i]; k = k + 1, j = j + 1) 
             data[k] = a[j];

	     MPI_Send(data,mess[0],MPI_UNSIGNED_CHAR,i,TAG2,MPI_COMM_WORLD);
      }
      for (i = 0; i < mess[0]; i = i + 1)
	        sum = sum + a[i];

      if (modop == VERBOSE) {
         printf("From %d Partial Sum = %d\n",whoami,sum);
         fflush(stdout);
      }	 
      for (i = 1; i < hmaw; i = i + 1){

	      MPI_Recv(&rsum,1,MPI_UNSIGNED,MPI_ANY_SOURCE,TAG3,MPI_COMM_WORLD,&status);
         sum = sum + rsum;
      } 

      ce = clock();
      te = time(NULL);
      E_wall = (long) (te - ts);
      E_cpu = (float)(ce - cs) / CLOCKS_PER_SEC;
      if (modop == VERBOSE) {
	 printf("From %d Total Sum = %d\n",whoami,sum);
	 fflush(stdout);
      }
      printf("\n\nElapsed CPU Time: %f [Secs] Elapsed Wall Time: %ld [Secs]\n\n",E_cpu,E_wall);
      fflush(stdout);
   }

   else {
      MPI_Recv(prev,3,MPI_UNSIGNED,MASTER,TAG1,MPI_COMM_WORLD,&status);
      modop = prev[0];
      data = calloc(prev[1],sizeof(unsigned char));
      MPI_Recv(data,prev[1],MPI_UNSIGNED_CHAR,MASTER,TAG2,MPI_COMM_WORLD,&status);
      for (i = 0; i < prev[2]; i = i + 1) {
         sum = sum + data[i];
         if (modop == VERBOSE) {
	    printf("From [%d] Data Received From MASTER = %d\n",whoami,data[i]);
	    fflush(stdout);
	 }
      } 
      if (modop == VERBOSE) {
         printf("From %d Partial Sum = %d\n",whoami,sum);
         fflush(stdout);
      }	      
      MPI_Send(&sum,1,MPI_UNSIGNED,MASTER,TAG3,MPI_COMM_WORLD);
   }
}


/*
 *
 */
void main( int argc, char *argv[]) {
  
   char processor_name[MPI_MAX_PROCESSOR_NAME];
   unsigned int me, n, modop;
   unsigned char *a;

   MPI_Init(&argc,&argv);
   MPI_Comm_size(MPI_COMM_WORLD,&hmaw);
   MPI_Comm_rank(MPI_COMM_WORLD,&whoami);
   MPI_Get_processor_name(processor_name,&me);
   printf("Process [%d] Alive on %s\n",whoami,processor_name);
   fflush(stdout);
   modop = SILENT;
   if (whoami == MASTER)  
     if (argc >= 2 && argc <= 3) {
        if (argc == 3) {
           if (strcmp(argv[2],"-V") == 0)
              modop = VERBOSE;
           if (strcmp(argv[2],"-S") == 0)
              modop = SILENT;
        }
        n = atoi(argv[1]);
        a = GenData(n,modop,whoami);
     }    
     else
        Usage(argv[0]);
   MPI_Barrier(MPI_COMM_WORLD);
   Process(a,n,modop);
   MPI_Finalize();      
}
