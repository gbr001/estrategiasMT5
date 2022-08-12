//+------------------------------------------------------------------+
//|                                                PerceptronXOR.mq5 |
//|                                     Copyright 2020, Lethan Corp. |
//|                           https://www.mql5.com/pt/users/14134597 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Lethan Corp."
#property link      "https://www.mql5.com/pt/users/14134597"
#property version   "1.00"
//#property script_show_inputs

#include "Libraries\Util.mqh"

#define nINPUT 3

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---

   double dataset[][nINPUT] =      
            //X1      //X2      //y
     {
        {2.7810836,  2.550537003, 0},
        {1.465489372,2.362125076, 0},
        {3.396561688,4.400293529, 0},
        {1.38807019, 1.850220317, 0},
        {3.06407232, 3.005305973, 0},
        {7.627531214,2.759262235, 1},
        {5.332441248,2.088626775, 1},
        {6.922596716,1.77106367,  1},
        {8.675418651,-0.242068655,1},
        {7.673756466,3.508563011, 1}
     };


   double weights[];
   train_weights(weights, dataset, 0.1, 100);

   for(int row=0; row<ArrayRange(dataset, 0); row++)
     {
      double predict = predict(dataset, weights, row);
      printf("Expected=%.1f, Predicted=%.1f", dataset[row][nINPUT-1], predict);
     }
  }
//+------------------------------------------------------------------+
// Make a prediction with weights
template <typename Array>
double predict(const Array &X[][nINPUT], const Array &weights[], const int row=0)
  {
   double z = weights[0];
   for(int i=0; i<ArrayRange(X, 1)-1; i++)
     {
      z+=weights[i+1]*X[row][i];
     }
   return activation(z);
  }
//+------------------------------------------------------------------+
//|                Transfer neuron activation                        |
//+------------------------------------------------------------------+
double activation(const double activation) //#
  {
   return activation>=0.0?1.0:0.0;
  }
//+------------------------------------------------------------------+
//|  Estimate Perceptron weights using stochastic gradient descent   |
//+------------------------------------------------------------------+
template <typename Array>
void train_weights(Array &weights[], const Array &X[][nINPUT], double l_rate=0.1, int n_epoch=5)
  {
   ArrayResize(weights, ArrayRange(X, 1));
   for(int i=0; i<ArrayRange(X, 1); i++)
     {
      weights[i]=random.random();
     }

   for(int epoch=0; epoch<n_epoch; epoch++)
     {
      double sum_error = 0.0;
      for(int row=0; row<ArrayRange(X, 0); row++)
        {
         double y = predict(X, weights, row);
         double error = X[row][nINPUT-1] - y;
         sum_error += pow(error, 2);
         weights[0] = weights[0] + l_rate * error;

         for(int i=0; i<ArrayRange(X, 1)-1; i++)
           {
            weights[i+1] = weights[i+1] + l_rate * error * X[row][i];
           }
        }
      printf(">epoch=%d, lrate=%.3f, error=%.3f",epoch, l_rate, sum_error);
     }
  }
//+------------------------------------------------------------------+
