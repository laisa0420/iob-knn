#include "system.h"
#include "periphs.h"
#include <iob-uart.h>
#include "iob_timer.h"
#include "iob_knn.h"
#include "random.h" //random generator for bare metal
#include "interconnect.h"
#include "KNNsw_reg.h"
#include <time.h>
#include <stdio.h>

//uncomment to use rand from C lib 
//#define cmwc_rand rand

#ifdef DEBUG //type make DEBUG=1 to print debug info
#define S 12  //random seed
#define N 10  //data set size
#define K 4   //number of neighbours (K)
#define C 4   //number data classes
#define M 4   //number samples to be classified
#else
#define S 12   
#define N 10
#define K 4  
#define C 4  
#define M 4
#define TP_ULIMIT 50 //simas --50 basys3||200 placa
#endif

#define INFINITE ~0


//base address
static int base_knn;

void knn_init( int base_address){
  base_knn=base_address;
}

//
//Data structures
//

//labeled dataset
struct datum {
  unsigned short x;
  unsigned short y;
  unsigned char label;
} data[N], x[M];


//neighbor info
struct neighbor {
  unsigned int idx; //index in dataset array
  unsigned int dist; //distance to test point
} neighbor[K];

//
//Functions
//

//square distance between 2 points a and b
unsigned int sq_dist( struct datum a, struct datum b) {
  short X = a.x-b.x;
  unsigned int X2=X*X;
  short Y = a.y-b.y;
  unsigned int Y2=Y*Y;
  return (X2 + Y2);
}

//insert element in ordered array of neighbours
void insert (struct neighbor element, unsigned int position) {
  for (int j=K-1; j>position; j--)
    neighbor[j] = neighbor[j-1];

  neighbor[position] = element;

}

/*
void write_test_to_reg(struct datum point){
  int *data_out = (struct datum *) &point;
  IO_SET(base_knn,TEST_POINT,data_out);
}

void write_data_to_reg(struct datum point){
  int *data_out = (struct datum *) &point;
  IO_SET(base_knn,DATA_POINT,data_out);
}*/


