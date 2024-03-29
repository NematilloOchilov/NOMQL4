//+--------------------------------------------------------------------------------------------------+
//|                                                                                     NO13_10.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double    Lots=0.1;
extern double    TakeProfit=100;
extern double    StopLoss=10000;

//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
string _Profit() {
    double BuyProfit = 0, SellProfit = 0;
    for(int i=0; i<OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {
                    BuyProfit = +OrderProfit();
                    }
                if (OrderType() == OP_SELL) {
                    SellProfit += OrderProfit();
                    }
                }
            }
        }
    string None = "Savdo mavjud emas";
    string matn = "  Buy foyda: " + DoubleToString(BuyProfit) + " Sell foyda: " + DoubleToString(SellProfit) +
    "  Jami: " + DoubleToString(BuyProfit + SellProfit);
    if (BuyProfit != 0 || 0 != SellProfit) {
        return (matn);
        }
    else{
        return (None);
        }
    }

void satr(string _name, string text, uint x, uint y, color rang) {
    long chart_ID = ChartID();
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,rang);
    ObjectSetString(chart_ID,_name,OBJPROP_TEXT,text);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
    ChartRedraw(chart_ID);
    }

void osb (double _Lot, double _BSL, double _BTP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_BUY, _Lot, Ask, 10, _BSL, _BTP, "Shamdon turi: " + strmagic, _Magic, 0, Blue))
        Print("OrderSend Buy " + strmagic + "-da muammo: ", GetLastError());
}

void oss (double _Lot, double _SSL, double _STP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_SELL, _Lot, Bid, 10, _SSL, _STP, "Shamdon turi: " + strmagic, _Magic, 0, Red))
        Print("OrderSend Sell " + strmagic + "-da muammo: ", GetLastError());
}

void om(int _Magic, double _a) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderMagicNumber() == _Magic) {
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), 0, _a, 0, Yellow))
                    Print("OrderModify " + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
            }
        }
    }
}

double TakeProfit() {double lots = 0.0, formula = 0.0;
    for (int ls = OrdersTotal(); ls >= 0; ls--) {
        if (OrderSelect(ls, SELECT_BY_POS, MODE_TRADES) == true) {
            lots += OrderLots();
            formula += (OrderLots() * OrderOpenPrice());
        }
    }
    return(formula / lots);
}


double OOP;
int step = 0, Magic = 1, hour = 0;

int start() {
    double TP=TakeProfit * Point;
    double SL=StopLoss * Point;
    double SMA=iMA(NULL,0,21,0,0,0,0);
    double PriceA=MarketInfo(Symbol(),MODE_ASK);
    double PriceB=MarketInfo(Symbol(),MODE_BID);
    double High1=iHigh(Symbol(),0,1);
    double High2=iHigh(Symbol(),0,2);
    double Low1=iLow(Symbol(),0,1);
    double Low2=iLow(Symbol(),0,2);
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish     _Profit()                                                                   |
    //+--------------------------------------------------------------------------------------------------+
    satr("0", _Profit(), 250, 50, clrWhite);
    if (Open) {
        if (High2 < High1 && SMA < PriceA) {
                osb(Lots, Ask - SL, Ask + TP, 1); step=1; Magic = 1; hour = TimeHour(TimeCurrent());
        }
        else if (Low2 > Low1 && SMA > PriceA) {
            oss(Lots, Bid + SL, Bid - TP, 2); step=1; Magic = 2; hour = TimeHour(TimeCurrent());
        }
    }
    return(0);}
