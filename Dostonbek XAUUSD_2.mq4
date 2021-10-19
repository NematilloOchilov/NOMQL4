//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO14.mq4  |
//|                                                     Strategiya muallifi: 𝓓𝓲𝓵𝓶𝓾𝓻𝓸𝓭 𝓠𝓪𝓵𝓪𝓷𝓭𝓪𝓻𝓸𝓿  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double Lot = 0.01;//                         Savdo hajmi
extern int    TakeProfit=10000;//                     Daromadni belgilash
extern int    StopLoss=10000;//                       Zararni cheklash
int           soat=0;
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
void satr(string _name, string text, uint x, uint y, color rang){
    long chart_ID = ChartID();
    //string _name = IntegerToString(chart_ID);
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,rang);
    ObjectSetString(chart_ID,_name,OBJPROP_TEXT,text);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
    ChartRedraw(chart_ID);
    }

int start()
{
    double TP = TakeProfit * Point;//                                   Foydani cheklash
    double SL = StopLoss * Point;//                                     Zararni cheklash
    int Highest = iHighest(NULL,0,MODE_HIGH,100,0);
    //satr("0", IntegerToString(Highest), 250, 50, clrWhite);
    double narx=iClose(Symbol(),0,1);
    double CCI=iCCI(Symbol(),0,10,PRICE_TYPICAL,0);
    double RSI=iRSI(NULL,0,14,PRICE_CLOSE,0);
    double SMA10=iMA(NULL,0,10,0,0,0,0);
    double SMA20=iMA(NULL,0,20,0,0,0,0);
    double SMA30=iMA(NULL,0,30,0,0,0,0);
    double SMA144=iMA(NULL,0,144,0,0,0,0);
    double SMA169=iMA(NULL,0,169,0,0,0,0);
    double SMA192=iMA(NULL,0,192,64,0,0,0);
    double AC=iAC(NULL,0,0);
    double AO=iAO(NULL,0,0);
    double AO1=iAO(NULL,0,1);
    double AO2=iAO(NULL,0,2);
    bool buy = (SMA10 > SMA20) && (SMA20 > SMA30) && (SMA30 > SMA144) && (SMA144 > SMA169);
    //&& (AO > AO1) && (AO1 > AO2) && (AO < 10);// && (AC > 0.3) && (AO < -2)
    bool sell = (SMA10 < SMA20) && (SMA20 < SMA30) && (SMA30 < SMA144) && (SMA144 < SMA169);
    //&& (AO < AO1) && (AO1 < AO2) && (AO > -10);// && (AC < -0.3) && (AO < -2)
    if ((1 > OrdersTotal()) && (TimeHour(TimeCurrent()) != soat)) {
        if (buy) {
            int tb = OrderSend(Symbol(), OP_BUY, Lot, Ask, 10, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Aqua);
            if (tb<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
        }
        if (sell) {
            int ts = OrderSend(Symbol(), OP_SELL, Lot, Bid, 10, Bid + SL, Bid - TP, "NO savdo ", 0, 0, Aqua);
            if (ts<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
        }
    }
    else if (OrdersTotal() > 0){
        for (int cb = OrdersTotal(); cb >= 0; cb--){
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
                if (OrderType() == OP_BUY && OrderProfit() > 1){soat=TimeHour(TimeCurrent());
                    if (iClose(Symbol(), 0, 0) < iClose(Symbol(), 0, 1)) {
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,CLR_NONE ))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());}
                    }
                if (OrderType() == OP_SELL && OrderProfit() > 1){soat=TimeHour(TimeCurrent());
                    if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)){
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,CLR_NONE ))
                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
                    }
                }
            }
        }
    }
    return(0);
}
