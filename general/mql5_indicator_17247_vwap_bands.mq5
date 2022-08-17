//------------------------------------------------------------------
#property copyright "© mladen, 2016, MetaQuotes Software Corp."
#property link      "www.forex-tsd.com, www.mql5.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   7
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLimeGreen
#property indicator_style3  STYLE_DOT
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_style4  STYLE_DOT
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSandyBrown
#property indicator_style5  STYLE_DOT
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSandyBrown
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrSandyBrown
#property indicator_width7  2

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

input int        AvgPeriod           = 20;          // Volume weighted average period
input enPrices   Price               = pr_close;    // Price
input bool       UseRealVolume       = false;       // Use real volume?
input bool       DeviationSample     = false;       // Deviation with sample correction?
input double     DeviationMuliplier1 = 1;           // First band(s) deviation
input double     DeviationMuliplier2 = 2;           // Second band(s) deviation
input double     DeviationMuliplier3 = 2.5;         // Third band(s) deviation

double  bandm[],bandu1[],bandu2[],bandu3[],bandd1[],bandd2[],bandd3[],prices[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,bandu3 ,INDICATOR_DATA);
   SetIndexBuffer(1,bandu2 ,INDICATOR_DATA);
   SetIndexBuffer(2,bandu1 ,INDICATOR_DATA);
   SetIndexBuffer(3,bandm  ,INDICATOR_DATA);
   SetIndexBuffer(4,bandd1 ,INDICATOR_DATA);
   SetIndexBuffer(5,bandd2 ,INDICATOR_DATA);
   SetIndexBuffer(6,bandd3 ,INDICATOR_DATA);
   SetIndexBuffer(7,prices ,INDICATOR_CALCULATIONS);
      IndicatorSetString(INDICATOR_SHORTNAME,"VWAP bands ("+(string)AvgPeriod+")");
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& real_volume[],
                const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
  
   //
   //
   //
   //
   //
  
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      prices[i] = getPrice(Price,open,close,high,low,i,rates_total);
         double sum1=0,sum2=0, deviation = iDeviation(prices[i],AvgPeriod,DeviationSample,i,rates_total);
      for (int k=0; k<AvgPeriod && (i-k)>=0; k++)
      {
         double volume = (UseRealVolume) ? (double)real_volume[i-k] : (double)tick_volume[i-k];
            sum1 += volume*prices[i-k];
         sum2 += volume;
      }
      bandm[i]  = (sum2!=0) ? sum1/sum2 : prices[i];
      bandu1[i] = (DeviationMuliplier1>0) ? bandm[i]+DeviationMuliplier1*deviation : EMPTY_VALUE;
      bandd1[i] = (DeviationMuliplier1>0) ? bandm[i]-DeviationMuliplier1*deviation : EMPTY_VALUE;
      bandu2[i] = (DeviationMuliplier2>0) ? bandm[i]+DeviationMuliplier2*deviation : EMPTY_VALUE;
      bandd2[i] = (DeviationMuliplier2>0) ? bandm[i]-DeviationMuliplier2*deviation : EMPTY_VALUE;
      bandu3[i] = (DeviationMuliplier3>0) ? bandm[i]+DeviationMuliplier3*deviation : EMPTY_VALUE;
      bandd3[i] = (DeviationMuliplier3>0) ? bandm[i]-DeviationMuliplier3*deviation : EMPTY_VALUE;
   }        
   return(i);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workDev[];
double iDeviation(double value, int length, bool isSample, int i, int bars)
{
   if (ArraySize(workDev)!=bars) ArrayResize(workDev,bars); workDev[i] = value;
                
   //
   //
   //
   //
   //
  
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k]-oldMean)*(workDev[i-k]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
        
         //
         //
         //
         //
         //
        
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; }
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  }
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
        
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
  
   //
   //
   //
   //
   //
  
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:  
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:  
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}
