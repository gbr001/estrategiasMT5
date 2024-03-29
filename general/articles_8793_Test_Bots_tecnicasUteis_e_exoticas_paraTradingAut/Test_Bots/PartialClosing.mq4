//+------------------------------------------------------------------+
//|                                               PartialClosing.mq4 |
//|                                Copyright 2020, Centropolis Corp. |
//|                                          https://Centropolis.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Centropolis Corp."
#property link      "https://Centropolis.com"
#property version   "1.00"
#property strict

///input parameters of the logic
extern double StartLotsToOnePoint=0.01;//starting closing lots for 1 profit point 
extern double EndLotsToOnePoint=1.0;//final closing lots 
extern double PointsForEndLots=100;//points for closing lots 

///

//

///////trading parameters
extern bool bBuyInit=true;//buy init
extern bool bSellInit=true;//sell init
int SlippageMaxOpen=15;//slippage for opening
int SlippageMaxClose=100;//slippage for closing

extern int SLE=10000;//stop loss
extern int TPE=10000;//take profit
extern double Lot=0.01;//lot
////////spread variables
extern int MagicF=15670867;//Magic
////

string CurrentSymbol=Symbol();


int HourCorrect(int hour0)
   {
   int rez=0;
   if ( hour0 < 24 && hour0 > 0 )
      {
      rez=hour0;
      }
   return rez;
   }
   
int MinuteCorrect(int minute0)
   {
   int rez=0;
   if ( minute0 < 60 && minute0 > 0 )
      {
      rez=minute0;
      }
   return rez;      
   }

void Trade()
   {
   if ( MathRand() >= 32767.0/2.0 ) BuyF(SLE,TPE,Lot);
   else SellF(SLE,TPE,Lot);
   }
   



/////////********/////////********//////////***********/////////trading functions code block
void BuyF(double SL0,double TP0,double Lot0)
   {
   bool ord;
   int OrdersG0=0;
   double DtA;
   double SLTemp0=MathAbs(SL0);
   double TPTemp0=MathAbs(TP0);   
   double Mt=Lot0; 
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
         if ( OrderSymbol() == CurrentSymbol &&  OrderMagicNumber() == MagicF )
            {
            OrdersG0++;
            }
         }
      
      
      
   DtA=double(TimeCurrent())-GlobalVariableGet("TimeStart161");
   if ( OrdersG0 == 0 && (DtA > 0 || DtA < 0) )
      {
      CheckForOpen(bBuyInit,MagicF,OP_BUY,Bid,Ask,MathAbs(SlippageMaxOpen),Bid,int(SLTemp0),int(TPTemp0),MathAbs(Mt),CurrentSymbol,0,NULL,false,false,0);
      }
   }
   
void SellF(double SL0,double TP0,double Lot0)
   {
   bool ord;
   int OrdersG0=0;
   double DtA;
   double SLTemp0=MathAbs(SL0);
   double TPTemp0=MathAbs(TP0);   
   double Mt=Lot0;     
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
         if ( OrderSymbol() == CurrentSymbol &&  OrderMagicNumber() == MagicF )
            {
            OrdersG0++;
            }
         }
         
   DtA=double(TimeCurrent())-GlobalVariableGet("TimeStart161");
   if ( OrdersG0 == 0 && (DtA > 0 || DtA < 0) )
      {
      CheckForOpen(bSellInit,MagicF,OP_SELL,Bid,Ask,MathAbs(SlippageMaxOpen),Bid,int(SLTemp0),int(TPTemp0),MathAbs(Mt),CurrentSymbol,0,NULL,false,false,0);
      }
   }

void CheckForOpen(bool Condition0,int Magic0,int OrdType,double PriceBid,double PriceAsk,int Slippage0,double PriceClose0,int SL0,int TP0,double Lot0,string Symbol0,datetime Expiration0,string Comment0,bool bLotControl0,bool bSpreadControl0,int Spread0)
   {
   bool ord;                          //open order in case of Condition0
   double LotTemp=Lot0;
   double SpreadLocal=MarketInfo(CurrentSymbol,MODE_SPREAD);
   double LotAntiError=MarketInfo(CurrentSymbol,MODE_MINLOT);
                                                       
   if ( Condition0 == true && ( (SpreadLocal <= Spread0 && bSpreadControl0 == true ) || ( bSpreadControl0 == false ) )  )                    
      {   
      LotTemp=Lot;
      LotAntiError=GetLotAniError(LotTemp);
      if ( LotAntiError <= 0 )
         {
         Print("TOO Low  Free Margin Level !");
         }

      if ( LotAntiError > 0 &&  (OrdType == OP_SELL || OrdType == OP_SELLLIMIT || OrdType == OP_SELLSTOP) )
         {
         GlobalVariableSet("TimeStart161",double(TimeCurrent()) );
         ord=OrderSend( Symbol0 , OrdType, LotAntiError, PriceBid, Slippage0, PriceClose0 + CorrectLevels(SL0)*Point, PriceClose0 - CorrectLevels(TP0)*Point, Comment0, Magic0, Expiration0, Red);
         }
      if ( LotAntiError > 0 &&  (OrdType == OP_BUY || OrdType == OP_BUYLIMIT || OrdType == OP_BUYSTOP) )
         {
         GlobalVariableSet("TimeStart161",double(TimeCurrent()) );
         ord=OrderSend( Symbol0 , OrdType, LotAntiError, PriceAsk, Slippage0, PriceClose0 - CorrectLevels(SL0)*Point, PriceClose0 + CorrectLevels(TP0)*Point, Comment0, Magic0, Expiration0, Green);
         }                     
      }
      
   }

