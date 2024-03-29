//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO12.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double Lots = 0.01;//                                Savdo hajmi
extern int    Slippage=10;//                        Oraliq farq (spreed) o'zgarishi               |
extern int    MA=1000;//                            Moving Average Period                         |
extern int    Savdo_Orasi=100;//                            Savdolar orqasidagi qadamlar                  |
extern int    Savdo_Soni=30;//
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
    }
//+------------------------------------------------------------------------------------------------------+
int start()//                                                                                            |
    {//                                                                                                  |
    //+--------------------------------------------------------------------------------------------------+
    //|   Ichki sozlamalar                                                         |
    //+--------------------------------------------------------------------------------------------------+
    //|   Texnik ko'rsatgichlar sozlamasi                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double SMA=iMA(NULL,0,MA,0,0,0,0); //                 |
    double SMA1=iMA(NULL,0,MA,0,0,0,1); //                 |
    double narx=MarketInfo(Symbol(),MODE_BID); //iMA(NULL,0,1,0,0,0,0);
    double Lot = Lots;
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olishni aniqlash qismi                                                          |
    //+--------------------------------------------------------------------------------------------------+
    //Print(_Profit());
    //satr("0", _Profit(), 250, 50, clrGreen);
    if (0 < OrdersTotal()) {
        if (Count_Stop() == 0) {
            Lot = 0.05;
            if ((OrderType() == OP_BUY)) {
                for (int OSSL2 = Savdo_Orasi, c2 = 1; OSSL2 < Savdo_Orasi * Savdo_Soni * 3; OSSL2 += Savdo_Orasi, c2++)
                    {
                    if (c2 % 2 == 0)
                        Lot = Lot + 0.05;
                    if (!OrderSend(Symbol(), OP_BUYLIMIT, Lot, Bid - OSSL2 * Point, Slippage,
                        Bid - OSSL2 * Point + StopLoss * Point,
                        Bid - OSSL2 * Point - TakeProfit * Point,
                        "NO savdo ", c2, 0, Red))
                        Print("OrderSend OP_BUYSTOPda muammo: ", GetLastError());
                    }
                }
            else if (OrderType() == OP_SELL) {
                for (int OSBL2 = Savdo_Orasi, s2 = 1; OSBL2 < Savdo_Orasi * Savdo_Soni * 3; OSBL2 += Savdo_Orasi, s2++)
                    {
                    if (s2 % 2 == 0)
                        Lot = Lot + 0.05;
                    if (!OrderSend(Symbol(), OP_SELLLIMIT, Lot, Ask + OSBL2 * Point, Slippage,
                        Ask + OSBL2 * Point - StopLoss * Point,
                        Ask + OSBL2 * Point + TakeProfit * Point, "NO savdo ", s2, 0, Aqua))
                        Print("OrderSend OP_SELLSTOPda muammo: ", GetLastError());
                    }
                }
            }

        if ((SMA + 10 * Point > narx && narx > SMA - 10 * Point) || (SMA - 10 * Point > narx && narx > SMA + 10 * Point)){
            for (int cb = OrdersTotal(); cb >= 0; cb--){
                if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true){
                    if (OrderType() == OP_BUY){
                        if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Blue))
                            Print("OrderClose OP_BUYda muammo: ", GetLastError());
                        }
                    if (OrderType() == OP_BUYLIMIT){
                        if (!OrderDelete(OrderTicket()))
                            Print("OrderClose OP_BUYLIMITda muammo: ", GetLastError());
                        }
                    if (OrderType() == OP_SELL){
                        if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Red))
                            Print("OrderClose OP_SELLda muammo: ", GetLastError());
                        }
                    if (OrderType() == OP_SELLLIMIT){
                        if (!OrderDelete(OrderTicket()))
                            Print("OrderClose OP_SELLLIMITda muammo: ", GetLastError());
                        }
                    }
                }
            }
        return(0);}
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    else if (1 > OrdersTotal()){
        if ((SMA + 90 * Point < narx) && (SMA + 110 * Point > narx)){
            if (!OrderSend(Symbol(), OP_SELL, Lot, Bid, Slippage, 0, 0,
                "NO savdo ", 0, 0, Red))
                Print("OrderSend SELLda muammo: ", GetLastError());
            }
            if (OrdersTotal() == 1){
                for (int OSSL = Savdo_Orasi, c = 0; OSSL < Savdo_Orasi * Savdo_Soni; OSSL += Savdo_Orasi, c++)
                    {
                    if (c % 3 == 0)
                        Lot = Lot + 0.01;
                    if (!OrderSend(Symbol(), OP_SELLLIMIT, Lot, Bid + OSSL * Point, Slippage,
                        0, 0,"NO savdo ", c, 0, Red))
                        Print("OrderSend SELLLIMITda muammo: ", GetLastError());
                    }
                }
        else if ((SMA - 90 * Point > narx) && (SMA - 110 - Point < narx)){
            if (!OrderSend(Symbol(), OP_BUY, Lot, Ask, Slippage, 0, 0,
                "NO savdo ", 0, 0, Aqua))
                Print("OrderSend BUYda muammo: ", GetLastError());//
            }
            if (OrdersTotal() == 1){
                for (int OSBL = Savdo_Orasi, s = 0; OSBL < Savdo_Orasi * Savdo_Soni; OSBL += Savdo_Orasi, s++)
                    {
                    if (s % 3 == 0)
                        Lot = Lot + 0.01;
                    if (!OrderSend(Symbol(), OP_BUYLIMIT, Lot, Ask - OSBL * Point, Slippage,
                        0, 0, "NO savdo ", s, 0, Aqua))
                        Print("OrderSend BUYLIMITda muammo: ", GetLastError());
                    }
                return(0);}
            return(0);}
    return(0);}
                                                       // for (int cb = OrdersTotal(); cb >= 0; cb--){
                                             //for(int i=0;i<OrdersTotal();i++)

//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
