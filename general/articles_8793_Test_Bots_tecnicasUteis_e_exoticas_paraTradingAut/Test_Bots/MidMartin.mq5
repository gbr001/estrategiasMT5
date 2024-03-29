//+------------------------------------------------------------------+
//|                                                    MidMartin.mq5 |
//|                                Copyright 2020, Centropolis Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Centropolis Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MT4Orders.mqh>


enum MODE_MID
   {
   MODE_HALF,
   MODE_SINGULARITY
   };

//настройки
input MODE_MID MODEE=MODE_SINGULARITY;//mode
input double ProfitFactorMinE=1.2;//minimum profit factor of cycle
input double DE=100;//minimum profit points for the last trade 
input double KE=5.0;//starting incremental profit factor / (rollback factor for HALF mode) 
input double XE=100.0;//bias towards loss in points for half of the additional coefficient 
input double StepE=10;//orders step in points
input int OrdersMaxE=10;//maximum orders


//

///do manually

///////trading parameters
bool bBuyInit=true;//buy init
bool bSellInit=true;//sell init
int SlippageMaxOpen=15;//slippage for opening
int SlippageMaxClose=100;//slippage for closing

input int SLE=10000;//stop loss points
input int TPE=10000;//take profit points
input double LotStart=0.01;//Cycle start lot
////////spread variables
input int MagicF=15670867;//Magic
////

string CurrentSymbol=Symbol();


////////////////////////////for mql4
//directives of assigned constants

#define MODE_SPREAD 0
#define MODE_STOPLEVEL 1

#define MODE_MINLOT 2
#define MODE_MAXLOT 3

#define MODE_LOTSTEP 4
#define MODE_TICKVALUE 5

#define MODE_MARGINREQUIRED 6
#define MODE_SWAPLONG 7
#define MODE_SWAPSHORT 8
//

//////////variables to be moved in mql5
double Close[];
double Open[];
double High[];
double Low[];
datetime Time[];
double Bid;
double Ask;
double Point=_Point;
int Bars=1000;
int BarsPrev=Bars;
int PositionHistory=0;

int pool0;
MqlTick TickAlphaPsi;

int TMagic0=0;
int TMagic1=0;
ENUM_ORDER_TYPE_FILLING FILLING=ORDER_FILLING_RETURN;
//////////////////////++++++++++++++++++++++++

///////////////functions for predefined mql5 arrays

void DimensionAllMQL5Values()//////////////////////////////
   {
   ArrayResize(Close,Bars-1,0);
   ArrayResize(Open,Bars-1,0);   
   ArrayResize(Time,Bars-1,0);
   ArrayResize(High,Bars-1,0);
   ArrayResize(Low,Bars-1,0);
   }

void CalcAllMQL5Values()///////////////////////////////////
   {
   ArraySetAsSeries(Close,false);                        
   ArraySetAsSeries(Open,false);                           
   ArraySetAsSeries(High,false);                        
   ArraySetAsSeries(Low,false);                              
   ArraySetAsSeries(Time,false);                                                            
   CopyClose(_Symbol,_Period,0,Bars-1,Close);
   CopyOpen(_Symbol,_Period,0,Bars-1,Open);   
   CopyHigh(_Symbol,_Period,0,Bars-1,High);
   CopyLow(_Symbol,_Period,0,Bars-1,Low);
   CopyTime(_Symbol,_Period,0,Bars-1,Time);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);                        
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);
   SymbolInfoTick(Symbol(),TickAlphaPsi);
   Bid=TickAlphaPsi.bid;
   Ask=TickAlphaPsi.ask;
   }
////////////////////////////////////////////////////////////

//////////////Functions to make mql4 and mql5 source libraries compatible
////////////////////////////////////////////////////////////

ENUM_DAY_OF_WEEK DayOfWeek()
   {
   MqlDateTime TimeInfo;
   TimeToStruct(TimeCurrent(),TimeInfo);
   ENUM_DAY_OF_WEEK rez=ENUM_DAY_OF_WEEK(TimeInfo.day_of_week);
   
   return rez;
   }
   
ENUM_DAY_OF_WEEK TimeDayOfWeek(datetime Time00)
   {
   MqlDateTime TimeInfo;
   TimeToStruct(Time00,TimeInfo);
   ENUM_DAY_OF_WEEK rez=ENUM_DAY_OF_WEEK(TimeInfo.day_of_week);
   
   return rez;
   }
   
int TimeHour(datetime Time00)
   {
   MqlDateTime TimeInfo;
   TimeToStruct(Time00,TimeInfo);
   int rez=int(TimeInfo.hour);
   
   return rez;
   }
   
