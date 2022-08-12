//+------------------------------------------------------------------+
//|                                                     Patterns.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 31
#property indicator_plots   30
//--- plot P1
#property indicator_label1  "Double inside"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot P2
#property indicator_label2  "Inside"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot P3
#property indicator_label3  "Outside"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot P4
#property indicator_label4  "Pin up"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot P5
#property indicator_label5  "Pin down"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot P6
#property indicator_label6  "Pivot Point Reversal Up"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot P7
#property indicator_label7  "Pivot Point Reversal Down"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrRed
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- plot P8
#property indicator_label8  "Double Bar Low With A Higher Close"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrRed
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
//--- plot P9
#property indicator_label9  "Double Bar High With A Lower Close"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1
//--- plot P10
#property indicator_label10  "Close Price Reversal Up"
#property indicator_type10   DRAW_ARROW
#property indicator_color10  clrRed
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1
//--- plot P11
#property indicator_label11  "Close Price Reversal Down"
#property indicator_type11   DRAW_ARROW
#property indicator_color11  clrRed
#property indicator_style11  STYLE_SOLID
#property indicator_width11  1
//--- plot P12
#property indicator_label12  "Neutral Bar"
#property indicator_type12   DRAW_ARROW
#property indicator_color12  clrRed
#property indicator_style12  STYLE_SOLID
#property indicator_width12  1
//--- plot P13
#property indicator_label13  "Force Bar Up"
#property indicator_type13   DRAW_ARROW
#property indicator_color13  clrRed
#property indicator_style13  STYLE_SOLID
#property indicator_width13  1
//--- plot P14
#property indicator_label14  "Force Bar Down"
#property indicator_type14   DRAW_ARROW
#property indicator_color14  clrRed
#property indicator_style14  STYLE_SOLID
#property indicator_width14  1
//--- plot P15
#property indicator_label15  "Mirror Bar"
#property indicator_type15   DRAW_ARROW
#property indicator_color15  clrRed
#property indicator_style15  STYLE_SOLID
#property indicator_width15  1
//--- plot P16
#property indicator_label16  "Hammer Pattern"
#property indicator_type16   DRAW_ARROW
#property indicator_color16  clrRed
#property indicator_style16  STYLE_SOLID
#property indicator_width16  1
//--- plot P17
#property indicator_label17  "Shooting Star"
#property indicator_type17   DRAW_ARROW
#property indicator_color17  clrRed
#property indicator_style17  STYLE_SOLID
#property indicator_width17  1
//--- plot P18
#property indicator_label18  "Evening Star"
#property indicator_type18   DRAW_ARROW
#property indicator_color18  clrRed
#property indicator_style18  STYLE_SOLID
#property indicator_width18  1
//--- plot P19
#property indicator_label19  "Morning Star"
#property indicator_type19   DRAW_ARROW
#property indicator_color19  clrRed
#property indicator_style19  STYLE_SOLID
#property indicator_width19  1
//--- plot P20
#property indicator_label20  "Bearish Harami"
#property indicator_type20   DRAW_ARROW
#property indicator_color20  clrRed
#property indicator_style20  STYLE_SOLID
#property indicator_width20  1
//--- plot P21
#property indicator_label21  "Bearish Harami Cross"
#property indicator_type21   DRAW_ARROW
#property indicator_color21  clrRed
#property indicator_style21  STYLE_SOLID
#property indicator_width21  1
//--- plot P22
#property indicator_label22  "Bullish Harami"
#property indicator_type22   DRAW_ARROW
#property indicator_color22  clrRed
#property indicator_style22  STYLE_SOLID
#property indicator_width22  1
//--- plot P23
#property indicator_label23  "Bullish Harami Cross"
#property indicator_type23   DRAW_ARROW
#property indicator_color23  clrRed
#property indicator_style23  STYLE_SOLID
#property indicator_width23  1
//--- plot P24
#property indicator_label24  "Dark Cloud Cover"
#property indicator_type24   DRAW_ARROW
#property indicator_color24  clrRed
#property indicator_style24  STYLE_SOLID
#property indicator_width24  1
//--- plot P25
#property indicator_label25  "Doji Star"
#property indicator_type25   DRAW_ARROW
#property indicator_color25  clrRed
#property indicator_style25  STYLE_SOLID
#property indicator_width25  1
//--- plot P26
#property indicator_label26  "Engulfing Bearish Line"
#property indicator_type26   DRAW_ARROW
#property indicator_color26  clrRed
#property indicator_style26  STYLE_SOLID
#property indicator_width26  1
//--- plot P27
#property indicator_label27  "Engulfing Bullish Line"
#property indicator_type27   DRAW_ARROW
#property indicator_color27  clrRed
#property indicator_style27  STYLE_SOLID
#property indicator_width27  1
//--- plot P28
#property indicator_label28  "Evening Doji Star"
#property indicator_type28   DRAW_ARROW
#property indicator_color28  clrRed
#property indicator_style28  STYLE_SOLID
#property indicator_width28  1
//--- plot P29
#property indicator_label29  "Morning Doji Star"
#property indicator_type29   DRAW_ARROW
#property indicator_color29  clrRed
#property indicator_style29  STYLE_SOLID
#property indicator_width29  1
//--- plot P30
#property indicator_label30  "Two Neutral Bars"
#property indicator_type30   DRAW_ARROW
#property indicator_color30  clrRed
#property indicator_style30  STYLE_SOLID
#property indicator_width30  1
//--- indicator buffers
double         BufferATR[];
//--- enums
enum ENUM_INPUT_ON_OFF
  {
   INPUT_ON    =  1,             // On
   INPUT_OFF   =  0              // Off
  };
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1,             // Yes
   INPUT_NO    =  0              // No
  };
