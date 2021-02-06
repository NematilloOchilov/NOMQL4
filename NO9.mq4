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
extern int       TakeProfit=1500;//                     Daromadni belgilash                           |
extern int       StopLoss=500;//                       Zararni cheklash                              |
extern int       MagicNumber=0;//                      Savdo raqami                                  |
//+--------------------------------------------------------------------------------------------------+
//|   Moving Everage texnik ko'rsatgichining sozlamalari                                             |
//+--------------------------------------------------------------------------------------------------+
extern int       Ma10Period=10;                                                                    
extern int       Ma50Period=50;
extern int       Ma100Period=1200;
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
//+--------------------------------------------------------------------------------------------------+
//|   Texnik ko'rsatgichlarning sozlamalari                                                          |
//|   Ushbu veb sahifa(https://docs.mql4.com/indicators)da texnik ko'rsatgichlarning qanday sozlash  |
//|   kerakligi haqida ko'rsatilgan.Moving Everage texnik ko'rsatgichidan MQL4 dasturlash tilida     |
//|   qanday foydalanishni ko'rib chiqamiz.                                                          |
//|   symbol - Valyuta jufligi nomi yoziladi (EURUSD yoki GBPUSD).Dastur oynadagi valyuta juftligida |
//|   savdo qilishi uchun NULL yozish kifoya.                                                        |
//|   timeframe - Savdo qilish vaqtiga daqiqalar(1, 5, 15, 60, 240,1440,10080, 43200)ni tanlash      |
//|   yoki oynadagi vaqtni tanlsh uchun 0 yoziladi.                                                  |
//|   https://docs.mql4.com/constants/chartconstants/enum_timeframes                                 |
//|   ma_period - davr                                                                               |
//|   ma_shift - surilish, ko'rsatkichlar qatorini almashtirish                                      |
//|   ma_method - uslub (0 - Simple, 1 - Exponential, 2 - Smoothed, 3 - Linear weighted)             |
//|   applied_price - narx holati (1-8)                                                              |
//|   shift - texnik ko'rsatgich tamponidan olingan qiymat indekslari (berilgan davrlarning oldingi  |
//|   miqdoriga nisbatan siljish).                                                                   |
//+--------------------------------------------------------------------------------------------------+
  double narx=MarketInfo(Symbol(),MODE_BID); // hozirgi narx                                         |
  double EMA_10_1=iMA(NULL,0,Ma10Period,0,1,0,1); //                 |
  double EMA_10_2=iMA(NULL,0,Ma10Period,0,1,0,2); //                 |
  double EMA_50_1=iMA(NULL,0,Ma50Period,0,1,0,1); //                 |
  double EMA_50_2=iMA(NULL,0,Ma50Period,0,1,0,2); //                 |
  double EMA_100=iMA(NULL,0,Ma100Period,0,0,0,0); //                 |
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
  if (Volume[0] == 1)//                                                                           |
    {//Print(iRSIOnArray(ExtBuffer,1000,14,0));//                                                                                              |
     if (EMA_10_2 < EMA_50_2 && EMA_10_1 > EMA_50_1 && EMA_100 < narx)//|
       {//                                                                                           |
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,slb,tpb,"NO savdo ",MagicNumber,0,Blue))//         |
          Print("OrderSend BUYda muammo: ", GetLastError());//                                       |
       }
     if (EMA_10_2 > EMA_50_2 && EMA_10_1 < EMA_50_1 && EMA_100 > narx)//|
       {//                                                                                           |
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,sls,tps,"NO savdo ",MagicNumber,0,Red))//         |
          Print("OrderSend SELLda muammo: ", GetLastError());//                                      |
       }//                                                                                           |
    }//                                                                                              |
  /*if (OrdersTotal()>0)
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