int TimeMinute(datetime Time00)
   {
   MqlDateTime TimeInfo;
   TimeToStruct(Time00,TimeInfo);
   int rez=int(TimeInfo.min);
   
   return rez;
   }                     

double AccountFreeMargin()
   {
   double rez;
   rez=AccountInfoDouble(ACCOUNT_MARGIN_FREE);   
   return rez;
   }

double AccountBalance()
   {
   double rez;
   rez=AccountInfoDouble(ACCOUNT_BALANCE);
   return rez;
   }

double StrToDouble(string str0)
   {
   double rez;
   rez=StringToDouble(str0);
   return rez;
   }


double MarketInfo(string Symbol0,int mode0)
   {
   double rez=0;
   if ( mode0 == MODE_SPREAD ) rez=double(SymbolInfoInteger(Symbol0,SYMBOL_SPREAD));            
   if ( mode0 == MODE_STOPLEVEL ) rez=double(SymbolInfoInteger(Symbol0,SYMBOL_TRADE_STOPS_LEVEL));                  
   if ( mode0 == MODE_MINLOT ) rez=SymbolInfoDouble(Symbol0,SYMBOL_VOLUME_MIN);      
   if ( mode0 == MODE_MAXLOT ) rez=SymbolInfoDouble(Symbol0,SYMBOL_VOLUME_MAX);            
   if ( mode0 == MODE_LOTSTEP ) rez=SymbolInfoDouble(Symbol0,SYMBOL_VOLUME_STEP);                  
   if ( mode0 == MODE_TICKVALUE ) rez=SymbolInfoDouble(Symbol0,SYMBOL_TRADE_TICK_VALUE);                        
   if ( mode0 == MODE_MARGINREQUIRED ) bool b1=OrderCalcMargin(ORDER_TYPE_BUY,Symbol0,1.0,Close[0],rez);
   if ( mode0 == MODE_SWAPLONG ) rez=SymbolInfoDouble(Symbol0,SYMBOL_SWAP_LONG);                        
   if ( mode0 == MODE_SWAPSHORT ) rez=SymbolInfoDouble(Symbol0,SYMBOL_SWAP_SHORT);                                                                                                                   
   return rez;
   }

string TimeToStr(datetime time0)
   {
   string rez="";
   rez=TimeToString(time0);
   return rez;
   }

int Hour()
   {
   int rez;
   MqlDateTime C1Info;
   TimeToStruct(TimeCurrent(),C1Info);
   rez=C1Info.hour;
   return rez;
   }

int Minute()
   {
   int rez;
   MqlDateTime C1Info;
   TimeToStruct(TimeCurrent(),C1Info);
   rez=C1Info.min;
   return rez;
   }



double OrderProfitPoints()
   {
   ulong ticket;
   double profit=0.0;
        
   if((ticket=HistoryDealGetTicket(PositionHistory)) > 0) profit=(HistoryDealGetDouble(ticket,DEAL_PROFIT)/HistoryDealGetDouble(ticket,DEAL_VOLUME))/MarketInfo(CurrentSymbol,MODE_TICKVALUE);
         
   return profit;
   }


////////////////////////////for mql4


///////additional

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

/////////********/////////********//////////***********/////////

