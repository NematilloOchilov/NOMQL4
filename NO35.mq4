
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"
//extern double    Lots=1;
//extern double    TakeProfit1=50;
//extern double    TakeProfit2=60;
////extern double    TakeProfit3=50;
////extern double    TakeProfit4=50;
////extern double    TakeProfit5=50;
////extern double    TakeProfit6=50;
////extern double    TakeProfit7=50;
////extern double    TakeProfit8=50;
//extern double    StopLoss1=70;
//extern double    StopLoss2=80;
////extern double    StopLoss3=70;
////extern double    StopLoss4=70;
////extern double    StopLoss5=70;
////extern double    StopLoss6=70;
////extern double    StopLoss7=70;
////extern double    StopLoss8=70;

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
double Lots = 0.01;
void start() {
    double Price = MarketInfo(Symbol(),MODE_ASK);
    string SuperTrendIndicatorFilename = "super-arrow-indicator";
    double sell=iCustom(_Symbol,0,SuperTrendIndicatorFilename,5,12,12,1,10,0,0.5,50,50,true,10, 1,1);
    double buy=iCustom(_Symbol,0,SuperTrendIndicatorFilename,5,12,12,1,10,0,0.5,50,50,true,10, 0,1);
//    for (int i=0; i < 10; i++) {
//    string s = DoubleToString(iCustom(_Symbol,0,SuperTrendIndicatorFilename,5,12,12,1,10,0,0.5,50,50,true,10, 1, i));
//    Print(IntegerToString(i) + "-sell-" + s);
//    }
//    for (int ii=0; ii < 10; ii++) {
//    string b = DoubleToString(iCustom(_Symbol,0,SuperTrendIndicatorFilename,5,12,12,1,10,0,0.5,50,50,true,10, 0, ii));
//    Print(IntegerToString(ii) + "-buy-" + b);
//    }
    if (OrdersTotal() == 1) {
        for (int cb = OrdersTotal(); cb >= 0; cb--) {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
                if (OrderType() == OP_SELL && OrderMagicNumber() == 2 && buy != 2147483647) {
                    ocs(2); osb(Lots, 0, 0, 1);
                }
                if (OrderType() == OP_BUY && OrderMagicNumber() == 1 && sell != 2147483647) {
                    ocb(1); oss(Lots, 0, 0, 2);
                }
                Sleep(6000);
            }
        }
    }
    else if (OrdersTotal() < 1) {
        if (buy != 2147483647) {osb(Lots, 0, 0, 1);}
        else if (sell != 2147483647) {oss(Lots, 0, 0, 2);}
    }
}