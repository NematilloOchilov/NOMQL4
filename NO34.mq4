
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"
extern bool    buy=true;
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
    double Lot = 1;  //AccountBalance() / 20000;
    double RSI				=iRSI(NULL,0,14,PRICE_CLOSE,0);
    double MACD244			=iMACD(NULL,0,244,304,9,PRICE_OPEN,MODE_MAIN,0);
    double MACD244100       =iMACD(NULL,0,244,304,9,PRICE_OPEN,MODE_MAIN,100);
    double MACD			    =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
    double MACDS			=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
    double MACD1			=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
    double MACDS1			=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
    double Price = MarketInfo(Symbol(),MODE_ASK);
    // satr("0", DoubleToString(MACD), 250, 50, clrWhite);
    if (OrdersTotal() == 1 && _Profit() < 0) {
        for (int cb = OrdersTotal(); cb >= 0; cb--) {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
                double Lots = OrderLots() * 1.33;
                satr("0", IntegerToString(a), 250, 50, clrWhite);
                if (OrderType() == OP_SELL) {int TP = 500;
                    int SL = T_P(OrderOpenPrice() - OrderTakeProfit()) ;
                    if (SL == 800) TP = 600;}
                    //satr("0", DoubleToString(OrderOpenPrice() - Price), 250, 50, clrWhite);}
                    if (Price - OrderOpenPrice() > 0.002) {
                        ocs(OrderMagicNumber());
                        osb(Lots, Ask - SL * Point, Ask + TP * Point, 0);
                        a += 1;
                    }
                    else if (OrderOpenPrice() - Price > 0.0045) {a = 0;
                }
                else if (OrderType() == OP_BUY) {int _TP = 500;
                    double _SL = T_P(OrderTakeProfit() - OrderOpenPrice());
                    if (_SL == 800) _TP = 600;}
                    if (OrderOpenPrice() - Price > 0.002) {
                        ocb(OrderMagicNumber());
                        oss(Lots, Bid + _SL * Point, Bid - _TP * Point, 0);
                        a += 1;
                    }
                    else if (Price - OrderOpenPrice() > 0.0045) {a = 0;
                }
            }
        }
    }
    else if (OrdersTotal() < 1) {// && a == 0
        if (MACD244 > 0) {
            if (MACD244100 - MACD244 > 0.0005) {oss(Lot, Bid + 300 * Point, Bid - 500 * Point, 0); a = 1;}
        }
        if (MACD244 < 0) {
            if (MACD244 - MACD244100 > 0.0005) {osb(Lot, Ask - 300 * Point, Ask + 500 * Point, 0); a = 1;}
        }
    }
//    else if (OrdersTotal() < 1) {// && a == 0
//        if (RSI > 70 && (MACDS1 < MACD1 && MACDS > MACD)) {
//            oss(Lot, Bid + 300 * Point, Bid - 500 * Point, 0); a = 1;
//        }
//        else if (RSI < 30 && (MACDS1 > MACD1 && MACDS < MACD)) {
//            osb(Lot, Ask - 300 * Point, Ask + 500 * Point, 0); a = 1;
//        }
//    }
    return(0);
}
