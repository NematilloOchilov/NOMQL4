//+--------------------------------------------------------------------------------------------------+
//|                                                                       Djamolliddin Boltayev.mq4  |
//|                                                      Strategiya muallifi: Djamolliddin Boltayev  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Hajm, vaqt, savdo raqami, foyda va zararni cheklash miqdori.                                   |
//+--------------------------------------------------------------------------------------------------+
//extern double    Lots=0.1;
extern int       TakeProfit=100;//                     Daromadni belgilash                           |
extern int       StopLoss=200;//                       Zararni cheklash                              |
extern int       MagicNumber=0;//                      Savdo raqami                                  |
//+--------------------------------------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------+
//|   Oynada dastur ishga tushgani haqida bildirishnoma paydo bo'ladi                                |
//+--------------------------------------------------------------------------------------------------+
int init()//                                                                                         |
  {//                                                                                                |
   Alert("Nematillo Ochilov tomonidan yaratilgan robot ishga tushmoqda");//                          |
   return(0);//                                                                                      |
  }//                                                                                                |
//+--------------------------------------------------------------------------------------------------+
//|   Dasturning asosiy sozlamalari start() maxsus funksiyasi ichida bajariladi.                     |
//+--------------------------------------------------------------------------------------------------+
int start()//                                                                                        |
  {   //                                                                                             |
//+--------------------------------------------------------------------------------------------------+
//|   NormalizeDouble - haqiqiy sonlarni belgilangan aniqlikka yaxlitlash.                           |
//|   Digits - kasrdan keyingi raqamlar sonini qaytaradi.                                            |
//+--------------------------------------------------------------------------------------------------+
  //Print(AccountBalance());
  double Lots=0.01;
  //if (AccountBalance() > 500) {Lots=AccountBalance() / 2000;}
  double TP=NormalizeDouble(TakeProfit,Digits);//                                                    |
  double SL=NormalizeDouble(StopLoss,Digits);//                                                      |
//+--------------------------------------------------------------------------------------------------+
//|   Foyda va zararni cheklash sozlamalari                                                          |
//+--------------------------------------------------------------------------------------------------+
  double slb=NormalizeDouble(Ask-SL*Point,Digits);//                                                 |
  double sls=NormalizeDouble(Bid+SL*Point,Digits);//                                                 |
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);//                                                 |
  double tps=NormalizeDouble(Bid-TP*Point,Digits);//                                                 |
  double tslb=NormalizeDouble(OrderStopLoss()+400*Point,Digits);//                                   |
  double tsls=NormalizeDouble(OrderStopLoss()-400*Point,Digits);//                                   |

  double narx=MarketInfo(Symbol(),MODE_BID); // hozirgi narx                                         |
  //double EMA_62=iMA(NULL,0,62,190,1,0,0); //                 |
  //double WPR0=iWPR(NULL,0,1200,0);
  //double WPR1=iWPR(NULL,0,1200,1);
  //double MACD_SIGNAL60=iMACD(NULL,0,62,190,9,PRICE_CLOSE,MODE_SIGNAL,0);//                   |
  //double MACD_SIGNAL=iMACD(NULL,0,62,190,9,PRICE_CLOSE,MODE_SIGNAL,0);//                    |
  //double RSI0=iRSI(NULL,0,14,PRICE_OPEN,0);//                                                |
  //double RSI1=iRSI(NULL,0,14,PRICE_CLOSE,1);//                                              |
  //double RSI2=iRSI(NULL,0,14,PRICE_CLOSE,2);//                                              |
  //double Stochastic=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);//                      |
//+--------------------------------------------------------------------------------------------------+
//|   Izoh                                                                                           |
//+--------------------------------------------------------------------------------------------------+
  Comment("Ushbu robotni katta real balansda sinab ko'rmang");//                                     |