void Trade()
   {
            if ( CalculateTranslation() >= StepE && TotalOrdersX() < OrdersMaxE )
               {
               if ( bBuyInit && bSellInit )
                  {
                  if ( !bLastDirection() ) BuyF(SLE,TPE,LotStart);
                  else SellF(SLE,TPE,LotStart);            
                  }
               else
                  {
                  BuyF(SLE,TPE,LotStart);
                  SellF(SLE,TPE,LotStart);           
                  }
               }
            if ( CalculateTranslation() < 0.0 && TotalOrdersX() == 0 )
               {
               if ( bBuyInit && bSellInit )
                  {
                  if ( !bLastDirection() ) BuyF(SLE,TPE,LotStart);
                  else SellF(SLE,TPE,LotStart);            
                  }
               else
                  {
                  BuyF(SLE,TPE,LotStart);
                  SellF(SLE,TPE,LotStart);          
                  }
               }
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
   if ( DtA > 0 || DtA < 0 )
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
   if ( DtA > 0 || DtA < 0 )
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
      CalcNL();
      LotTemp=NeedLot;
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
   
void CloseAll(int magic0)//close all
   {
   bool order;
   bool ord;
   long Tickets[];
   double Lotsx[];
   bool Typex[];      
   string SymbolX[];   
   int TicketsTotal=0;
   int TicketNumCurrent=0;
   MqlTick TickS;
   
   if ( true )
      {
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
         if ( OrderMagicNumber() == magic0 )
            {
            TicketsTotal=TicketsTotal+1;
            }
         }
      ArrayResize(Tickets,TicketsTotal);
      ArrayResize(Lotsx,TicketsTotal);
      ArrayResize(Typex,TicketsTotal);
      ArrayResize(SymbolX,TicketsTotal);
            
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
         if (  OrderMagicNumber() == magic0 && TicketNumCurrent < TicketsTotal )
            {
            Tickets[TicketNumCurrent]=OrderTicket();
            if ( OrderType() == OP_BUY )
               {
               Typex[TicketNumCurrent]=true;
               }
            if ( OrderType() == OP_SELL )
               {
               Typex[TicketNumCurrent]=false;
               }                           
            Lotsx[TicketNumCurrent]=OrderLots();
            SymbolX[TicketNumCurrent]=OrderSymbol();            
            TicketNumCurrent=TicketNumCurrent+1;
            }
         }
         
      for ( int i=0; i<TicketsTotal; i++ )
         {
         SymbolInfoTick(SymbolX[i],TickS);
         if ( Typex[i] == true )
            {
            order=OrderClose(Tickets[i],Lotsx[i],TickS.bid,MathAbs(SlippageMaxClose),Green);
            }
         if ( Typex[i] == false )
            {
            order=OrderClose(Tickets[i],Lotsx[i],TickS.ask,MathAbs(SlippageMaxClose),Red);
            }       
         }                     
      }
   
   }  

void CloseType(ENUM_ORDER_TYPE OT,int magic0)//close all orders of the specified type
   {
   bool order;
   bool ord;
   long Tickets[];
   double Lotsx[];
   bool Typex[];      
   string SymbolX[];   
   int TicketsTotal=0;
   int TicketNumCurrent=0;
   MqlTick TickS;
   
   if ( true )
      {
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
         if ( OrderMagicNumber() == magic0 )
            {
            TicketsTotal=TicketsTotal+1;
            }
         }
      ArrayResize(Tickets,TicketsTotal);
      ArrayResize(Lotsx,TicketsTotal);
      ArrayResize(Typex,TicketsTotal);
      ArrayResize(SymbolX,TicketsTotal);
            
      for ( int i=0; i<OrdersTotal(); i++ )
         {
         ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
         if (  OrderMagicNumber() == magic0 && TicketNumCurrent < TicketsTotal )
            {
            Tickets[TicketNumCurrent]=OrderTicket();
            if ( OrderType() == OP_BUY )
               {
               Typex[TicketNumCurrent]=true;
               }
            if ( OrderType() == OP_SELL )
               {
               Typex[TicketNumCurrent]=false;
               }                           
            Lotsx[TicketNumCurrent]=OrderLots();
            SymbolX[TicketNumCurrent]=OrderSymbol();            
            TicketNumCurrent=TicketNumCurrent+1;
            }
         }
         
      for ( int i=0; i<TicketsTotal; i++ )
         {
         SymbolInfoTick(SymbolX[i],TickS);
         if ( Typex[i] == true && OT == OP_BUY )
            {
            order=OrderClose(Tickets[i],Lotsx[i],TickS.bid,MathAbs(SlippageMaxClose),Green);
            }
         if ( Typex[i] == false && OT == OP_SELL )
            {
            order=OrderClose(Tickets[i],Lotsx[i],TickS.ask,MathAbs(SlippageMaxClose),Red);
            }       
         }                     
      }
   
   }    
/////////////////////////////////










//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  DimensionAllMQL5Values();
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
  CalcAllMQL5Values();  
  if ( bClose() ) CloseAll(MagicF);
  //Trade();
  if ( bNewBar())
     {
     //if ( bClose() ) CloseAll(MagicF);
     Trade();
     } 
  }
  
  
///логика

double D(double D0,double K0,double X0,double X)//function for calculating the predicted rollback
   {
   return D0+(D0*K0)*MathPow(MathPow(0.5,1.0/X0),X);
   }
   
