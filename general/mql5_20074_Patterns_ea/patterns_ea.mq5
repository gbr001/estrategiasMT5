//+------------------------------------------------------------------+
//|                                                  Patterns_EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- includes
#include "Include.mqh"
//--- input parameters
input    ENUM_INPUT_ON_OFF    InpEnableOneBarPatterns       =  INPUT_ON;                        // Enable One-bar patterns:
input    ENUM_INPUT_ON_OFF    InpEnableTwoBarPatterns       =  INPUT_ON;                        // Enable Two-bar patterns:
input    ENUM_INPUT_ON_OFF    InpEnableThreeBarPatterns     =  INPUT_ON;                        // Enable Three-bar patterns:
input    uint                 InpEQ                         =  1;                               // Maximum of pips distance between equal prices
sinput   ENUM_INPUT_YES_NO    InpShowPatternDescript        =  INPUT_NO;                        // Draw Pattern and Descriptions
sinput   uint                 InpFontSize                   =  8;                               // Font size
sinput   color                InpFontColor                  =  clrGray;                         // Texts color
sinput   string               InpFontName                   =  "Calibri";                       // Font name
sinput   long                 InpMagic                      =  1234567;                         // Experts magic number
input    ENUM_OPENED_MODE     InpModeOpened                 =  OPENED_MODE_ANY;                 // Mode of opening positions
input    double               InpVolume                     =  0.1;                             // Lots
input    uint                 InpStopLoss                   =  0;                               // Stop loss in points
input    uint                 InpTakeProfit                 =  0;                               // Take profit in points
sinput   ulong                InpDeviation                  =  10;                              // Slippage of price
sinput   uint                 InpSizeSpread                 =  2;                               // Multiplier spread for stops
//---
input    ENUM_INPUT_ON_OFF    InpEnablePAT_DOUBLE_INSIDE    =  INPUT_ON;                        // <Double inside> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_INSIDE           =  INPUT_ON;                        // <Inside> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_OUTSIDE          =  INPUT_ON;                        // <Outside> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_PINUP            =  INPUT_ON;                        // <Pin up> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_PINDOWN          =  INPUT_ON;                        // <Pin down> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_PPRUP            =  INPUT_ON;                        // <Pivot Point Reversal Up> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_PPRDN            =  INPUT_ON;                        // <Pivot Point Reversal Down> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_DBLHC            =  INPUT_ON;                        // <Double Bar Low With A Higher Close> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_DBHLC            =  INPUT_ON;                        // <Double Bar High With A Lower Close> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_CPRU             =  INPUT_ON;                        // <Close Price Reversal Up> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_CPRD             =  INPUT_ON;                        // <Close Price Reversal Down> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_NB               =  INPUT_ON;                        // <Neutral Bar> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_FBU              =  INPUT_ON;                        // <Force Bar Up> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_FBD              =  INPUT_ON;                        // <Force Bar Down> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_MB               =  INPUT_ON;                        // <Mirror Bar> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_HAMMER           =  INPUT_ON;                        // <Hammer Pattern> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_SHOOTSTAR        =  INPUT_ON;                        // <Shooting Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_EVSTAR           =  INPUT_ON;                        // <Evening Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_MORNSTAR         =  INPUT_ON;                        // <Morning Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_BEARHARAMI       =  INPUT_ON;                        // <Bearish Harami> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_BEARHARAMICROSS  =  INPUT_ON;                        // <Bearish Harami Cross> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_BULLHARAMI       =  INPUT_ON;                        // <Bullish Harami> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_BULLHARAMICROSS  =  INPUT_ON;                        // <Bullish Harami Cross> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_DARKCLOUD        =  INPUT_ON;                        // <Dark Cloud Cover> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_DOJISTAR         =  INPUT_ON;                        // <Doji Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_ENGBEARLINE      =  INPUT_ON;                        // <Engulfing Bearish Line> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_ENGBULLLINE      =  INPUT_ON;                        // <Engulfing Bullish Line> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_EVDJSTAR         =  INPUT_ON;                        // <Evening Doji Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_MORNDJSTAR       =  INPUT_ON;                        // <Morning Doji Star> pattern
input    ENUM_INPUT_ON_OFF    InpEnablePAT_NB2              =  INPUT_ON;                        // <Two Neutral Bars> pattern
//---
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_DOUBLE_INSIDE    =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Double inside> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_INSIDE           =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Inside> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_OUTSIDE          =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Outside> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_PINUP            =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Pin up> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_PINDOWN          =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Pin down> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_PPRUP            =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Pivot Point Reversal Up> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_PPRDN            =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Pivot Point Reversal Down> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_DBLHC            =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Double Bar Low With A Higher Close> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_DBHLC            =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Double Bar High With A Lower Close> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_CPRU             =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Close Price Reversal Up> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_CPRD             =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Close Price Reversal Down> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_NB               =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Neutral Bar> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_FBU              =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Force Bar Up> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_FBD              =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Force Bar Down> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_MB               =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Mirror Bar> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_HAMMER           =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Hammer Pattern> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_SHOOTSTAR        =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Shooting Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_EVSTAR           =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Evening Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_MORNSTAR         =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Morning Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_BEARHARAMI       =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Bearish Harami> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_BEARHARAMICROSS  =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Bearish Harami Cross> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_BULLHARAMI       =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Bullish Harami> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_BULLHARAMICROSS  =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Bullish Harami Cross> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_DARKCLOUD        =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Dark Cloud Cover> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_DOJISTAR         =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Doji Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_ENGBEARLINE      =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Engulfing Bearish Line> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_ENGBULLLINE      =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Engulfing Bullish Line> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_EVDJSTAR         =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Evening Doji Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_MORNDJSTAR       =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Morning Doji Star> pattern
input    ENUM_ORDER_TYPE_BY_PATTERN InpTypeOrderPAT_NB2              =  ENUM_ORDER_TYPE_BY_PATT_BUY;  // <Two Neutral Bars> pattern

