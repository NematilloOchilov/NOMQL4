
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

//extern double    Lots=0.01;

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

double Lots() {double b = AccountBalance(), l = 100000, r=b/l;
    if (AccountBalance()<1000) r=0.01;
    return(r);}

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

void omb(int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {
                if (OrderStopLoss() < OrderOpenPrice()) {
                    if (OrderOpenPrice() + 300 * Point < Ask) {
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 100 * Point,
                            OrderTakeProfit(), 0, Yellow))
                            Print("OrderModify OP_BUY START" + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                    }
                }
            }
        }
    }
}

void oms(int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {
                if (OrderStopLoss() > OrderOpenPrice()) {
                    if (OrderOpenPrice() - 300 * Point > Bid) {
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 100 * Point,
                            OrderTakeProfit(), 0, Yellow))
                            Print("OrderModify OP_SELL START" + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                    }
                }
            }
        }
    }
}

void start() {
    double Lots = AccountBalance() / 5000;
    double Price = MarketInfo(Symbol(),MODE_ASK);
    double MA=iMA(NULL,0,500,0,0,0,0);
    double high=iCustom(NULL,0,"Price Border","All tf",61,0,2.6,110,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,MODE_UPPER,0);
    double low=iCustom(NULL,0,"Price Border","All tf",61,0,2.6,110,TRUE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,MODE_LOWER,0);
    //string st = "High: " + DoubleToString(high) + " Low: " + DoubleToString(low);
    //satr("0", st, 250, 50, clrWhite);
    //bool buy = (low < Price + 10 * Point) && (low > Price - 10 * Point);
    //bool sell = (high < Price + 10 * Point) && (high > Price - 10 * Point);
    bool buy = (low > iOpen(Symbol(), 1, 1)) && (low < iOpen(Symbol(), 1, 0));
    bool sell = (high < iOpen(Symbol(), 1, 1)) && (high > iOpen(Symbol(), 1, 0));
//    bool buy = (low > Price);
//    bool sell = (high < Price);
    if (OrdersTotal() > 0) {
        if (buy) ocs(2);
        else if (sell) ocb(1);
    }
    else if (OrdersTotal() < 1) {
        if (buy && (MA < Price)) {osb(Lots, 0, 0, 1);}
        else if (sell && (MA > Price)) {oss(Lots, 0, 0, 2);}
    }
}

/*    if (TimeCurrent() > vaqt) {
        if (OrdersTotal() > 0) {vaqt = TimeCurrent() + 3600;
            if (buy) ocs(2);
            else if (sell) ocb(1);
        }
        else if (OrdersTotal() < 1) {vaqt = TimeCurrent() + 3600;
            if (buy && (MA < Price)) {osb(Lots, 0, 0, 1);}
            else if (sell && (MA > Price)) {oss(Lots, 0, 0, 2);}
        }
    }*/
