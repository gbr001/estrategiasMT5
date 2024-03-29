//+------------------------------------------------------------------+
//|                                                   GybridLots.mq4 |
//|                                Copyright 2020, Centropolis Corp. |
//|                                          https://Centropolis.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Centropolis Corp."
#property link      "https://Centropolis.com"
#property version   "1.00"
#property strict


///input parameters of the logic
extern bool HybridInit=true;//Init Hybrid Variation
extern double MinLot=0.01;//Max Lot
extern double MaxLot=1.0;//Min Lot
extern double LotForMultiplier=0.01;//Addition Or Subtraction Of A Lot Upon Reaching A Certain Profit 
extern double ProfitForMultiplier=100;//Profit To Increase 

///

//

///////trading parameters
extern bool bBuyInit=true;//buy init
extern bool bSellInit=true;//sell init
extern bool TradeJustWhenNoOrders=true;//trade just when no ordes
extern int SlippageMaxOpen=15;//slippage open
extern int SlippageMaxClose=100;//slippage close

extern int SLE=10000;//stop loss
extern int TPE=10000;//take profit
////////spread variables
extern bool bInitSpreadControl=false;//Spread Control
extern int SpreadE=16;//Spread Max
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

bool bLastBuy;
void Trade()
   {
   
   if ( !bLastBuy ) BuyF(SLE,TPE);
   else SellF(SLE,TPE);
   }
   



/////////********/////////********//////////***********/////////trading functions code block
void BuyF(double SL0,double TP0)
   {
   bool ord;
   int OrdersG0=0;
   double DtA;
   double SLTemp0=MathAbs(SL0);
   double TPTemp0=MathAbs(TP0);   
   double Mt=0.0; 
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
      CheckForOpen(bBuyInit,MagicF,OP_BUY,Bid,Ask,MathAbs(SlippageMaxOpen),Bid,int(SLTemp0),int(TPTemp0),MathAbs(Mt),CurrentSymbol,0,NULL,false,bInitSpreadControl,SpreadE);
      }
   }
   
void SellF(double SL0,double TP0)
   {
   bool ord;
   int OrdersG0=0;
   double DtA;
   double SLTemp0=MathAbs(SL0);
   double TPTemp0=MathAbs(TP0);   
   double Mt=0.0;     
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
      CheckForOpen(bSellInit,MagicF,OP_SELL,Bid,Ask,MathAbs(SlippageMaxOpen),Bid,int(SLTemp0),int(TPTemp0),MathAbs(Mt),CurrentSymbol,0,NULL,false,bInitSpreadControl,SpreadE);
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
      LotTemp=CalcMultiplierLot();
      LotAntiError=GetLotAniError(LotTemp);
      if ( LotAntiError <= 0 )
         {
         Print("TOO Low  Free Margin Level !");
         }

      if ( LotAntiError > 0 &&  (OrdType == OP_SELL || OrdType == OP_SELLLIMIT || OrdType == OP_SELLSTOP) )
         {
         GlobalVariableSet("TimeStart161",double(TimeCurrent()) );
         ord=OrderSend( Symbol0 , OrdType, LotAntiError, PriceBid, Slippage0, PriceClose0 + CorrectLevels(SL0)*Point, PriceClose0 - CorrectLevels(TP0)*Point, Comment0, Magic0, Expiration0, Red);
         bLastBuy=false;
         }
      if ( LotAntiError > 0 &&  (OrdType == OP_BUY || OrdType == OP_BUYLIMIT || OrdType == OP_BUYSTOP) )
         {
         GlobalVariableSet("TimeStart161",double(TimeCurrent()) );
         ord=OrderSend( Symbol0 , OrdType, LotAntiError, PriceAsk, Slippage0, PriceClose0 - CorrectLevels(SL0)*Point, PriceClose0 + CorrectLevels(TP0)*Point, Comment0, Magic0, Expiration0, Green);
         bLastBuy=true;
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
   double LotD;
   LotCorrection=int(MathFloor(InputLot/Step));
   LotD=InputLot-MathFloor(InputLot);
   if ( MathRand() >= 32767.0/2.0 ) Lot13=(LotCorrection+1)*Step;
   else Lot13=LotCorrection*Step;
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


/////////////////////////////////
//логика

double CalcMultiplierLot()
   {
   bool ord;
   double templot=(MaxLot+MinLot)/2.0;
   if ( !HybridInit ) return templot;     
   for ( int i=OrdersHistoryTotal()-1; i>=0; i-- )
      {
      ord=OrderSelect( i, SELECT_BY_POS, MODE_HISTORY );
      if ( ord && OrderSymbol() == CurrentSymbol &&  OrderMagicNumber() == MagicF )
         {
         double PointsProfit=(OrderProfit()+OrderCommission()+OrderSwap())/(OrderLots()*MarketInfo(CurrentSymbol,MODE_TICKVALUE));
         //Print(PointsProfit);
         if ( OrderLots() >= (MaxLot+MinLot)/2.0 )
            {
            if ( PointsProfit < 0.0 ) templot=OrderLots()-(LotForMultiplier*(PointsProfit/ProfitForMultiplier))*((MaxLot-OrderLots())/((MaxLot-MinLot)/2.0));
            if ( PointsProfit > 0.0 ) templot=OrderLots()-(LotForMultiplier*(PointsProfit/ProfitForMultiplier))/((MaxLot-OrderLots())/((MaxLot-MinLot)/2.0));
            if ( PointsProfit == 0.0 ) templot=OrderLots();
            //Print("1");
            break;
            }
         else
            {
            if ( PointsProfit > 0.0 ) templot=OrderLots()-(LotForMultiplier*(PointsProfit/ProfitForMultiplier))*((OrderLots()-MinLot)/((MaxLot-MinLot)/2.0));
            if ( PointsProfit < 0.0 ) templot=OrderLots()-(LotForMultiplier*(PointsProfit/ProfitForMultiplier))/((OrderLots()-MinLot)/((MaxLot-MinLot)/2.0));
            if ( PointsProfit == 0.0 ) templot=OrderLots();
            break;
            }
         }
      }
   if ( templot <= MinLot ) templot=(MaxLot+MinLot)/2.0;
   if ( templot >= MaxLot ) templot=(MaxLot+MinLot)/2.0;
   return templot;
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
     Trade();
     } 
  }