//--- global variables
string   ArrayNames[][2]=
  {
     {"Double inside","DBLIN"}, {"Inside Bar","IN"}, {"Outside Bar","OUT"}, {"Pin Bar up","PINUP"}, {"Pin Bar down","PINDOWN"},
     {"Pivot Point Reversal Up","PPRUP"}, {"Pivot Point Reversal Down","PPRDN"}, {"Double Bar Low With A Higher Close","DBLHC"},
     {"Double Bar High With A Lower Close","DBHLC"}, {"Close Price Reversal Up","CPRU"}, {"Close Price Reversal Down","CPRD"},
     {"Neutral Bar","NB"}, {"Force Bar Up","FBU"}, {"Force Bar Down","FBD"}, {"Mirror Bar","MB"}, {"Hammer","HAMMER"},
     {"Shooting Star","SHOOTSTAR"}, {"Evening Star","EVSTAR"}, {"Morning Star","MORNSTAR"}, {"Bearish Harami","BEARHARAMI"},
     {"Bearish Harami Cross","BEARHARAMICROSS"}, {"Bullish Harami","BULLHARAMI"}, {"Bullish Harami Cross","BULLHARAMICROSS"},
     {"Dark Cloud Cover","DARKCLOUD"}, {"Doji Star","DOJISTAR"}, {"Engulfing Bearish Line","ENGBEARLINE"},
     {"Engulfing Bullish Line","ENGBULLLINE"}, {"Evening Doji Star","EVDJSTAR"},
     {"Morning Doji Star","MORNDJSTAR"}, {"Two Neutral Bars","NB2"}
  };
SDataInput  data_inputs;
//--- includes
#include "Patterns.mqh"
#include <Arrays\ArrayLong.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\Trade.mqh>
//--- objects
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
CAccountInfo   account_info;        // Объект-CAccountInfo
CTerminalInfo  terminal_info;       // Объект-CTerminalInfo
CTrade         trade;               // Объект-CTrade
CPatterns      patt();              // Объект-паттерны
CArrayLong     list_trade_patt;     // Список паттернов для открытия
//--- structures
struct SDatas
  {
   CArrayLong        list_tickets;  // список тикетов
   double            total_volume;  // Общий объём
  };
//---
struct SDataPositions
  {
   SDatas            Buy;           // Данные позиций Buy
   SDatas            Sell;          // Данные позиций Sell
  }
