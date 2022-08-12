//+------------------------------------------------------------------+
//|                                                   MLP_Script.mq5 |
//|                                     Copyright 2020, Lethan Corp. |
//|                           https://www.mql5.com/pt/users/14134597 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lethan Corp."
#property link      "https://www.mql5.com/pt/users/14134597"
#property version   "1.00"

#define numInputs  3
#define numPatterns  4
#define numHidden 4

const int numEpochs = 200;
const double LR_IH = 0.7;
const double LR_HO = 0.07;

int patNum = 0;
double errThisPat = 0.0;
double outPred = 0.0;
double RMSerror = 0.0;

// the outputs of the hidden neurons
double hiddenVal[numHidden];

// the weights
double weightsIH[numInputs][numHidden];
double weightsHO[numHidden];

// the data
int X[numPatterns][numInputs];
int y[numPatterns];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void seed(int seed=-1)
  {
   if(seed!=-1)
      _RandomSeed=seed;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double random(void)
  {
   return ((double)rand())/(double)SHORT_MAX;
  }
//+------------------------------------------------------------------+
//|                   Initialize a network                           |
//+------------------------------------------------------------------+
void initialize_network(void)
  {
   for(int j = 0; j<numHidden; j++)
     {
      weightsHO[j] = (random() - 0.5)/2;
      for(int i = 0; i<numInputs; i++)
        {
         weightsIH[i][j] = (random() - 0.5)/5;
         printf("Weight = %f\n", weightsIH[i][j]);
        }
     }
  }
//+------------------------------------------------------------------+
//|         Forward propagate input to a network output              |
//+------------------------------------------------------------------+
void forward_propagate(void)
  {
//calculate the outputs of the hidden neurons
//the hidden neurons are tanh
   int i = 0;
   for(i = 0; i<numHidden; i++)
     {
      hiddenVal[i] = 0.0;
      for(int j = 0; j<numInputs; j++)
        {
         hiddenVal[i] += (X[patNum][j] * weightsIH[j][i]);
        }
      hiddenVal[i] = tanh(hiddenVal[i]);
     }
//calculate the output of the network
//the output neuron is linear
   outPred = 0.0;
   for(i = 0; i<numHidden; i++)
     {
      outPred += hiddenVal[i] * weightsHO[i];
     }
//calculate the error
   errThisPat = outPred - y[patNum];
  }
//+------------------------------------------------------------------+
//|                Regularisation on the output weights              |
//+------------------------------------------------------------------+
void regularisationWeights(double &weight)
  {
   weight<-5?weight=-5:weight>5?weight=5:weight=weight;
  }
//+------------------------------------------------------------------+
//|        Backpropagate error and change network weights            |
//+------------------------------------------------------------------+
void backward_propagate_error(void)
  {
//adjust the weights hidden-output
   for(int k = 0; k<numHidden; k++)
     {
      double weightChange = LR_HO * errThisPat * hiddenVal[k];
      weightsHO[k] -= weightChange;
      //regularisation on the output weights
      regularisationWeights(weightsHO[k]);
     }
// adjust the weights input-hidden
   for(int i = 0; i<numHidden; i++)
     {
      for(int k = 0; k<numInputs; k++)
        {
         double x = 1 - pow(hiddenVal[i],2);
         x = x * weightsHO[i] * errThisPat * LR_IH;
         x = x * X[patNum][k];
         double weightChange = x;
         weightsIH[k][i] -= weightChange;
        }
     }
  }
//+------------------------------------------------------------------+
//|                    read in the data                              |
//+------------------------------------------------------------------+
void initData(void)
  {
   printf("initialising data\n");

// the data here is the XOR data
// it has been rescaled to the range
// [-1][1]
// an extra input valued 1 is also added
// to act as the bias
// the output must lie in the range -1 to 1

   X[0][0]  = 1;
   X[0][1]  = -1;
   X[0][2]  = 1;    //bias
   y[0] = 1;

   X[1][0]  = -1;
   X[1][1]  = 1;
   X[1][2]  = 1;       //bias
   y[1] = 1;

   X[2][0]  = 1;
   X[2][1]  = 1;
   X[2][2]  = 1;        //bias
   y[2] = -1;

   X[3][0]  = -1;
   X[3][1]  = -1;
   X[3][2]  = 1;     //bias
   y[3] = -1;

  }
//+------------------------------------------------------------------+
//|              Make a prediction with a network                    |
//+------------------------------------------------------------------+
void predict(void)
  {
   for(int i = 0; i<numPatterns; i++)
     {
      patNum = i;
      forward_propagate();
      printf("real = %d predict = %f",y[patNum],outPred);
     }
  }
//+------------------------------------------------------------------+
//|       Train a network for a fixed number of epochs               |
//+------------------------------------------------------------------+
void train(void)
  {
   for(int j = 0; j <= numEpochs; j++)
     {
      for(int i = 0; i<numPatterns; i++)
        {
         //select a pattern at random
         patNum = rand()%numPatterns;
         //calculate the current network output
         //and error for this pattern
         forward_propagate();
         backward_propagate_error();
        }
      //display the overall network error
      //after each epoch
      calcOverallError();
      printf("epoch = %d RMS Error = %f",j,RMSerror);
     }
  }
//+------------------------------------------------------------------+
//|             calculate the overall error                          |
//+------------------------------------------------------------------+
void calcOverallError(void)
  {
   RMSerror = 0.0;
   for(int i = 0; i<numPatterns; i++)
     {
      patNum = i;
      forward_propagate();
      RMSerror += pow(errThisPat,2);
     }
   RMSerror/=numPatterns;
   RMSerror = sqrt(RMSerror);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
// seed random number function
   seed(42);
// initiate the weights
   initialize_network();
// load in the data
   initData();
// train the network
   train();
//training has finished
//display the results
   predict();
  }
//+------------------------------------------------------------------+
