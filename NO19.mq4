//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO14.mq4  |
//|                                                     Strategiya muallifi: 𝓓𝓲𝓵𝓶𝓾𝓻𝓸𝓭 𝓠𝓪𝓵𝓪𝓷𝓭𝓪𝓻𝓸𝓿  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
//extern double Lot = 0.01;//                         Savdo hajmi
extern int    TakeProfit=1000;//                     Daromadni belgilash
extern int    StopLoss=10000;//                       Zararni cheklash
int           soat=99, soat3=99, soat4=99, close=99;
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
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

double Lots() {double b = AccountBalance(), l = 20000, r;
    r=b/l;
    if (AccountBalance()<200) r=0.01;
    return(r);}

int start()
    {double Lot = 0.01;
    double RSI=iRSI(NULL,0,14,PRICE_CLOSE,0);
    double TP = TakeProfit * Point;//                                   Foydani cheklash
    double SL = StopLoss * Point;//                                     Zararni cheklash
    int Highest = iHighest(NULL,0,MODE_HIGH,100,0);
    int Lowest = iLowest(NULL,0,MODE_LOW,100,0);
    if (1 > OrdersTotal()) {
        if ((Highest == 0 && RSI > 70) && (TimeHour(TimeCurrent()) != soat)) {
            soat3=TimeHour(TimeCurrent() + 3 * 3600); soat = TimeHour(TimeCurrent());
            soat4=TimeHour(TimeCurrent() + 10 * 3600);
            int buy = OrderSend(Symbol(), OP_BUY, Lot, Ask, 10, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Aqua);
            if (buy<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
        }
        /*if ((Lowest == 0 && RSI < 30) && (TimeHour(TimeCurrent()) != soat)) {
            soat3=TimeHour(TimeCurrent() + 3 * 3600); soat = TimeHour(TimeCurrent());
            soat4=TimeHour(TimeCurrent() + 10 * 3600);
            int sell = OrderSend(Symbol(), OP_SELL, Lot, Bid, 10, Bid + SL, Bid - TP, "NO savdo ", 0, 0, Red);
            if (sell<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
        }*/
    }
  if (OrdersTotal()>0){//satr("0", IntegerToString(OrderProfit()), 250, 50, clrWhite);
    for(int ii=0;ii<OrdersTotal();ii++){
       if (OrderSelect(ii,SELECT_BY_POS)==true){
          if (OrderSymbol()==Symbol()&&OrderType()==OP_BUY){
             if (soat3 <= TimeHour(TimeCurrent()) && OrderProfit() > 3) {close=1; }
             if (soat4 < TimeHour(TimeCurrent()) && iHighest(NULL,0,MODE_HIGH,500,0) == 0) {close=1;soat4=99;}
             if (close == 1) {close = 0;
             if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Green))
                    Print("OrderClose BUYda muammo: ",GetLastError());}
             }
          /*if (OrderSymbol()==Symbol()&&OrderType()==OP_SELL){
             if (soat3 <= TimeHour(TimeCurrent()) && OrderProfit() > 3) {close=1; }
             if (soat4 < TimeHour(TimeCurrent()) && iLowest(NULL,0,MODE_LOW,500,0) == 0) {close=1;soat4=99;}
             if (close == 1) {close = 0;
             if (!OrderClose(OrderTicket(),OrderLots(),Bid,10,Red))
                    Print("OrderClose SELLda muammo: ",GetLastError());}
             }*/
          }
       }
    }
    return(0);
    }
