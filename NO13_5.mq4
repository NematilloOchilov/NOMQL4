//+--------------------------------------------------------------------------------------------------+
//|                                                                                      NO13_1.mq4  |
//|                                                                       Strategiya muallifi: ....  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double Lots = 0.1;//                                Savdo hajmi
extern int    Slippage=10;//                        Oraliq farq (spreed) o'zgarishi               |
extern int    MA=500;//                            Moving Average Period                         |
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

int Count_Stop() {
    int u = 0;
    for(int i=0; i<OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES ) == true) {
            if ((OrderType() == OP_BUYLIMIT) || (OrderType() == OP_SELLLIMIT)) {u = 1; break;}
            }
        }
    return(u);}

void satr(string _name, string text, uint x, uint y, color rang){
    long chart_ID = ChartID();
    //string _name = IntegerToString(chart_ID);
    ObjectCreate(chart_ID,_name,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chart_ID,_name,OBJPROP_COLOR,rang);
    ObjectSetString(chart_ID,_name,OBJPROP_TEXT,text);
    ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
    ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
    ChartRedraw(chart_ID);
    Sleep(600);
    }


double OOP;
//+------------------------------------------------------------------------------------------------------+
int start()//                                                                                            |
    {//                                                                                                  |
    //+--------------------------------------------------------------------------------------------------+
    //|   Ichki sozlamalar                                                         |
    //+--------------------------------------------------------------------------------------------------+
    //|   Texnik ko'rsatgichlar sozlamasi                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double SMA=iMA(NULL,0,MA,0,0,0,0); //                 |
    double MACD0=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);//                    |
    double MACD1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);//                    |
    double narx=MarketInfo(Symbol(),MODE_BID); //iMA(NULL,0,1,0,0,0,0);
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olishni aniqlash qismi                                                          |
    //+--------------------------------------------------------------------------------------------------+
    //Print(_Profit());
    satr("0", DoubleToString(Lots), 250, 50, clrWhite);
    if (0 < OrdersTotal()) {
        if (AccountFreeMargin() > AccountBalance()*0.5){
            if ((SMA > narx) && (OOP > narx)) {
                if (Lots == 0.01) Lots=0.01; else Lots-=0.01;
                int ticket_s = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "NO savdo ", 0, 0, Red);
                if (ticket_s < 0) {Print("OrderSend SELLda muammo: ", GetLastError());}
                else {OOP -= 100 * Point;}
                }
            else if ((SMA < narx) && (OOP < narx)) {
                if (Lots == 0.01) Lots=0.01; else Lots-=0.01;
                int ticket_b = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "NO savdo ", 0, 0, Aqua);
                if (ticket_b < 0) {Print("OrderSend BUYda muammo: ", GetLastError());}
                else {OOP += 100 * Point;}
                }
            }
        if ((SMA + 10 * Point > narx && narx > SMA - 10 * Point) ||
            (SMA - 10 * Point > narx && narx > SMA + 10 * Point) ||
            (MACD0 > 0 && 0 < MACD1)
            ){
            for (int cb = OrdersTotal(); cb >= 0; cb--){
                if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
                    if (OrderType() == OP_BUY){
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());
                        }
                    if (OrderType() == OP_SELL){
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red))
                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
                        }
                    }
                }
            }
        return(0);}
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    else if (1 > OrdersTotal()) {Lots=0.10;
        if ((SMA > narx + 90 * Point) && (SMA < narx + 110 - Point)) {
            OOP = Bid - 100 * Point;
            if (!OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "NO savdo ", 77777, 0, Aqua))
                Print("OrderSend BUYda muammo: ", GetLastError());
            }
        else if ((SMA < narx - 90 * Point) && (SMA > narx - 110 * Point)) {
            OOP = Ask + 100 * Point;
            if (!OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "NO savdo ", 77777, 0, Red))
                Print("OrderSend SELLda muammo: ", GetLastError());
            }
        }
    return(0);}
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
