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
extern int    TakeProfit=100;//                     Daromadni belgilash
extern int    StopLoss=100;//                       Zararni cheklash
//+--------------------------------------------------------------------------------------------------+
//|   Ichki sozlamalar
//+--------------------------------------------------------------------------------------------------+
int start()//
    {//Bollinger Bands va CCI texnik ko'rsatgichlari https://docs.mql4.com/indicators
    double CCI=iCCI(Symbol(),0,10,PRICE_TYPICAL,0);
    double BandsU=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_UPPER,0);
    double BandsL=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_LOWER,0);
    double BandsM=iBands(NULL,0,20,2,0,PRICE_OPEN,MODE_MAIN,0);
    double TP = TakeProfit * Point;//                                   Foydani cheklash
    double SL = StopLoss * Point;//                                     Zararni cheklash
    if (1 > OrdersTotal()) { // Agar order ochilgan bo'lsa
        if (CCI > 100) { // Agar CCI 100 dan katta bo'lsa
            // Agar oxirgi shamchaning boshlagan qismi Bandsdan katta bo'lsa va tugallangan qismi Bandsdan kichik bo'lsa
            if ((iOpen(Symbol(),0,0) > BandsM) && (iClose(Symbol(),0,0) < BandsM)) { 
                int buy = OrderSend(Symbol(), OP_BUY, Lot, Ask, 3, Ask - SL, Ask + TP, "NO savdo ", 0, 0, Aqua); // Sotib olish
                if (buy<0) {Print("OrderSend BUYda muammo: ",GetLastError());}
                }
            }
        if (CCI < -100) { // Agar CCI 100 dan kichik bo'lsa
            // Agar oxirgi shamchaning boshlagan qismi Bandsdan katta bo'lsa va tugallangan qismi Bandsdan kichik bo'lsa
            if ((iOpen(Symbol(),0,0) > BandsM) && (iClose(Symbol(),0,0) < BandsM)) {
                int sell = OrderSend(Symbol(), OP_SELL, Lot, Bid, 3, Bid + SL, Bid - TP, "NO savdo ", 0, 0, Red);// Sotish
                if (sell<0) {Print("OrderSend SELLda muammo: ",GetLastError());}
                }
            }
        }
    return(0);
    }
