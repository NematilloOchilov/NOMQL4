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
double buy;
double sell;
int hl = 0;
int start()//                                                                                        |
  {   //                                                                                             |
//+--------------------------------------------------------------------------------------------------+
//|   NormalizeDouble - haqiqiy sonlarni belgilangan aniqlikka yaxlitlash.                           |
//|   Digits - kasrdan keyingi raqamlar sonini qaytaradi.                                            |
//+--------------------------------------------------------------------------------------------------+
  //Print(AccountBalance());
  double Lots=0.01;
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
   int day = 0;// && day != TimeDay(TimeCurrent())
   int th = TimeHour(TimeCurrent());
   if (hl == 0 && TimeHour(TimeCurrent()) == 2 && TimeMinute(TimeCurrent()) == 5 && OrdersTotal() < 1)
        {
         buy = High[iHighest(Symbol(), 0, MODE_HIGH, 13, 1)];// + NormalizeDouble(0.0002,Digits)
         sell = Low[iLowest (Symbol(), 0, MODE_LOW, 13, 1)];//
         hl = 1;
        }
   if (hl == 1)
    {
     if (buy < iLow(Symbol(),0,0))
       {hl = 0;
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,slb,tpb,"NO savdo ",0,0,Blue))
          Print("OrderSend BUYda muammo: ", GetLastError());
       }
     if (sell > iHigh(Symbol(),0,0))
       {hl = 0;
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,sls,tps,"NO savdo ",0,0,Red))
          Print("OrderSend SELLda muammo: ", GetLastError());
       }
    }

  return(0);//                                                                                       |
  }//                                                                                                |
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
