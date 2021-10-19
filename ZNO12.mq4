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
    for(int i = 0; i < OrdersTotal(); i++)
        {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT)
        count_buy_orders++;
        }
    return(count_buy_orders);
    }

int Count_Sell()
    {
    int count_sell_orders = 0;
    for (int i = 0; i < OrdersTotal(); i++)
        {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT)
            count_sell_orders++;
        }
    return (count_sell_orders);
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
    //+--------------------------------------------------------------------------------------------------+
    //|   Texnik ko'rsatgichlar sozlamasi                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double RSI0=iRSI(NULL,0,RSI,PRICE_CLOSE,0);//                                                |
    double RSI1=iRSI(NULL,0,RSI,PRICE_OPEN,1);//                                  |
    double RSI2=iRSI(NULL,0,RSI,PRICE_OPEN,2);//                                  |
    bool RSI_BUY_CLOSE = RSI1 > 79;//RSI2 < RSI1 && RSI1 > RSI0 &&
    bool RSI_SELL_CLOSE = RSI1 < 21;//RSI2 > RSI1 && RSI1 < RSI0 &&
    double SMA=iMA(NULL,0,MA,0,0,0,0); //                 |
    double AC=iAC(NULL,0,0);
    double BandsU=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_UPPER,0);
    double BandsL=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_LOWER,0);
    //Print("BandsU ", BandsU);
    //Print("BandsL ", BandsL);
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
    double BuyHistory[11][8];
    ArrayResize(BuyHistory,CB + 1);
    ArrayInitialize(BuyHistory, 0.0);
    int NumberBuy = 0;
    for(int BH = 0; BH < OrdersTotal(); BH++)
        {
        if (OrderSelect(BH, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderSymbol() == Symbol())
            {
            NumberBuy++;
            if (OrderType() == OP_BUYLIMIT)
                {
                BuyHistory[NumberBuy][0] = OrderTicket();
                BuyHistory[NumberBuy][3] = OrderType();
                }
            if (OrderType() == OP_BUY)
                {
                BuyHistory[NumberBuy][0] = OrderTicket();
                BuyHistory[NumberBuy][1] = OrderOpenPrice();
                BuyHistory[NumberBuy][2] = OrderLots();
                BuyHistory[NumberBuy][3] = OrderType();
                BuyHistory[NumberBuy][4] = OrderMagicNumber();
                BuyHistory[NumberBuy][5] = OrderStopLoss();
                BuyHistory[NumberBuy][6] = OrderTakeProfit();
                BuyHistory[NumberBuy][7] = OrderProfit();
                }
            }
        }
    //+--------------------------------------------------------------------------------------------------+
    //|   Sotilgan tovar haqida ma'lumotlarni saqlash                                                     |
    //+--------------------------------------------------------------------------------------------------+
    double SellHistory[11][8];
    ArrayResize(SellHistory, CS + 1);
    ArrayInitialize(SellHistory, 0.0);
    int NumberSell = 0;
    for(int SH = 0; SH < OrdersTotal(); SH++)
        {
        if (OrderSelect(SH, SELECT_BY_POS, MODE_TRADES) == false)
            break;
        if (OrderSymbol() == Symbol())
            {
            NumberSell++;
            if (OrderType() == OP_SELLLIMIT)
                {
                SellHistory[NumberSell][0] = OrderTicket();
                SellHistory[NumberSell][3] = OrderType();
                }
            if (OrderType() == OP_SELL)
                {
                SellHistory[NumberSell][0] = OrderTicket();
                SellHistory[NumberSell][1] = OrderOpenPrice();
                SellHistory[NumberSell][2] = OrderLots();
                SellHistory[NumberSell][3] = OrderType();
                SellHistory[NumberSell][4] = OrderMagicNumber();
                SellHistory[NumberSell][5] = OrderStopLoss();
                SellHistory[NumberSell][6] = OrderTakeProfit();
                SellHistory[NumberSell][7] = OrderProfit()
                }
            }
        }
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
    if (OrdersTotal() < 1)
        {
         OpenBuy = (RSI1 > 79) && (RSI0 < 79) && SMA < price && AC < 0.0005;
         OpenSell = (RSI1 < 21) && (RSI0 > 21) && SMA > price && AC > -0.0005;
        }
    if (CB > 0)
        {
        //OpenBuy = BuyHistory[CB][1] - Step * Point > Ask && AccountFreeMargin() > AccountBalance() * 0.5;
        //&& Bands && SMA < price && -0.0002 < AC && AC < 0.0002;
        if (RSI_BUY_CLOSE)//BuyHistory[CB][7] / (BuyHistory[CB][2]*10) > Step / 5 &&
            {
            for (int OCB = 0; OCB < CB; OCB++)
                {Print("tttttttttttt", OrderType());Print("bbbbbbbbbbb", SellHistory[OCB][0]);
                if (OrderType() == OP_BUYLIMIT)
                    {
                    if (!OrderDelete(BuyHistory[OCB][0]))
                        Print("OrderDelete BUYLIMITda muammo: ",GetLastError());
                    }
                else
                    {
                    if (!OrderClose(BuyHistory[OCB][0],BuyHistory[OCB][2],Bid,Slippage,Aqua))
                        Print("OrderClose BUYda muammo: ",GetLastError());
                    }
                }
            }
        }
    if (CS > 0)
        {
        //OpenSell = SellHistory[CS][1] + Step * Point < Bid && AccountFreeMargin() > AccountBalance() * 0.5;
        //&& Bands && SMA > price && -0.0002 < AC && AC < 0.0002;
        if (RSI_SELL_CLOSE)//SellHistory[CS][7] / (SellHistory[CS][2]*10) > Step / 5 &&
            {
            for (int OCS = 0; OCS < CS; OCS++)
                {Print("tttttttttttt", OrderType());Print("ssssssssss", SellHistory[OCS][0]);
                if (OrderType() == OP_SELLLIMIT)
                    {
                    if (!OrderDelete(SellHistory[OCS][0]))
                        Print("OrderDelete SELLLIMITda muammo: ",GetLastError());
                    }
                else
                    {
                    if (!OrderClose(SellHistory[OCS][0],SellHistory[OCS][2],Ask,Slippage,Red))
                        Print("OrderClose SELLda muammo: ",GetLastError());
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