//+------------------------------------------------------------------+
//| Перечисление типов паттернов                                     |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE
  {
   PATTERN_TYPE_DOUBLE_INSIDE,   // Double inside
   PATTERN_TYPE_INSIDE,          // Inside
   PATTERN_TYPE_OUTSIDE,         // Outside
   PATTERN_TYPE_PINUP,           // Pin up
   PATTERN_TYPE_PINDOWN,         // Pin down
   PATTERN_TYPE_PPRUP,           // Pivot Point Reversal Up
   PATTERN_TYPE_PPRDN,           // Pivot Point Reversal Down
   PATTERN_TYPE_DBLHC,           // Double Bar Low With A Higher Close
   PATTERN_TYPE_DBHLC,           // Double Bar High With A Lower Close
   PATTERN_TYPE_CPRU,            // Close Price Reversal Up
   PATTERN_TYPE_CPRD,            // Close Price Reversal Down
   PATTERN_TYPE_NB,              // Neutral Bar
   PATTERN_TYPE_FBU,             // Force Bar Up
   PATTERN_TYPE_FBD,             // Force Bar Down
   PATTERN_TYPE_MB,              // Mirror Bar
   PATTERN_TYPE_HAMMER,          // Hammer Pattern
   PATTERN_TYPE_SHOOTSTAR,       // Shooting Star
   PATTERN_TYPE_EVSTAR,          // Evening Star
   PATTERN_TYPE_MORNSTAR,        // Morning Star
   PATTERN_TYPE_BEARHARAMI,      // Bearish Harami
   PATTERN_TYPE_BEARHARAMICROSS, // Bearish Harami Cross
   PATTERN_TYPE_BULLHARAMI,      // Bullish Harami
   PATTERN_TYPE_BULLHARAMICROSS, // Bullish Harami Cross
   PATTERN_TYPE_DARKCLOUD,       // Dark Cloud Cover
   PATTERN_TYPE_DOJISTAR,        // Doji Star
   PATTERN_TYPE_ENGBEARLINE,     // Engulfing Bearish Line
   PATTERN_TYPE_ENGBULLLINE,     // Engulfing Bullish Line
   PATTERN_TYPE_EVDJSTAR,        // Evening Doji Star
   PATTERN_TYPE_MORNDJSTAR,      // Morning Doji Star
   PATTERN_TYPE_NB2              // Two Neutral Bars
  };