double CalculateTranslation()//calculate movement against orders in points
   {
   bool ord;
   bool bStartDirection;
   bool bFind;
   double ExtremumPrice=0.0;
   
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         if ( OrderType() == OP_SELL ) bStartDirection=false;
         if ( OrderType() == OP_BUY ) bStartDirection=true;
         ExtremumPrice=OrderOpenPrice();
         bFind=true;
         break;
         }
      }   
   
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                        
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         if ( OrderType() == OP_SELL && OrderOpenPrice() > ExtremumPrice ) ExtremumPrice=OrderOpenPrice();
         if ( OrderType() == OP_BUY && OrderOpenPrice() < ExtremumPrice ) ExtremumPrice=OrderOpenPrice();
         }
      }
   
   if ( bFind )
      {
      if ( bStartDirection ) return (ExtremumPrice-Close[0])/_Point;
      else return (Close[0]-ExtremumPrice)/_Point;      
      }   
   else
      {
      return -1.0;
      }
   }
   
   
double TotalProfitPoints=0;   
double TotalProfit=0;
double TotalLoss=0;   
void CalcLP()//calculate losses or profits of all existing orders
   {
   bool ord;
   int OrdersG=0;
   
   double TempProfit=0.0;
   TotalProfit=0;   
   TotalLoss=0;    
    
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         OrdersG++;
         TempProfit=OrderProfit()+OrderCommission()+OrderSwap();
         TotalProfitPoints=(OrderProfit()+OrderCommission()+OrderSwap())/(OrderLots()*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE));
         if ( TempProfit >= 0.0 ) TotalProfit+=TempProfit;
         else TotalLoss-=TempProfit;
         }
      }
   }
   
void CalcLPFuture()//calculate losses or profits of all existing orders in the future
   {
   bool ord;
   int OrdersG=0;
   
   double TempProfit=0;
   TotalProfit=0;   
   TotalLoss=0;    
    
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         OrdersG++;
         TempProfit=OrderProfit()+OrderCommission()+OrderSwap()+(OrderLots()*MarketInfo(Symbol(),MODE_TICKVALUE)*Dd);
         if ( TempProfit >= 0.0 ) TotalProfit+=TempProfit;
         else TotalLoss-=TempProfit;
         }
      }
   }
   
bool bLastDirection()//direction of the last deal
   {
   bool ord;
   
   for ( int i=OrdersHistoryTotal()-1; i>=0; i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );
                            
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         if ( OrderType() == OP_BUY ) return true;
         if ( OrderType() == OP_SELL ) return false;
         }
      }
      
   return false;
   }   

double Xx;//shift X
double Dd;//desired rollback D
void CalcX()//calculate current X
   {
   bool ord;
   bool bStartDirection=false;
   bool bFind=false;
   double ExtremumPrice=0.0;
   
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( 0, SELECT_BY_POS, MODE_TRADES );
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         if ( OrderType() == OP_SELL ) bStartDirection=false;
         if ( OrderType() == OP_BUY ) bStartDirection=true;
         ExtremumPrice=OrderOpenPrice();
         bFind=true;
         }
      }   
   
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                        
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         if ( OrderType() == OP_SELL && OrderOpenPrice() < ExtremumPrice ) ExtremumPrice=OrderOpenPrice();
         if ( OrderType() == OP_BUY && OrderOpenPrice() > ExtremumPrice ) ExtremumPrice=OrderOpenPrice();
         }
      }

   Xx=0.0;
   Dd=0.0;   
   
   if ( bFind )
      {
      if ( !bStartDirection ) Xx=(Close[0]-ExtremumPrice)/Point;
      if ( bStartDirection ) Xx=(ExtremumPrice-Close[0])/Point;
      if ( MODEE==MODE_SINGULARITY ) Dd=D(DE,KE,XE,Xx);
      else Dd=Xx*KE;
      }      
   }

double NeedLot;//required lot
void CalcNL()//calculate the next lot
   {
   CalcX();
   CalcLPFuture();
   
   if ( TotalLoss != 0.0 && Xx > 0.0 )
      {
      NeedLot=(ProfitFactorMinE*TotalLoss-TotalProfit)/((Dd+MarketInfo(Symbol(),MODE_SPREAD))*MarketInfo(Symbol(),MODE_TICKVALUE));
      }
   else
      {
      NeedLot=LotStart;
      }
      
   }
   
int TotalOrdersX() 
   {
   bool ord;
   int orders=0;
   
   for ( int i=0; i<OrdersTotal(); i++ )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_TRADES );
                            
      if ( OrderMagicNumber() == MagicF && OrderSymbol() == Symbol() )
         {
         orders++;
         }
      }
   return orders;
   }
   
   
bool bClose()
   {
   CalcLP();
   if ( TotalLoss != 0.0 && TotalProfit/TotalLoss >= ProfitFactorMinE ) return true;
   if ( TotalLoss == 0.0 && TotalProfitPoints >= DE*KE ) return true;
   //CalcLP();
   //if ( TotalLoss >= MaxLossUSD ) return true;
   return false;
   }