//+--------------------------------------------------------------------------------------------------+
//|   Zararni kamaytirish qismi                                                                      |
//+--------------------------------------------------------------------------------------------------+
//+--------------------------------------------------------------------------------------------------+
//|   Savdoni ochish, foyda va zararni cheklash qismi                                                |
//+--------------------------------------------------------------------------------------------------+
   //Print(iOpen(Symbol(), 0, 12));
            //Print(High[iHighest(Symbol(), 0, MODE_HIGH, 12, 0)] + NormalizeDouble(0.0010,Digits));
         //Print(Low[iLowest (Symbol(), 0, MODE_LOW, 12, 0)] - NormalizeDouble(0.0012,Digits));
   int hl = 0;
   int day = 0;
   //double buy;
   //double sell;
   int th = TimeHour(TimeCurrent());
   //Print("TimeHour ", TimeHour(TimeCurrent()));
   if (OrdersTotal() < 1)
     {//Print("1 ", hl);
      if (TimeHour(TimeCurrent()) == 2 && hl == 0 && day != TimeDay(TimeCurrent())) //  && day != TimeDay(TimeCurrent())
        {//Print("2 ", hl);
         double buy = High[iHighest(Symbol(), 0, MODE_HIGH, 13, 1)];// + NormalizeDouble(0.0002,Digits)
         double sell = Low[iLowest (Symbol(), 0, MODE_LOW, 13, 1)];//
         hl = 1;
         //Print("buy ", buy);Print("sell ", sell);Print("narx ", narx);Print("hl ", hl);
        }
      if (hl == 1 && day != TimeDay(TimeCurrent()))
        {
         //double obuy = High[iHighest(Symbol(), 0, MODE_HIGH, 1, 0)];// + NormalizeDouble(0.0010,Digits)
         //double osell = Low[iLowest (Symbol(), 0, MODE_LOW, 1, 0)];// - NormalizeDouble(0.0010,Digits)
         if (buy < narx)
           {day = TimeDay(TimeCurrent());hl = 0;
            if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,slb,tpb,"NO savdo ",MagicNumber,0,Blue))
              Print("OrderSend BUYda muammo: ", GetLastError());
           }
         if (sell > narx)
           {day = TimeDay(TimeCurrent());hl = 0;
            if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,sls,tps,"NO savdo ",MagicNumber,0,Red))
              Print("OrderSend SELLda muammo: ", GetLastError());
           }
        }
     }

  //Print(iHighest(Symbol(), 0, MODE_HIGH, 10, 1));
  /*if (Volume[0] == 1)//                                                                           |
    {//Print(iRSIOnArray(ExtBuffer,1000,14,0));//                                                                                              |
     if (EMA_10_2 < EMA_50_2 && EMA_10_1 > EMA_50_1)//|
       {//                                                                                           |
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,slb,tpb,"NO savdo ",MagicNumber,0,Blue))//         |
          Print("OrderSend BUYda muammo: ", GetLastError());//                                       |
       }
     if (EMA_10_2 > EMA_50_2 && EMA_10_1 < EMA_50_1)//|
       {//                                                                                           |
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,sls,tps,"NO savdo ",MagicNumber,0,Red))//         |
          Print("OrderSend SELLda muammo: ", GetLastError());//                                      |
       }//                                                                                           |
    }//                                                                                              |
  if (OrdersTotal()>0)
    {//
     for(int i=0;i<OrdersTotal();i++)
      {
       if (OrderSelect(i,SELECT_BY_POS)==true)
         {
          if (OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            {
             if (OrderType()==OP_BUY)
               {
                if ((WPR0 < -20) && (WPR1 > -20))
                  {
                  if (!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
                    Print("OrderClose BUYda muammo: ",GetLastError());
                  }
               }
             if (OrderType()==OP_SELL)
               {
                if ((WPR0 > -80) && (WPR1 < -80))
                  {
                   if (!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                     Print("OrderClose SELLda muammo: ",GetLastError());
                  }
               }
            }
         }
       }
    }*/
  return(0);//                                                                                       |
  }//                                                                                                |
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
