//+--------------------------------------------------------------------------------------------------+
//|                                                                                      NO13_7.mq4  |
//|                                                                       Strategiya muallifi: ....  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
double OOP, lot = 0.01;
int step = 0, minut = 0, bs = 0;
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

double minus() {
    double m = 0;
    for(int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {m = OrderProfit() / OrderLots();}
                if (OrderType() == OP_SELL) {m = OrderProfit() / OrderLots();}
                }
            }
        }
    return(m);
    }

void buy(double l, double BSL, double BTP) {
    if (!OrderSend(Symbol(), OP_BUY, l, Ask, 10, BSL, BTP, "NO savdo ", 0, 0, Blue))
        Print("OrderSend BUYda muammo: ", GetLastError());
}

void sell(double l, double SSL, double STP) {
    if (!OrderSend(Symbol(), OP_SELL, l, Bid, 10, SSL, STP, "NO savdo ", 0, 0, Red))
        Print("OrderSend SELLda muammo: ", GetLastError());
}

int start()
    {satr("0", minus(), 250, 50, clrWhite);
    double SMA=iMA(NULL,0,190,62,0,0,0);
    double narx=MarketInfo(Symbol(),MODE_BID), open = iOpen(Symbol(),0,1), close = iClose(Symbol(),0,1);
    double BTP = Ask + 100 * Point, BSL = Ask - 100 * Point;
    double STP = Bid - 100 * Point, SSL = Bid + 100 * Point;
    //if (lot > 1) Sleep(24 * 60 * 600);if (lot > 0.63) lot /= 128; else lot *= 2;
    if (OrdersTotal() > 0) {
        if (minus() < -100) {lot *= 2;
            if (OrderType()==OP_BUY) {
                int _b = OrderClose(OrderTicket(),OrderLots(),Bid,10,Green);
                if (_b > -1) {
                    if (open < close) {buy(lot, 0, 0);}
                    else if (open > close) {sell(lot, 0, 0);}
                }
                else Print("OrderClose BUYda muammo: ",GetLastError());
            }
            if (OrderType()==OP_SELL) {
                int _s = OrderClose(OrderTicket(),OrderLots(),Ask,10,Red);
                if (_s > -1) {
                    if (open < close) {buy(lot, 0, 0);}
                    else if (open > close) {sell(lot, 0, 0);}
                }
                else Print("OrderClose BUYda muammo: ",GetLastError());
            }
        }
        if (minus() > 100) {lot = 0.01;
            if (OrderType()==OP_BUY) {
                int b = OrderClose(OrderTicket(),OrderLots(),Bid,10,Green);
                if (b > -1) {buy(lot, 0, 0);}
                else Print("OrderClose BUYda muammo: ",GetLastError());
            }
            if (OrderType()==OP_SELL) {
                int s = OrderClose(OrderTicket(),OrderLots(),Ask,10,Red);
                if (s > -1) {sell(lot, 0, 0);}
                else Print("OrderClose BUYda muammo: ",GetLastError());
            }
        }
    }

    else if (OrdersTotal() < 1) {lot = 0.01;
        if (open < close && narx > SMA) {buy(lot, 0, 0);}
        else if (open > close && narx < SMA) {sell(lot, 0, 0);}
    }
    return(0);}
