﻿//+---------------------------------------------------------------------------+
//|                                                                    NO3.mq4 |
//|                                                          Nematillo Ochilov |
//| Bizni qo'llab-quvvatlash uchun Uzcard karta raqami        8600032937412948 |
//+----------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/MQLUZ"

extern double    Lots=0.01;
extern int       TakeProfit=10000;
extern int       StopLoss=1000;
extern int       MagicNumber=1;

extern int       Ma1Period=100;
extern int       Ma1Shift=1;
extern int       Ma1Method=0;
extern int       Ma1AppliedPrice=2;
extern int       Ma2Period=150;
extern int       Ma2Shift=8;
extern int       Ma2Method=1;
extern int       Ma2AppliedPrice=3;
extern int       Ma3Period=50;
extern int       Ma3Shift=0;
extern int       Ma3Method=0;
extern int       Ma3AppliedPrice=4;

//+------------------------------------------------------------------+
//| robotni ishga tushirish qismi                          |
//+------------------------------------------------------------------+
int init()
  {
//----
   Alert("Nematillo Ochilov tomonidan yaratilgan robot ishga tushmoqda");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|robot faol holatda                                                |
//+------------------------------------------------------------------+
int start()
  {
  double TP=NormalizeDouble(TakeProfit,Digits);
// stop loss
  double SL=NormalizeDouble(StopLoss,Digits);

// Stop-lossni hisoblash
  double slb=NormalizeDouble(Ask-SL*Point,Digits);
  double sls=NormalizeDouble(Bid+SL*Point,Digits);
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);
  double tps=NormalizeDouble(Bid-TP*Point,Digits);
  //double bigslb=NormalizeDouble(Ask-100*Point,Digits);
  //double bigsls=NormalizeDouble(Bid+100*Point,Digits);
  //double oneslb=NormalizeDouble(OrderOpenPrice()+100*Point,Digits);
  //double onesls=NormalizeDouble(OrderOpenPrice()-100*Point,Digits);
  double tslb=NormalizeDouble(OrderStopLoss()+SL*Point,Digits);
  double tsls=NormalizeDouble(OrderStopLoss()-SL*Point,Digits);

  //double MA1=iMA(NULL,0,Ma1Period,Ma1Shift,Ma1Method,Ma1AppliedPrice,0); // DarkSkyBlue
  //double MA2=iMA(NULL,0,Ma2Period,Ma2Shift,Ma2Method,Ma2AppliedPrice,0); // Red
  //double MA3=iMA(NULL,0,Ma3Period,Ma3Shift,Ma3Method,Ma3AppliedPrice,0); // Yellow
  //double STOCH_SIGNAL=iStochastic(NULL,0,7,5,3,0,0,MODE_SIGNAL,0);
  //double STOCH_MAIN=iStochastic(NULL,0,7,5,3,0,0,MODE_MAIN,0);
  //double MACD_SIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  //double MACD_MAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  double MA1=iMA(NULL,0,Ma1Period,Ma1Shift,Ma1Method,Ma1AppliedPrice,0); // DarkSkyBlue
  double MA2=iMA(NULL,0,Ma2Period,Ma2Shift,Ma2Method,Ma2AppliedPrice,0); // Red
  double RSI0=iRSI(NULL,0,14,PRICE_OPEN,0);
  double RSI1=iRSI(NULL,0,14,PRICE_CLOSE,1);

//-------------------------------------------------------------------+
// savdo taktikasi
//-------------------------------------------------------------------+

  Comment("Ushbu robotni katta real balansda sinab ko'rmang");


  if(OrdersTotal()>0)
    {
     for(int i=0;i<OrdersTotal();i++)
      {
       if(OrderSelect(i,SELECT_BY_POS)==true)
         {
          if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            {
             if(OrderType()==OP_BUY)
               {
                if(tslb<Ask)
                  {
                   if(!OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
               }
             if(OrderType()==OP_SELL)
               {
                if(tsls>Bid)
                  {
                   if(!OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,Orange))
                     Print("OrderModify SELLda muammo: ",GetLastError());
                  }
               }
            }
         }
       }
    }


  else if(OrdersTotal()<1)
    {
     if(RSI1<28)
        {
         if(RSI0>RSI1)
           {
            if(MA1>MA2)
              {
               if(!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slb,tpb,"NO savdo ",MagicNumber,0,Aqua))
                 Print("OrderSend BUYda muammo: ",GetLastError());
              }
           }
        }
     if(RSI1>68)
       {
        if(RSI0<RSI1)
          {
           if(MA1<MA2)
             {
              if(!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sls,tps,"NO savdo ",MagicNumber,0,Red))
                Print("OrderSend SELLda muammo: ",GetLastError());
             }
          }
        }
    }
  return(0);
  }