Data;
//--- global variables
double         lot;                 // Объём позиции
string         symb;                // Символ
int            prev_total;          // Количество позиций на прошлой проверке
int            size_spread;         // Множитель спреда
bool           to_logs;             // Флаг логирования в визуализаторе
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Установка торговых параметров
   if(!SetTradeParameters())
      return INIT_FAILED;
//--- Установка значений переменных
   size_spread=int(InpSizeSpread<1 ? 1 : InpSizeSpread);
   symb=symbol_info.Name();
   prev_total=0;
   to_logs=(MQLInfoInteger(MQL_VISUAL_MODE) ? true : false);
//--- заполнение структуры данных паттернов
   list_trade_patt.Sort();
   int size=FillingArrayDataPatterns();
   if(size==WRONG_VALUE)
      return INIT_FAILED;
   if(!patt.OnInit(data_inputs))
      return INIT_FAILED;
   patt.SearchProcess();
//--- Успешная инициализация
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Проверка нулевых цен
   if(!RefreshRates()) return;
//--- Заполнение списков тикетов позиций
   int positions_total=PositionsTotal();
   if(prev_total!=positions_total)
     {
      FillingListTickets();
      prev_total=positions_total;
     }
   int num_b=NumberBuy();
   int num_s=NumberSell();
   long magic=InpMagic;
//--- Поиск паттернов и заполнение списка сигналов
   list_trade_patt.Clear();
   if(patt.SearchProcess())
     {
      CArrayObj *list=patt.ListPattern();
      if(list!=NULL)
        {
         int total=list.Total();
         for(int i=0; i<total; i++)
           {
            CPattern *pattern=list.At(i);
            if(pattern==NULL) continue;
            long pattern_type=(long)pattern.TypePattern();
            if(list_trade_patt.Search(pattern_type)==WRONG_VALUE)
               list_trade_patt.Add(pattern_type);
            if(to_logs)
               Print("Found ",pattern.Group(),"-bars pattern ",string(i+1),": ",patt.DescriptPattern((ENUM_PATTERN_TYPE)pattern_type),", position: ",patt.DescriptOrdersPattern((ENUM_PATTERN_TYPE)pattern_type));
           }
        }
     }

