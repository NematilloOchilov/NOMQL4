
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

double Lots = 0.01;

void satr(string _name, string text, uint x, uint y, color rang) {
    long chart_ID = ChartID();
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,rang);
    ObjectSetString(chart_ID,_name,OBJPROP_TEXT,text);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
    ChartRedraw(chart_ID);
    }

void osb (double _Lots, double _BSL, double _BTP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_BUY, _Lots, Ask, 10, _BSL, _BTP, "Shamdon turi: " + strmagic, _Magic, 0, Blue))
        Print("OrderSend Buy " + strmagic + "-da muammo: ", GetLastError());
}

void oss (double _Lots, double _SSL, double _STP, int _Magic) {
    string strmagic = IntegerToString(_Magic);
    if (!OrderSend(Symbol(), OP_SELL, _Lots, Bid, 10, _SSL, _STP, "Shamdon turi: " + strmagic, _Magic, 0, Red))
        Print("OrderSend Sell " + strmagic + "-da muammo: ", GetLastError());
}

int ocb(int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
                return(0);
            }
        }
    }
return(_Magic);
}

int ocs(int _Magic) {Print(OrderMagicNumber()); Print("i" + IntegerToString(_Magic));
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
                return(0);
            }
        }
    }
return(_Magic);
}


void start() {
    double Price = MarketInfo(Symbol(),MODE_ASK);
    string SuperTrendIndicatorFilename = "supertrendprofit4";
    double STI=iCustom(_Symbol,0,SuperTrendIndicatorFilename,29,15,15,true,true,14,14,DarkTurquoise,Red,2,1);
    if (OrdersTotal() > 0) {
        for (int cb = OrdersTotal(); cb >= 0; cb--) {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
                if (OrderType() == OP_SELL && OrderMagicNumber() == 2 && STI == 2147483647) {
                    ocs(2); osb(Lots, 0, 0, 1);
                }
                if (OrderType() == OP_BUY && OrderMagicNumber() == 1 && STI != 2147483647) {
                    ocb(1); oss(Lots, 0, 0, 2);
                }
            }
        }
    }
    else if (OrdersTotal() < 1) {
        if (STI == 2147483647) {osb(Lots, 0, 0, 1);}
        else if (STI != 2147483647) {oss(Lots, 0, 0, 2);}
    }
}

