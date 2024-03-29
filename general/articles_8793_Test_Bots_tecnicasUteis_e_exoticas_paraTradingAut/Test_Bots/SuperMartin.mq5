//+------------------------------------------------------------------+
//|                                                  SuperMartin.mq5 |
//|                                Copyright 2020, Centropolis Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Centropolis Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position=CPositionInfo();// trade position object
CTrade         m_trade=CTrade();          // trading object

////////minimum trading implementation
input bool bInitAdditionalMode=false;//Enable reversed pyramid
input double LotDecrease=0.01;//Lot Decrease Value step
input int SLE=300;//Stop Loss Points
input int TPE=300;//Take Profit Points
input int SlippageMaxOpen=15; //Slippage For Open In Points
input double Lot=0.1;//Start Lot
input int MagicC=679034;//Magic
input int HistoryDaysLoadI=10;//History Deals Window Days
input int DealsMinusToBreak=5;//Deals Minus For Interrupt

/////////

MqlTick LastTick;//last tick


double DecreasedLot=Lot;
double CalcSmartLot()//Calculate previous cycle
   {
   bool ord;
   int PrevCycleDeals=0;
   HistorySelect(TimeCurrent()-HistoryDaysLoadI*86400,TimeCurrent());
   for ( int i=HistoryDealsTotal()-1; i>=0; i-- )
      {
      ulong ticket=HistoryDealGetTicket(i);
      ord=HistoryDealSelect(ticket);
      if ( ord && HistoryDealGetString(ticket,DEAL_SYMBOL) == _Symbol 
      && HistoryDealGetInteger(ticket,DEAL_MAGIC) == MagicC 
      && HistoryDealGetInteger(ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT )
         {
         if ( HistoryDealGetDouble(ticket,DEAL_PROFIT) > 0 )
            {
            for ( int j=i+1; j>=0; j-- )//Found a profitable deal followed by losing (count them)
                {
                ticket=HistoryDealGetTicket(j);
                ord=HistoryDealSelect(ticket);
                if ( ord && HistoryDealGetString(ticket,DEAL_SYMBOL) == _Symbol 
                && HistoryDealGetInteger(ticket,DEAL_MAGIC) == MagicC 
                && HistoryDealGetInteger(ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT )
                   {
                   if ( HistoryDealGetDouble(ticket,DEAL_PROFIT) < 0 )
                      {
                      PrevCycleDeals++;
                      }
                   else
                      {
                      break;
                      }
                   }                
                }
            break;    
            }
         else
            {
            break;
            }
         }
      }
      
   if ( PrevCycleDeals < DealsMinusToBreak ) DecreasedLot-=LotDecrease;
   else DecreasedLot=Lot;
   if ( DecreasedLot <= 0.0 ) DecreasedLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

   return DecreasedLot;
   }

double CalcLot()//calculate the lot
   {
   bool ord;
   double TotalLot=0;
   HistorySelect(TimeCurrent()-HistoryDaysLoadI*86400,TimeCurrent());
   for ( int i=HistoryDealsTotal()-1; i>=0; i-- )
      {
      ulong ticket=HistoryDealGetTicket(i);
      ord=HistoryDealSelect(ticket);
      if ( ord && HistoryDealGetString(ticket,DEAL_SYMBOL) == _Symbol 
      && HistoryDealGetInteger(ticket,DEAL_MAGIC) == MagicC 
      && HistoryDealGetInteger(ticket,DEAL_ENTRY) == DEAL_ENTRY_OUT )
         {
         if ( HistoryDealGetDouble(ticket,DEAL_PROFIT) < 0 )
            {
            TotalLot+=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            }
         else
            {
            break;
            }
         }
      } 
   if ( bInitAdditionalMode ) return TotalLot == 0 ? CalcSmartLot(): TotalLot;
   else return TotalLot == 0 ? Lot: TotalLot;
   }

bool bLastBuy;
void Trade()//the main function where all actions are performed
   {
   bool ord=PositionSelect(Symbol());
   SymbolInfoTick(Symbol(),LastTick);
   if ( !ord )
      {
      if ( !bLastBuy )
         {
         m_trade.Buy(CalcLot(),_Symbol,LastTick.ask,LastTick.bid-double(SLE)*_Point,LastTick.ask+double(TPE)*_Point);
         bLastBuy=true;
         }
      else
         {
         m_trade.Sell(CalcLot(),_Symbol,LastTick.ask,LastTick.ask+double(SLE)*_Point,LastTick.bid-double(TPE)*_Point);
         bLastBuy=false;
         }
      }
   }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  m_trade.SetExpertMagicNumber(MagicC);//set the magic number for positions
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
void OnTick()
  {
  Trade();
  }
//+------------------------------------------------------------------+