//--- input parameters
input ENUM_INPUT_ON_OFF InpEnableOneBarPatterns       =  INPUT_ON;   // Enable One-bar patterns:
input ENUM_INPUT_ON_OFF InpEnableTwoBarPatterns       =  INPUT_ON;   // Enable Two-bar patterns:
input ENUM_INPUT_ON_OFF InpEnableThreeBarPatterns     =  INPUT_ON;   // Enable Three-bar patterns:
input uint              InpEQ                         =  1;          // Maximum of pips distance between equal prices
input ENUM_INPUT_YES_NO InpShowPatternDescript        =  INPUT_YES;  // Show Pattern Descriptions
input uint              InpFontSize                   =  8;          // Font size
input color             InpFontColor                  =  clrGray;    // Texts color
input string            InpFontName                   =  "Calibri";  // Font name
//---
input ENUM_INPUT_ON_OFF InpEnablePAT_DOUBLE_INSIDE    =  INPUT_ON;   // <Double inside> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_INSIDE           =  INPUT_ON;   // <Inside> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_OUTSIDE          =  INPUT_ON;   // <Outside> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_PINUP            =  INPUT_ON;   // <Pin up> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_PINDOWN          =  INPUT_ON;   // <Pin down> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_PPRUP            =  INPUT_ON;   // <Pivot Point Reversal Up> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_PPRDN            =  INPUT_ON;   // <Pivot Point Reversal Down> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_DBLHC            =  INPUT_ON;   // <Double Bar Low With A Higher Close> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_DBHLC            =  INPUT_ON;   // <Double Bar High With A Lower Close> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_CPRU             =  INPUT_ON;   // <Close Price Reversal Up> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_CPRD             =  INPUT_ON;   // <Close Price Reversal Down> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_NB               =  INPUT_ON;   // <Neutral Bar> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_FBU              =  INPUT_ON;   // <Force Bar Up> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_FBD              =  INPUT_ON;   // <Force Bar Down> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_MB               =  INPUT_ON;   // <Mirror Bar> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_HAMMER           =  INPUT_ON;   // <Hammer Pattern> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_SHOOTSTAR        =  INPUT_ON;   // <Shooting Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_EVSTAR           =  INPUT_ON;   // <Evening Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_MORNSTAR         =  INPUT_ON;   // <Morning Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_BEARHARAMI       =  INPUT_ON;   // <Bearish Harami> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_BEARHARAMICROSS  =  INPUT_ON;   // <Bearish Harami Cross> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_BULLHARAMI       =  INPUT_ON;   // <Bullish Harami> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_BULLHARAMICROSS  =  INPUT_ON;   // <Bullish Harami Cross> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_DARKCLOUD        =  INPUT_ON;   // <Dark Cloud Cover> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_DOJISTAR         =  INPUT_ON;   // <Doji Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_ENGBEARLINE      =  INPUT_ON;   // <Engulfing Bearish Line> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_ENGBULLLINE      =  INPUT_ON;   // <Engulfing Bullish Line> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_EVDJSTAR         =  INPUT_ON;   // <Evening Doji Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_MORNDJSTAR       =  INPUT_ON;   // <Morning Doji Star> pattern
input ENUM_INPUT_ON_OFF InpEnablePAT_NB2              =  INPUT_ON;   // <Two Neutral Bars> pattern
//--- global variables
int      handle_atr;
double   eq_pp;
string   prefix;
string   font_name;
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
//--- structures
struct SDataBuffers
  {
   double            Buffer[];         // Буфер паттерна
   ENUM_PATTERN_TYPE type_pattern;     // Тип паттерна
   //--- Возвращает Название паттерна
   string            Description(void) { return DescriptionPattern(type_pattern); }
  } Pattern[];  // Структура данных паттернов
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   if(Point()==0)
     {
      Print("Error. Unable to get the value of points on ",Symbol());
      return INIT_FAILED;
     }
   eq_pp=InpEQ*Point();
   prefix="Patterns_";
   font_name=(InpFontName=="" ? "Calibri" : InpFontName);
