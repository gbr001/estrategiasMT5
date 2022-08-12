//+------------------------------------------------------------------+
//|                                                     Patterns.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
//--- defines
#define TOTAL_RATES                                      (4)   // Требуемое количество баров для поиска паттернов
#define INDEX_START_FINDING_PATTERN                      (1)   // Бар, на котором регистрируются паттерны (0 - текущий)
//--- includes
#include "Include.mqh"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Класс объект-паттерн                                             |
//+------------------------------------------------------------------+
class CPattern : public CObject
  {
protected:
   uchar                m_group;                            // Группа (размер паттерна в барах)
   ENUM_PATTERN_TYPE    m_type;                             // Тип паттерна
   ENUM_ORDER_TYPE      m_order_type;                       // Тип ордера для паттерна (открываемая позиция)
public:
   ENUM_PATTERN_TYPE    TypePattern(void)             const { return m_type;        }
   ENUM_ORDER_TYPE      TypeOrder(void)               const { return m_order_type;  }
   uchar                Group(void)                   const { return m_group;       }
   void                 OnInit(const ENUM_PATTERN_TYPE type,const uchar group,const ENUM_ORDER_TYPE order_type);
                        CPattern(void) {;}
                       ~CPattern(void) {;}
  };
//+------------------------------------------------------------------+
//| Инициализация CPattern                                           |
//+------------------------------------------------------------------+
void CPattern::OnInit(const ENUM_PATTERN_TYPE type,const uchar group,const ENUM_ORDER_TYPE order_type)
  {
   this.m_type=type;
   this.m_group=group;
   this.m_order_type=order_type;
  }
