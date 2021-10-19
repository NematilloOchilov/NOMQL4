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
extern int    TakeProfit=600;//                     Daromadni belgilash
extern int    StopLoss=10000;//                       Zararni cheklash
int           soat=99, soat3=99, soat4=99, close=99;
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
double minus() {
    double m = 0;
    for(int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {if (m > OrderProfit()) m = OrderProfit();}
                if (OrderType() == OP_SELL) {if (m > OrderProfit()) m = OrderProfit();}
                }
            }
        }
    return(m);
    }

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

double Lots() {double b = AccountBalance(), l = 20000, r;
    r=b/l;
    if (AccountBalance()<200) r=0.01;
    return(r);}

double OOP;
int start()
    {
    double Lot = Lots();
    double narx=MarketInfo(Symbol(),MODE_ASK);
    double SMA60=iMA(NULL,PERIOD_H1,190,62,0,0,0);
    double SMA=iMA(NULL,0,190,62,0,0,0);
    double MACD_SIGNAL=iMACD(NULL,0,190,62,9,PRICE_CLOSE,MODE_SIGNAL,0);
    double RSI=iRSI(NULL,0,14,PRICE_OPEN,0);
    double Stomain=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);//green
    double Stosignal=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);//red
    double TP = TakeProfit * Point;
    double SL = StopLoss * Point;
    bool buy = (narx > SMA60) && (narx > SMA) && (0 < MACD_SIGNAL) && (50 < RSI) && (50 < Stomain) && (Stosignal < Stomain);
    bool sell = (narx < SMA60) && (narx < SMA) && (0 > MACD_SIGNAL) && (50 > RSI) && (50 > Stomain) && (Stosignal > Stomain);
    if (0 < OrdersTotal()) {
        double min = minus();
        if (min < -2) {
            satr("0", DoubleToString(min), 250, 50, clrWhite);
            for (int cb = OrdersTotal(); cb >= 0; cb--){
                if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
                    if (OrderType() == OP_BUY){
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());
                        }
                    if (OrderType() == OP_SELL){
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
                        }
                    }
                }
            }
        if (buy && OOP < narx) {OOP = Ask + 300 * Point;
            if (!OrderSend(Symbol(), OP_BUY, Lot, Ask, 10, 0, Ask + TP, "NO savdo ", 0, 0, Aqua))
                Print("OrderSend BUYda muammo: ", GetLastError());
            }
        else if (sell && OOP > narx) {OOP = Bid - 300 * Point;
            if (!OrderSend(Symbol(), OP_SELL, Lot, Bid, 10, 0, Bid - TP, "NO savdo ", 0, 0, Red))
                Print("OrderSend SELLda muammo: ", GetLastError());
            }
        }
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    if (1 > OrdersTotal()){
        if (buy) {OOP = Ask + 100 * Point;
            if (!OrderSend(Symbol(), OP_BUY, Lot, Ask, 10, 0, Ask + TP, "NO savdo ", 0, 0, Aqua))
                Print("OrderSend BUYda muammo: ", GetLastError());
            }
        else if (sell) {OOP = Bid - 100 * Point;
            if (!OrderSend(Symbol(), OP_SELL, Lot, Bid, 10, 0, Bid - TP, "NO savdo ", 0, 0, Red))
                Print("OrderSend SELLda muammo: ", GetLastError());
            }
        }
    return(0);}
