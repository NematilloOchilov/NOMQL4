//+--------------------------------------------------------------------------------------------------+
//|                                                                                  Shamdonlar.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double    Lots=0.01;//                       Zararni cheklash
extern int    TakeProfit=600;//                     Daromadni belgilash
extern int    StopLoss=200;//                       Zararni cheklash

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
    double Price=MarketInfo(Symbol(),MODE_ASK);
    double SMA=iMA(NULL,0,200,0,0,0,0);
    double ATR = iATR(NULL,0,20,0);
    double ADXMain240 = iADX(OrderSymbol(),PERIOD_H4,14,PRICE_CLOSE,MODE_MAIN,0);
    double ADXMain = iADX(OrderSymbol(),0,14,PRICE_CLOSE,MODE_MAIN,0);
    double ADXP = iADX(OrderSymbol(),0,14,PRICE_CLOSE,MODE_PLUSDI,0);
    double ADXM = iADX(OrderSymbol(),0,14,PRICE_CLOSE,MODE_MINUSDI,0);
    double BTP = Ask + TakeProfit * Point, BSL = Ask - StopLoss * Point;
    double STP = Bid - TakeProfit * Point, SSL = Bid + StopLoss * Point;
    double o0 = iOpen(Symbol(),0,0), o1 = iOpen(Symbol(),0,1), o2 = iOpen(Symbol(),0,2);
    double o3 = iOpen(Symbol(),0,3), o4 = iOpen(Symbol(),0,4), o5 = iOpen(Symbol(),0,5);
    double h0 = iHigh(Symbol(), 0, 0), h1 = iHigh(Symbol(), 0, 1), h2 = iHigh(Symbol(), 0, 2);
    double h3 = iHigh(Symbol(), 0, 3), h4 = iHigh(Symbol(), 0, 4), h5 = iHigh(Symbol(), 0, 5);
    double l0 = iLow(Symbol(), 0, 0), l1 = iLow(Symbol(), 0, 1), l2 = iLow(Symbol(), 0, 2);
    double l3 = iLow(Symbol(), 0, 3), l4 = iLow(Symbol(), 0, 4), l5 = iLow(Symbol(), 0, 5);
    double c0 = iClose(Symbol(), 0, 0), c1 = iClose(Symbol(), 0, 1), c2 = iClose(Symbol(), 0, 2);
    double c3 = iClose(Symbol(), 0, 3), c4 = iClose(Symbol(), 0, 4), c5 = iClose(Symbol(), 0, 5);
    double c2mo2 = (c2 - o2), o2mc2 = (o2 - c2);
    double h2ml2 = (h2 - l2), h2mc2 = (h2 - c2), c2ml2 = (c2 - l2);
    bool buy = o4 > c4 && o3 > c3 && SMA < Price;  // && 20 < ADXMain240
    bool sell = o4 < c4 && o3 < c3 && SMA > Price;  // && 20 < ADXMain240
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    if (OrdersTotal() < 20) {
        //if (OrdersTotal() > 0)
            //omb(500, 1);
            //oms(500, 2);
            //if (ATR > 0.0019) {MN = ocb(1);MN = ocs(2);}
        if (buy) {  //  && ADXMain > 20
            if (c0 > o0 && c1 > o1 && c2 > o2) {
                if (MN != 1) {
                    if (c2mo2 * 2 < h2ml2 && h2ml2 * 0.1 > h2mc2) {MN = 1; satr("0", "2", 250, 50, clrWhite);
                        osb(Lots, BSL, BTP, 1);  //ocs();
                    }
                }
            }
        }
        if (sell) {  // && ADXMain > 20
            if (c0 < o0 && c1 < o1 && c2 < o2) {
                if (MN != 2) {
                    if (o2mc2 * 2 < h2ml2 && h2ml2 * 0.1 > c2ml2) {MN = 2; satr("0", "2", 250, 50, clrWhite);
                        oss(Lots, SSL, STP, 2); //ocb();
                    }
                }
            }
        }
    }
    return(0);}