//--- indicator buffers mapping
//--- and setting a code from the Wingdings charset as the property of PLOT_ARROW,
//--- and setting as series
   ArraySetAsSeries(BufferATR,true);
   int total=ArrayRange(ArrayNames,0);
   ArrayResize(Pattern,total);
   ZeroMemory(Pattern);
   for(int i=0; i<total; i++)
     {
      SetIndexBuffer(i,Pattern[i].Buffer,INDICATOR_DATA);
      PlotIndexSetInteger(i,PLOT_ARROW,159);
      Pattern[i].type_pattern=(ENUM_PATTERN_TYPE)i;
      ArraySetAsSeries(Pattern[i].Buffer,true);
     }
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Patterns");
//--- create ATR handles
   ResetLastError();
   handle_atr=iATR(Symbol(),PERIOD_CURRENT,14);
   if(handle_atr==INVALID_HANDLE)
     {
      Print("The iATR object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,prefix);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка индексации массивов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      int total=ArraySize(Pattern);
      for(int i=0; i<total; i++)
         ArrayInitialize(Pattern[i].Buffer,EMPTY_VALUE);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_atr,0,0,count,BufferATR);
   if(copied!=count) return 0;
//--- Расчёт индикатора
   for(int i=limit; i>0 && !IsStopped(); i--)
      CheckPatterns(i,open,high,low,close,time);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверяет наличие паттерна по индексу бара                       |
//+------------------------------------------------------------------+
void CheckPatterns(const int index,const double &open[],const double &high[],const double &low[],const double &close[],const datetime &time[])
  {
//--- Очистка буферов на текущем индексе
   int total=ArraySize(Pattern);
   for(int i=0; i<total; i++)
      Pattern[i].Buffer[index]=EMPTY_VALUE;
//--- Расчёт паттернов
   double min_dev=fmax(eq_pp,Point());
   double min_dev4=fmax(eq_pp*4,Point()*4);
//--- свеча со смещением 0
   double open_0=open[index];
   double close_0=close[index];
   double low_0=low[index];
   double high_0=high[index];
   double body_top_0=fmax(open_0,close_0);
   double body_bottom_0=fmin(open_0,close_0);
   double body_size_0=body_top_0-body_bottom_0;
   double shadow_upper_0=high_0-body_top_0;
   double shadow_lower_0=body_bottom_0-low_0;
//--- свеча со смещением 1
   double open_1=open[index+1];
   double close_1=close[index+1];
   double low_1=low[index+1];
   double high_1=high[index+1];
   double body_top_1=fmax(open_1,close_1);
   double body_bottom_1=fmin(open_1,close_1);
   double body_size_1=body_top_1-body_bottom_1;
   double shadow_upper_1=high_1-body_top_1;
   double shadow_lower_1=body_bottom_1-low_1;
//--- свеча со смещением 2
   double open_2=open[index+2];
   double close_2=close[index+2];
   double low_2=low[index+2];
   double high_2=high[index+2];
   double body_top_2=fmax(open_2,close_2);
   double body_bottom_2=fmin(open_2,close_2);
   double body_size_2=body_top_2-body_bottom_2;
   double shadow_upper_2=high_2-body_top_2;
   double shadow_lower_2=body_bottom_2-low_2;

//--- однобаровые паттерны
   if(InpEnableOneBarPatterns)
     {
      if(Cmp(open_0,close_0)==0 && shadow_upper_0>min_dev4 && shadow_lower_0>min_dev4)
         if(InpEnablePAT_NB) DrawPattern(index,PATTERN_TYPE_NB,high,low,time);
      if(close_0==high_0)
         if(InpEnablePAT_FBU) DrawPattern(index,PATTERN_TYPE_FBU,high,low,time);
      if(close_0==low_0)
         if(InpEnablePAT_FBD) DrawPattern(index,PATTERN_TYPE_FBD,high,low,time);
      if(shadow_upper_0<=min_dev && shadow_lower_0>2*body_size_0)
         if(InpEnablePAT_HAMMER) DrawPattern(index,PATTERN_TYPE_HAMMER,high,low,time);
      if(shadow_lower_0<=min_dev && shadow_upper_0>2*body_size_0)
         if(InpEnablePAT_SHOOTSTAR) DrawPattern(index,PATTERN_TYPE_SHOOTSTAR,high,low,time);
     }

//--- двухбаровые паттерны
   if(InpEnableTwoBarPatterns)
     {
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0)
         if(InpEnablePAT_INSIDE) DrawPattern(index,PATTERN_TYPE_INSIDE,high,low,time);
      if(Cmp(high_0,high_1)>0 && Cmp(low_0,low_1)<0)
         if(InpEnablePAT_OUTSIDE) DrawPattern(index,PATTERN_TYPE_OUTSIDE,high,low,time);
      if(Cmp(high_0,high_1)==0 && Cmp(close_0,close_1)<0 && Cmp(low_0,low_1)<=0)
         if(InpEnablePAT_DBHLC) DrawPattern(index,PATTERN_TYPE_DBHLC,high,low,time);
      if(Cmp(low_0,low_1)==0 && Cmp(close_0,close_1)>0 && Cmp(high_0,high_1)>=0)
         if(InpEnablePAT_DBLHC) DrawPattern(index,PATTERN_TYPE_DBLHC,high,low,time);
      if(Cmp(body_size_1,body_size_0)==0 && Cmp(open_1,close_0)==0)
         if(InpEnablePAT_MB) DrawPattern(index,PATTERN_TYPE_MB,high,low,time);
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0 && Cmp(close_1,open_1)>0 && Cmp(close_0,open_0)<0 && Cmp(body_size_1,body_size_0)>0 && Cmp(close_1,open_0)>0 && Cmp(open_1,close_0)<0)
         if(InpEnablePAT_BEARHARAMI) DrawPattern(index,PATTERN_TYPE_BEARHARAMI,high,low,time);
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0 && Cmp(close_1,open_1)>0 && Cmp(open_0,close_0)==0 && Cmp(body_size_1,body_size_0)>0 && Cmp(close_1,open_0)>0 && Cmp(open_1,close_0)<0)
         if(InpEnablePAT_BEARHARAMICROSS) DrawPattern(index,PATTERN_TYPE_BEARHARAMICROSS,high,low,time);
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0 && Cmp(close_1,open_1)<0 && Cmp(close_0,open_0)>0 && Cmp(body_size_1,body_size_0)>0 && Cmp(close_1,open_0)<0 && Cmp(open_1,close_0)>0)
         if(InpEnablePAT_BULLHARAMI) DrawPattern(index,PATTERN_TYPE_BULLHARAMI,high,low,time);
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0 && Cmp(close_1,open_1)<0 && Cmp(open_0,close_0)==0 && Cmp(body_size_1,body_size_0)>0 && Cmp(close_1,open_0)<0 && Cmp(open_1,close_0)>0)
         if(InpEnablePAT_BULLHARAMICROSS) DrawPattern(index,PATTERN_TYPE_BULLHARAMICROSS,high,low,time);
      if(Cmp(close_1,open_1)>0 && Cmp(close_0,open_0)<0 && Cmp(high_1,open_0)<0 && Cmp(close_0,close_1)<0 && Cmp(close_0,open_1)>0)
         if(InpEnablePAT_DARKCLOUD) DrawPattern(index,PATTERN_TYPE_DARKCLOUD,high,low,time);
      if(Cmp(open_0,close_0)==0 && Cmp(close_1,open_1)>0 && Cmp(open_0,high_1)>0 && Cmp(close_1,open_1)<0 && Cmp(open_0,low_1)<0)
         if(InpEnablePAT_DOJISTAR) DrawPattern(index,PATTERN_TYPE_DOJISTAR,high,low,time);
      if(Cmp(close_1,open_1)>0 && Cmp(close_0,open_0)<0 && Cmp(open_0,close_1)>0 && Cmp(close_0,open_1)<0)
         if(InpEnablePAT_ENGBEARLINE) DrawPattern(index,PATTERN_TYPE_ENGBEARLINE,high,low,time);
      if(Cmp(close_1,open_1)<0 && Cmp(close_0,open_0)>0 && Cmp(open_0,close_1)<0 && Cmp(close_0,open_1)>0)
         if(InpEnablePAT_ENGBULLLINE) DrawPattern(index,PATTERN_TYPE_ENGBULLLINE,high,low,time);
      if(Cmp(open_0,close_0)==0 && shadow_upper_0>min_dev4 && shadow_lower_0>min_dev4 && Cmp(open_1,close_1)==0 && shadow_upper_1>min_dev4 && shadow_lower_1>min_dev4)
         if(InpEnablePAT_NB2) DrawPattern(index,PATTERN_TYPE_NB2,high,low,time);
     }