//--- Открытие позиций по сигналам
   int total=list_trade_patt.Total();
   if(total>0)
     {
      for(int i=total-1; i>WRONG_VALUE; i--)
        {
         ENUM_PATTERN_TYPE type=(ENUM_PATTERN_TYPE)list_trade_patt.At(i);
         if(type==NULL) continue;
         int res=Trade(type,i);
         if(res==WRONG_VALUE)
           {
            list_trade_patt.Clear();
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Торговая функция                                                 |
//+------------------------------------------------------------------+
int Trade(const ENUM_PATTERN_TYPE &pattern_type,const int index)
  {
   ENUM_POSITION_TYPE type=patt.PositionPattern(pattern_type);
   int number=0,last_total=list_trade_patt.Total();
//--- Всегда одна позиция в рынке Buy или Sell
   if(InpModeOpened==OPENED_MODE_SWING)
     {
      if(type==POSITION_TYPE_BUY && NumberSell()>0) CloseSell();
      if(type==POSITION_TYPE_SELL && NumberBuy()>0) CloseBuy();
     }
//--- Только одна позиция Buy
   if(InpModeOpened==OPENED_MODE_BUY_ONE)
     {
      if(NumberBuy()>0) return WRONG_VALUE;
      if(type==POSITION_TYPE_SELL) return last_total;
     }
//--- Любое количество Buy
   if(InpModeOpened==OPENED_MODE_BUY_MANY)
      if(type==POSITION_TYPE_SELL) return last_total;
//--- Только одна позиция Sell
   if(InpModeOpened==OPENED_MODE_SELL_ONE)
     {
      if(NumberSell()>0) return WRONG_VALUE;
      if(type==POSITION_TYPE_BUY) return last_total;
     }
//--- Любое количество Sell
   if(InpModeOpened==OPENED_MODE_SELL_MANY)
      if(type==POSITION_TYPE_BUY) return last_total;
//--- Все проверки пройдены, либо выбрано любое количество любых позиций - открываем позицию
   if(to_logs)
      Print(__FUNCTION__,": To open ",(type==POSITION_TYPE_BUY ? "Buy" : "Sell")," position by pattern ",patt.DescriptPattern(pattern_type));
   if(OpenPosition(pattern_type))
      list_trade_patt.Delete(index);
//--- Возврат количества открытых позиций
   return last_total-list_trade_patt.Total();
  }
//+------------------------------------------------------------------+
//| Открытие позиции                                                 |
//+------------------------------------------------------------------+
bool OpenPosition(const ENUM_PATTERN_TYPE &pattern_type)
  {
   string comment=patt.DescriptPattern(pattern_type);
   ENUM_POSITION_TYPE type=patt.PositionPattern(pattern_type);
   double sl=(InpStopLoss==0   ? 0 : CorrectStopLoss(symb,type,InpStopLoss));
   double tp=(InpTakeProfit==0 ? 0 : CorrectTakeProfit(symb,type,InpTakeProfit));
   double ll=trade.CheckVolume(symb,lot,(type==POSITION_TYPE_BUY ? SymbolInfoDouble(symb,SYMBOL_ASK) : SymbolInfoDouble(symb,SYMBOL_BID)),(ENUM_ORDER_TYPE)type);
   if(ll>0 && CheckLotForLimitAccount(type,ll))
     {
      //trade.SetExpertMagicNumber(magic_number);  // Можно сделать для каждого типа паттерна свой магик, но для этого нужен иной учёт позиций
      if(RefreshRates())
        {
         if(type==POSITION_TYPE_BUY)
           {
            if(trade.Buy(ll,symb,symbol_info.Ask(),sl,tp,comment))
              {
               FillingListTickets();
               return true;
              }
           }
         if(type==POSITION_TYPE_SELL)
           {
            if(trade.Sell(ll,symb,symbol_info.Bid(),sl,tp))
              {
               FillingListTickets();
               return true;
              }
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Заполнение массива структур данных паттернов                     |
//+------------------------------------------------------------------+
int FillingArrayDataPatterns(void)
  {
   int total=ArrayRange(ArrayNames,0);
   ResetLastError();
   if(ArrayResize(data_inputs.pattern,total)!=total)
     {
      Print(__FUNCTION__,": Error changing s_patterns array size: ",GetLastError());
      return WRONG_VALUE;
     }
   ZeroMemory(data_inputs);
   data_inputs.equ_min=(double)InpEQ;
   data_inputs.font_color=InpFontColor;
   data_inputs.font_name=InpFontName;
   data_inputs.font_size=InpFontSize;
   data_inputs.used_group1=InpEnableOneBarPatterns;
   data_inputs.used_group2=InpEnableTwoBarPatterns;
   data_inputs.used_group3=InpEnableThreeBarPatterns;
   data_inputs.show_descript=InpShowPatternDescript;
   for(int i=0; i<total; i++)
     {
      data_inputs.pattern[i].name_long=ArrayNames[i][0];
      data_inputs.pattern[i].mame_short=ArrayNames[i][1];
      data_inputs.pattern[i].used_this=
                                       (
                                       i==0  ?  InpEnablePAT_DOUBLE_INSIDE    :
                                       i==1  ?  InpEnablePAT_INSIDE           :
                                       i==2  ?  InpEnablePAT_OUTSIDE          :
                                       i==3  ?  InpEnablePAT_PINUP            :
                                       i==4  ?  InpEnablePAT_PINDOWN          :
                                       i==5  ?  InpEnablePAT_PPRUP            :
                                       i==6  ?  InpEnablePAT_PPRDN            :
                                       i==7  ?  InpEnablePAT_DBLHC            :
                                       i==8  ?  InpEnablePAT_DBHLC            :
                                       i==9  ?  InpEnablePAT_CPRU             :
                                       i==10 ?  InpEnablePAT_CPRD             :
                                       i==11 ?  InpEnablePAT_NB               :
                                       i==12 ?  InpEnablePAT_FBU              :
                                       i==13 ?  InpEnablePAT_FBD              :
                                       i==14 ?  InpEnablePAT_MB               :
                                       i==15 ?  InpEnablePAT_HAMMER           :
                                       i==16 ?  InpEnablePAT_SHOOTSTAR        :
                                       i==17 ?  InpEnablePAT_EVSTAR           :
                                       i==18 ?  InpEnablePAT_MORNSTAR         :
                                       i==19 ?  InpEnablePAT_BEARHARAMI       :
                                       i==20 ?  InpEnablePAT_BEARHARAMICROSS  :
                                       i==21 ?  InpEnablePAT_BULLHARAMI       :
                                       i==22 ?  InpEnablePAT_BULLHARAMICROSS  :
                                       i==23 ?  InpEnablePAT_DARKCLOUD        :
                                       i==24 ?  InpEnablePAT_DOJISTAR         :
                                       i==25 ?  InpEnablePAT_ENGBEARLINE      :
                                       i==26 ?  InpEnablePAT_ENGBULLLINE      :
                                       i==27 ?  InpEnablePAT_EVDJSTAR         :
                                       i==28 ?  InpEnablePAT_MORNDJSTAR       :
                                       i==29 ?  InpEnablePAT_NB2              :
                                       false
                                       );
                                       data_inputs.pattern[i].order_type=ENUM_ORDER_TYPE
                                       (
                                       i==0  ?  InpTypeOrderPAT_DOUBLE_INSIDE    :
                                       i==1  ?  InpTypeOrderPAT_INSIDE           :
                                       i==2  ?  InpTypeOrderPAT_OUTSIDE          :
                                       i==3  ?  InpTypeOrderPAT_PINUP            :
                                       i==4  ?  InpTypeOrderPAT_PINDOWN          :
                                       i==5  ?  InpTypeOrderPAT_PPRUP            :
                                       i==6  ?  InpTypeOrderPAT_PPRDN            :
                                       i==7  ?  InpTypeOrderPAT_DBLHC            :
                                       i==8  ?  InpTypeOrderPAT_DBHLC            :
                                       i==9  ?  InpTypeOrderPAT_CPRU             :
                                       i==10 ?  InpTypeOrderPAT_CPRD             :
                                       i==11 ?  InpTypeOrderPAT_NB               :
                                       i==12 ?  InpTypeOrderPAT_FBU              :
                                       i==13 ?  InpTypeOrderPAT_FBD              :
                                       i==14 ?  InpTypeOrderPAT_MB               :
                                       i==15 ?  InpTypeOrderPAT_HAMMER           :
                                       i==16 ?  InpTypeOrderPAT_SHOOTSTAR        :
                                       i==17 ?  InpTypeOrderPAT_EVSTAR           :
                                       i==18 ?  InpTypeOrderPAT_MORNSTAR         :
                                       i==19 ?  InpTypeOrderPAT_BEARHARAMI       :
                                       i==20 ?  InpTypeOrderPAT_BEARHARAMICROSS  :
                                       i==21 ?  InpTypeOrderPAT_BULLHARAMI       :
                                       i==22 ?  InpTypeOrderPAT_BULLHARAMICROSS  :
                                       i==23 ?  InpTypeOrderPAT_DARKCLOUD        :
                                       i==24 ?  InpTypeOrderPAT_DOJISTAR         :
                                       i==25 ?  InpTypeOrderPAT_ENGBEARLINE      :
                                       i==26 ?  InpTypeOrderPAT_ENGBULLLINE      :
                                       i==27 ?  InpTypeOrderPAT_EVDJSTAR         :
                                       i==28 ?  InpTypeOrderPAT_MORNDJSTAR       :
                                       i==29 ?  InpTypeOrderPAT_NB2              :
                                       WRONG_VALUE
                                       );
                                       }
   return total;
  }
//+------------------------------------------------------------------+
//| Установка торговых параметров                                    |
//+------------------------------------------------------------------+
bool SetTradeParameters()
  {
//--- Установка символа
   ResetLastError();
   if(!symbol_info.Name(Symbol()))
     {
      Print(__FUNCTION__,": Error setting ",Symbol()," symbol: ",GetLastError());
      return false;
     }
//--- Получение цен
   ResetLastError();
   if(!symbol_info.RefreshRates())
     {
      Print(__FUNCTION__,": Error obtaining ",symbol_info.Name()," data: ",GetLastError());
      return false;
     }
   if(account_info.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING)
     {
      Print(__FUNCTION__,": ",account_info.MarginModeDescription(),"-account. EA should work on a hedge account.");
      return false;
     }
//--- Автоматическая установка типа заполнения
   trade.SetTypeFilling(GetTypeFilling());
//--- Установка магика
   trade.SetExpertMagicNumber(InpMagic);
//--- Установка проскальзывания
   trade.SetDeviationInPoints(InpDeviation);
//--- Установка лота с корректировкой введённого значения
   lot=CorrectLots(InpVolume);
//--- Асинхронный режим отправки ордеров выключен
   trade.SetAsyncMode(false);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Обновление цен                                                   |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
   if(!symbol_info.RefreshRates()) return false;
   if(symbol_info.Ask()==0 || symbol_info.Bid()==0) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия заданного бара                         |
//+------------------------------------------------------------------+
datetime Time(int shift)
  {
   datetime array[];
   if(CopyTime(symb,PERIOD_CURRENT,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Возвращает корректный лот                                        |
//+------------------------------------------------------------------+
double CorrectLots(const double lots,const bool to_min_correct=true)
  {
   double min=symbol_info.LotsMin();
   double max=symbol_info.LotsMax();
   double step=symbol_info.LotsStep();
   return(to_min_correct ? VolumeRoundToSmaller(lots,min,max,step) : VolumeRoundToCorrect(lots,min,max,step));
  }
//+------------------------------------------------------------------+
//| Возвращает ближайший корректный лот                              |
//+------------------------------------------------------------------+
double VolumeRoundToCorrect(const double volume,const double min,const double max,const double step)
  {
   return(step==0 ? min : fmin(fmax(round(volume/step)*step,min),max));
  }
//+------------------------------------------------------------------+
//| Возвращает ближайший в меньшую сторону корректный лот            |
//+------------------------------------------------------------------+
double VolumeRoundToSmaller(const double volume,const double min,const double max,const double step)
  {
   return(step==0 ? min : fmin(fmax(floor(volume/step)*step,min),max));
  }
//+------------------------------------------------------------------+
//| Возвращает флаг не превышения общего объёма на счёте             |
//+------------------------------------------------------------------+
bool CheckLotForLimitAccount(const ENUM_POSITION_TYPE position_type,const double volume)
  {
   if(symbol_info.LotsLimit()==0) return true;
   double total_volume=(position_type==POSITION_TYPE_BUY ? Data.Buy.total_volume : Data.Sell.total_volume);
   return(total_volume+volume<=symbol_info.LotsLimit());
  }
//+------------------------------------------------------------------+
//| Проверяет возможность модификации по уровню заморозки            |
//+------------------------------------------------------------------+
bool CheckFreezeLevel(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_modified)
  {
   int lv=(int)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_FREEZE_LEVEL);
   if(lv==0) return true;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return false;
   int dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) :
                 order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_modified);
   return(NormalizeDouble(fabs(price-price_modified)-lv*pt,dg)>0);
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double stop_loss,const double open_price=0)
  {
   if(stop_loss==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(open_price>0 ? open_price : position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmin(price-lv*pt,stop_loss),dg) :
    NormalizeDouble(::fmax(price+lv*pt,stop_loss),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_POSITION_TYPE position_type,const int stop_loss)
  {
   if(stop_loss==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmin(price-lv*pt,price-stop_loss*pt),dg) :
    NormalizeDouble(::fmax(price+lv*pt,price+stop_loss*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Проверяет StopLoss на корректность относительно StopLevel        |
//+------------------------------------------------------------------+
bool CheckCorrectStopLoss(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double stop_loss)
  {
   if(stop_loss==0) return true;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return false;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (
    position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(stop_loss-price+lv*pt,dg)<0 :
    NormalizeDouble(stop_loss-price-lv*pt,dg)>0
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const int take_profit)
  {
   if(take_profit==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(fmax(price+lv*pt,price+take_profit*pt),dg) :
    NormalizeDouble(fmin(price-lv*pt,price-take_profit*pt),dg)
    );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double take_profit,const double open_price=0)
  {
   if(take_profit==0) return 0;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return 0;
   double price=(open_price>0 ? open_price : position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : SymbolInfoDouble(symbol_name,SYMBOL_ASK));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(::fmax(price+lv*pt,take_profit),dg) :
    NormalizeDouble(::fmin(price-lv*pt,take_profit),dg)
    );
  }
//+------------------------------------------------------------------+
//| Прверяет TakeProfit на корректность относительно StopLevel       |
//+------------------------------------------------------------------+
bool CheckCorrectTakeProfit(const string symbol_name,const ENUM_POSITION_TYPE position_type,const double take_profit)
  {
   if(take_profit==0) return true;
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   if(pt==0) return false;
   double price=(position_type==POSITION_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : SymbolInfoDouble(symbol_name,SYMBOL_BID));
   int lv=StopLevel(symbol_name),dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   return
   (
    position_type==POSITION_TYPE_BUY ?
    NormalizeDouble(take_profit-price-lv*pt,dg)>0 :
    NormalizeDouble(take_profit-price+lv*pt,dg)<0
    );
  }
//+------------------------------------------------------------------+
//| Возвращает рассчитанный StopLevel                                |
//+------------------------------------------------------------------+
int StopLevel(const string symbol_name)
  {
   int sp=(int)SymbolInfoInteger(symbol_name,SYMBOL_SPREAD);
   int lv=(int)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_STOPS_LEVEL);
   return(lv==0 ? sp*size_spread : lv);
  }//+------------------------------------------------------------------+
//| Закрывает позиции Buy                                            |
//+------------------------------------------------------------------+
void CloseBuy(void)
  {
   int total=Data.Buy.list_tickets.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Buy.list_tickets.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
   FillingListTickets();
  }
//+------------------------------------------------------------------+
//| Закрывает позиции Sell                                           |
//+------------------------------------------------------------------+
void CloseSell(void)
  {
   int total=Data.Sell.list_tickets.Total();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=Data.Sell.list_tickets.At(i);
      if(ticket==NULL) continue;
      trade.PositionClose(ticket,InpDeviation);
     }
   FillingListTickets();
  }
//+------------------------------------------------------------------+
//| Заполняет массивы тикетов позиций                                |
//+------------------------------------------------------------------+
void FillingListTickets(void)
  {
   Data.Buy.list_tickets.Clear();
   Data.Sell.list_tickets.Clear();
   Data.Buy.total_volume=0;
   Data.Sell.total_volume=0;
//---
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic)   continue;
      if(PositionGetString(POSITION_SYMBOL)!=symb)       continue;
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double volume=PositionGetDouble(POSITION_VOLUME);
      if(type==POSITION_TYPE_BUY)
        {
         Data.Buy.list_tickets.Add(ticket);
         Data.Buy.total_volume+=volume;
        }
      else
        {
         Data.Sell.list_tickets.Add(ticket);
         Data.Sell.total_volume+=volume;
        }
     }
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Buy                                |
//+------------------------------------------------------------------+
int NumberBuy(void)
  {
   return Data.Buy.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает количество позиций Sell                               |
//+------------------------------------------------------------------+
int NumberSell(void)
  {
   return Data.Sell.list_tickets.Total();
  }
//+------------------------------------------------------------------+
//| Возвращает тип исполнения ордера, равный type,                   |
//| если он доступен на символе, иначе - корректный вариант          |
//| https://www.mql5.com/ru/forum/170952/page4#comment_4128864       |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetTypeFilling(const ENUM_ORDER_TYPE_FILLING type=ORDER_FILLING_RETURN)
  {
   const ENUM_SYMBOL_TRADE_EXECUTION exe_mode=symbol_info.TradeExecution();
   const int filling_mode=symbol_info.TradeFillFlags();

   return(
          (filling_mode==0 || (type>=ORDER_FILLING_RETURN) || ((filling_mode &(type+1))!=type+1)) ?
          (((exe_mode==SYMBOL_TRADE_EXECUTION_EXCHANGE) || (exe_mode==SYMBOL_TRADE_EXECUTION_INSTANT)) ?
          ORDER_FILLING_RETURN :((filling_mode==SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) : type
          );
  }
//+------------------------------------------------------------------+
//| Возвращает флаг валидного магика                                 |
//+------------------------------------------------------------------+
bool IsValidMagic(const ulong magic_number)
  {
   for(int i=0; i<TOTAL_PATTERNS; i++)
     {
      ulong mn=InpMagic+(ulong)i;
      if(mn==magic_number) return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
