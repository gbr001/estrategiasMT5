//+------------------------------------------------------------------+
//|                                          CatBoost martingale.mq5 |
//|                                 Copyright 2020, Dmitrievsky Max. |
//|                        https://www.mql5.com/ru/users/dmitrievsky |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Dmitrievsky Max."
#property link      "https://www.mql5.com/ru/users/dmitrievsky"
#property version   "1.4"

// Через макросы обрубаем любые намеки о присутствии MT4Orders.
#define Alert PrintTmp
#define Print PrintTmp
void PrintTmp( string ) {}

#include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006
#undef Print
#undef Alert

#include <Trade\AccountInfo.mqh>
#include <EURUSD_cat_model_martin.mqh>

sinput int      OrderMagic = 666;      //Orders magic
sinput double   MaximumRisk=0.0;       //Progressive lot
sinput double   CustomLot=0.01;        //Fixed lot

input int stoploss = 10000;            //Stop loss
input int takeprofit = 10000;          //Take profit
static datetime last_time=0;
#define Ask SymbolInfoDouble(_Symbol, SYMBOL_ASK)
#define Bid SymbolInfoDouble(_Symbol, SYMBOL_BID)
MqlDateTime hours;

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int OnInit() {

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---
   if(!isNewBar()) return;
   TimeToStruct(TimeCurrent(), hours);
   double features[];

   fill_arays(features);
   if(ArraySize(features) !=ArraySize(MAs)) {
      Print("No history availible, will try again on next signal!");
      return;
   }
   double sig = catboost_model(features);

// Close positions by an opposite signal
   if(count_market_orders(0) || count_market_orders(1))
      for(int b = OrdersTotal() - 1; b >= 0; b--)
         if(OrderSelect(b, SELECT_BY_POS) == true) {
            if(OrderType() == 0 && OrderSymbol() == _Symbol && OrderMagicNumber() == OrderMagic && sig > 0.5)
               if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Red)) {
               }
            if(OrderType() == 1 && OrderSymbol() == _Symbol && OrderMagicNumber() == OrderMagic && sig < 0.5)
               if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, Red)) {
               }
         }

// Delete all pending orders if there are no pending orders
   if(!count_market_orders(0) && !count_market_orders(1)) {

      for(int b = OrdersTotal() - 1; b >= 0; b--)
         if(OrderSelect(b, SELECT_BY_POS) == true) {

            if(OrderType() == 2 && OrderSymbol() == _Symbol && OrderMagicNumber() == OrderMagic )
               if(OrderDelete(OrderTicket())) {
               }

            if(OrderType() == 3 && OrderSymbol() == _Symbol && OrderMagicNumber() == OrderMagic )
               if(OrderDelete(OrderTicket())) {
               }
         }
   }

// Open positions and pending orders by signals
   if(countOrders() == 0 && CheckMoneyForTrade(_Symbol,LotsOptimized(),ORDER_TYPE_BUY)) {
      double l = LotsOptimized();

      if(sig < 0.5) {
         OrderSend(Symbol(),OP_BUY,l, Ask, 0, Bid-stoploss*_Point, Ask+takeprofit*_Point, NULL, OrderMagic);
         double p = Ask;
         for(int i=0; i<grid_size; i++) {
            p = NormalizeDouble(p - grid_distances[i], _Digits);
            double gl = NormalizeDouble(l * grid_coefficients[i], 2);
            OrderSend(Symbol(),OP_BUYLIMIT,gl, p, 0, p-stoploss*_Point, p+takeprofit*_Point, NULL, OrderMagic);
         }
      }
      else {
         OrderSend(Symbol(),OP_SELL,l, Bid, 0, Ask+stoploss*_Point, Bid-takeprofit*_Point, NULL, OrderMagic);
         double p = Ask;
         for(int i=0; i<grid_size; i++) {
            p = NormalizeDouble(p + grid_distances[i], _Digits);
            double gl = NormalizeDouble(l * grid_coefficients[i], 2);
            OrderSend(Symbol(),OP_SELLLIMIT,gl, p, 0, p+stoploss*_Point, p-takeprofit*_Point, NULL, OrderMagic);
         }
      }
   }
}

//+------------------------------------------------------------------+
double LotsOptimized() {
   CAccountInfo myaccount;
   SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   double lot;

   lot=NormalizeDouble(myaccount.FreeMargin()*MaximumRisk/1000.0,2);
   if(CustomLot!=0.0) lot=CustomLot;

   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001) {
      lot = ratio*volume_step;
   }
   if(lot<SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)) lot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX)) lot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   return(lot);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countOrders() {
   int result=0;
   for(int k=OrdersTotal()-1; k>=0; k--) {
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderMagicNumber()==OrderMagic && OrderSymbol() == _Symbol) result++;
   }
   return(result);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int count_market_orders(int type) {
   int result=0;
   for(int k=OrdersTotal()-1; k>=0; k--) {
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderType() == type && OrderMagicNumber()==OrderMagic && OrderSymbol() == _Symbol) result++;
   }
   return(result);
}

//+------------------------------------------------------------------+
//| New bar func                                                     |
//+------------------------------------------------------------------+
bool isNewBar() {
   datetime lastbar_time=datetime(SeriesInfoInteger(Symbol(),PERIOD_CURRENT,SERIES_LASTBAR_DATE));

   if(last_time==0) {
      last_time=lastbar_time;
      return(false);
   }
   if(last_time!=lastbar_time) {
      last_time=lastbar_time;
      return(true);
   }
   return(false);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check money                                                      |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type) {
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL) price=mqltick.bid;

   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(!OrderCalcMargin(type,symb,lots,price,margin)) {
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
   }

   if(margin>free_margin) {
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
   }
   return(true);
}
//+------------------------------------------------------------------+