//--- трёхбаровые паттерны
   if(InpEnableThreeBarPatterns)
     {
      if(Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)>0 && Cmp(high_1,high_2)<0 && Cmp(low_1,low_2)>0)
         if(InpEnablePAT_DOUBLE_INSIDE) DrawPattern(index,PATTERN_TYPE_DOUBLE_INSIDE,high,low,time);
      if(Cmp(high_1,high_2)>0 && Cmp(high_1,high_0)>0 && Cmp(low_1,low_2)>0 && Cmp(low_1,low_0)>0 && body_size_1*2<shadow_upper_1)
         if(InpEnablePAT_PINUP) DrawPattern(index,PATTERN_TYPE_PINUP,high,low,time);
      if(Cmp(high_1,high_2)<0 && Cmp(high_1,high_0)<0 && Cmp(low_1,low_2)<0 && Cmp(low_1,low_0)<0 && body_size_1*2<shadow_lower_1)
         if(InpEnablePAT_PINDOWN) DrawPattern(index,PATTERN_TYPE_PINDOWN,high,low,time);
      if(Cmp(high_1,high_2)>0 && Cmp(high_1,high_0)>0 && Cmp(low_1,low_2)>0 && Cmp(low_1,low_0)>0 && Cmp(close_0,low_1)<0)
         if(InpEnablePAT_PPRDN) DrawPattern(index,PATTERN_TYPE_PPRDN,high,low,time);
      if(Cmp(high_1,high_2)<0 && Cmp(high_1,high_0)<0 && Cmp(low_1,low_2)<0 && Cmp(low_1,low_0)<0 && Cmp(close_0,high_1)>0)
         if(InpEnablePAT_PPRUP) DrawPattern(index,PATTERN_TYPE_PPRUP,high,low,time);
      if(Cmp(high_1,high_2)<0 && Cmp(low_1,low_2)<0 && Cmp(high_0,high_1)<0 && Cmp(low_0,low_1)<0 && Cmp(close_0,close_1)>0 && Cmp(open_0,close_0)<0)
         if(InpEnablePAT_CPRU) DrawPattern(index,PATTERN_TYPE_CPRU,high,low,time);
      if(Cmp(high_1,high_2)>0 && Cmp(low_1,low_2)>0 && Cmp(high_0,high_1)>0 && Cmp(low_0,low_1)>0 && Cmp(close_0,close_1)<0 && Cmp(open_0,close_0)>0)
         if(InpEnablePAT_CPRD) DrawPattern(index,PATTERN_TYPE_CPRD,high,low,time);
      if(Cmp(close_2,open_2)>0 && Cmp(close_1,open_1)>0 && Cmp(close_0,open_0)<0 && Cmp(close_2,open_1)<0 && Cmp(body_size_2,body_size_1)>0 && Cmp(body_size_1,body_size_0)<0 && Cmp(close_0,open_2)>0 && Cmp(close_0,close_2)<0)
         if(InpEnablePAT_EVSTAR) DrawPattern(index,PATTERN_TYPE_EVSTAR,high,low,time);
      if(Cmp(close_2,open_2)<0 && Cmp(close_1,open_1)>0 && Cmp(close_0,open_0)>0 && Cmp(close_2,open_1)>0 && Cmp(body_size_2,body_size_1)>0 && Cmp(body_size_1,body_size_0)<0 && Cmp(close_0,close_2)>0 && Cmp(close_0,open_2)<0)
         if(InpEnablePAT_MORNSTAR) DrawPattern(index,PATTERN_TYPE_MORNSTAR,high,low,time);
      if(Cmp(close_2,open_2)>0 && Cmp(close_1,open_1)==0 && Cmp(close_0,open_0)<0 && Cmp(close_2,open_1)<0 && Cmp(body_size_2,body_size_1)>0 && Cmp(body_size_1,body_size_0)<0 && Cmp(close_0,open_2)>0 && Cmp(close_0,close_2)<0)
         if(InpEnablePAT_EVDJSTAR) DrawPattern(index,PATTERN_TYPE_EVDJSTAR,high,low,time);
      if(Cmp(close_2,open_2)<0 && Cmp(close_1,open_1)==0 && Cmp(close_0,open_0)>0 && Cmp(close_2,open_1)>0 && Cmp(body_size_2,body_size_1)>0 && Cmp(body_size_1,body_size_0)<0 && Cmp(close_0,close_2)>0 && Cmp(close_0,open_2)<0)
         if(InpEnablePAT_MORNDJSTAR) DrawPattern(index,PATTERN_TYPE_MORNDJSTAR,high,low,time);
     }
  }
