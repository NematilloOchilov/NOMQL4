//+------------------------------------------------------------------------------------------------------+
//|                                                          NO1.mq4 |
//|                                                Nematillo Ochilov |
//|                                                Nematillo Ochilov |
//+------------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"
#property link      "https://t.me/Nematillo_Ochilov"

extern double    Lot95 = 0.1;
extern double    Lot90 = 0.05;
extern double    Lot85 = 0.03;
extern double    Lot80 = 0.02;
extern int       TakeProfit = 600;
extern int       StopLoss = 200;


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
double LotFunc(double LOT95, double LOT90, double LOT85, double LOT80, double w)//
    {
    double lot = 0.0;
    for (int y = 0; y <= 95; y += 5){
        int i = -y;
        bool tafovut = (w < i) && (w > i - 5);
        if ((i == -80) && tafovut) lot = LOT80;
        if ((i == -85) && tafovut) lot = LOT85;
        if ((i == -90) && tafovut) lot = LOT90;
        if ((i == -95) && tafovut) lot = LOT95;
        if ((i == -15) && tafovut) lot = LOT80;
        if ((i == -10) && tafovut) lot = LOT85;
        if ((i == -5) && tafovut) lot = LOT90;
        if ((i == 0) && tafovut) lot = LOT95;
        }
    return(lot);
    }

int start()
    {
    double TP = TakeProfit * Point;//                   Foydani cheklash                                 |
    double SL = StopLoss * Point;//                     Zararni cheklash                                 |
    double OOPOSL = OrderOpenPrice() - OrderTakeProfit();
    double narx = MarketInfo(Symbol(),MODE_BID);
    double EMA50 = iMA(Symbol(),0,50,0,1,0,0);
    double WPR_60_0 = iWPR(NULL,0,60,0);
    double WPR_60_1 = iWPR(NULL,0,60,1);
    double WPR_60_2 = iWPR(NULL,0,60,2);
    bool WPRB = WPR_60_0 > WPR_60_1 && WPR_60_1 < WPR_60_2;
    bool WPRS = WPR_60_0 < WPR_60_1 && WPR_60_1 > WPR_60_2;
    double Lots = LotFunc(Lot95, Lot90, Lot85, Lot80, WPR_60_0);//
    bool emab550 = ((narx > EMA50 - 560 * Point) && (narx < EMA50 - 540 * Point));
    bool emab750 = ((narx > EMA50 - 760 * Point) && (narx < EMA50 - 740 * Point));
    bool emas550 = ((narx > EMA50 + 540 * Point) && (narx < EMA50 + 560 * Point));
    bool emas750 = ((narx > EMA50 + 740 * Point) && (narx < EMA50 + 760 * Point));
    //-------------------------------------------------------------------------------------------------------+
    // savdo taktikasi
    //-------------------------------------------------------------------------------------------------------+
  if (OrdersTotal()<1 && Lots != 0)
    {
     if (emab550 || emab750)
       {
        if (!OrderSend(Symbol(),OP_BUY,Lots,Ask,30,Ask - SL, Ask + TP,"NO savdo ",0,0,Aqua))
          Print("OrderSend BUYda muammo: ",GetLastError());
       }
     if (emas550 || emas750)
       {
        if (!OrderSend(Symbol(),OP_SELL,Lots,Bid,30,Bid + SL, Bid - TP,"NO savdo ",0,0,Red))
          Print("OrderSend SELLda muammo: ",GetLastError());
       }
    }
  return(0);
  }


