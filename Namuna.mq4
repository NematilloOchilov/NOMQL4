//+--------------------------------------------------------------------------------------------------+
//|                                                                         Dastur nomi: Namuna.mq4  |
//|                                                          Strategiya muallifi: Nematillo Ochilov  |
//|                                                                    Dasturchi: Nematillo Ochilov  |
//|        mql4 dasturlash tilidagi bilimlar telegramdagi @mqluz kanalining yuqori qismida yozilgan  |
//|                                            Savollaringizni telegramdagi @mql_uz guruhiga yozing  |
//+--------------------------------------------------------------------------------------------------+
#property copyright "Nematillo Ochilov MQL4"//                                                       |
#property link      "https://t.me/MQLUZ"//                                                           |
//+--------------------------------------------------------------------------------------------------+
//|   Tashqi o'zgaruvchilar                                                                          |
//+--------------------------------------------------------------------------------------------------+
extern double stoploss=100;
extern double takeprofit=100;

extern int butun_son = 20;
extern double haqiqiy_son = 0.01;
extern bool mantiqiy = true;
extern string satr = "Forex";
extern datetime vaqt;
extern datetime rang;

extern string api_bot="1141252783:AAHR3uXE5vV9Dd2zMTF475SJ2-3m03FWQFYQ";
extern string chat_id="-678913288";
string url_for_send="https://api.telegram.org/bot" + api_bot + "/sendMessage?chat_id=" + chat_id + "&text=";

//+--------------------------------------------------------------------------------------------------+
//|   Funksiyalar                                                                                    |
//+--------------------------------------------------------------------------------------------------+
void telegram_send_text(string urlx)
{
    string cookie=NULL,headers;
    char post[],result[];
    int res;
    int timeout=5000;  // 5 sec
    res=WebRequest("GET",urlx,cookie,NULL,timeout,post,0,result,headers);
    if(res==-1)
    {
        Print("XATOLIK: TelegramSendText");
    }
    else
    {
        Print("Muvaffaqiyatli TelegramSendText");
    }
}

double profit() // Ochiq bitimlardagi barcha foydani ko'rsatuvchi funksiya
{
    double buyProfit = 0, sellProfit = 0;
    for(int i=0; i<OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUY)
            {
                buyProfit += OrderProfit();
            }
            else if (OrderType() == OP_SELL)
            {
                sellProfit += OrderProfit();
            }
        }
    }
    return(buyProfit + sellProfit);
}

void bc (string text) // Ekranda yozuv hosil qiladigan BigComment funksiyasi
{
    long chart_ID = ChartID();
    string bc_name = "0";
    ObjectCreate(chart_ID, bc_name, OBJ_LABEL, 0, 0, 0);
    ObjectSet(chart_ID, OBJPROP_XDISTANCE, 70);
    ObjectSet(chart_ID, OBJPROP_YDISTANCE, 180);
    ObjectSetInteger(chart_ID, bc_name, OBJPROP_COLOR, clrWhite);
    ObjectSetText(bc_name, text, 14, "Arial", clrRed);
    ChartRedraw(chart_ID);
}

void osb (double lot, double price_ask, double bsl, double btp, int magic) // Buyga bitim ochadigan funksiya
{
    string strmagic = IntegerToString(magic);
    if (!OrderSend(Symbol(), OP_BUY, lot, price_ask, 10, bsl, btp, "Shamdon turi: " + strmagic, magic, 0, Blue))
        Print("OrderSend Buy " + strmagic + "-da muammo: ", GetLastError());
}

void oss (double lot, double price_bid, double ssl, double stp, int magic) // Sellga bitim ochadigan funksiya
{
    string strmagic = IntegerToString(magic);
    if (!OrderSend(Symbol(), OP_SELL, lot, price_bid, 10, ssl, stp, "Shamdon turi: " + strmagic, magic, 0, Red))
        Print("OrderSend Sell " + strmagic + "-da muammo: ", GetLastError());
}

void om (double stop, string sym) // Bitimlardagi stop lossni o'zgartiradigan funksiya (treyling stop)
{
    for (int cb = OrdersTotal(); cb >= 0; cb--)
    {
        if (OrderSelect(cb, SELECT_BY_POS, MODE_TRADES) == true)
        {
            if (OrderSymbol() == sym)
            {
                if (!OrderModify(OrderTicket(), OrderOpenPrice(), stop, OrderTakeProfit(), 0, Yellow))
                    Print("OrderModify da muammo: ", GetLastError());
            }
        }
    }
}

