//+------------------------------------------------------------------+
//|                                                   BlackGhost.mq4 |
//|                                                Nematillo Ochilov |
//|                                                Nematillo Ochilov |
//+------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

extern double    Lots=0.01;
extern int       TakeProfit=5000;
extern int       StopLoss=300;
extern int       MagicNumber=1;
extern int       Ma1Period=16;
extern int       Ma1Shift=1;
extern int       Ma1Method=1;
extern int       Ma1AppliedPrice=4;
extern int       Ma2Period=25;
extern int       Ma2Shift=4;
extern int       Ma2Method=1;
extern int       Ma2AppliedPrice=4;
extern int       Ma3Period=150;
extern int       Ma3Shift=0;
extern int       Ma3Method=0;
extern int       Ma3AppliedPrice=2;
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
  double S_L=NormalizeDouble(200,Digits);
  double SLL=NormalizeDouble(400,Digits);

// Stop-lossni hisoblash
  double slbb=NormalizeDouble(Ask-S_L*Point,Digits);
  double slss=NormalizeDouble(Bid+S_L*Point,Digits);
  double slb=NormalizeDouble(Ask-SL*Point,Digits);
  double sls=NormalizeDouble(Bid+SL*Point,Digits);
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);
  double tps=NormalizeDouble(Bid-TP*Point,Digits);
  double tslb=NormalizeDouble(OrderStopLoss()+SLL*Point,Digits);
  double tsls=NormalizeDouble(OrderStopLoss()-SLL*Point,Digits);
  double WPR0=iWPR(NULL,0,10,0);
  double WPR1=iWPR(NULL,0,10,1);
  double MA1=iMA(NULL,0,Ma1Period,Ma1Shift,Ma1Method,Ma1AppliedPrice,0); // DarkSkyBlue
  double MA2=iMA(NULL,0,Ma2Period,Ma2Shift,Ma2Method,Ma2AppliedPrice,0); // Red
  double MA3=iMA(NULL,0,Ma3Period,Ma3Shift,Ma3Method,Ma3AppliedPrice,0); // white
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
                /* if(WPR0>-10)
                  {
                   if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Red))
                     Print("OrderClose BUYda muammo: ",GetLastError());
                  }
                else */
                if(tslb<Ask)
                  {
                   if(!OrderModify(OrderTicket(),0,slbb,OrderTakeProfit(),0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
               }
             if(OrderType()==OP_SELL)
               {
                /* if(WPR0<-90)
                  {
                   if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                     Print("OrderClose SELLda muammo: ",GetLastError());
                  }
                else */
                if(tsls>Bid)
                  {
                   if(!OrderModify(OrderTicket(),0,slss,OrderTakeProfit(),0,Orange))
                     Print("OrderModify SELLda muammo: ",GetLastError());
                  }
               }
            }
         }
       }
    }
  else if(OrdersTotal()<1)
    {
     if((WPR0>-10)&&(WPR0<-9))
        {
         if((MA1>MA2)&&(MA2>MA3))
           {
            if(!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slb,tpb,"NO savdo ",MagicNumber,0,Aqua))
              Print("OrderSend BUYda muammo: ",GetLastError());
           }
        }
     if((WPR0>-91)&&(WPR0<-90))
       {
        if((MA1<MA2)&&(MA2<MA3))
          {
           if(!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sls,tps,"NO savdo ",MagicNumber,0,Red))
             Print("OrderSend SELLda muammo: ",GetLastError());
          }
        }
    }
  return(0);
  }

