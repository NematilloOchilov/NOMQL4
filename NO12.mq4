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
extern int       TakeProfit=30;//                     Daromadni belgilash                           |
extern int       StopLoss=300;//                      Zararni cheklash                              |
extern int       Slippage=10;//                        Oraliq farq (spreed) o'zgarishi               |
extern int       MA=1200;//                            Moving Average Period                         |
extern int       RSI=8;//                              RSI Period                                    |
extern int       Step=30;//                            Savdolar orqasidagi qadamlar                  |
//+--------------------------------------------------------------------------------------------------+
//|   Ochiq savdo miqdorlarini aniqlash funksiyalari                                                 |
//+--------------------------------------------------------------------------------------------------+
int Count_Buy()
    {
    int count_buy_orders = 0;
    int oob = 0;
    for(int i = 0; i < OrdersTotal(); i++)
        {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            return(0);
        if (OrderType() == OP_BUY)
            count_buy_orders++;
            oob++;
        if (OrderType() == OP_BUYLIMIT)
            count_buy_orders++;
        }
    int cbo[2];
    cbo[0] = count_buy_orders;
    cbo[1] = oob;
    return(cbo);
    }

int Count_Sell()
    {
    int oos = 0;
    int count_sell_orders = 0;
    for (int i = 0; i < OrdersTotal(); i++)
        {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            return(0);
        if (OrderType() == OP_SELL)
            count_sell_orders++;
            oos++;
        if (OrderType() == OP_SELLLIMIT)
            count_sell_orders++;
        }
    int cso[2] = {count_sell_orders, oos};
    return (cso);
    }

double Lot(double Lots)
    {
    /*if (Lots == 0.01)
        Lots = 0.02;
    if (OrdersTotal() > 1)
        Lots = 2 * OrderLots();
    if (Lots > 10)
        Lots = 10;*/
    return (0.01);
    }


void satr(string text, uint x, uint y, color rang)
    {
    long chart_ID=0;//ChartID();
    string obj_name="Text: "+IntegerToString(y);
    if (ObjectsTotal() < 1)
        {
        if (ObjectCreate(obj_name,OBJ_LABEL,0,0,0))
            {
            ObjectSetInteger(chart_ID,obj_name,OBJPROP_COLOR,rang);
            ObjectSetString(chart_ID,obj_name,OBJPROP_TEXT,text);
            ObjectSet(chart_ID,OBJPROP_XDISTANCE,x);
            ObjectSet(chart_ID,OBJPROP_YDISTANCE,y);
            ChartRedraw(chart_ID);
            }
        else
            {
            Print("Error: can't create label! code #",GetLastError());
            }
        }
    else
        {
        if(!ObjectSetString(chart_ID,obj_name,OBJPROP_TEXT,text))
            {
                Print(__FUNCTION__, ": failed to change the text! Error code = ",GetLastError());
            }
        }
    }


