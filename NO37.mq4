
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"


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
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 200 * Point,
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
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 200 * Point,
                            OrderTakeProfit(), 0, Yellow))
                            Print("OrderModify OP_SELL START" + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                    }
                }
            }
        }
    }
}


int a = 0;
int start() {
    double Lot = AccountBalance() / 10000;
    double ADX				=iADX(NULL,PERIOD_H4,50,PRICE_CLOSE,MODE_MAIN,0);
    double Parabolic		=iCustom(NULL, 0, "Parabolic", 0, 0);
    double MACD			    =iMACD(NULL,0,30,60,1,PRICE_OPEN,MODE_MAIN,0);
    double MACD1			=iMACD(NULL,0,30,60,1,PRICE_OPEN,MODE_MAIN,1);
    double Price = MarketInfo(Symbol(),MODE_ASK);
    // satr("0", DoubleToString(ParabolicUp) + " " + DoubleToString(ParabolicDown), 250, 50, clrWhite);
    if (OrdersTotal() > 0) {
        for (int cb = OrdersTotal(); cb >= 0; cb--) {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
                if (OrderType() == OP_SELL) {oms(OrderMagicNumber());}
                else if (OrderType() == OP_BUY) {omb(OrderMagicNumber());}
            }
        }
    }
    else if (OrdersTotal() < 1 && ADX > 20) {
        if (MACD1 > 0 && 0 > MACD && Parabolic > Price) {oss(Lot, Bid + 400 * Point, 0, 1);}
        if (MACD1 < 0 && 0 < MACD && Parabolic < Price) {osb(Lot, Ask - 400 * Point, 0, 2);}
    }
    return(0);
}