//+------------------------------------------------------------------+
//| Класс поиска паттернов                                           |
//+------------------------------------------------------------------+
class CPatterns
  {
private:
   SDataInput           m_data_inputs;                      // Структура входных параметров
   CArrayObj            m_list_patterns;                    // Список текущих найденных паттернов
   MqlRates             m_rates[];                          // массив-таймсерия
   double               m_data_atr[];                       // массив данных ATR
   int                  m_handle_atr;                       // хэндл ATR
   string               m_prefix;                           // префикс имён объектов
   string               m_symbol;                           // символ
   ENUM_TIMEFRAMES      m_timeframe;                        // таймфрейм
   double               m_point;                            // Point()
   double               m_equation;                         // Минимальное значение сравнения
   datetime             m_last_time;                        // Время последнего доступа
  
   //--- Заполняет массив данных таймсерии
   bool                 FillingRates(void)                                 { return(::CopyRates(m_symbol,m_timeframe,0,TOTAL_RATES,m_rates)==TOTAL_RATES);  }
   //--- Заполняет массив данных ATR
   bool                 FillingDataATR(void)                               { return(::CopyBuffer(m_handle_atr,0,0,TOTAL_RATES,m_data_atr)==TOTAL_RATES);    }
   //--- Возвращает время открытия бара
   datetime             Time(const int shift) const;
   //--- Возвращает индекс наибольшего значения в массиве
   int                  Highest(const int count,const int start)  const;
   //--- Возвращает индекс наименьшего значения в массиве
   int                  Lowest(const int count,const int start)   const;
   //--- Заполняет массив структур данных паттернов
   int                  FillingDataInputs(const SDataInput &struct_inputs);
   //--- Проверяет наличие паттерна, возвращает количество найденных
   uint                 CheckPatterns(void);
   //--- Установка паттерна
   bool                 SetPattern(const ENUM_PATTERN_TYPE type,const uchar group,const ENUM_ORDER_TYPE order_type);
   //--- Отображает паттерн и заносит его в список сигналов
   void                 DrawPattern(const ENUM_PATTERN_TYPE type);
   //--- Выводит надпись с названием паттерна
   void                 DrawLabel(const ENUM_PATTERN_TYPE type,const double price,const double high,const double low,const datetime time,const bool upper);
   //--- Сравнивает два double значения
   int                  Cmp(const double price1,const double price2)       const { return(fabs(price1-price2)<m_equation ? 0 : price1>price2 ? 1 : -1);     }
   //--- Возвращает флаг использования паттерна по перечислению
   bool                 IsUsedPattern(const ENUM_PATTERN_TYPE type)        const { return m_data_inputs.pattern[(int)type].used_this;                       }
   //--- Возвращает флаг использования паттерна в группе
   bool                 IsUsedGroupPattern(const uchar group)  const;
   //--- Возвращает короткое наименование паттерна по индексу
   string               DescrShortPattern(const int index)                 const { return m_data_inputs.pattern[index].mame_short;                          }
   //--- Возвращает наименование таймфрейма
   string               NameTimeframe(void) const;

public:
   //--- Инициализация
   bool                 OnInit(const SDataInput &struct_inputs);
   //--- Возвращает количество текущих паттернов
   uint                 NumberPatterns(void)                               const { return m_list_patterns.Total();                                          }
   //--- Возвращает наличие сигнала
   bool                 IsSignal(void)                                     const { return(m_list_patterns.Total()>0);                                       }
   //--- Возвращает текущий список паттернов
   CArrayObj*           ListPattern(void)                                        { return& m_list_patterns;                                                 }
   //--- Возвращает наименование паттерна по перечислению
   string               DescriptPattern(const ENUM_PATTERN_TYPE type)      const { return m_data_inputs.pattern[(int)type].name_long;                       }
   //--- Возвращает наименование ордера паттерна по перечислению
   string               DescriptOrdersPattern(const ENUM_PATTERN_TYPE type)const;
   //--- Возвращает тип позиции паттерна по перечислению
   ENUM_POSITION_TYPE   PositionPattern(const ENUM_PATTERN_TYPE type)      const { return (ENUM_POSITION_TYPE)m_data_inputs.pattern[(int)type].order_type;  }
   //--- Исполняющий метод
   bool                 SearchProcess(void);
   //--- Конструктор/деструктор
                        CPatterns(void);
                       ~CPatterns(void);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CPatterns::CPatterns(void) : m_symbol(::Symbol()),
                             m_timeframe(PERIOD_CURRENT),
                             m_last_time(0)
  {
   ::ZeroMemory(m_rates);
   ::ZeroMemory(m_data_inputs);
  }
//+------------------------------------------------------------------+
//| Деструктор                                                       |
//+------------------------------------------------------------------+
CPatterns::~CPatterns()
  {
   ::ObjectsDeleteAll(0,m_prefix);
  }
//+------------------------------------------------------------------+
//| Инициализация                                                    |
//+------------------------------------------------------------------+
bool CPatterns::OnInit(const SDataInput &struct_inputs)
  {
   m_prefix=::MQLInfoString(MQL_PROGRAM_NAME)+"_";
   m_list_patterns.Sort();
   m_list_patterns.Clear();
   ResetLastError();
   if(!::SymbolInfoDouble(m_symbol,SYMBOL_POINT,m_point))
     {
      ::Print(__FUNCTION__,": Error getting Point() of Symbol ",m_symbol,": ",::GetLastError());
      return false;
     }
   if(m_point==0)
     {
      ::Print(__FUNCTION__,": Error: Point of the ",m_symbol," is zero");
      return false;
     }
   if(this.FillingDataInputs(struct_inputs)==WRONG_VALUE)
      return false;
   ::ResetLastError();
   m_handle_atr=iATR(m_symbol,m_timeframe,14);
   if(m_handle_atr==INVALID_HANDLE)
     {
      ::Print(__FUNCTION__,": Error creating iATR handle: ",::GetLastError());
      return false;
     }
   return this.FillingRates();
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера паттерна по перечислению          |
//+------------------------------------------------------------------+
string CPatterns::DescriptOrdersPattern(const ENUM_PATTERN_TYPE type) const
  {
   return(m_data_inputs.pattern[(int)type].order_type==ORDER_TYPE_BUY ? "Buy" : "Sell");
  }  
//+------------------------------------------------------------------+
//| Исполняющий метод                                                |
//+------------------------------------------------------------------+
bool CPatterns::SearchProcess(void)
  {
//--- проверка открытия нового бара
   datetime tm=this.Time(0);
   if(tm==m_last_time)
      return false;
   else m_last_time=tm;
//--- заполнение данных таймсерии
   if(!this.FillingRates())
      return false;
//--- заполнение данных ATR
   if(!this.FillingDataATR())
      return false;
//--- поиск паттернов
   return(this.CheckPatterns()>0);
  }
//+------------------------------------------------------------------+
//| Заполняет входные параметры                                      |
//+------------------------------------------------------------------+
int CPatterns::FillingDataInputs(const SDataInput &struct_inputs)
  {
   int total=::ArraySize(struct_inputs.pattern);
   ::ResetLastError();
   if(::ArrayResize(m_data_inputs.pattern,total)!=total)
     {
      ::Print(__FUNCTION__,": Error changing s_patterns array size: ",::GetLastError());
      return WRONG_VALUE;
     }
   ::ZeroMemory(m_data_inputs);
   m_data_inputs.equ_min=struct_inputs.equ_min*m_point;
   m_data_inputs.font_color=struct_inputs.font_color;
   m_data_inputs.font_name=struct_inputs.font_name;
   m_data_inputs.font_size=struct_inputs.font_size;
   m_data_inputs.used_group1=struct_inputs.used_group1;
   m_data_inputs.used_group2=struct_inputs.used_group2;
   m_data_inputs.used_group3=struct_inputs.used_group3;
   m_data_inputs.show_descript=struct_inputs.show_descript;
   for(int i=0;i<total;i++)
     {
      m_data_inputs.pattern[i].name_long=struct_inputs.pattern[i].name_long;
      m_data_inputs.pattern[i].mame_short=struct_inputs.pattern[i].mame_short;
      m_data_inputs.pattern[i].used_this=struct_inputs.pattern[i].used_this;
      m_data_inputs.pattern[i].order_type=struct_inputs.pattern[i].order_type;
     }
   this.m_equation=m_data_inputs.equ_min;
   return ::ArraySize(m_data_inputs.pattern);
  }
//+------------------------------------------------------------------+
//| Возвращает время открытия бара                                   |
//+------------------------------------------------------------------+
datetime CPatterns::Time(const int shift) const
  {
   datetime array[];
   return(::CopyTime(m_symbol,m_timeframe,0,1,array)==1 ? array[0] : 0);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс наибольшего значения в массиве                 |
//+------------------------------------------------------------------+
int CPatterns::Highest(const int count,const int start) const
  {
   double array[];
   ::ArraySetAsSeries(array,true);
   if(::CopyHigh(m_symbol,m_timeframe,start,count,array)==count)
      return ::ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс наименьшего значения в массиве                 |
//+------------------------------------------------------------------+
int CPatterns::Lowest(const int count,const int start) const
  {
   double array[];
   ::ArraySetAsSeries(array,true);
   if(::CopyLow(m_symbol,m_timeframe,start,count,array)==count)
      return ::ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает флаг использования паттерна в группе                  |
//+------------------------------------------------------------------+
bool CPatterns::IsUsedGroupPattern(const uchar group) const
  {
   return
     (
      group==1 ? m_data_inputs.used_group1 :
      group==2 ? m_data_inputs.used_group2 :
      group==3 ? m_data_inputs.used_group3 :
      false
     );
  }
//+------------------------------------------------------------------+
//| Проверяет наличие паттерна, возвращает количество найденных      |
//+------------------------------------------------------------------+
uint CPatterns::CheckPatterns(void)
  {
//---
   int index=INDEX_START_FINDING_PATTERN;
   m_list_patterns.Clear();
//--- Получение данных бара
   if(!this.FillingRates()) return 0;
   if(!this.FillingDataATR()) return 0;
//--- Расчёт паттернов
   double min_dev=fmax(m_equation,m_point);
   double min_dev4=fmax(m_equation*4,m_point*4);
//--- свеча со смещением 0
   double open_0=m_rates[index].open;
   double close_0=m_rates[index].close;
   double low_0=m_rates[index].low;
   double high_0=m_rates[index].high;
   double body_top_0=fmax(open_0,close_0);
   double body_bottom_0=fmin(open_0,close_0);
   double body_size_0=body_top_0-body_bottom_0;
   double shadow_upper_0=high_0-body_top_0;
   double shadow_lower_0=body_bottom_0-low_0;
//--- свеча со смещением 1
   double open_1=m_rates[index+1].open;
   double close_1=m_rates[index+1].close;
   double low_1=m_rates[index+1].low;
   double high_1=m_rates[index+1].high;
   double body_top_1=fmax(open_1,close_1);
   double body_bottom_1=fmin(open_1,close_1);
   double body_size_1=body_top_1-body_bottom_1;
   double shadow_upper_1=high_1-body_top_1;
   double shadow_lower_1=body_bottom_1-low_1;
//--- свеча со смещением 2
   double open_2=m_rates[index+2].open;
   double close_2=m_rates[index+2].close;
   double low_2=m_rates[index+2].low;
   double high_2=m_rates[index+2].high;
   double body_top_2=fmax(open_2,close_2);
   double body_bottom_2=fmin(open_2,close_2);
   double body_size_2=body_top_2-body_bottom_2;
   double shadow_upper_2=high_2-body_top_2;
   double shadow_lower_2=body_bottom_2-low_2;

//--- однобаровые паттерны
   if(m_data_inputs.used_group1)
     {
      //--- Neutral Bar
      if(this.Cmp(open_0,close_0)==0 && shadow_upper_0>min_dev4 && shadow_lower_0>min_dev4)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_NB;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(1))
           {
            if(this.SetPattern(type,1,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Force Bar Up
      if(close_0==high_0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_FBU;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(1))
           {
            if(this.SetPattern(type,1,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Force Bar Down
      if(close_0==low_0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_FBD;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(1))
           {
            if(this.SetPattern(type,1,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Hammer Pattern
      if(shadow_upper_0<=min_dev && shadow_lower_0>2*body_size_0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_HAMMER;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(1))
           {
            if(this.SetPattern(type,1,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Shooting Star
      if(shadow_lower_0<=min_dev && shadow_upper_0>2*body_size_0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_SHOOTSTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(1))
           {
            if(this.SetPattern(type,1,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
     }

//--- двухбаровые паттерны
   if(m_data_inputs.used_group2)
     {
      //--- Inside Bar
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_INSIDE;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Outside Bar
      if(this.Cmp(high_0,high_1)>0 && this.Cmp(low_0,low_1)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_OUTSIDE;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Double Bar High With A Lower Close
      if(this.Cmp(high_0,high_1)==0 && this.Cmp(close_0,close_1)<0 && this.Cmp(low_0,low_1)<=0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_DBHLC;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Double Bar Low With A Higher Close
      if(this.Cmp(low_0,low_1)==0 && this.Cmp(close_0,close_1)>0 && this.Cmp(high_0,high_1)>=0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_DBLHC;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Mirror Bar
      if(this.Cmp(body_size_1,body_size_0)==0 && this.Cmp(open_1,close_0)==0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_MB;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Bearish Harami
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0 && this.Cmp(close_1,open_1)>0 && this.Cmp(close_0,open_0)<0 && this.Cmp(body_size_1,body_size_0)>0 && this.Cmp(close_1,open_0)>0 && this.Cmp(open_1,close_0)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_BEARHARAMI;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Bearish Harami Cross
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0 && this.Cmp(close_1,open_1)>0 && this.Cmp(open_0,close_0)==0 && this.Cmp(body_size_1,body_size_0)>0 && this.Cmp(close_1,open_0)>0 && this.Cmp(open_1,close_0)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_BEARHARAMICROSS;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Bullish Harami
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0 && this.Cmp(close_1,open_1)<0 && this.Cmp(close_0,open_0)>0 && this.Cmp(body_size_1,body_size_0)>0 && this.Cmp(close_1,open_0)<0 && this.Cmp(open_1,close_0)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_BULLHARAMI;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Bullish Harami Cross
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0 && this.Cmp(close_1,open_1)<0 && this.Cmp(open_0,close_0)==0 && this.Cmp(body_size_1,body_size_0)>0 && this.Cmp(close_1,open_0)<0 && this.Cmp(open_1,close_0)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_BULLHARAMICROSS;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Dark Cloud Cover
      if(this.Cmp(close_1,open_1)>0 && this.Cmp(close_0,open_0)<0 && this.Cmp(high_1,open_0)<0 && this.Cmp(close_0,close_1)<0 && this.Cmp(close_0,open_1)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_DARKCLOUD;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Doji Star
      if(this.Cmp(open_0,close_0)==0 && this.Cmp(close_1,open_1)>0 && this.Cmp(open_0,high_1)>0 && this.Cmp(close_1,open_1)<0 && this.Cmp(open_0,low_1)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_DOJISTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Engulfing Bearish Line
      if(this.Cmp(close_1,open_1)>0 && this.Cmp(close_0,open_0)<0 && this.Cmp(open_0,close_1)>0 && this.Cmp(close_0,open_1)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_ENGBEARLINE;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Engulfing Bullish Line
      if(this.Cmp(close_1,open_1)<0 && this.Cmp(close_0,open_0)>0 && this.Cmp(open_0,close_1)<0 && this.Cmp(close_0,open_1)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_ENGBULLLINE;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Two Neutral Bars
      if(this.Cmp(open_0,close_0)==0 && shadow_upper_0>min_dev4 && shadow_lower_0>min_dev4 && this.Cmp(open_1,close_1)==0 && shadow_upper_1>min_dev4 && shadow_lower_1>min_dev4)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_NB2;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(2))
           {
            if(this.SetPattern(type,2,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
     }

//--- трёхбаровые паттерны
   if(m_data_inputs.used_group3)
     {
      //--- Double inside Bar
      if(this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)>0 && this.Cmp(high_1,high_2)<0 && this.Cmp(low_1,low_2)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_DOUBLE_INSIDE;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Pin up
      if(this.Cmp(high_1,high_2)>0 && this.Cmp(high_1,high_0)>0 && this.Cmp(low_1,low_2)>0 && this.Cmp(low_1,low_0)>0 && body_size_1*2<shadow_upper_1)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_PINUP;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Pin down
      if(this.Cmp(high_1,high_2)<0 && this.Cmp(high_1,high_0)<0 && this.Cmp(low_1,low_2)<0 && this.Cmp(low_1,low_0)<0 && body_size_1*2<shadow_lower_1)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_PINDOWN;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Pivot Point Reversal Down
      if(this.Cmp(high_1,high_2)>0 && this.Cmp(high_1,high_0)>0 && this.Cmp(low_1,low_2)>0 && this.Cmp(low_1,low_0)>0 && this.Cmp(close_0,low_1)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_PPRDN;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Pivot Point Reversal Up
      if(this.Cmp(high_1,high_2)<0 && this.Cmp(high_1,high_0)<0 && this.Cmp(low_1,low_2)<0 && this.Cmp(low_1,low_0)<0 && this.Cmp(close_0,high_1)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_PPRUP;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Close Price Reversal Up
      if(this.Cmp(high_1,high_2)<0 && this.Cmp(low_1,low_2)<0 && this.Cmp(high_0,high_1)<0 && this.Cmp(low_0,low_1)<0 && this.Cmp(close_0,close_1)>0 && this.Cmp(open_0,close_0)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_CPRU;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Close Price Reversal Down
      if(this.Cmp(high_1,high_2)>0 && this.Cmp(low_1,low_2)>0 && this.Cmp(high_0,high_1)>0 && this.Cmp(low_0,low_1)>0 && this.Cmp(close_0,close_1)<0 && this.Cmp(open_0,close_0)>0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_CPRD;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Evening Star
      if(this.Cmp(close_2,open_2)>0 && this.Cmp(close_1,open_1)>0 && this.Cmp(close_0,open_0)<0 && this.Cmp(close_2,open_1)<0 && this.Cmp(body_size_2,body_size_1)>0 && this.Cmp(body_size_1,body_size_0)<0 && this.Cmp(close_0,open_2)>0 && this.Cmp(close_0,close_2)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_EVSTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
     //--- Morning Star
     if(this.Cmp(close_2,open_2)<0 && this.Cmp(close_1,open_1)>0 && this.Cmp(close_0,open_0)>0 && this.Cmp(close_2,open_1)>0 && this.Cmp(body_size_2,body_size_1)>0 && this.Cmp(body_size_1,body_size_0)<0 && this.Cmp(close_0,close_2)>0 && this.Cmp(close_0,open_2)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_MORNSTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Evening Doji Star
      if(this.Cmp(close_2,open_2)>0 && this.Cmp(close_1,open_1)==0 && this.Cmp(close_0,open_0)<0 && this.Cmp(close_2,open_1)<0 && this.Cmp(body_size_2,body_size_1)>0 && this.Cmp(body_size_1,body_size_0)<0 && this.Cmp(close_0,open_2)>0 && this.Cmp(close_0,close_2)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_EVDJSTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
      //--- Morning Doji Star
      if(this.Cmp(close_2,open_2)<0 && this.Cmp(close_1,open_1)==0 && this.Cmp(close_0,open_0)>0 && this.Cmp(close_2,open_1)>0 && this.Cmp(body_size_2,body_size_1)>0 && this.Cmp(body_size_1,body_size_0)<0 && this.Cmp(close_0,close_2)>0 && this.Cmp(close_0,open_2)<0)
        {
         ENUM_PATTERN_TYPE type=PATTERN_TYPE_MORNDJSTAR;
         if(this.IsUsedPattern(type) && this.IsUsedGroupPattern(3))
           {
            if(this.SetPattern(type,3,m_data_inputs.pattern[type].order_type))
               this.DrawPattern(type);
           }
        }
     }
   return (uint)m_list_patterns.Total();
  }
//+------------------------------------------------------------------+
//| Установка паттерна                                               |
//+------------------------------------------------------------------+
bool CPatterns::SetPattern(const ENUM_PATTERN_TYPE type,const uchar group,const ENUM_ORDER_TYPE order_type)
  {
   CPattern* pattern=new CPattern();
   if(pattern!=NULL)
     {
      pattern.OnInit(type,group,order_type);
      if(m_list_patterns.Search(pattern)==WRONG_VALUE)
        {
         if(m_list_patterns.Add(pattern))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Отображает паттерн                                               |
//+------------------------------------------------------------------+
void CPatterns::DrawPattern(const ENUM_PATTERN_TYPE type)
  {
   if(::MQLInfoInteger(MQL_TESTER) && (::MQLInfoInteger(MQL_OPTIMIZATION) || !::MQLInfoInteger(MQL_VISUAL_MODE))) return;
   if(!m_data_inputs.show_descript) return;
   int index=INDEX_START_FINDING_PATTERN;
   bool up=true;
   int length=1;
   double price=0;
//---
   if(type==PATTERN_TYPE_NB)              { up=true;  length=1; }
   if(type==PATTERN_TYPE_FBU)             { up=false; length=1; }
   if(type==PATTERN_TYPE_FBD)             { up=true;  length=1; }
   if(type==PATTERN_TYPE_HAMMER)          { up=true;  length=1; }
   if(type==PATTERN_TYPE_SHOOTSTAR)       { up=true;  length=1; }

   if(type==PATTERN_TYPE_INSIDE)          { up=true;  length=2; }
   if(type==PATTERN_TYPE_OUTSIDE)         { up=true;  length=2; }
   if(type==PATTERN_TYPE_DBHLC)           { up=true;  length=2; }
   if(type==PATTERN_TYPE_DBLHC)           { up=false; length=2; }
   if(type==PATTERN_TYPE_MB)              { up=true;  length=2; }
   if(type==PATTERN_TYPE_BEARHARAMI)      { up=true;  length=2; }
   if(type==PATTERN_TYPE_BEARHARAMICROSS) { up=true;  length=2; }
   if(type==PATTERN_TYPE_BULLHARAMI)      { up=true;  length=2; }
   if(type==PATTERN_TYPE_BULLHARAMICROSS) { up=true;  length=2; }
   if(type==PATTERN_TYPE_DARKCLOUD)       { up=true;  length=2; }
   if(type==PATTERN_TYPE_DOJISTAR)        { up=true;  length=2; }
   if(type==PATTERN_TYPE_ENGBEARLINE)     { up=true;  length=2; }
   if(type==PATTERN_TYPE_ENGBULLLINE)     { up=true;  length=2; }
   if(type==PATTERN_TYPE_NB2)             { up=true;  length=2; }

   if(type==PATTERN_TYPE_DOUBLE_INSIDE)   { up=true;  length=3; }
   if(type==PATTERN_TYPE_PINUP)           { up=true;  length=3; }
   if(type==PATTERN_TYPE_PINDOWN)         { up=false; length=3; }
   if(type==PATTERN_TYPE_PPRDN)           { up=true;  length=3; }
   if(type==PATTERN_TYPE_PPRUP)           { up=false; length=3; }
   if(type==PATTERN_TYPE_CPRU)            { up=false; length=3; }
   if(type==PATTERN_TYPE_CPRD)            { up=true;  length=3; }
   if(type==PATTERN_TYPE_EVSTAR)          { up=true;  length=3; }
   if(type==PATTERN_TYPE_MORNSTAR)        { up=true;  length=3; }
   if(type==PATTERN_TYPE_EVDJSTAR)        { up=true;  length=3; }
   if(type==PATTERN_TYPE_MORNDJSTAR)      { up=true;  length=3; }

   int highest=this.Highest(length,index);
   int lowest=this.Lowest(length,index);
   if(highest==WRONG_VALUE || lowest==WRONG_VALUE)
      return;
   double shift=m_data_inputs.font_size*8*m_list_patterns.Total()*m_point;
   price=(up ? m_rates[highest].high+m_data_atr[index]+shift : m_rates[lowest].low-m_data_atr[index]-shift);
  
   this.DrawLabel(type,price,m_rates[index].high,m_rates[index].low,m_rates[index].time,up);
  }
//+------------------------------------------------------------------+
//| Выводит надпись с названием паттерна                             |
//+------------------------------------------------------------------+
void CPatterns::DrawLabel(const ENUM_PATTERN_TYPE type,const double price,const double high,const double low,const datetime time,const bool upper)
  {
   string tm=TimeToString(m_rates[1].time);
   string name=m_prefix+this.DescrShortPattern(type)+"_"+tm;
   ::ObjectCreate(0,name,OBJ_TEXT,0,time,price);
   ::ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ::ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ::ObjectSetString(0,name,OBJPROP_TEXT,this.DescriptPattern(type));
   ::ObjectSetInteger(0,name,OBJPROP_FONTSIZE,m_data_inputs.font_size);
   ::ObjectSetString(0,name,OBJPROP_FONT,m_data_inputs.font_name);
   ::ObjectSetInteger(0,name,OBJPROP_COLOR,m_data_inputs.font_color);
   ::ObjectSetString(0,name,OBJPROP_TOOLTIP,"Pattern on "+this.NameTimeframe()+":\n"+this.DescriptPattern(type)+"\n"+tm);
   ::ObjectSetInteger(0,name,OBJPROP_ANCHOR,(upper ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER));
   //---
   name=m_prefix+this.DescrShortPattern(type)+"_vl_"+tm;
   ::ObjectCreate(0,name,OBJ_TREND,0,0,0,0,0);
   ::ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ::ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ::ObjectSetInteger(0,name,OBJPROP_COLOR,clrRed);
   ::ObjectSetInteger(0,name,OBJPROP_WIDTH,0);
   ::ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
   ::ObjectSetInteger(0,name,OBJPROP_RAY,false);
   ::ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
   ::ObjectSetInteger(0,name,OBJPROP_TIME,0,time);
   ::ObjectSetInteger(0,name,OBJPROP_TIME,1,time);
   ::ObjectSetDouble(0,name,OBJPROP_PRICE,0,(upper ? high : low));
   ::ObjectSetDouble(0,name,OBJPROP_PRICE,1,price);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование таймфрейма                               |
//+------------------------------------------------------------------+
string CPatterns::NameTimeframe(void) const
  {
   ENUM_TIMEFRAMES timeframe=Period();
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
      default     : return (string)(int)::Period();
     }
  }
//+------------------------------------------------------------------+