double GetLotAniError(double InputLot)
   {
   double Free = AccountFreeMargin();
   double margin = MarketInfo(CurrentSymbol,MODE_MARGINREQUIRED);
   double minLot = MarketInfo(CurrentSymbol,MODE_MINLOT);
   double Max_Lot = MarketInfo(CurrentSymbol,MODE_MAXLOT);
   double Step = MarketInfo(CurrentSymbol,MODE_LOTSTEP);
   double Lot13;
   int LotCorrection;
   LotCorrection=int(MathFloor(InputLot/Step));
   Lot13=LotCorrection*Step;   
   if(Lot13<=minLot) Lot13 = minLot;
   if(Lot13>=Max_Lot) Lot13 = Max_Lot;
   
   if( Lot13*margin>=Free ) Lot13=-1.0;

   return Lot13;
   }

double CalcNad(double Lots, double yT)//calculate reliability
   {
   double NadR=0.0;
   double Ab=AccountBalance();
   double mi=MarketInfo(CurrentSymbol,MODE_TICKVALUE);
   
   if ( yT != 0 && Lots != 0 && mi != 0 )
      {
      NadR=Ab/( yT*mi*Lots );
      }
   
   return NadR;
   }

int CorrectLevels(int level0)
   {
   int rez;
   int ZeroLevel0=int(MathAbs(MarketInfo(CurrentSymbol,MODE_STOPLEVEL))+MathAbs(MarketInfo(CurrentSymbol,MODE_SPREAD))+MathAbs(SlippageMaxOpen)+1);

   if ( MathAbs(level0) > ZeroLevel0 )
      {
      rez=int(MathAbs(level0));
      }
   else
      {
      rez=ZeroLevel0;
      }   
   return rez;
   }


void PartialCloseType()//close order partially
   {
   bool ord;
   double ValidLot;
   MqlTick TickS;
   SymbolInfoTick(_Symbol,TickS);
            
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
      if ( ord && OrderMagicNumber() == MagicF && OrderSymbol() == _Symbol )
         {
         if ( OrderType() == OP_BUY )
            {
            ValidLot=CalcCloseLots(OrderLots(),(Open[0]-Open[1])/_Point);
            if ( ValidLot > 0.0 ) ord=OrderClose(OrderTicket(),ValidLot,TickS.bid,MathAbs(SlippageMaxClose),Green);
            }
         if ( OrderType() == OP_SELL )
            {
            ValidLot=CalcCloseLots(OrderLots(),(Open[1]-Open[0])/_Point);
            if ( ValidLot > 0.0 ) ord=OrderClose(OrderTicket(),ValidLot,TickS.ask,MathAbs(SlippageMaxClose),Red);
            }         
         break;
         }
      }
   }    
/////////////////////////////////
//логика

double CalcCloseLots(double orderlots0,double X)//calculate lot for closing
   {
   double functionvalue;
   double correctedlots;
   if ( X < 0.0 ) return 0.0;
   functionvalue=StartLotsToOnePoint*MathPow(X ,MathLog(EndLotsToOnePoint/StartLotsToOnePoint)/MathLog(PointsForEndLots));
   correctedlots=GetLotAniError(functionvalue);
   if ( correctedlots > orderlots0 ) return orderlots0;
   else return correctedlots;
   }








//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+


datetime Time0;

bool bNewBar()
   {
   if ( Time0 < Time[0] )
      {
      if (Time0 != 0)
         {
         Time0=Time[0];
         return true;
         }
      else
         {
         Time0=Time[0];
         return false;
         }
      }
   else return false;
   }

void OnTick()
  {
  if ( bNewBar())
     {
     if ( OrdersTotal() > 0 ) PartialCloseType();     
     Trade();
     } 
  }