//+------------------------------------------------------------------+
//| Отображает паттерн                                               |
//+------------------------------------------------------------------+
void DrawPattern(int index,ENUM_PATTERN_TYPE pattern_type,const double &high[],const double &low[],const datetime &time[])
  {
   bool up=true;
   int length=1;
   double price=0;
//---
   if(pattern_type==PATTERN_TYPE_NB) {up=true; length=1;}
   if(pattern_type==PATTERN_TYPE_FBU) {up=false; length=1;}
   if(pattern_type==PATTERN_TYPE_FBD) {up=true; length=1;}
   if(pattern_type==PATTERN_TYPE_HAMMER) {up=true; length=1;}
   if(pattern_type==PATTERN_TYPE_SHOOTSTAR) {up=true; length=1;}

   if(pattern_type==PATTERN_TYPE_INSIDE) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_OUTSIDE) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_DBHLC) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_DBLHC) {up=false; length=2;}
   if(pattern_type==PATTERN_TYPE_MB) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_BEARHARAMI) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_BEARHARAMICROSS) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_BULLHARAMI) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_BULLHARAMICROSS) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_DARKCLOUD) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_DOJISTAR) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_ENGBEARLINE) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_ENGBULLLINE) {up=true; length=2;}
   if(pattern_type==PATTERN_TYPE_NB2) {up=true; length=2;}

   if(pattern_type==PATTERN_TYPE_DOUBLE_INSIDE) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_PINUP) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_PINDOWN) {up=false; length=3;}
   if(pattern_type==PATTERN_TYPE_PPRDN) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_PPRUP) {up=false; length=3;}
   if(pattern_type==PATTERN_TYPE_CPRU) {up=false; length=3;}
   if(pattern_type==PATTERN_TYPE_CPRD) { up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_EVSTAR) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_MORNSTAR) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_EVDJSTAR) {up=true; length=3;}
   if(pattern_type==PATTERN_TYPE_MORNDJSTAR) {up=true; length=3;}

   price=(up ? high[Highest(NULL,PERIOD_CURRENT,length,index)]+BufferATR[index] : low[Lowest(NULL,PERIOD_CURRENT,length,index)]-BufferATR[index]);
   Pattern[pattern_type].Buffer[index]=price;
   Pattern[pattern_type].type_pattern=pattern_type;
   if(InpShowPatternDescript)
      DrawLabel(pattern_type,price,index,high,low,time,up);
  }
