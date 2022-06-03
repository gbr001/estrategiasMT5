//+------------------------------------------------------------------+
//| Thiago Oliveira - Olimbot |
//| contato@olimbot.com.br |
//+------------------------------------------------------------------+
#property copyright "Thiago Oliveira - OlimBot"
#property link "olimbot.com.br"
#property version "1.00"

#property description "Última atualização em 22/Junho/2021"
#property description " "
#property description "Este indicador calcula a regressão linear entre o preço de fechamento e uma média móvel exponencial"
#property description "É exibido a distância do preço em relação a regressão"
#property description "A regressão é dividida por uma média simples do desvio padrão do preço"
#property description "Este procedimento suaviza o movimento do indicador"
#property description "O indicador pode ser usado para mostrar força do movimento ou movimentos discrepantes"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "Ratio"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

input int m_periodo_media = 20; // Período Médio
input double m_desvio = 2.0;    // Coeficiente de Desvio

int periodo_media = m_periodo_media;
int handle_ema;
int handle_std;
double RatioBuffer[]; // Buffer dos dados verdadeiros da regressão
//+------------------------------------------------------------------+
//| Inicialização das variavéis do indicador |
//+------------------------------------------------------------------+
int OnInit()
{
    if (m_periodo_media < 2) // Garantido que pelo input o valor do período terá um valor mínimo
        periodo_media = 2;

    // Indicadores usados no cálculo da regressão
    handle_std = iStdDev(_Symbol, _Period, periodo_media, 0, MODE_EMA, PRICE_CLOSE);
    handle_ema = iMA(_Symbol, _Period, periodo_media, 0, MODE_EMA, PRICE_CLOSE);

    if (handle_ema == INVALID_HANDLE)
    {
        printf("Falha em obter o handle da EMA");
        return INIT_FAILED;
    }

    if (handle_std == INVALID_HANDLE)
    {
        printf("Falha em obter o handle do desvio padrão");
        return INIT_FAILED;
    }

    // Selecionando as linhas fixas através do desvioselecionado
    IndicatorSetInteger(INDICATOR_LEVELS, 2);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, m_desvio);
    IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, -m_desvio);

    SetIndexBuffer(0, RatioBuffer, INDICATOR_DATA); // Indicando o buffer dos valores
    ArraySetAsSeries(RatioBuffer, true);
    IndicatorSetInteger(INDICATOR_DIGITS, 5);

    // Nome dado ao indicador
    IndicatorSetString(INDICATOR_SHORTNAME, "Regressão Linear (" +
                                                IntegerToString(periodo_media) + "/" +
                                                DoubleToString(m_desvio, 1) + ")");

    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Cálculo do indicador, utilizar como base o fechamento |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
    if (IsStopped())
        return 0;

    int pos = 0;
    int limit_ema = periodo_media + 1;
    double ema[];
    double std[];

    if (prev_calculated == 0)
    {
        pos = rates_total - 1;
        limit_ema = rates_total;
    }

    ArraySetAsSeries(ema, true);
    ArraySetAsSeries(price, true);
    ArraySetAsSeries(std, true);

    CopyBuffer(handle_ema, 0, 0, limit_ema, ema);
    CopyBuffer(handle_std, 0, 0, limit_ema, std);

    for (int i = pos; i >= 0 && !IsStopped(); i--)
        if (i < rates_total - periodo_media)
        {
            // Dados para calculo da regressão linear
            int cnt = 0; // Contador do loop
            double mediaX = 0;
            double mediaY = 0;
            double xy = 0;
            double x2 = 0;
            double X = 0;
            double Y = 0;
            double media_std = 0; // Média do desvio padrão

            for (int k = periodo_media - 1; k >= 0; k--) // Verificando valores para cálculo da regressão sobre a média
            {
                X = ema[i + k];
                Y = price[i + k];
                mediaX += X;
                mediaY += Y;
                xy += (X * Y);
                x2 += MathPow(X, 2);
                media_std += std[i + k]; // Média do desvio padrão
                cnt++;                   // Contador de loop para confirmação
            }

            // Ínicio dos cálculos da regressão
            mediaX = (cnt == 0) ? 0.0 : mediaX / cnt;
            mediaY = (cnt == 0) ? 0.0 : mediaY / cnt;
            media_std /= ((periodo_media == 0) ? 0.0 : periodo_media); // Finalizando a média do desvio padrão

            double divisor = x2 - (cnt * MathPow(mediaX, 2));
            double b = (divisor == 0) ? 0.0 : (xy - (cnt * mediaX * mediaY)) / divisor;
            double a = mediaY - (b * mediaX);
            double res = a + (b * X); // Cálculo do residuo da regressão

            RatioBuffer[i] = Y - res;                                // Verificando distância do preço em relação à regressão
            RatioBuffer[i] /= (media_std > 0 ? media_std : DBL_MIN); // Estacionarizando a média dividindo pelo desvio padrão
        }

    return (rates_total - 1);
}
//+------------------------------------------------------------------+