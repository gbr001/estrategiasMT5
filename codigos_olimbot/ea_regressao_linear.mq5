//+------------------------------------------------------------------+
//| Thiago Oliveira - Olimbot |
//| contato@olimbot.com.br |
//+------------------------------------------------------------------+
#property copyright "Thiago Oliveira - OlimBot"
#property link "olimbot.com.br"
#property version "1.00"

#property description "Última atualização em 11/Janeiro/2022"
#property description " "
#property description "Este expert é constituído sem o uso de bibliotecas padrões do meta trader"
#property description "Todos os recursos são adaptados para uma melhor perfomance"
#property description "Este modelo funciona tanto para contas HEDGINGS quanto para NETTINGS"
#property description "Entradas e saídas são sempre utilizando ordens limitadas para garantir melhor preço na B3"
#property description "Se existir distância mínima para ordem pendente esta é ajustada automaticamente"
#property description "Em contas HEDGINGS a saída é fechada utilizando a posição inversa"

// O indicador personalizado deve estar com o arquivo executável na pasta de indicadores
#define indicador "Indicators\\Regressao.ex5" // Indicador personalizado que será compilado na pasta Indicators\\...
// Indicador compilado deve estar no formato .ex5
#resource "\\" + indicador // Compilando junto ao EA o indicador

// Enumerador para o tipo de preenchimento
enum e_filling
{
    es_fok = ORDER_FILLING_FOK,      // Fok
    es_ioc = ORDER_FILLING_IOC,      // Ioc
    es_return = ORDER_FILLING_RETURN // Return
};

// Enumerador para o tipo de validade da ordem
enum e_time
{
    es_gtc = ORDER_TIME_GTC, // Até cancelar
    es_day = ORDER_TIME_DAY  // Hoje
};

// Caracterização de true e false para sim e não
enum e_sn
{
    nao = 0, // Não
    sim = 1  // Sim
};
//+------------------------------------------------------------------+
//| Parâmetros de entrada |
//+------------------------------------------------------------------+
sinput group "CONFIGURAÇÃO INICIAL";
sinput string in_nome = "SET OLIMBOT";               // Nome do expert
sinput ulong in_magic = 123;                         // Magic Number
sinput double in_volume = 1;                         // Volume
input ENUM_TIMEFRAMES in_timeframe = PERIOD_CURRENT; // Tempo gráfico do EA
sinput group "CONFIGURAÇÃO ADICIONAL";
sinput e_filling in_preenchimento = es_return; // Tipo de preenchimento
sinput e_time in_validade = es_day;            // Validade da ordem
sinput e_sn in_hab_painel = true;              // Habilitar painel gráfico
sinput e_sn in_hab_indicadores = false;        // Inserir indicadores
sinput group "ALVOS DE SAÍDA";
input double in_takeprofit = 0; // TakeProfit (pts)
input double in_stoploss = 0;   // StopLoss (pts)
sinput group "INDICADOR REGRESSÃO LINEAR";
input int in_reg_periodo = 20;   // Período da regressão
input double in_reg_coef = 2.00; // Coeficiente de regressão
sinput group "INDICADOR MACD";
input int in_macd_fast = 12; // Período EMA rápida
input int in_macd_slow = 5;  // Período EMA lenta
sinput group "AJUSTES DE SINAIS";
input e_sn in_cancel_sinal = true; // Atualizar pendente a cada sinal
input e_sn in_barra_atual = true;  // Impedir novas entradas na mesma barra
input double in_macd_min = 0;      // Tamanho mínimo do MACD
sinput double in_spread = 0;       // Spread máximo (ticks)(0=off)
sinput group "REGRAS DE HORÁRIOS";
input e_sn in_hab_hora = true;     // Habilitar verificação de horários
input string in_iniciar = "09:00"; // Horário de iniciar (novas posições)
input string in_parar = "14:45";   // Horário de parar (novas posições)
input e_sn in_hab_zerar = true;    // Habilitar zeragem compulsória
input string in_zerar = "14:55";   // Horário de zeragem (compulsória)

int handle_macd, handle_reg;                                  // Manipuladores de indicadores
MqlDateTime hora_iniciar, hora_parar, hora_zerar, hora_atual; // Estruturas de horários

// Estrutura para armazenar os dados das ordens pendentes
struct s_ordens
{
    ulong compra_limit; // Número que corresponderá a uma ordem de compra pendente
    ulong venda_limit;  // Para venda pendente (ordem limitada)
};