//+------------------------------------------------------------------+
//| Выводит надпись с названием паттерна                             |
//+------------------------------------------------------------------+
void DrawLabel(const ENUM_PATTERN_TYPE type_pattern,const double price,const int index,const double &high[],const double &low[],const datetime &time[],const bool upper)
  {
   string tm=TimeToString(time[index]);
   string name=prefix+DescrShortPattern(type_pattern)+"_"+(string)index+"_"+tm;
   ObjectCreate(0,name,OBJ_TEXT,0,time[index],price);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetString(0,name,OBJPROP_TEXT,DescriptionPattern(type_pattern));
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,InpFontSize);
   ObjectSetString(0,name,OBJPROP_FONT,font_name);
   ObjectSetInteger(0,name,OBJPROP_COLOR,InpFontColor);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"Pattern on "+NameTimeframe()+":\n"+DescriptionPattern(type_pattern)+"\n"+tm);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,(upper ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER));
   //---
   name=prefix+DescrShortPattern(type_pattern)+"_vl_"+(string)index+"_"+tm;
   ObjectCreate(0,name,OBJ_TREND,0,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,0);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time[index]);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,time[index]);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,(upper ? high[index] : low[index]));
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,price);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование паттерна по индексу                      |
//+------------------------------------------------------------------+
string DescriptionPattern(const int index)
  {
   return(ArrayNames[index][0]);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование паттерна по перечислению                 |
//+------------------------------------------------------------------+
string DescriptionPattern(const ENUM_PATTERN_TYPE pattern)
  {
   return(ArrayNames[(int)pattern][0]);
  }
//+------------------------------------------------------------------+
//| Возвращает короткое наименование паттерна по индексу             |
//+------------------------------------------------------------------+
string DescrShortPattern(const int index)
  {
   return(ArrayNames[index][1]);
  }
//+------------------------------------------------------------------+
//| Возвращает короткое наименование паттерна по перечислению        |
//+------------------------------------------------------------------+
string DescrShortPattern(const ENUM_PATTERN_TYPE pattern)
  {
   return(ArrayNames[(int)pattern][1]);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс наибольшего значения в массиве                 |
//+------------------------------------------------------------------+
int Highest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int count,const int start)
  {
   string symb=(symbol_name==NULL || symbol_name=="" ? Symbol() : symbol_name);
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyHigh(symb,timeframe,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс наименьшего значения в массиве                 |
//+------------------------------------------------------------------+
int Lowest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int count,const int start)
  {
   string symb=(symbol_name==NULL || symbol_name=="" ? Symbol() : symbol_name);
   double array[];
   ArraySetAsSeries(array,true);
   if(CopyLow(symb,timeframe,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает результат сравнения двух цен                          |
//+------------------------------------------------------------------+
int Cmp(double price1,double price2)
  {
   return(fabs(price1-price2)<eq_pp ? 0 : price1>price2 ? 1 : -1);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование таймфрейма                               |
//+------------------------------------------------------------------+
string NameTimeframe(int timeframe=PERIOD_CURRENT)
  {
   if(timeframe==PERIOD_CURRENT) timeframe=Period();
   switch(timeframe)
     {
      case 1      : return "M1";
      case 2      : return "M2";
      case 3      : return "M3";
      case 4      : return "M4";
      case 5      : return "M5";
      case 6      : return "M6";
      case 10     : return "M10";
      case 12     : return "M12";
      case 15     : return "M15";
      case 20     : return "M20";
      case 30     : return "M30";
      case 16385  : return "H1";
      case 16386  : return "H2";
      case 16387  : return "H3";
      case 16388  : return "H4";
      case 16390  : return "H6";
      case 16392  : return "H8";
      case 16396  : return "H12";
      case 16408  : return "D1";
      case 32769  : return "W1";
      case 49153  : return "MN1";
      default     : return (string)(int)Period();
     }
  }
//+------------------------------------------------------------------+
