extern double    Lots=0.01;
extern int       TakeProfit=3000;
extern int       StopLoss=3000;
extern int       MagicNumber=0;
double buy = Ask;
double sell = Bid;
void satr(string _name, string text, uint x, uint y, color rang) {
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
    {
    //double MACD_SIGNAL=iMACD(NULL,0,190,62,9,PRICE_CLOSE,MODE_SIGNAL,0);//                    |
    double MA=iMA(NULL,0,190,62,0,0,0); //                 |
    double WPR=iWPR(NULL,0,50,0);
    double FractalsU = iFractals(NULL,0,MODE_UPPER,2);
    double FractalsU1 = iFractals(NULL,0,MODE_UPPER,3);
    double FractalsL = iFractals(NULL,0,MODE_LOWER,2);
    double FractalsL1 = iFractals(NULL,0,MODE_LOWER,3);
    double TP = TakeProfit * Point;
    double SL = StopLoss * Point;
    //double Fractals = iFractals(NULL,0,MODE_LOWER,1);
    //if (Fractals != 0) {satr("0", DoubleToString(Fractals), 250, 50, clrWhite);Sleep(10000);}
    if (FractalsL != 0 ) {
         if (OrdersTotal() < 15 && MA < Ask && Ask > buy) {buy = Ask + 100 * Point;sell = Bid - 100 * Point;
            if (!OrderSend(Symbol(), OP_BUY, Lots, Ask, 10, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Blue))
                Print("OrderSend BUYda muammo: ", GetLastError());
        }
        else if (OrdersTotal() > 0 && WPR < -90) {
            for (int cs = OrdersTotal(); cs >= 0; cs--) {
                if (OrderSelect(cs, SELECT_BY_POS, MODE_TRADES ) == true) {
                    if (OrderType() == OP_SELL) {// && OrderProfit() > 1
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,10,CLR_NONE ))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());}
                    }
                }
            }
        }
    if (FractalsU != 0 ) {
        if (OrdersTotal() < 15 && MA > Bid && Bid < sell) {sell = Bid - 100 * Point;buy = Ask + 100 * Point;
                if (!OrderSend(Symbol(), OP_SELL, Lots, Bid, 10, Bid + SL, Bid - TP, "NO savdo ", 0, 0, Red))
            Print("OrderSend SELLda muammo: ", GetLastError());
        }
        else if (OrdersTotal() > 0 && WPR > -10) {
            for (int cb = OrdersTotal(); cb >= 0; cb--) {
                if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true) {
                    if (OrderType() == OP_BUY) {//buy = Ask + 100 * Point;
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,CLR_NONE ))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());}
                    }
                }
            }
        }

return(0);}