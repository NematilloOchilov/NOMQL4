
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"
extern bool    buy=true;


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


int T_P(double OTP) {
    double ret;
    //Print("ret " + DoubleToString(OTP));
    if (OTP < 0.0055) ret = 700;
    else if (OTP > 0.0055) ret = 800;
    //Print("ret " + DoubleToString(ret));
    return (ret);
}

int a = 0;
int start() {
    double Lot = AccountBalance() / 10000;
    double Bands			=iBands(NULL,0,1000,2,0,PRICE_CLOSE,MODE_MAIN,0);
    double BandsP			=iBands(NULL,0,1000,2,0,PRICE_CLOSE,MODE_PLUSDI,0);
    double BandsM			=iBands(NULL,0,1000,2,0,PRICE_CLOSE,MODE_MINUSDI,0);
    double MACD500			=iMACD(NULL,0,500,800,9,PRICE_OPEN,MODE_MAIN,0);
    double MACD50050		=iMACD(NULL,0,500,800,9,PRICE_OPEN,MODE_MAIN,50);
    double MACD100			=iMACD(NULL,0,100,150,9,PRICE_OPEN,MODE_MAIN,0);
    double MACD1001			=iMACD(NULL,0,100,150,9,PRICE_OPEN,MODE_MAIN,1);
    double Price = MarketInfo(Symbol(),MODE_ASK);
    // satr("0", DoubleToString(MACD), 250, 50, clrWhite);
    if (OrdersTotal() > 0) {
        for (int cb = OrdersTotal(); cb >= 0; cb--) {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
                if (OrderType() == OP_SELL) {
                    if (BandsM > Price || MACD100 > 0) {ocs(OrderMagicNumber());}
                }
                else if (OrderType() == OP_BUY) {
                    if (BandsP < Price || MACD100 < 0) {ocb(OrderMagicNumber());}
                }
            }
        }
    }
    else if (OrdersTotal() < 1) {
        if (MACD50050 > MACD500 && MACD500 < 0 && MACD1001 > 0 && MACD100 < 0 && BandsM < Price) {oss(Lot, 0, Bid - 800 * Point, 1);}
        if (MACD50050 < MACD500 && MACD500 > 0 && MACD1001 < 0 && MACD100 > 0 && BandsP > Price) {osb(Lot, 0, Ask + 800 * Point, 2); }
    }
    return(0);
}
