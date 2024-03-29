
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"

extern double    Lots=0.01;
extern double    TakeProfit=200;
extern double    StopLoss=150;
int mod = 0;

string _Profit() {
    double BuyProfit = 0, SellProfit = 0;
    for(int i=0; i<OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {
                    BuyProfit += OrderProfit();
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

double Lots() {double b = AccountBalance(), l = 2000, r=b/l;
    if (AccountBalance()<20) r=0.01;
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
    double TP = TakeProfit * Point;
    double SL = StopLoss * Point;
    double Price = MarketInfo(Symbol(),MODE_ASK);
    double EMA10=iMA(NULL,PERIOD_CURRENT,10,0,MODE_EMA,PRICE_CLOSE,0);  // Yellow
    double EMA21=iMA(NULL,PERIOD_CURRENT,21,0,MODE_EMA,PRICE_CLOSE,0);  // Orange
    double EMA50=iMA(NULL,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE,0);  // Red
    double EMA10_1b=iMA(NULL,PERIOD_CURRENT,10,0,MODE_EMA,PRICE_CLOSE,0) - 100 * Point;
    double EMA10_1s=iMA(NULL,PERIOD_CURRENT,10,0,MODE_EMA,PRICE_CLOSE,0) + 200 * Point;
    double ADX=iADX(NULL,PERIOD_CURRENT,14,PRICE_HIGH,MODE_MAIN,0);
    double ADX7=iADX(NULL,PERIOD_CURRENT,14,PRICE_HIGH,MODE_MAIN,7);
    bool buy = (EMA10_1b > EMA21 > EMA50);  //  && EMA10_1 < EMA50_1
    bool sell = (EMA10_1s <  EMA21 < EMA50);
    if (OrdersTotal() < 1 && ADX > ADX7 && ADX > 35) {
         if (buy) {osb(Lots(), Ask - SL, Ask + TP, 1);}
         else if (sell) {oss(Lots(), Bid + SL, Bid - TP, 2);}
//        if (buy) {osb(Lots(), 0, 0, 1);}
//        else if (sell) {oss(Lots(), 0, 0, 2);}
    }
//    else if (OrdersTotal() > 0) {for(int i=0;i<OrdersTotal();i++) {
//        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
//            if (OrderType() == OP_BUY && OrderProfit() > 0.5){
//                if (iClose(Symbol(), 0, 0) < iClose(Symbol(), 0, 1)) {
//                    if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,CLR_NONE ))
//                        Print("OrderClose OP_BUYda muammo: ", GetLastError());}
//                    }
//                if (OrderType() == OP_SELL && OrderProfit() > 0.5){
//                    if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)){
//                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,CLR_NONE ))
//                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
//                    }
//                }
//            }
//                if (OrderType() == OP_BUY && (OrderStopLoss() + 2000 * Point) < Ask) msl = OrderStopLoss() + 1000 * Point;
//                if (OrderType() == OP_SELL && (OrderStopLoss() - 2000 * Point) > Bid) msl = OrderStopLoss() - 1000 * Point;
//                if (msl != 0) {mod = 0;
//                    if (!OrderModify(OrderTicket(),OrderOpenPrice(),msl,OrderTakeProfit(),0,Orange))
//                        Print("OrderModifyda muammo: ",GetLastError());
//                    }
//                }
//            }
//    }
}