void oc (string sym) // Bitimlarni yopadigan funksiya
{
    for (int cl = OrdersTotal(); cl >= 0; cl--)
    {
        if (OrderSelect(cl, SELECT_BY_POS, MODE_TRADES) == true)
        {
            if (OrderSymbol() == sym)
            {
                if (OrderType() == OP_BUY)
                {
                    if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 10, Blue))
                        Print("OrderClose OP_BUYda muammo: ", GetLastError());
                }
                else if (OrderType() == OP_SELL)
                {
                    if (!OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 10, Red))
                        Print("OrderClose OP_SELLda muammo: ", GetLastError());
                }
                else if (OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || 
                    OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                {
                    if (!OrderDelete(OrderTicket()))
                        Print("OrderDelete da muammo: ", GetLastError());
                }
            }
        }
    }
}

//+--------------------------------------------------------------------------------------------------+
//|   Ichki o'zgaruvchilar                                                                           |
//+--------------------------------------------------------------------------------------------------+

int ichki_butun_son = 20;
double ichki_haqiqiy_son = 0.01;
bool ichki_mantiqiy = true;
string ichki_satr = "Forex";
datetime last_order_time = TimeCurrent();

double Lots = AccountBalance()/10000;

//+--------------------------------------------------------------------------------------------------+
//|   Asosiy funksiya                                                                                |
//+--------------------------------------------------------------------------------------------------+

