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

int ocb(int _Magic) {int m;
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {m=0;
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
            }
            else m=7;
        }
    }
return(m);
}

int oc(int _Magic) {int m = 7;
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderMagicNumber() == _Magic) {m=0;
                if (OrderType() == OP_SELL) {
                    if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                        Print("OrderClose OP_SELLda muammo: ", GetLastError());
                }
                else if (OrderType() == OP_BUY) {
                    if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                        Print("OrderClose OP_BUYda muammo: ", GetLastError());
                }
            }
        }
    }
return(m);
}

int ocs(int _Magic) {int m;
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {m=0;
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
            }
            else m=7;
        }
    }
return(m);
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

double Lot(int st) {
    double l[6] = {0.1, 0.2, 0.4, 0.8, 1.6, 5}; // , 2.2, 3.3, 5.0
    //if (st > 6) return(0.1);
    return(l[st]);
}

double OOP;
int step = 0, Magic = 0;

int start() {
    double PriceA=MarketInfo(Symbol(),MODE_ASK);
    double PriceB=MarketInfo(Symbol(),MODE_BID);
    double SMA=iMA(NULL,0,900,0,0,0,0);
    double BandsU=iBands(NULL,0,900,0.75,0,PRICE_OPEN,MODE_UPPER,0);
    double BandsL=iBands(NULL,0,900,0.75,0,PRICE_OPEN,MODE_LOWER,0);
    double BandsM=iBands(NULL,0,900,0.75,0,PRICE_OPEN,MODE_MAIN,0);
    double ADXMain240 = iADX(OrderSymbol(),PERIOD_H4,7,PRICE_CLOSE,MODE_MAIN,0);
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    satr("0", _Profit(), 250, 50, clrWhite);

    /*if (ADXMain240 > 35) { //trend
        if ((SMA - 800 * Point  > Price) && (OOP > Price)) {
            osb(Lot(step), 0, 0, 1); OOP -= 100 * Point; step+=1; Magic = 1;
        }
        else if ((SMA + 800 * Point < Price) && (OOP < Price)) {
            oss(Lot(step), 0, 0, 2); OOP += 100 * Point; step+=1; Magic = 2;
        }
    }
    else */
    if (OrdersTotal() > 0) {
        if (BandsU < PriceB || BandsL > PriceA) {if (ocb(1) == 0 || ocs(2) == 0) {step = 0;}}
        if (step <= 4) {
            if ((BandsL > PriceA) && (OOP > PriceA)) {
                osb(Lot(step), 0, 0, 1); OOP = PriceA - 100 * Point; step+=1; Magic = 1;
            }
            else if ((BandsU < PriceB) && (OOP < PriceB)) {
                oss(Lot(step), 0, 0, 2); OOP = PriceB + 100 * Point; step+=1; Magic = 2;
            }
        }
        else if (step == 5) {
            if ((BandsL > PriceA) && (OOP > PriceA)) {
                oss(Lot(step), 0, 0, 1);
            }
            else if ((BandsU < PriceB) && (OOP < PriceB)) {
                osb(Lot(step), 0, 0, 2);

            }
        }
    }
    if (OrdersTotal() < 1) {
        if (BandsL > PriceA) {
            osb(Lot(step), 0, 0, 1); step+=1; Magic = 1;
            OOP = PriceA - 100 * Point;
        }
        else if (BandsU < PriceB) {
            oss(Lot(step), 0, 0, 2); step+=1; Magic = 2;
            OOP = PriceB + 100 * Point;
        }
    }
    return(0);}
