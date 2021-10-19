//+------------------------------------------------------------------+
//|                                                  BlackGhost.mq4  |
//|                                 Strategiya muallifi: BlackGhost  |
//|                                    Dasturchi: Nematillo Ochilov  |
//+------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

extern double    Lots=0.01;  // AccountBalance()/1000
extern int       TakeProfit=10000;
extern int       StopLoss=100;
extern int       MagicNumber=1;


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
  double mslb=NormalizeDouble(Ask-NormalizeDouble(500,Digits)*Point,Digits);
  double msls=NormalizeDouble(Bid+NormalizeDouble(500,Digits)*Point,Digits);
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);
  double tps=NormalizeDouble(Bid-TP*Point,Digits);
  double opb=NormalizeDouble(1000,Digits);  //190
  double ops=NormalizeDouble(1000,Digits);
  double tslb=NormalizeDouble(OrderOpenPrice()+opb*Point,Digits);
  double tsls=NormalizeDouble(OrderOpenPrice()-ops*Point,Digits);
  double WPR0=iWPR(NULL,0,500,0);
  double WPR1=iWPR(NULL,0,500,1);
  double narx=MarketInfo(Symbol(),MODE_ASK); // hozirgi narx                                         |
  double SMA=iMA(NULL,0,22,8,0,0,0); //                 |
  double TOP=OrderOpenPrice();
  double TSL=OrderStopLoss();
//-------------------------------------------------------------------+
// savdo taktikasi
//-------------------------------------------------------------------+

  Comment("Ushbu robotni katta real balansda sinab ko'rmang");


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
                if ((TOP > TSL) && (tslb<Ask))
                  {
                   if (!OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                   //else
                     //return(0);
                  }
                /* if (tslb<Ask)
                  {
                   if (!OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  } */
                if ((WPR0 < -20) && (WPR1 > -20) && (narx < SMA))
                  {
                  if (!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
                     Print("OrderClose BUYda muammo: ",GetLastError());
                  }
               }
             if (OrderType()==OP_SELL)
               {Print("TOP ", TOP);Print("TSL ", TSL);Print("tsls ", tsls);Print("Bid ", Bid);Print("narx ", narx);Print("sls ", sls);
                if ((TOP < TSL) && (tsls>Bid))
                  {
                   if (!OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,Red))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                   //else
                     //return(0);
                  }

                /* if (tsls>Bid)
                  {
                   if (!OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,Orange))
                     Print("OrderModify SELLda muammo: ",GetLastError());
                  } */
                if ((WPR0 > -80) && (WPR1 < -80) && (narx > SMA))
                  {
                 if (!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                    Print("OrderClose SELLda muammo: ",GetLastError());
                  }
               }
            }
         }
       }
    }


  else if (OrdersTotal()<1)
    {
     if ((WPR0 > -80) && (WPR1 < -80))
        {
         if (narx > SMA)
           {
            if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slb,tpb,"NO savdo ",MagicNumber,0,Aqua))
              Print("OrderSend BUYda muammo: ",GetLastError());
           }
        }
     if ((WPR0 < -20) && (WPR1 > -20))
        {
         if (narx < SMA)
          {
          if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sls,tps,"NO savdo ",MagicNumber,0,Red))
            Print("OrderSend SELLda muammo: ",GetLastError());
          }
        }
    }
  return(0);
  }


