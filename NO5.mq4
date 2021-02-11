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
extern double    Lots=0.01;//                          Savdo hajmi                                   |
extern int       Timeframe=5;//                       Savdo vaqti                                   |
extern int       TakeProfit=5000;//                     Daromadni belgilash                           |
extern int       StopLoss=300;//                       Zararni cheklash                              |                           |
extern int       MagicNumber=1;//                      Savdo raqami                                  |
//+--------------------------------------------------------------------------------------------------+
//|   Moving Everage texnik ko'rsatgichining sozlamalari                                             |
//+--------------------------------------------------------------------------------------------------+
extern int       Ma1Period=500;//                                                                    |
extern int       Ma1Shift=8;//                                                                       |
extern int       Ma1Method=0;//                                                                      |
extern int       Ma1AppliedPrice=0;//                                                                |
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
  double TP=NormalizeDouble(TakeProfit,Digits);//                                                    |
  double SL=NormalizeDouble(StopLoss,Digits);//                                                      |
//+--------------------------------------------------------------------------------------------------+
//|   Foyda va zararni cheklash sozlamalari                                                          |
//+--------------------------------------------------------------------------------------------------+
  double slb=NormalizeDouble(Ask-SL*Point,Digits);//                                                 |
  double sls=NormalizeDouble(Bid+SL*Point,Digits);//                                                 |
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);//                                                 |
  double tps=NormalizeDouble(Bid-TP*Point,Digits);//                                                 |
  double tslb=NormalizeDouble(OrderStopLoss()+SL*Point,Digits);
  double tsls=NormalizeDouble(OrderStopLoss()-SL*Point,Digits);
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
//|   shift - texnik ko'rsatgich tamonidan olingan qiymat indekslari (berilgan davrlarning oldingi   |
//|   miqdoriga nisbatan siljish).                                                                   |
//+--------------------------------------------------------------------------------------------------+
  double narx=MarketInfo(Symbol(),MODE_ASK); // hozirgi narx                                         |
  //double narx=iMA(NULL,0,0,0,0,0,0); //                 |
  double SMA=iMA(NULL,0,Ma1Period,Ma1Shift,Ma1Method,Ma1AppliedPrice,0); //                 |
  //double MACD_SIGNAL=iMACD(NULL,0,62,190,9,PRICE_CLOSE,MODE_MAIN,0);//                    |
  double RSI0=iRSI(NULL,0,6,PRICE_CLOSE,0);//                                                |
  double RSI1=iRSI(NULL,0,6,PRICE_CLOSE,1);//                                              |
  double RSI2=iRSI(NULL,0,6,PRICE_CLOSE,2);//                                              |
  double Stochastic=iStochastic(NULL,0,3,1,6,MODE_SMA,0,MODE_MAIN,0);//                      |
  double num=NormalizeDouble(20,Digits);//
  double opb=NormalizeDouble(OrderOpenPrice()-num*Point,Digits);
  double ops=NormalizeDouble(OrderOpenPrice()+num*Point,Digits);
  int OP=0;
  //double WPR0=iWPR(NULL,0,500,0);
  //double WPR1=iWPR(NULL,0,500,1);
//+--------------------------------------------------------------------------------------------------+
//|   Izoh                                                                                           |
//+--------------------------------------------------------------------------------------------------+
  Comment("Ushbu robotni katta real balansda sinab ko'rmang");//                                     |
//+--------------------------------------------------------------------------------------------------+
//|   Zararni kamaytirish qismi                                                                      |
//+--------------------------------------------------------------------------------------------------+
  if(OrdersTotal() > 0)
    {//Print("narx", narx);
     //Print("sma",SMA);
     for(int i=0;i<OrdersTotal();i++)
      {
       if(OrderSelect(i,SELECT_BY_POS)==true)
         {
          if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            {
             if (OrderType()==OP_BUY)
               {
                if (tslb<Ask)
                  {OP=1;
                   if(!OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
               if (((Stochastic > 70) && (RSI1 > 79) && (RSI0 < 79)) || (opb > Ask))
                 {
                  if (!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
                     Print("OrderClose BUYda muammo: ",GetLastError());
                 }
               }
             if (OrderType()==OP_SELL)
               {
                if(tsls>Bid)
                  {OP=1;
                   if(!OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,Orange))
                     Print("OrderModify SELLda muammo: ",GetLastError());
                  }
                if (((Stochastic < 30) && (RSI1 < 21) && (RSI0 > 21)) || (ops < Bid))
                  {
                   if (!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                    Print("OrderClose SELLda muammo: ",GetLastError());
                }
              }
           }
         }
       }
    }
//+--------------------------------------------------------------------------------------------------+
//|   Savdoni ochish, foyda va zararni cheklash qismi                                                |
//+--------------------------------------------------------------------------------------------------+
  else//if (OrdersTotal() < 1)
    {
     //if (narx > SMA)
       //{
       if ((Stochastic < 30) && (RSI1 < 21) && (RSI0 > 21))
         {
          if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slb,tpb,"NO savdo ",MagicNumber,0,Blue))
            Print("OrderSend BUYda muammo: ", GetLastError());
         }
       //}
     //if (narx < SMA)
       //{
        if ((Stochastic > 70) && (RSI1 > 79) && (RSI0 < 79))
          {
           if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sls,tps,"NO savdo ",MagicNumber,0,Red))
             Print("OrderSend SELLda muammo: ", GetLastError());
          }
       //}
     }
  return(0);//                                                                                       |
  }//                                                                                                |
//+--------------------------------------------------------------------------------------------------+
//|  Tugadi                                                                                          |
//+--------------------------------------------------------------------------------------------------+
