//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO21.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern int    TakeProfit=10000;//                     Daromadni belgilash
extern int    StopLoss=500;//                       Zararni cheklash
int day = 0, mod = 0;
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
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
    }

double Lots() {double b = AccountBalance(), l = 100000, r=b/l;
    if (AccountBalance()<1000) r=0.01;
    return(r);}

double OOP;
int start() {
    satr("0", _Profit(), 250, 50, clrWhite);
    double narx=MarketInfo(Symbol(),MODE_ASK);
    double BTP = Ask + TakeProfit * Point, BSL = Ask - StopLoss * Point;
    double STP = Bid - TakeProfit * Point, SSL = Bid + StopLoss * Point;
    //double BTP = Ask + TakeProfit * Point, BSL = iLow(Symbol(),PERIOD_D1,1);
    //double STP = Bid - TakeProfit * Point, SSL = iHigh(Symbol(),PERIOD_D1,1);
    //double SMA240=iMA(NULL,PERIOD_H4,5,0,0,0,0);
    bool buy = iHigh(Symbol(),PERIOD_D1,1) + 150 * Point < Ask;
    bool sell = iLow(Symbol(),PERIOD_D1,1) + 150 * Point > Bid;
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    if (OrdersTotal()>0) {
        for(int i=0;i<OrdersTotal();i++) {
            if (OrderSelect(i,SELECT_BY_POS)==true) {
                double msl = 0;
                if (OrderType() == OP_BUY && (OrderStopLoss() + 2000 * Point) < Ask) msl = OrderStopLoss() + 1000 * Point;
                if (OrderType() == OP_SELL && (OrderStopLoss() - 2000 * Point) > Bid) msl = OrderStopLoss() - 1000 * Point;
                if (msl != 0) {mod = 0;
                    if (!OrderModify(OrderTicket(),OrderOpenPrice(),msl,OrderTakeProfit(),0,Orange))
                        Print("OrderModifyda muammo: ",GetLastError());
                    }
                }
            }
        }
    else if (TimeHour(TimeCurrent()) == 1) {
        if (OrdersTotal() < 1 && TimeDay(TimeCurrent()) != day) {mod = 1;
            if (buy) {
                day = TimeDay(TimeCurrent());
                if (!OrderSend(Symbol(), OP_BUY, Lots(), Ask, 30, BSL, BTP, "NO savdo ", 0, 0, Blue))
                    Print("OrderSend BUYda muammo: ", GetLastError());
            }
            if (sell) {
                day = TimeDay(TimeCurrent());
                if (!OrderSend(Symbol(), OP_SELL, Lots(), Bid, 30, SSL, STP, "NO savdo ", 0, 0, Red))
                    Print("OrderSend SELLda muammo: ", GetLastError());
            }
        }
    }

    return(0);}