// Estrutura para armazenar os dados das posições abertas
struct s_posicoes
{
    double volume;       // Lot
    double lucro;        // Lucro real da posição aberta, referente ao verdadeiro preço de saída
    datetime abertura;   // Horário que se inicio a posição
    ulong ticket_compra; // Bilhete da posição se for de compra
    ulong ticket_venda;  // Bilhete da posição de venda se existir ambas simultanemanetes, são fechadas entre si
};
//+------------------------------------------------------------------+
//| Inicializãção do expert |
//+------------------------------------------------------------------+
int OnInit()
{
    ChartSetSymbolPeriod(0, _Symbol, in_timeframe); // Força que o tempo gráfico da janela do robô fique no escolhido

    if (!in_hab_indicadores)        // Desabilita visualização dos indicadores no backtest, se não permitir inserir
        TesterHideIndicators(true); // Deve ser chamado antes da inicialização dos indicadores

    // Chamada dos indicadores utilizados
    // No macd, o parâmetro de sinal não é necessário para esta estratégia
    handle_macd = iMACD(_Symbol, _Period, in_macd_fast, in_macd_slow, 1, PRICE_CLOSE);     // Indicador nativo mql5
    handle_reg = iCustom(_Symbol, _Period, "::" + indicador, in_reg_periodo, in_reg_coef); // Indicador personalizado

    // Confirmando se os indicadores foram inseridos corretamente no EA
    if (handle_reg == INVALID_HANDLE)
    {
        Print("[%s] Erro na criação do manipulador do indicador regressão linear", in_nome);
        return INIT_FAILED;
    }

    if (handle_macd == INVALID_HANDLE)
    {
        Print("[%s] Erro na criação do manipulador do indicador MACD", in_nome);
        return INIT_FAILED;
    }

    // Passando a referência de horário para o padrão correto
    TimeToStruct(StringToTime(in_iniciar), hora_iniciar);
    TimeToStruct(StringToTime(in_parar), hora_parar);
    TimeToStruct(StringToTime(in_zerar), hora_zerar);

    // Verifica se o horário de ínicio realmente antecede o horário máximo de abertura de posição
    if (hora_iniciar.hour > hora_parar.hour || (hora_iniciar.hour == hora_parar.hour && hora_iniciar.min >= hora_parar.min))
    {
        printf("[%s] Configuração de horários de entrada e parada inválidos", in_nome);
        return INIT_FAILED;
    }

    // Se estiver habilitada inicia o desenho do painel gráfico (dashboard)
    if (in_hab_painel)
        if (!iniciar_painel())
        {
            printf("[%s] Falha ao iniciar o painel gráfico", in_nome);
            return INIT_FAILED;
        }

    // Adiciona as linhas de preço e retira a separação em grade para melhor visualizar
    ChartSetInteger(0, CHART_SHOW_GRID, 0, false);     // Remove grade do gráfico
    ChartSetInteger(0, CHART_SHOW_ASK_LINE, 0, true);  // Adiciona linha ask
    ChartSetInteger(0, CHART_SHOW_BID_LINE, 0, true);  // Adiciona linha bid
    ChartSetInteger(0, CHART_SHOW_LAST_LINE, 0, true); // Adiciona linha do último negócio se for mercado de bolsa

    if (in_hab_indicadores)        // Possibilita a inserção dos indicadores no gráfico do EA
        if (remover_indicadores()) // Remove todos os indicadores no gráfico antes de inserir os usados pelo EA
        {
            ChartIndicatorAdd(0, 1, handle_reg);  // Inserindo no modo visual o indicador de regressão
            ChartIndicatorAdd(0, 2, handle_macd); // Inserindo no modo visual o indicador de MACD
        }

    printf("[%s] ***** Expert Iniciado com sucesso", in_nome);
    printf("[%s] ***** Horários: Local %s Corretora %s",
           in_nome, TimeToString(TimeLocal(), TIME_SECONDS), TimeToString(TimeCurrent(), TIME_SECONDS));

    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
//| Desligamento de expert |
//+------------------------------------------------------------------+
void OnDeinit(const int motivo)
{
    if (in_hab_indicadores)
        remover_indicadores(); // Remove todos os indicadores do gráfico se a opção estiver habilitada

    ObjectsDeleteAll(0, "painel_", 0, -1); // Remove o painel do gráfico, se existir
    IndicatorRelease(handle_macd);         // Liberando mémoria alocada para os indicadores
    IndicatorRelease(handle_reg);

    printf("[%s] ***** Horários: Local %s Corretora %s",
           in_nome, TimeToString(TimeLocal(), TIME_SECONDS), TimeToString(TimeCurrent(), TIME_SECONDS));
    printf("[%s] ***** Expert desligado pelo motivo %d", in_nome, motivo);

    // A liberação de memória dos indicadores pode ser mais lenta que na inicialização
    // Se o EA for inserido enquanto ainda está o no porcesso de liberar mémoria, parte dos dados dos indicadores pode ser perdido
    Sleep(1000); // Por isso é necessário aguardar a remoção completa
}
//+------------------------------------------------------------------+
//| Remoção de indicadores |
//+------------------------------------------------------------------+
bool remover_indicadores(void)
{
    // Verifica todas as janelas do gráfico
    for (int i = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL) - 1; i >= 0; i--)
        while (ChartIndicatorsTotal(0, i) > 0) // Verifica todos os indicadores em cada subjanela
        {
            string nome = ChartIndicatorName(0, i, 0); // Pega o nome do indicador
            if (!ChartIndicatorDelete(0, i, nome))     // Após a obtenção do nome, o mesmo é deletado da janela
                break;
        }

    return true;
}
//+------------------------------------------------------------------+
//| Inicialização do painel gráfico |
//+------------------------------------------------------------------+
bool iniciar_painel(void)
{
    // Somente necessário chamar uma vez tal função
    // Nome dado ao fundo do painel
    string nome = "painel_fundo";

    if (ObjectCreate(0, nome, OBJ_RECTANGLE_LABEL, 0, 0, 0))
    {
        ObjectSetInteger(0, nome, OBJPROP_XDISTANCE, 5); // Distância da borda
        ObjectSetInteger(0, nome, OBJPROP_YDISTANCE, 15);
        ObjectSetInteger(0, nome, OBJPROP_XSIZE, 250);        // Tamanho das cordernadas do painel eixo X
        ObjectSetInteger(0, nome, OBJPROP_YSIZE, 130);        // Eixo Y
        ObjectSetInteger(0, nome, OBJPROP_BGCOLOR, clrBlack); // Cor de fundo
        ObjectSetInteger(0, nome, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, nome, OBJPROP_CORNER, CORNER_LEFT_UPPER); // Referência de posicionamento (borda superior esquerda)
        ObjectSetInteger(0, nome, OBJPROP_COLOR, clrMaroon);          // Cor da borda
        ObjectSetInteger(0, nome, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, nome, OBJPROP_WIDTH, 3);
        ObjectSetInteger(0, nome, OBJPROP_BACK, false); // Força painel para frente do gráfico
        ObjectSetInteger(0, nome, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, nome, OBJPROP_SELECTED, false);
        ObjectSetInteger(0, nome, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, nome, OBJPROP_ZORDER, 0);
    }
    else
        return false;

    Sleep(200);    // Pausa para processar o desenho do fundo do painel
    ChartRedraw(); // Força uma atualização do desenho, garantindo o fundo desenhado antes dos objetos

    // Loop para desenhar cada item exibido no painel
    for (int i = 0; i < 8; i++)
    {
        string texto[8];
        nome = "painel_parametro_" + IntegerToString(i); // Nome de cada item pegando a sua posuição como complementação

        switch (i)
        {
        case 0:
            texto[i] = "Nome do EA";
            break;
        case 1:
            texto[i] = "Magic Number";
            break;
        case 2:
            texto[i] = "Posição";
            break;
        case 3:
            texto[i] = "Abertura Pos";
            break;
        case 4:
            texto[i] = "Lucro Real";
            break;
        case 5:
            texto[i] = "Oscilação";
            break;
        case 6:
            texto[i] = "Atraso Corretora";
            break;
        case 7:
            texto[i] = "Tempo Nova Barra";
            break;
        default:
            break;
        }

        // Criando cada item do painel como objeto de texto
        if (ObjectCreate(0, nome, OBJ_LABEL, 0, 0, 0))
        {
            ObjectSetInteger(0, nome, OBJPROP_COLOR, clrSnow); // Cor do texto dos parâmetros
            ObjectSetInteger(0, nome, OBJPROP_XDISTANCE, 10);
            ObjectSetInteger(0, nome, OBJPROP_YDISTANCE, 20 + (i * 15)); // Pula uma linha com esses valores em cada passo do loop
            ObjectSetInteger(0, nome, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, nome, OBJPROP_FONT, "Rockwell"); // Tipo da fonte de texto
            ObjectSetString(0, nome, OBJPROP_TEXT, texto[i]);   // Texto a ser exibido
            ObjectSetInteger(0, nome, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, nome, OBJPROP_BACK, false);
        }
        else
            return false;

        // Criando os itens que receberão os dados no painel
        nome = "painel_dados_" + IntegerToString(i); // Nome dos objetos criados, ainda no loop

        if (ObjectCreate(0, nome, OBJ_LABEL, 0, 0, 0))
        {
            ObjectSetInteger(0, nome, OBJPROP_COLOR, clrGray);
            ObjectSetInteger(0, nome, OBJPROP_XDISTANCE, 140);           // Distânciando mais da borda, garantido que ficará lada a lado
            ObjectSetInteger(0, nome, OBJPROP_YDISTANCE, 20 + (i * 15)); // Pulando uma linha a cada ciclo do loop
            ObjectSetInteger(0, nome, OBJPROP_FONTSIZE, 9);
            ObjectSetString(0, nome, OBJPROP_FONT, "Rockwell");
            ObjectSetString(0, nome, OBJPROP_TEXT, "-");
            ObjectSetInteger(0, nome, OBJPROP_HIDDEN, true);
            ObjectSetInteger(0, nome, OBJPROP_BACK, false);
        }
        else
            return false;
    }

    Sleep(200);
    ChartRedraw();

    // Verifica as posições e envia os dados para o painel
    s_posicoes posicao = posicionamento();
    atualizar_painel(posicao); // Enviando posicionamento do EA para o painel

    return true;
}
//+------------------------------------------------------------------+
//| Atualização dos dados do painel |
//+------------------------------------------------------------------+
void atualizar_painel(const s_posicoes &posicao)
{
    // Alguns dados exibidos no painel
    string texto[8];                                                                      // Receberá os valores exibidos no painel
    datetime tempo = iTime(_Symbol, _Period, 0) + PeriodSeconds(_Period) - TimeCurrent(); // Tempo restante da barra
    double ontem = iClose(_Symbol, PERIOD_D1, 1);                                         // Fechamento dia anterior
    double dif = iClose(_Symbol, PERIOD_D1, 0) - ontem;                                   // DIferença entre fechamentos
    double oscilacao = (ontem > 0) ? (dif / ontem) * 100 : 0.00;                          // Cálculo percentual do desempenho diário do ativo

    // Atribuindo os valores
    for (int i = 0; i < 8; i++)
    {
        string nome = "painel_dados_" + IntegerToString(i);

        switch (i)
        {
        case 0:
            texto[i] = in_nome;
            break;
        case 1:
            texto[i] = IntegerToString(in_magic);
            break;
        case 2:
            texto[i] = DoubleToString(posicao.volume, 2);
            if (posicao.volume > 0) // Regra de coloração para alta
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrGreen);
            else if (posicao.volume < 0) // Regra de coloração para baixa
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrRed);
            else
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrWhite); // Regra de coloração neutra
            break;
        case 3:
            texto[i] = TimeToString(posicao.abertura, TIME_SECONDS);
            break;
        case 4:
            texto[i] = DoubleToString(posicao.lucro, 2);
            if (posicao.lucro > 0)
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrGreen);
            else if (posicao.lucro < 0)
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrRed);
            else
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrWhite);
            break;
        case 5:
            texto[i] = DoubleToString(dif, _Digits) + " (" + DoubleToString(oscilacao, 2) + "%)";
            if (dif > 0)
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrGreen);
            else if (dif < 0)
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrRed);
            else
                ObjectSetInteger(0, nome, OBJPROP_COLOR, clrWhite);
            break;
        case 6:
            texto[i] = TimeToString(TimeLocal() - TimeCurrent(), TIME_SECONDS); // Sincronização do tempo local e da corretora
            break;
        case 7:
            texto[i] = TimeToString(tempo, TIME_SECONDS);
            break;
        default:
            break;
        }

        ObjectSetString(0, nome, OBJPROP_TEXT, texto[i]); // Atualiza o valor em forma de texto
    }
}
//+------------------------------------------------------------------+
//| Checar se horário de operação |
//+------------------------------------------------------------------+
bool horario_entrar(void)
{
    if (!in_hab_hora) // Se não for para verificar horários a função retorna que pode continuar
        return true;

    static bool exibir_msg = true; // Variável estática para evitar excesso de repetição da msg exibida na codicional

    // Verifica se está dentro do horário permitido
    if (hora_atual.hour > hora_iniciar.hour || (hora_atual.hour == hora_iniciar.hour && hora_atual.min >= hora_iniciar.min))
        if (hora_atual.hour < hora_parar.hour || (hora_atual.hour == hora_parar.hour && hora_atual.min < hora_parar.min))
        {
            if (exibir_msg)
                printf("[%s] Horário de operações permitido. Operacional das %s às %s", in_nome, in_iniciar, in_parar);

            exibir_msg = false; // Impede a repetição da msg
            return true;
        }

    if (!exibir_msg)
    {
        if (exibir_msg)
            printf("[%s] Fora do horário de operações. Operacional das %s às %s", in_nome, in_iniciar, in_parar);

        exibir_msg = true; // Atualiza que deverá repetir a msg se a condicional for satisfeita na próxima chamada
    }

    return false; // Não stá no horário de novas posições
}
//+------------------------------------------------------------------+
//| Horário de zeragem compulsória |
//+------------------------------------------------------------------+
bool horario_zeragem(void)
{
    // Função que verifica horário de zeragem
    static bool exibir_msg = true; // Idem recurso anterior

    if (in_hab_zerar) // Desabilita e habilita zeragem ou não pr horário
        if (hora_atual.hour > hora_zerar.hour || (hora_atual.hour == hora_zerar.hour && hora_atual.min >= hora_zerar.min))
        {
            if (exibir_msg)
                printf("[%s] Horário de zeragem compulsória às %s", in_nome, in_zerar);

            exibir_msg = false;
            return true; // Confirma que terá que zerar as posições
        }

    exibir_msg = true;
    return false;
}
//+------------------------------------------------------------------+
//| Contador de ordens pendentes |
//+------------------------------------------------------------------+
s_ordens pendentes(void)
{
    // Estrutura que armzenará e retornará os valores das ordens pendentes encontradas
    s_ordens ordem;
    ZeroMemory(ordem);

    for (int i = OrdersTotal() - 1; i >= 0; i--) // Loop para verificar todas as ordens
    {
        ulong ticket = OrderGetTicket(i); // Pegando separadamente o bilhete atribuído a cada ordem
        if (!OrderSelect(ticket))
            continue;

        if ((ulong)OrderGetInteger(ORDER_MAGIC) != in_magic) // Verificar magic number
            continue;

        if (OrderGetString(ORDER_SYMBOL) != _Symbol) // Verificar simbolo
            continue;

        ENUM_ORDER_TYPE tipo = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); // Verifica ó tipo de ordem, limitada ou stop
        bool deletar_repetida = false;

        // Se houver ordem colocada em barra anterior a mesma é deletada na troca de barra
        if (in_cancel_sinal) // Pode ser habilitada ou não este recurso via input
            if (OrderGetInteger(ORDER_TIME_SETUP) < iTime(_Symbol, _Period, 0))
                if (realizar_negocio(TRADE_ACTION_REMOVE, tipo, ticket))
                    continue;

        // Se houver mais de uma ordem no mesmo sentido, a mais antiga é deletada
        if (tipo == ORDER_TYPE_BUY_LIMIT)
        {
            if (ordem.compra_limit == 0)
                ordem.compra_limit = ticket;
            else
                deletar_repetida = true; // Confimando que há ordens repetidas
        }
        else if (tipo == ORDER_TYPE_SELL_LIMIT)
        {
            if (ordem.venda_limit == 0)
                ordem.venda_limit = ticket;
            else
                deletar_repetida = true;
        }
        else
            deletar_repetida = true;

        if (deletar_repetida)
            realizar_negocio(TRADE_ACTION_REMOVE, tipo, ticket); // Deletando ordem repetida, se houver
    }

    return ordem;
}
//+------------------------------------------------------------------+
//| Posicionamento |
//+------------------------------------------------------------------+
s_posicoes posicionamento(void)
{
    // Estrutura para armazenar os dados de ordens executadas
    s_posicoes posicao;
    ZeroMemory(posicao);

    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (!PositionSelectByTicket(ticket))
            continue;

        if (PositionGetInteger(POSITION_MAGIC) != in_magic)
            continue;

        if (PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;

        ENUM_POSITION_TYPE tipo = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        double vol = PositionGetDouble(POSITION_VOLUME);
        double price = PositionGetDouble(POSITION_PRICE_OPEN);

        if (posicao.abertura == 0)
            posicao.abertura = (datetime)PositionGetInteger(POSITION_TIME);

        if (tipo == POSITION_TYPE_BUY)
        {
            posicao.volume += vol; // Verifica o volume aberto, positivo para compras
            posicao.ticket_compra = ticket;

            // Verifica o lucro real da posição com base no preço verdadeiro de saída e não pelo último negócio
            if (!OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, vol, price, SymbolInfoDouble(_Symbol, SYMBOL_BID), posicao.lucro))
                printf("[%s] Falha no cálculo de lucro da posição comprada %d", in_nome, (string)ticket);
        }
        else
        {
            posicao.volume -= vol; // Verifica o volume aberto, negativo para vendas
            posicao.ticket_venda = ticket;

            if (!OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, vol, price, SymbolInfoDouble(_Symbol, SYMBOL_ASK), posicao.lucro))
                printf("[%s] Falha no cálculo de lucro da posição vendida %d", in_nome, (string)ticket);
        }

        // Se houver compra e venda abertas simultaneamente, conta tipo hedge, serão fechadas uma pela outra
        if (posicao.ticket_compra > 0)
            if (posicao.ticket_venda > 0)
                if (realizar_negocio(TRADE_ACTION_CLOSE_BY, ORDER_TYPE_CLOSE_BY, posicao.ticket_compra, 0, 0, 0, 0, posicao.ticket_venda))
                {
                    i = PositionsTotal(); // Reinicia o contador para contabilizar a atualização de posições
                    ZeroMemory(posicao);  // Zera os dados armazenados para verificar novamente
                }
    }

    return posicao;
}
//+------------------------------------------------------------------+
//| Verificação de spread entre compra e venda |
//+------------------------------------------------------------------+
bool check_spread(void)
{
    if (in_spread == 0) // Se selecionado zero via input, desabilita a verificação
        return true;

    double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;                     // Verificando o spread atual
    double spr = normalizar(in_spread * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)); // Convertendo para tamanho de tick

    if (spread > spr) // Verificando se o spread é superior ao selecionado
    {
        printf("[%s] Entrada não permitida. Spread de %f supera o máximo de %f", in_nome, spread, spr);
        return false;
    }
    else
        return true;
}
//+------------------------------------------------------------------+
//| Verificação da distância mínima do stop |
//+------------------------------------------------------------------+
double check_stoplevel(double price, const ENUM_ORDER_TYPE tipo)
{
    // Distância mínima permitida do preço para colocar ordens pendentes
    double stoplevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
    double referencia = 0.00; // Iniciando variavel

    switch (tipo)
    {
    case ORDER_TYPE_BUY_LIMIT:
        referencia = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - stoplevel; // Referência para o stoplevel
        if (price > referencia)
            price = normalizar(referencia); // Altera para o valor mínimo aceito se a ordem estiver fora do parâmetro
        break;
    case ORDER_TYPE_SELL_LIMIT:
        referencia = SymbolInfoDouble(_Symbol, SYMBOL_BID) + stoplevel;
        if (price < referencia)
            price = normalizar(referencia);
        break;
    default:
        break;
    }

    return price;
}
//+------------------------------------------------------------------+
//| Filtro de ordens a mercado repetidas |
//+------------------------------------------------------------------+
bool check_permissao(void)
{
    // Verifica se tem ordem aguardando ser executada ou não, evita ordens a mercado repetidas ou excessivas
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        ulong ticket = OrderGetTicket(i);
        if (!OrderSelect(ticket))
            continue;

        if ((ulong)OrderGetInteger(ORDER_MAGIC) != in_magic)
            continue;

        if (OrderGetString(ORDER_SYMBOL) != _Symbol)
            continue;

        ENUM_ORDER_TYPE tipo = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
        // Verificando ordens a mercado que ainda não foram confirmadas pela corretora
        if (tipo == ORDER_TYPE_BUY || tipo == ORDER_TYPE_SELL || tipo == SYMBOL_ORDER_CLOSEBY)
            return false;
    }

    return true;
}
//+------------------------------------------------------------------+
//| Filtro de posição executada em barra atual |
//+------------------------------------------------------------------+
bool check_barra(void)
{
    // Verifica se houve ordem executada na barra atual, evitando entradas excessivas na mesma barra
    // Pode ser habilitada ou não
    if (!in_barra_atual)
        return false;

    // Selecionando apenas a barra atual para o período
    HistorySelect(iTime(_Symbol, _Period, 0), TimeCurrent());

    for (int i = HistoryDealsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = HistoryDealGetTicket(i);
        if (ticket == 0)
            continue;

        if (HistoryDealGetInteger(ticket, DEAL_MAGIC) != in_magic)
            continue;

        if (HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol)
            continue;

        ENUM_DEAL_TYPE tipo = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);

        // Confirmando que a ordem foi de compra ou venda, não pendente nem fechamento pela oposta
        if (tipo == DEAL_TYPE_BUY || tipo == DEAL_TYPE_SELL)
            return true;
    }

    return false;
}
//+------------------------------------------------------------------+
//| Deletar ordens pendentes |
//+------------------------------------------------------------------+
void deletar_pendentes(const s_ordens &ordem)
{
    // Verifica se o bilhete da ordem existe e remove se positivo
    if (ordem.compra_limit != 0)
        if (OrderSelect(ordem.compra_limit))                                                 // Confirmando e selecionando a ordem pelo bilhete único
            realizar_negocio(TRADE_ACTION_REMOVE, ORDER_TYPE_BUY_LIMIT, ordem.compra_limit); // Deletando ordem pendente

    if (ordem.venda_limit != 0)
        if (OrderSelect(ordem.venda_limit))
            realizar_negocio(TRADE_ACTION_REMOVE, ORDER_TYPE_SELL_LIMIT, ordem.venda_limit);
}
//+------------------------------------------------------------------+
//| Zeragem compulsória |
//+------------------------------------------------------------------+
void zeragem_compulsoria(void)
{
    // Verificando todas as posições abertas inclusive serve para contas hedge
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);
        if (!PositionSelectByTicket(ticket))
            continue;

        if (PositionGetInteger(POSITION_MAGIC) != in_magic)
            continue;

        if (PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;

        ENUM_POSITION_TYPE tipo = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        double vol = PositionGetDouble(POSITION_VOLUME);

        // Zerando ordem a mercado, seja de compra ou venda
        if (tipo == POSITION_TYPE_BUY)
            realizar_negocio(TRADE_ACTION_DEAL, ORDER_TYPE_SELL, ticket, vol, SymbolInfoDouble(_Symbol, SYMBOL_BID));
        else
            realizar_negocio(TRADE_ACTION_DEAL, ORDER_TYPE_BUY, ticket, vol, SymbolInfoDouble(_Symbol, SYMBOL_ASK));
    }
}
//+------------------------------------------------------------------+
//| Normalizar preço |
//+------------------------------------------------------------------+
double normalizar(const double price)
{
    // Função que garante que o preço fique com valores aceitos para o ativo
    double tamanho = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    int digitos = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double ajuste = (tamanho > 0 && price > 0) ? ((MathRound(price / tamanho)) * tamanho) : 0.00;

    if (price > 0)
        if (ajuste < tamanho)
            ajuste = tamanho;

    // Ajustando como saída o preço corrigido ou aprovado
    return NormalizeDouble(ajuste, digitos);
}
//+------------------------------------------------------------------+
//| Realizando as transações |
//+------------------------------------------------------------------+
bool realizar_negocio(const ENUM_TRADE_REQUEST_ACTIONS acao,
                      const ENUM_ORDER_TYPE tipo,
                      const ulong ticket,
                      const double volume = 0.0,
                      const double price = 0.0,
                      const double stoploss = 0.0,
                      const double takeprofit = 0.0,
                      const ulong ticket_by = 0.0)
{
    MqlTradeRequest request;          // Estrutura da ordem a ser enviada
    MqlTradeResult result;            // Resultados de verificação
    MqlTradeCheckResult check_result; // Dados de verificação

    // Zerando residuos da solicitação anterior
    ZeroMemory(request);
    ZeroMemory(result);
    ZeroMemory(check_result);

    request.magic = in_magic;
    request.symbol = _Symbol;
    request.comment = "[" + in_nome + "]";

    request.type_time = (ENUM_ORDER_TYPE_TIME)in_validade;            // Tipo de validade da ordem, obrigatório em algumas corretoras
    request.type_filling = (ENUM_ORDER_TYPE_FILLING)in_preenchimento; // Tipo de preenchimento, de acordo com o tipo de mercado

    request.price = normalizar(price);
    request.volume = NormalizeDouble(volume, 2);
    request.action = acao;
    request.type = tipo;
    request.sl = stoploss;
    request.tp = takeprofit;
    request.position = ticket;
    request.position_by = ticket_by;
    request.order = ticket;

    // Checando a ordem e seus resultados antes do envio da mesma
    if (!OrderCheck(request, check_result))
    {
        printf("[%s] Erro %d na checagem da ordem. Código %d (%s)", in_nome, GetLastError(), check_result.retcode, check_result.comment);
        return false;
    }
    else
        printf("[%s] Checagem de ordem bem sucedida. Enviando ordem...", in_nome);

    // Se bem sucessedida a verificação a ordem é enviada
    if (!OrderSend(request, result))
    {
        // Mensagem exibida em caso de falha no envio da ordem
        printf("[%s] Erro %d no envio da ordem. Código %d (%s)", in_nome, GetLastError(), result.retcode, result.comment);
        return false;
    }
    else
        printf("[%s] Sucesso no negócio [%d]. Código %d (%s)", in_nome, result.order, result.retcode, result.comment);

    return true;
}
//+------------------------------------------------------------------+
//| Envio de compra limitada |
//+------------------------------------------------------------------+
bool comprar(const double stop, const double take)
{
    // Austando na entrada o preço de acordo com o stoplevel mínimo permitido
    double price = check_stoplevel(SymbolInfoDouble(_Symbol, SYMBOL_ASK), ORDER_TYPE_BUY_LIMIT);
    double sl = (stop > 0.0) ? normalizar(price - (in_stoploss * _Point)) : 0.00;   // Stoploss
    double tp = (take > 0.0) ? normalizar(price + (in_takeprofit * _Point)) : 0.00; // Takeprofit

    // Envio sempre de ordem pendente
    return realizar_negocio(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_LIMIT, 0, in_volume, price, sl, tp);
}
//+------------------------------------------------------------------+
//| Envio de venda limitada |
//+------------------------------------------------------------------+
bool vender(const double stop, const double take)
{
    double price = check_stoplevel(SymbolInfoDouble(_Symbol, SYMBOL_BID), ORDER_TYPE_SELL_LIMIT);
    double sl = (stop > 0.0) ? normalizar(price + (in_stoploss * _Point)) : 0.00;
    double tp = (take > 0.0) ? normalizar(price - (in_takeprofit * _Point)) : 0.00;

    return realizar_negocio(TRADE_ACTION_PENDING, ORDER_TYPE_SELL_LIMIT, 0, in_volume, price, sl, tp);
}
//+------------------------------------------------------------------+
//| Sinal e envio de entrada |
//+------------------------------------------------------------------+
bool sinal_entrada(const s_ordens &ordem)
{
    double regressao[1] = {0};
    double macd[1] = {0};

    if (!check_barra())                                         // Verificando se houve ou não negócio relizado na barra atual
        if (CopyBuffer(handle_reg, 0, 0, 1, regressao) > 0)     // Confere se copiou corretamente os dados do indicador
            if (MathAbs(regressao[0]) >= in_reg_coef)           // Verifica o valor do indicador de regressão
                if (CopyBuffer(handle_macd, 0, 0, 1, macd) > 0) // Verifica o valor do indicador macd
                    if (regressao[0] > in_reg_coef)
                    {
                        if (!OrderSelect(ordem.venda_limit)) // Verifica se existe alguma ordem pendente, evitar repetidas
                            if (macd[0] < -in_macd_min)
                                if (check_spread())                            // Checando o spread
                                    return vender(in_stoploss, in_takeprofit); // Enviando ordem
                    }
                    else if (!OrderSelect(ordem.compra_limit)) // Regra para compra
                        if (macd[0] > in_macd_min)
                            if (check_spread())
                                return comprar(in_stoploss, in_takeprofit);

    return false; // Não foram enviadas ordem
}
//+------------------------------------------------------------------+
//| Sinal de encerramento de uma posição |
//+------------------------------------------------------------------+
bool sinal_saida(const s_ordens &ordem, const s_posicoes &posicao)
{
    if (in_barra_atual)
        if (iTime(_Symbol, _Period, 0) < posicao.abertura) // Impede saída no mesmo candle
            return false;

    double regressao[1] = {0};

    if (CopyBuffer(handle_reg, 0, 0, 1, regressao) > 0)
        if (posicao.volume < 0.00) // Verifica a condicional para uma posição comprada
        {
            if (regressao[0] < 0.00)                  // Saída no curzamento da linha central
                if (!OrderSelect(ordem.compra_limit)) // Verifica se não há ordem repetida
                    return comprar(0.0, 0.0);         // Ordem de saída
        }
        else if (regressao[0] > 0.00)
            if (!OrderSelect(ordem.venda_limit))
                return vender(0.0, 0.0);

    return false;
}
//+------------------------------------------------------------------+
//| Execução do expert |
//+------------------------------------------------------------------+
void OnTick(void)
{
    s_posicoes posicao = posicionamento(); // Contabilizando posições abertas

    if (in_hab_painel)
        atualizar_painel(posicao); // Atualiza os dados do painel

    if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) // Evita que o expert funcione se não for permitido pelas configurações da plataforma
        return;

    if (!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) // Verifica se a conta é habilitada para robôs
        return;

    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) // Verifica se a opção auto trading do terminal está ativa
        return;

    s_ordens ordem = pendentes();            // Verificando todas as ordens pendentes
    TimeToStruct(TimeCurrent(), hora_atual); // Atualizando o horário atual

    // Verifica se não foi acionado o horário de zeragem compulsória, tem prioridade sobre o recurso de hora normal
    if (horario_zeragem())
    {
        deletar_pendentes(ordem); // Deleta todas as ordens pendentes no horário de zeragem

        if (posicao.volume != 0.0)
            if (check_permissao())     // Confere se já foi ou não enviada a ordem a mercado
                zeragem_compulsoria(); // Zerando a mercado todas as posições abertas
    }
    else if (posicao.volume != 0.00)
    {
        if (sinal_saida(ordem, posicao)) // Se possuir posição procura pelo sinal de saída
            printf("[%s] Enviado ordem de saída", in_nome);
    }
    else if (horario_entrar()) // Se não for horário de zeragem compulsória, verifica se está dentro da janela operacional de horário
    {
        if (sinal_entrada(ordem))
            printf("[%s] Enviado ordem para entrada", in_nome);
    }
    else
        deletar_pendentes(ordem); // Enviando dados das ordens a serem apagadas
}
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+