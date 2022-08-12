//+------------------------------------------------------------------+
//|                                                       MAGrid.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                          From https://www.mql5.com/en/code/38303 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include  <Trade\Trade.mqh>
#include  <Trade\AccountInfo.mqh>
#include  <Trade\SymbolInfo.mqh>

input int      peiod          = 48;    //MA peiod
input ENUM_TIMEFRAMES period_time = PERIOD_D1;
input int      setGridAmount     = 6;     //Grid amount (fill in even numbers)
input double   distance       = 0.005;  //Grid distance

CTrade         trade;
CAccountInfo   info;
CSymbolInfo    symbolInfo;

int      gridAmount;
int      handle;
double   buf[];
int      currentGrid;                  //Current grid
int      buyAmount;                    //Holding long positions
int      sellAmount;                   //Holding short positions
int      grid[];                       //Record grid ticket
double   nextgrid;                     //Next grid's price
double   lastgrid;                     //Last grid's price
datetime lasttime;                     //Record last calculate MA time
MqlRates rates[];
bool     FirstTrade  = true;
double   fee         = 0.0008;         //Fee
double   totalfee;                     //Record all fee
int      step_int;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   gridAmount = setGridAmount;
   if(setGridAmount/2 <(double)setGridAmount / 2.0)
      gridAmount++;
      
   handle = iMA(_Symbol, period_time, peiod, 0, MODE_EMA, PRICE_CLOSE);
   ArrayResize(grid, gridAmount+1);

//Calculate the minimum number of positions to open
   symbolInfo.Refresh();
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   for(double v = step; v<1; step_int++)
      v = v * 10;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates);
   if(FirstTrade)
      SetGrid();
   if(rates[0].time != lasttime)
     {
      CopyBuffer(handle, 0, 0, 2, buf);
      CalcGrid();
      lasttime = rates[0].time;
     }
   if(rates[0].close >= nextgrid && nextgrid != 0)
     {
      currentGrid++;
      Close("CloseBuy");
      Open("Sell");
     }
   else if(rates[0].close <= lastgrid && lastgrid != 0)
     {
      currentGrid--;
      Close("CloseSell");
      Open("Buy");
     }
  }
//+---------------------- Open position --------------------------+
void Open(string TradeType)
  {
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates);
   double volume = NormalizeDouble(info.Balance() / gridAmount * 2 / symbolInfo.ContractSize() / rates[0].close, step_int);
   if(volume <= 0)
      volume = symbolInfo.LotsMin();
   if(info.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,volume,rates[0].close)<0.0)
      return;
   if(TradeType == "Buy")
     {
      trade.Buy(volume);
      grid[gridAmount / 2 + currentGrid + 1] = trade.ResultOrder();
      buyAmount++;
     }
   else if(TradeType == "Sell")
     {
      trade.Sell(volume);
      grid[gridAmount / 2 + currentGrid - 1] = trade.ResultOrder();
      sellAmount++;
     }
   totalfee = totalfee + trade.ResultPrice() * trade.ResultVolume() * fee;
   Comment("Total: ", totalfee," Current Grid: ", currentGrid, " / ", gridAmount/2);
  }
//+--------------------- Close position --------------------------+
void Close(string CloseType)
  {
   if(CloseType == "CloseBuy")
     {
      trade.PositionClose(grid[gridAmount / 2 + currentGrid]);
      buyAmount--;
      grid[gridAmount / 2 + currentGrid] = 0;
     }
   else if(CloseType == "CloseSell")
     {
      trade.PositionClose(grid[gridAmount / 2 + currentGrid]);
      sellAmount--;
      grid[gridAmount / 2 + currentGrid] = 0;
     }
   CalcGrid();
  }
//+-------------------- Calculate grid's price --------------------+
void CalcGrid()
  {
   if(currentGrid < gridAmount-1)
      nextgrid = buf[0] * (1 + distance * (1 + currentGrid));
   else
      nextgrid = 0;
   if(currentGrid > 1 - gridAmount)
      lastgrid = buf[0] * (1 - distance * (1 - currentGrid));
   else
      lastgrid = 0;
   //Break through grid edges
   if(buyAmount == 0)
      nextgrid = DBL_MAX;
   else if(sellAmount == 0)
      lastgrid = DBL_MIN;
  }
//+-------------------------- Set grid ----------------------------+
void SetGrid()
  {
   //Determine which grid it is currently in
   CopyBuffer(handle, 0, 0, 2, buf);
   int a = gridAmount/2;
   currentGrid = 100;
   if(rates[0].close < buf[0])
     {
      for(int i=1; i<=a; i++)
        {
         if(rates[0].close > buf[0] * (1 - distance * i))
           {
            currentGrid = 1 - i;
            break;
           }
        }
      //Break through grid edges
      if(currentGrid == 100)
         currentGrid = gridAmount / 2;
     }
   else
     {
      for(int i=1; i<=a; i++)
        {
         if(rates[0].close < buf[0] * (1 + distance * i))
           {
            currentGrid = i - 1;
            break;
           }
        }
      //Break through grid edges
      if(currentGrid == 100)
         currentGrid = 0 - gridAmount / 2;
     }
   int bAmount = gridAmount / 2 - currentGrid;
   int sAmount = gridAmount - bAmount;
   int c = currentGrid;
   for(int i=0; i<bAmount; i++)
     {
      Open("Buy");
      currentGrid++;
     }
   currentGrid = c;
   for(int i=0; i<sAmount; i++)
     {
      Open("Sell");
      currentGrid--;
     }
   currentGrid = c;
   FirstTrade = false;
  }