//+------------------------------------------------------------------------------------------------------+
int start()//                                                                                            |
    {//                                                                                                  |
    //+--------------------------------------------------------------------------------------------------+
    //|   Ichki sozlamalar                                                         |
    //+--------------------------------------------------------------------------------------------------+
    //|   Texnik ko'rsatgichlar sozlamasi                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double RSI0=iRSI(NULL,0,RSI,PRICE_CLOSE,0);//                                                |
    double RSI1=iRSI(NULL,0,RSI,PRICE_OPEN,1);//                                  |
    double RSI2=iRSI(NULL,0,RSI,PRICE_OPEN,2);//                                  |
    bool RSI_BUY_CLOSE = RSI1 > 75;//RSI2 < RSI1 && RSI1 > RSI0 &&
    bool RSI_SELL_CLOSE = RSI1 < 25;//RSI2 > RSI1 && RSI1 < RSI0 &&
    double SMA=iMA(NULL,0,MA,0,0,0,0); //                 |
    double AC=iAC(NULL,0,2);
    double BandsU=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_UPPER,0);
    double BandsL=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_LOWER,0);
    bool Bands = BandsU - BandsL < 0.0025;
    //+--------------------------------------------------------------------------------------------------+
    //|                                                        |
    //+--------------------------------------------------------------------------------------------------+
    double Lots = 0.01;//                                Savdo hajmi
    double TP = TakeProfit * Point;//                   Foydani cheklash                                 |
    double SL = StopLoss * Point;//                     Zararni cheklash                                 |
    double price=MarketInfo(Symbol(),MODE_BID); //        Hozirgi narx
    bool OpenBuy = false, OpenSell = false;
    int CB = Count_Buy();
    int CS = Count_Sell();
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotib olingan tovar haqida ma'lumotlarni saqlash                                                     |
    //+--------------------------------------------------------------------------------------------------+

    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olishni aniqlash qismi                                                          |
    //+--------------------------------------------------------------------------------------------------+
    /*satr(
        "Ticket: " + IntegerToString(BuyHistory[CB][0]) +
        "  OpenPrice: " + DoubleToString(BuyHistory[CB][1]) +
        "  Lots: " + DoubleToString(BuyHistory[CB][2]) +
        //"  OrderType: " + IntegerToString(BuyHistory[CB][3]) +
        //"  OrderMagicNumber: " + IntegerToString(BuyHistory[CB][4]) +
        //"  OrderStopLoss: " + IntegerToString(BuyHistory[CB][5]) +
        //"  OrderTakeProfit: " + IntegerToString(BuyHistory[CB][6]) +
        "  Profit: " + DoubleToString(BuyHistory[CB][7]),
        250,
        1,
        clrWhite);*/
    if (CB == 0 && 0 == CS)
        {
         OpenBuy = RSI2 > 79 && RSI1 < 79 && SMA < price && AC < 0.0005;
         OpenSell = RSI2 < 21 && RSI1 > 21 && SMA > price && AC > -0.0005;
        }
    if (CB > 0 && RSI_BUY_CLOSE)//BuyHistory[CB][7] / (BuyHistory[CB][2]*10) > Step / 5 &&
        {
        for( int cb = 0 ; cb < OrdersTotal() ; cb++ )
            {
            if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES ) == true)
                {
                if (OrderType() == OP_BUY)
                    {
                    if (!OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Aqua))
                        Print("OrderClose da muammo: ", GetLastError());
                    }
                if (OrderType() == OP_BUYLIMIT)
                    {
                    if (!OrderDelete(OrderTicket()))
                        Print("OrderClose da muammo: ", GetLastError());
                    }
                }
            }
        }
    if (CS > 0 && RSI_SELL_CLOSE) //SellHistory[CS][7] / (SellHistory[CS][2]*10) > Step / 5 &&
        {
        for( int cs = 0 ; cs < OrdersTotal() ; cs++ )
            {
            if (OrderSelect(cs, SELECT_BY_POS, MODE_TRADES ) == true)
                {
                if (OrderType() == OP_SELL)
                    {
                    if (!OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Aqua))
                        Print("OrderClose da muammo: ", GetLastError());
                    }
                if (OrderType() == OP_SELLLIMIT)
                    {
                    if (!OrderDelete(OrderTicket()))
                        Print("OrderClose da muammo: ", GetLastError());
                    }
                }
            }
        }
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotish yoki sotib olish                                                          |
    //+--------------------------------------------------------------------------------------------------+
    if (OpenBuy)
        {
        if (!OrderSend(Symbol(), OP_BUY, Lot(Lots), Ask, Slippage, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Blue))
            Print("OrderSend BUYda muammo: ", GetLastError());//
        }
        if (OrdersTotal() == 1)
            {
            for (int OSBL = 30; OSBL < 300; OSBL += 30)
                {Lots *= 2;
                if (!OrderSend(Symbol(), OP_BUYLIMIT, Lots, Ask - OSBL * Point, Slippage,
                    Ask - (StopLoss + OSBL) * Point, Ask - (OSBL - TakeProfit) * Point, "NO savdo ", 0, 0, Blue))
                    Print("OrderSend BUYLIMITda muammo: ", GetLastError());//
                }
            }
    if (OpenSell)
        {
        if (!OrderSend(Symbol(), OP_SELL, Lot(Lots), Bid, Slippage, Bid + SL, Bid - TP,"NO savdo ", 0, 0, Red))
            Print("OrderSend SELLda muammo: ", GetLastError());//
        }
        if (OrdersTotal() == 1)
            {
            for (int OSSL = 30; OSSL < 300; OSSL += 30)
                {Lots *= 2;
                if (!OrderSend(Symbol(), OP_SELLLIMIT, Lots, Bid + OSSL * Point, Slippage,
                    Bid + (StopLoss + OSSL) * Point, Bid + (OSSL - TakeProfit) * Point, "NO savdo ", 0, 0, Red))
                    Print("OrderSend SELLLIMITda muammo: ", GetLastError());//
                }
            }
    return(0);//                                                                                     |
    }//                                                                                              |
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
