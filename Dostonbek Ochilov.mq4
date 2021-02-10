//+------------------------------------------------------------------+
//|                                           Dostonbek Ochilov.mq4  |
//|                          Strategiya muallifi: Dostonbek Ochilov  |
//|                                    Dasturchi: Nematillo Ochilov  |
//+------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

extern double    Lots=0.01;
extern int       TakeProfit=1000;
extern int       StopLoss=200;
extern int       MagicNumber=1;


//+------------------------------------------------------------------------------------------------------+
//| robotni ishga tushirish qismi                          |
//+------------------------------------------------------------------------------------------------------+
int init()
  {
//----
   Alert("Nematillo Ochilov tomonidan yaratilgan robot ishga tushmoqda");
//----
   return(0);
  }
//+------------------------------------------------------------------------------------------------------+
//|  robot faol holatda                                                |
//+------------------------------------------------------------------------------------------------------+
int start()
  {
  double OOPOSL=OrderOpenPrice() - OrderTakeProfit();
  double narx0=iMA(Symbol(),0,1,0,0,0,0);
  double narx1=iMA(Symbol(),0,1,0,0,0,1);
//-------------------------------------------------------------------------------------------------------+
// Savdoni ochishda foyda va zararni cheklash miqdorlari
//-------------------------------------------------------------------------------------------------------+
  double TPB4=NormalizeDouble(Ask+NormalizeDouble(450,Digits)*Point,Digits);
  double SLB4=NormalizeDouble(Ask-NormalizeDouble(200,Digits)*Point,Digits);
  double TPB6=NormalizeDouble(Ask+NormalizeDouble(650,Digits)*Point,Digits);
  double SLB6=NormalizeDouble(Ask-NormalizeDouble(200,Digits)*Point,Digits);
  double TPS4=NormalizeDouble(Bid-NormalizeDouble(450,Digits)*Point,Digits);
  double SLS4=NormalizeDouble(Bid+NormalizeDouble(200,Digits)*Point,Digits);
  double TPS6=NormalizeDouble(Bid-NormalizeDouble(650,Digits)*Point,Digits);
  double SLS6=NormalizeDouble(Bid+NormalizeDouble(200,Digits)*Point,Digits);
//-------------------------------------------------------------------------------------------------------+
// Savdoni o'zgartirishda foyda va zararni cheklash miqdorini o'zgartirish
//-------------------------------------------------------------------------------------------------------+
  double MTPB4=NormalizeDouble(OrderTakeProfit()+NormalizeDouble(450,Digits)*Point,Digits);
  double MSLB4=NormalizeDouble(OrderStopLoss()+NormalizeDouble(200,Digits)*Point,Digits);
  double MTPB6=NormalizeDouble(OrderTakeProfit()+NormalizeDouble(650,Digits)*Point,Digits);
  double MSLB6=NormalizeDouble(OrderStopLoss()+NormalizeDouble(200,Digits)*Point,Digits);
  double MTPS4=NormalizeDouble(OrderTakeProfit()-NormalizeDouble(450,Digits)*Point,Digits);
  double MSLS4=NormalizeDouble(OrderStopLoss()-NormalizeDouble(200,Digits)*Point,Digits);
  double MTPS6=NormalizeDouble(OrderTakeProfit()-NormalizeDouble(650,Digits)*Point,Digits);
  double MSLS6=NormalizeDouble(OrderStopLoss()-NormalizeDouble(200,Digits)*Point,Digits);
//-------------------------------------------------------------------------------------------------------+
// 45 va 65 darajalarga narx borganda
//-------------------------------------------------------------------------------------------------------+
  double MA450=NormalizeDouble(iMA(Symbol(),0,50,0,1,0,0) + 450 * Point,Digits);
  double MAM450=NormalizeDouble(iMA(Symbol(),0,50,0,1,0,0) - 450 * Point,Digits);
  double MA650=NormalizeDouble(iMA(Symbol(),0,50,0,1,0,0) + 650 * Point,Digits);
  double MAM650=NormalizeDouble(iMA(Symbol(),0,50,0,1,0,0) - 650 * Point,Digits);
//-------------------------------------------------------------------------------------------------------+
  double i45=0.0045;
  double i65=0.0065;
  double i9=0.009;
  double i13=0.013;
  double mi45=-0.0045;
  double mi65=-0.0065;
  double mi9=-0.009;
  double mi13=-0.013;
//-------------------------------------------------------------------------------------------------------+
// savdo taktikasi
//-------------------------------------------------------------------------------------------------------+
  Comment("Ushbu robotni katta real balansda sinab ko'rmang");
  if (OrdersTotal()>0)
    {
     for(int i=0;i<OrdersTotal();i++)
      {
       if (OrderSelect(i,SELECT_BY_POS)==true)
         {
          if (OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            {
             if (OrderType()==OP_BUY)
               {
                if ((OOPOSL == mi45) || (OOPOSL == mi9))
                  {
                   if (!OrderModify(OrderTicket(),0,MSLB4,MTPB4,0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
                if ((OOPOSL == mi65) || (OOPOSL == mi13))
                  {
                   if (!OrderModify(OrderTicket(),0,MSLB6,MTPB6,0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
               }
             if (OrderType()==OP_SELL)
               {Print("OOPOSL ", OOPOSL);Print("i45 ", i45);
                if (OOPOSL == i45) //  || (OOPOSL == i9)
                  {Print("------");
                   if (!OrderModify(OrderTicket(),0,MSLS4,MTPS4,0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
                if ((OOPOSL == i65) || (OOPOSL == i13))
                  {
                   if (!OrderModify(OrderTicket(),0,MSLS6,MTPS6,0,Aqua))
                     Print("OrderModify BUYda muammo: ",GetLastError());
                  }
               }
            }
         }
      }
    }
  if (OrdersTotal()<1)
    {
     if ((narx1 > MAM450) && (narx0 < MAM450))
       {
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SLB4,TPB4,"NO savdo ",MagicNumber,0,Aqua))
          Print("OrderSend BUYda muammo: ",GetLastError());
       }
     if ((narx1 > MAM650) && (narx0 < MAM650))
       {
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,3,SLB6,TPB6,"NO savdo ",MagicNumber,0,Aqua))
          Print("OrderSend BUYda muammo: ",GetLastError());
       }
     if ((narx1 > MA450) && (narx0 < MA450))
       {
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SLS4,TPS4,"NO savdo ",MagicNumber,0,Red))
          Print("OrderSend SELLda muammo: ",GetLastError());
       }
     if ((narx1 > MA650) && (narx0 < MA650))
       {
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,3,SLS6,TPS6,"NO savdo ",MagicNumber,0,Red))
          Print("OrderSend SELLda muammo: ",GetLastError());
       }
    }
  return(0);
  }