int start()
{

//    int time_day=TimeDay(TimeCurrent());  //  Hozirgi kun
//    int time_hour=TimeHour(TimeCurrent());  //  Hozirgi soat
//    int time_minute=TimeMinute(TimeCurrent());  //  Hozirgi daqida
//
    double priceAsk=MarketInfo(Symbol(), MODE_ASK);  // Sotish narxi
    double priceBid=MarketInfo(Symbol(), MODE_BID);  // Sotib olish narxi
//
//    double high1=iHigh(Symbol(), PERIOD_CURRENT, 1);  // 1-shamni eng yuqori narxi
//    double high2=iHigh(Symbol(), PERIOD_CURRENT, 2);  // 2-shamni eng yuqori narxi
//    double high3=iHigh(Symbol(), PERIOD_CURRENT, 3);  // 3-shamni eng yuqori narxi
//    double high4=iHigh(Symbol(), PERIOD_CURRENT, 4);  // 4-shamni eng yuqori narxi
//
//    double low1=iLow(Symbol(), PERIOD_CURRENT, 1);  // 1-shamni eng past narxi
//    double low2=iLow(Symbol(), PERIOD_CURRENT, 2);  // 2-shamni eng past narxi
//    double low3=iLow(Symbol(), PERIOD_CURRENT, 3);  // 3-shamni eng past narxi
//    double low4=iLow(Symbol(), PERIOD_CURRENT, 4);  // 4-shamni eng past narxi
//
//    double open1=iOpen(Symbol(), PERIOD_CURRENT, 1);  // 1-shamni ochilish narxi
//    double open2=iOpen(Symbol(), PERIOD_CURRENT, 2);  // 2-shamni ochilish narxi
//    double open3=iOpen(Symbol(), PERIOD_CURRENT, 3);  // 3-shamni ochilish narxi
//    double open4=iOpen(Symbol(), PERIOD_CURRENT, 4);  // 4-shamni ochilish narxi
//    double open5=iOpen(Symbol(), PERIOD_CURRENT, 5);  // 5-shamni ochilish narxi
//
//    double close1=iClose(Symbol(), PERIOD_CURRENT, 1);  // 1-shamni yopilish narxi
//    double close2=iClose(Symbol(), PERIOD_CURRENT, 2);  // 2-shamni yopilish narxi
//    double close3=iClose(Symbol(), PERIOD_CURRENT, 3);  // 3-shamni yopilish narxi
//    double close4=iClose(Symbol(), PERIOD_CURRENT, 4);  // 4-shamni yopilish narxi
//    double close5=iClose(Symbol(), PERIOD_CURRENT, 5);  // 5-shamni yopilish narxi
//
//    double sham_tana_1 = MathAbs(open1 - close1);  // 1-sham tanasining uzunligi (soya hisoblanmaydi)
//    double sham_tana_2 = MathAbs(open2 - close2);  // 2-sham tanasining uzunligi (soya hisoblanmaydi)
//    double sham_tana_3 = MathAbs(open3 - close3);  // 3-sham tanasining uzunligi (soya hisoblanmaydi)
//    double sham_tana_4 = MathAbs(open4 - close4);  // 4-sham tanasining uzunligi (soya hisoblanmaydi)
//
//    double hl1 = high1 - low1;  // 1-shamning umumiy uzunligi (soya hisoblanadi)
//    double hl2 = high2 - low2;  // 2-shamning umumiy uzunligi (soya hisoblanadi)
//    double hl3 = high3 - low3;  // 3-shamning umumiy uzunligi (soya hisoblanadi)
//    double hl4 = high4 - low4;  // 4-shamning umumiy uzunligi (soya hisoblanadi)
//
//    bool sell1 = open1 > close1;  //  agar 1-sham sell bo'lsa
//    bool sell2 = open2 > close2;  //  agar 2-sham sell bo'lsa
//    bool sell3 = open3 > close3;  //  agar 3-sham sell bo'lsa
//    bool sell4 = open4 > close4;  //  agar 4-sham sell bo'lsa
//    bool sell5 = open5 > close5;  //  agar 5-sham sell bo'lsa
//
//    bool buy1 = open1 < close1;  //  agar 1-sham buy bo'lsa
//    bool buy2 = open2 < close2;  //  agar 1-sham buy bo'lsa
//    bool buy3 = open3 < close3;  //  agar 1-sham buy bo'lsa
//    bool buy4 = open4 < close4;  //  agar 1-sham buy bo'lsa
//    bool buy5 = open5 < close5;  //  agar 1-sham buy bo'lsa

//+--------------------------------------------------------------------------------------------------+
//|   Indikatorlar (Ko'rsatgichlar)                                                                  |
//+--------------------------------------------------------------------------------------------------+

//    double AC				=iAC(NULL, 0, 0);
//    double AD				=iAD(NULL, 0, 0);
//    double Alligator		=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 1);
//    double ADX				=iADX(NULL, 0, 14, PRICE_HIGH, MODE_MAIN, 0);
//    double ATR				=iATR(NULL, 0, 12, 0);
//    double AO				=iAO(NULL, 0, 2);
//    double BearsPower		=iBearsPower(NULL, 0, 13, PRICE_CLOSE, 0);
//    double Bands			=iBands(NULL, 0, 20, 2, 0, PRICE_LOW, MODE_LOWER, 0);
//    double BullsPower		=iBullsPower(NULL, 0, 13, PRICE_CLOSE, 0);
//    double Fractals		    =iFractals(NULL, 0, MODE_UPPER, 3);
//    double Force			=iForce(NULL, 0, 13, MODE_SMA, PRICE_CLOSE, 0);
//    double Envelopes		=iEnvelopes(NULL, 0, 13, MODE_SMA, 10, PRICE_CLOSE, 0.2, MODE_UPPER, 0);
//    double DeMarker		    =iDeMarker(NULL, 0, 13, 1);
//    double CCI				=iCCI(Symbol(), 0, 12, PRICE_TYPICAL, 0);
//    double Stochastic		=iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0);
//    double WPR				=iWPR(NULL, 0, 14, 0);
//    double StdDev			=iStdDev(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE, 0);
//    double RVI				=iRVI(NULL, 0, 10, MODE_MAIN, 0);
    double RSI				=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
//    double SAR				=iSAR(NULL, 0, 0.02, 0.2, 0);
//    double OBV				=iOBV(NULL, 0, PRICE_CLOSE, 1);
//    double MACD			    =iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 0);
//    double OsMA			    =iOsMA(NULL, 0, 12, 26, 9, PRICE_OPEN, 1);
//    double MA				=iMA(NULL, 0, 13, 8, MODE_SMMA, PRICE_MEDIAN, 0);
//    double MFI				=iMFI(NULL, 0, 14, 0);
//    double Momentum		    =iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);
//    double BWMFI			=iBWMFI(NULL, 0, 0);
//    double Ichimoku		    =iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, 1);
//    double Gator			=iGator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_UPPER, 1);
//
//    double Custom			=iCustom(NULL, 0, "SampleInd", 13, 1, 0);  // Maxsus ko'rsatgichlar

//+--------------------------------------------------------------------------------------------------+
//|   Bitimlarni boshqarish (ochish, yopish, o'zgartirish                                            |
//+--------------------------------------------------------------------------------------------------+

    if (OrdersTotal() < 1)
    {
        if (RSI < 20)
        {
            osb(Lots, priceAsk, priceAsk - stoploss * Point, priceBid + takeprofit * Point, 1000);
        }
        else if (RSI > 80)
        {
            oss(Lots, priceBid, priceBid + stoploss * Point, priceAsk - takeprofit * Point, 1001);
        }
    }

    bc(priceAsk);  // Ekranda narxni ko'rsatib turadi
//+--------------------------------------------------------------------------------------------------+
//|   Telegram guruhga xabar yuborish                                                                |
//+--------------------------------------------------------------------------------------------------+

//    req = url_for_send + "Символ:"+Symbol()+"\r\n"+"Сигнал:BUY%20Цена:"+DoubleToString(priceAsk)+"\r\nПериод:"+DoubleToString(Period())+"\r\nВремя:"+Hour()+":"+Minute();
//    TelegramSendText(req);
    return(0);
}