int main() {


  unsigned long long elapsed=0;
  unsigned int elapsedu=0;

  //init uart and timer
  uart_init(UART_BASE, FREQ/BAUD);
  uart_printf("\nInit timer\n");
  uart_txwait();

  timer_reset(TIMER_BASE);

  int k=0;
  struct datum* data_IOSET;
  char* data_label;



  //read current timer count, compute elapsed time
  //elapsed  = timer_get_count();
  //elapsedu = timer_time_us();


  //int vote accumulator
  int votes_acc[C] = {0};

  //generate random seed 
  random_init(S);

  //init dataset
  for (int i=0; i<N; i++) {

    //init coordinates
    data[i].x = (short) cmwc_rand();
    data[i].y = (short) cmwc_rand();

    //init label
    data[i].label = (unsigned char) (cmwc_rand()%C);
  }

#ifdef DEBUG
  uart_printf("\n\n\nDATASET\n");
  uart_printf("Idx \tX \tY \tLabel\n");
  for (int i=0; i<N; i++)
    uart_printf("%d \t%d \t%d \t%d\n", i, data[i].x,  data[i].y, data[i].label);
#endif
  
  //init test points
  for (int k=0; k<M; k++) {
    x[k].x  = (short) cmwc_rand();
    x[k].y  = (short) cmwc_rand();
    //x[k].label will be calculated by the algorithm
  }

#ifdef DEBUG
  uart_printf("\n\nTEST POINTS\n");
  uart_printf("Idx \tX \tY\n");
  for (int k=0; k<M; k++)
    uart_printf("%d \t%d \t%d\n", k, x[k].x, x[k].y);
#endif
  
  //
  // PROCESS DATA
  //

  //start knn here
  knn_init(KNN_BASE);
  timer_init(TIMER_BASE);

  //for (k=0; k<M; k+= TP_ULIMIT){ //Tem o index do bloco de 50 TestPoints || bloco50[0] -- bloco50[1] (...)

#ifdef DEBUG
    uart_printf("\n\nProcessing x[%d]:\n", k);
#endif

#ifdef DEBUG
    uart_printf("Datum \tX \tY \tLabel \tDistance\n");
#endif
    //knn_reset //AKA fzr reset no hardware


    //Mandar 1 bloco de 50 TPoints
   /* for (int i = 0; i < M && i < TP_ULIMIT ; i++){
        int offset = i+k;
        targetADDR = BANK_REG0 + offset;
        *data_IOSET = (struct datum *) &(x[offset]);
        IO_SET(base, targetADDR, data_IOSET); // XY concatenado ->ver VIP
    }*/

    IO_SET(base_knn, KNN_RESET, 1);

    IO_SET(base_knn, KNN_ENABLE, 1);
    
    unsigned short x_val;
    unsigned short y_val;
    unsigned int coord_test[4];
    unsigned int address_tp = 0;
    IO_SET(base_knn, KNN_RESET, 0);
    for(int a = 0; a < 4; a++){
      x_val = x[a].x;
      y_val = x[a].y;
      //uart_printf("a=%d = %d %d\n",a,x_val,y_val);
      
      coord_test[a] = (unsigned int)(x_val <<16) | (unsigned short)y_val; 
      //uart_printf("coordtest = %d\n\n",coord_test[a]);
      address_tp = BANK_TESTP0+a;
      IO_SET(base_knn, address_tp, coord_test[a]);
    }
    unsigned int coord_data;
    char label_data;
    
    
    
    IO_SET(base_knn, KNN_START, 1);

    //knn_start -- provavelmente distribuir do banco de registos para cada modulo


    //Mandar 1 dataPoint de cada vez
    for(int d = 0; d<N; d++){
      x_val = data[d].x;
      y_val = data[d].y;
      coord_data = (unsigned int)(x_val <<16) | (unsigned short)y_val; 
      IO_SET(base_knn,DATAP_REG,coord_data); // X Y LABEL lim 32 bits
      label_data = data[d].label;
      IO_SET(base_knn,LABEL_REG,label_data);
    }

    //clear all votes
    int votes[C] = {0};
    int best_votation = 0;
    int best_voted = 0;
    int nb_list0 = 0;

    nb_list0 = IO_GET(base_knn, BANK_nb_list0);
    uart_printf("%d\n",nb_list0);


    //make neighbours vote
    for (int j=0; j<K; j++) { //for all neighbors
      if ( (++votes[data[neighbor[j].idx].label]) > best_votation ) {
        best_voted = data[neighbor[j].idx].label;
        best_votation = votes[best_voted];
      }
    }

    x[k].label = best_voted;

    votes_acc[best_voted]++;
    
#ifdef DEBUG
    uart_printf("\n\nNEIGHBORS of x[%d]=(%d, %d):\n", k, x[k].x, x[k].y);
    uart_printf("K \tIdx \tX \tY \tDist \t\tLabel\n");
    for (int j=0; j<K; j++)
      uart_printf("%d \t%d \t%d \t%d \t%d \t%d\n", j+1, neighbor[j].idx, data[neighbor[j].idx].x,  data[neighbor[j].idx].y, neighbor[j].dist,  data[neighbor[j].idx].label);
    
    uart_printf("\n\nCLASSIFICATION of x[%d]:\n", k);
    uart_printf("X \tY \tLabel\n");
    uart_printf("%d \t%d \t%d\n\n\n", x[k].x, x[k].y, x[k].label);

#endif

  //} //all test points classified

  //stop knn here
  //read current timer count, compute elapsed time
  elapsedu=timer_time_us(TIMER_BASE);
  uart_printf("\nExecution time: %dus @%dMHz\n\n", elapsedu, FREQ/1000000);


  
  //print classification distribution to check for statistical bias
  for (int l=0; l<C; l++)
    uart_printf("%d ", votes_acc[l]);
  uart_printf("\n");
  
}


