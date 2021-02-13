//+--------------------------------------------------------------------------------------------------+
//|                                                                                        NO14.mq4  |
//|                                                     Strategiya muallifi: 𝓓𝓲𝓵𝓶𝓾𝓻𝓸𝓭 𝓠𝓪𝓵𝓪𝓷𝓭𝓪𝓻𝓸𝓿  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi sozlamalar                                                                              |
//+--------------------------------------------------------------------------------------------------+
extern double Lot = 0.01;//                         Savdo hajmi
extern int    TakeProfit=760;//                     Daromadni belgilash
extern int    StopLoss=360;//                       Zararni cheklash
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
int start()//
    {//
    double AO1=iAO(NULL,0,1);
    double AO2=iAO(NULL,0,2);
    double BandsU=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_UPPER,0);
    double BandsL=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_LOWER,0);
    double BandsM=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_MAIN,0);
    double TP = TakeProfit * Point;//                                   Foydani cheklash
    double SL = StopLoss * Point;//                                     Zararni cheklash
    if (1 > OrdersTotal()){
        if ((AO1 > 0) && (AO1 > AO2) && (iClose(Symbol(),0,0) > BandsM)){
            for(int i=0; i<6; i++){
                if (iHigh(Symbol(),0,i) < BandsM){
                    for(int x=5; x<11; x++){
                        if (iLow(Symbol(),0,x) > BandsM){
                            int ticket = OrderSend(Symbol(), OP_BUY, Lot, Ask, 10, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Aqua);
                            if (ticket<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
                            else break;
                            }
                        }
                    }
                }
            }
        }
    return(0);//
    }//
