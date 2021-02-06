//+--------------------------------------------------------------------------------------------------+
//|                                                                           Nematillo Ochilov.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Hajm, vaqt, savdo raqami, foyda va zararni cheklash miqdori.                                   |
//+--------------------------------------------------------------------------------------------------+
extern int       TakeProfit=500;//                     Daromadni belgilash                           |
extern int       StopLoss=1000;//                       Zararni cheklash                             |
//+--------------------------------------------------------------------------------------------------+
int start()//                                                                                        |
  {   //                                                                                             |
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

   int day = 0;
   //Print("iHigh ", iHigh(Symbol(), 0, 0)); Print("iHigh12 ", iHigh(Symbol(), 0, 12));
   if (OrdersTotal() < 1)
     {//
      if (TimeHour(TimeCurrent()) == 2 && TimeMinute(TimeCurrent()) == 0) //  && day != TimeDay(TimeCurrent())
        {
         if (iHigh(Symbol(), 0, 6) < iHigh(Symbol(), 0, 0))
           {
            if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,slb,tpb,"NO savdo ",1,0,Blue))
              Print("OrderSend BUYda muammo: ", GetLastError());
           }
         if (iLow(Symbol(), 0, 6) > iLow(Symbol(), 0, 0))
           {
            if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,sls,tps,"NO savdo ",1,0,Red))
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
