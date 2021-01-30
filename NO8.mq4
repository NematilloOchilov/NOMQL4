//+------------------------------------------------------------------+
//|                                                         NO8.mq4  |
//|                          Strategiya muallifi: Nematillo Ochilov  |
//|                                    Dasturchi: Nematillo Ochilov  |
//+------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

extern double    Lots=0.01;
extern int       TakeProfit=100;
extern int       StopLoss=600;
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
  double tpb=NormalizeDouble(Ask+TP*Point,Digits);
  double tps=NormalizeDouble(Bid-TP*Point,Digits);
  double opb=NormalizeDouble(190,Digits);
  double ops=NormalizeDouble(190,Digits);
  double tslb=NormalizeDouble(OrderOpenPrice()+opb*Point,Digits);
  double tsls=NormalizeDouble(OrderOpenPrice()-ops*Point,Digits);

  double narx=MarketInfo(Symbol(),MODE_ASK); // hozirgi narx                                         |

  double SMA=iMA(NULL,0,62,190,0,0,0);
  double SMA10=iMA(NULL,0,10,0,0,0,0);
  double MACD_SIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  double RSI0=iRSI(NULL,0,16,PRICE_OPEN,0);
  double RSI1=iRSI(NULL,0,16,PRICE_OPEN,1);
  double Bands=iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_MAIN,0);
  double TOP=OrderOpenPrice();
  double TSL=OrderStopLoss();
//-------------------------------------------------------------------+
// savdo taktikasi
//-------------------------------------------------------------------+

  Comment("Ushbu robotni katta real balansda sinab ko'rmang");
  if (OrdersTotal() > 0)
    {
     for(int i=0;i<OrdersTotal();i++)
      {
       if (OrderSelect(i,SELECT_BY_POS)==true)
         {
          if (OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            {
             if (OrderType()==OP_BUY)
               {
                if (RSI0 < 50)
                  {
                   if (!OrderClose(OrderTicket(),OrderLots(),Bid,3,Green))
                     Print("OrderClose BUYda muammo: ",GetLastError());
                  }
               }
             if (OrderType()==OP_SELL)
               {
                if (RSI0 > 50)
                  {
                   if (!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
                     Print("OrderClose SELLda muammo: ",GetLastError());
                  }
               }
            }
         }
      }
    }
  if (OrdersTotal() < 1)
    {
     if ((SMA10 > Bands) && (MACD_SIGNAL > 0) && (RSI0 > 60))  //(narx > SMA) && (narx < SMA) &&
       {
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,slb,tpb,"NO savdo ",MagicNumber,0,Aqua))
          Print("OrderSend BUYda muammo: ",GetLastError());
       }
     if ((SMA10 < Bands) && (MACD_SIGNAL < 0) && (RSI0 < 40))
        {
         if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,sls,tps,"NO savdo ",MagicNumber,0,Red))
           Print("OrderSend SELLda muammo: ",GetLastError());
        }
    }
  return(0);
  }




