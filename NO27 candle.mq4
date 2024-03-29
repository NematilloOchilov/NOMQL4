//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO24.mq4  |
//|                                                             Strategiya muallifi: Doston Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double    Lots=0.01;//                       Zararni cheklash
extern int    TakeProfit=10000;//                     Daromadni belgilash
extern int    StopLoss=10000;//                       Zararni cheklash

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

int ocb() {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY) {
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
            }
        }
    }
return(0);
}

int ocs() {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL) {
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
            }
        }
    }
return(0);
}

void omb(int _PlusSL, int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {
                if (OrderStopLoss() < OrderOpenPrice() && OrderOpenPrice() + 300 * Point < Ask) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 100 * Point,
                        OrderTakeProfit(), 0, Yellow))
                        Print("OrderModify OP_BUY START" + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                }
                else if (OrderStopLoss() + (_PlusSL*2) * Point < Ask) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss() + _PlusSL * Point,
                        OrderTakeProfit(), 0, Aqua))
                        Print("OrderModify OP_BUY " + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                }
            }
        }
    }
}

void oms(int _PlusSL, int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {Print("ot ", TimeHour(TimeCurrent() - OrderOpenTime()));
                if (OrderStopLoss() > OrderOpenPrice() && OrderOpenPrice() - 300 * Point > Bid) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 100 * Point,
                        OrderTakeProfit(), 0, Yellow))
                        Print("OrderModify OP_SELL START" + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                }
                else if (OrderStopLoss() - (_PlusSL*2) * Point > Bid) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss() - _PlusSL * Point,
                        OrderTakeProfit(), 0, Orange))
                        Print("OrderModify OP_SELL " + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
                }
            }
        }
    }
}

bool tick(int loop) {
    double bull, bear;
    for (int i=1; i <= loop; i++) {
        if (iOpen(Symbol(), 0, i) < iClose(Symbol(), 0, i))
            bull += iHigh(Symbol(), 0, i) - iLow(Symbol(), 0, i);
        else if (iOpen(Symbol(), 0, i) > iClose(Symbol(), 0, i))
            bear += iHigh(Symbol(), 0, i) - iLow(Symbol(), 0, i);
    }
    //string tex = "Bull: " + DoubleToString(bull) + " Bear: " + DoubleToString(bear);
    //satr("0", tex, 250, 50, clrWhite);
return(bull > bear);
}

int MN = 0;

int start() {
    double Price = MarketInfo(Symbol(),MODE_ASK);
    double SMA1440 = iMA(NULL,1440,200,50,0,0,0);
    double SMA60 = iMA(NULL,60,200,50,0,0,0);
    double SMA15 = iMA(NULL,15,50,50,0,0,0);
    double ADXMain = iADX(OrderSymbol(),0,10,0,MODE_MAIN,0);
    double BTP = Ask + TakeProfit * Point, BSL = Ask - StopLoss * Point;
    double STP = Bid - TakeProfit * Point, SSL = Bid + StopLoss * Point;
    bool t = tick(10);
    bool buy = SMA60 < Price && SMA15 < Price && t == true; //SMA1440 < Price &&
    bool sell = SMA60 > Price && SMA15 > Price && t == false;//SMA1440 > Price &&
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    //satr("0", t, 250, 50, clrWhite);
    if (OrdersTotal() > 0) {
        if (buy && MN == 2) ocs();
        else if (sell && MN == 1) ocb();
    }
    else if (OrdersTotal() < 1) {
        if (buy) {osb(Lots, BSL, BTP, 1); MN = 1;}
        else if (sell) {oss(Lots, SSL, STP, 2); MN = 2;}
    }
    return(0);}
