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
extern int    TakeProfit=1900;//                     Daromadni belgilash
extern int    StopLoss=650;//                       Zararni cheklash

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

int ocb(int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {return(0);
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
            }
        }
    }
return(_Magic);
}

int ocs(int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {return(0);
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
            }
        }
    }
return(_Magic);
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

int MN = 0;

int start() {
    double Price = MarketInfo(Symbol(),MODE_ASK);
    double SMA41 = iMA(NULL,0,41,0,0,0,0);
    double SMA44 = iMA(NULL,0,44,0,0,0,0);
    double ADXMain = iADX(OrderSymbol(),0,10,0,MODE_MAIN,0);
    double BTP = Ask + TakeProfit * Point, BSL = Ask - StopLoss * Point;
    double STP = Bid - TakeProfit * Point, SSL = Bid + StopLoss * Point;
    bool buy = SMA41 < Price && SMA44 < Price;  // && 20 < ADXMain240
    bool sell = SMA41 > Price && SMA44 > Price;  // && 20 < ADXMain240
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    satr("0", _Profit(), 250, 50, clrWhite);
    if (OrdersTotal() < 1 && ADXMain < 20) {
        if (buy) {osb(Lots, BSL, BTP, 1);}
        if (sell) {oss(Lots, SSL, STP, 2);}
    }
    return(0);}
