//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO27.mq4  |
//|                                                         Strategiya muallifi:  Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
#property version "1.00"
//#property strict
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
double Lots = 5000;//                                Savdo hajmi
double ATR_min = 0.003;
double ATR_max = 0.009;
int soat = 40;//                                Savdo hajmi
int    Slippage=10;//                        Oraliq farq (spreed) o'zgarishi               |
//+--------------------------------------------------------------------------------------------------+
//|   Ochiq savdo miqdorlarini aniqlash funksiyalari                                                 |
//+--------------------------------------------------------------------------------------------------+


string _Profit(){
    double BuyProfit = 0, SellProfit = 0;
    for(int i=0; i<OrdersTotal(); i++){
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if (OrderSymbol() == Symbol()){
                if (OrderType() == OP_BUY){
                    BuyProfit = +OrderProfit();
                    }
                if (OrderType() == OP_SELL){
                    SellProfit += OrderProfit();
                    }
                }
            }
        }
    string None = "Savdo mavjud emas";
    string matn = "  Buy foyda: " + DoubleToString(BuyProfit) + " Sell foyda: " + DoubleToString(SellProfit) +
    "  Jami: " + DoubleToString(BuyProfit + SellProfit);
    if (BuyProfit != 0 || 0 != SellProfit){
        return (matn);
        }
    else{
        return (None);
        }
    }


void satr(string _name, string text, uint x, uint y, color rang){
    long chart_ID = ChartID();
    //string _name = IntegerToString(chart_ID);
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,rang);
    ObjectSetString(chart_ID,_name,OBJPROP_TEXT,text);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
    ChartRedraw(chart_ID);
    //Sleep(600);
    }

int ocb(int _Magic) {int _m;
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {_m=0;
                if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Blue))
                    Print("OrderClose OP_BUYda muammo: ", GetLastError());
            }
            else _m=7;
        }
    }
return(_m);
}

int ocs(int _Magic) {int _m;
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {_m=0;
                if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,Red))
                    Print("OrderClose OP_SELLda muammo: ", GetLastError());
            }
            else _m=7;
        }
    }
return(_m);
}

void omb(double _PlusSL, int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_BUY && OrderMagicNumber() == _Magic) {Print("123");
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), _PlusSL, OrderTakeProfit(), 0, Orange))
                    Print("OrderModify OP_BUY " + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
            }
        }
    }
}

void oms(double _PlusSL, int _Magic) {
    for (int cb = OrdersTotal(); cb >= 0; cb--) {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true) {
            if (OrderType() == OP_SELL && OrderMagicNumber() == _Magic) {Print("321");
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), _PlusSL, OrderTakeProfit(), 0, Orange))
                    Print("OrderModify OP_SELL " + IntegerToString(_Magic) + "-da muammo: ", GetLastError());
            }
        }
    }
}

int modify;
datetime M = TimeCurrent(), P = TimeCurrent();
int p = 0, m = 0;
//+------------------------------------------------------------------------------------------------------+



void start()//                                                                                          |
    {//                                                                                                  |
    //+--------------------------------------------------------------------------------------------------+
    //|   Ichki sozlamalar                                                         |
    //+--------------------------------------------------------------------------------------------------+
    //|   Texnik ko'rsatgichlar sozlamasi                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double ADX0				=iADX(NULL,PERIOD_H4,7,PRICE_CLOSE,MODE_MAIN,0);
    double ADX1				=iADX(NULL,PERIOD_H4,7,PRICE_CLOSE,MODE_MAIN,1);
    double ADX2				=iADX(NULL,PERIOD_H4,7,PRICE_CLOSE,MODE_MAIN,2);
    double ADX3				=iADX(NULL,PERIOD_H4,7,PRICE_CLOSE,MODE_MAIN,3);
    double ATR				=iATR(NULL,PERIOD_H4,14,0);
    double Bands			=iBands(NULL,0,900,1.3,0,PRICE_CLOSE,MODE_MAIN,0);
    double BandsP			=iBands(NULL,0,900,1.3,0,PRICE_CLOSE,MODE_PLUSDI,0);
    double BandsM			=iBands(NULL,0,900,1.3,0,PRICE_CLOSE,MODE_MINUSDI,0);
    double Price=MarketInfo(Symbol(),MODE_BID); //iMA(NULL,0,1,0,0,0,0);
    int HP = TimeCurrent() - P;
    int HM = TimeCurrent() - M;
    string tex = "HP: " + IntegerToString(HP/3600) + " : HM: " + IntegerToString(HM/3600);
    double Lot = AccountBalance() / Lots;
    int SOAT = soat * 3600;
    //satr("0", tex, 250, 50, clrWhite);
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olishni aniqlash qismi                                                          |
    //+--------------------------------------------------------------------------------------------------+
    //Print(_Profit());
    satr("0", _Profit(), 250, 50, clrWhite);
    if (BandsP < Price) {P = TimeCurrent(); p = 1;}
    if (BandsM > Price) {M = TimeCurrent(); m = 1;}
    if (0 < OrdersTotal()) {
        if (OrderType() == OP_BUY) {
            if ((OrderOpenPrice() > Price && iHighest(NULL,0,MODE_HIGH,200,0) == 0) || p == 1) {
                ocb(1);
                }
            else if (modify == 0) {
                if (Bands > Price - 10 * Point && Bands < Price + 10 * Point) {
                    omb(BandsM + 100 * Point, 1); modify = 1;
                }
            }
        }
        else if (OrderType() == OP_SELL) {
            if ((OrderOpenPrice() < Price && iLowest(NULL,0,MODE_HIGH,200,0) == 0) || m == 1) {
                ocs(2);
            }
            else if (modify == 0) {
                if (Bands > Price - 10 * Point && Bands < Price + 10 * Point) {
                    oms(BandsP - 100 * Point, 2); modify = 1;
                }
            }
        }
    }
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    if (1 > OrdersTotal()) {
        if (ATR > ATR_min && ATR < ATR_max) {
            if (BandsM > Price && HP < SOAT && IsTradeAllowed() && !IsTradeContextBusy()) {modify = 0;
                if (!OrderSend(Symbol(), OP_BUY, Lot, Ask, Slippage, 0, 0, "NO savdo ", 1, 0, Aqua))
                    Print("OrderSend BUYda muammo: ", GetLastError());
            }
            else if (BandsP < Price && HM < SOAT && IsTradeAllowed() && !IsTradeContextBusy()) {modify = 0;
                if (!OrderSend(Symbol(), OP_SELL, Lot, Bid, Slippage, 0, 0, "NO savdo ", 2, 0, Red))
                    Print("OrderSend SELLda muammo: ", GetLastError());
            }
        }
    }
    p = 0;
    m = 0;
}
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
