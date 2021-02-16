extern double    Lots=0.01;
extern int       TakeProfit=3000;
extern int       StopLoss=200;
extern int       MagicNumber=0;
int th;
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
int start()
    {double TP = TakeProfit * Point;
    double SL = StopLoss * Point;
    satr("0", IntegerToString(OrderProfit()), 250, 50, clrWhite);
    if (th != TimeHour(TimeCurrent()) && OrdersTotal() < 1) {
        int buy = 0;
        int sell = 0;
        for(int i=1; i<5; i++) {//Print(i);
            buy += int (iClose(Symbol(), 0, i - 1) < iClose(Symbol(), 0, i)) +
            int (iOpen(Symbol(), 0, i - 1) < iOpen(Symbol(), 0, i));
            sell += int (iClose(Symbol(), 0, i - 1) > iClose(Symbol(), 0, i)) +
            int (iOpen(Symbol(), 0, i - 1) > iOpen(Symbol(), 0, i));}
        //satr("0", IntegerToString(buy) + " " + IntegerToString(sell), 250, 50, clrWhite);
        if ((buy > 7) && (iClose(Symbol(), 0, 1) < iOpen(Symbol(), 0, 0))) {th = TimeHour(TimeCurrent());// && iOpen(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)
            if (!OrderSend(Symbol(), OP_BUY, Lots, Ask, 10, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Blue))
                Print("OrderSend BUYda muammo: ", GetLastError());}
        if ((sell > 7) && (iClose(Symbol(), 0, 1) > iOpen(Symbol(), 0, 0))) {th = TimeHour(TimeCurrent());
            if (!OrderSend(Symbol(), OP_SELL, Lots, Bid, 10, Bid + SL, Bid - TP, "NO savdo ", 0, 0, Red))
                Print("OrderSend SELLda muammo: ", GetLastError());}}

    else if (OrdersTotal() > 0){
        for (int cb = OrdersTotal(); cb >= 0; cb--){
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
                if (OrderType() == OP_BUY && OrderProfit() > 0.5){
                    if (iClose(Symbol(), 0, 0) < iClose(Symbol(), 0, 1)) {
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,CLR_NONE ))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());}
                    }
                if (OrderType() == OP_SELL && OrderProfit() > 0.5){
                    if (iClose(Symbol(), 0, 0) > iClose(Symbol(), 0, 1)){
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,CLR_NONE ))
                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
                    }
                }
            }
        }
    }
return(0);}