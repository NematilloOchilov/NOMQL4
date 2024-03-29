//+------------------------------------------------------------------+
//|                                        Sanity Trading Family.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2016-2020, Sanity Trading Family"
#property copyright "By Murodillo Eshquvvatov"
#property link      "https://www.mql5.com/en/users/murodillo"
#property description "Bu maslahatchi Murodillo Eshquvvatov tomonidan yaratildi"
#property description "https://t.me/MQL_UZ da dasturchilar uchun"


#define EAName      "SanityTrend"

extern string Masofa="Positsiyalar orasidagi masofa, Trend Bundan Tashqari";
extern double Step=300;
 int StepMode=0;
extern string Martin="Umumiy Lotni kengaytirib borish";
 bool Use_with_win=true;
 bool Use_with_loss=true;
extern double LotKengayishi=1.5;
extern double BuyLot=0.01;
extern double SellLot=0.01; 
extern string SLTP="Foyda/Zarar sozlamasi";
extern double BittaPositsiyaTP=600;
extern double BittaPositsiyaSL=30000;
extern double UmumiyTP=75;  // Take profit level


extern string MovingAverageFilter="Indicator Moving Average uchun Liniya Sozlamasi, Kirish nuqtasi";
extern double Ma_Period=200;
extern string MovingAverageTuri="0=sma, 1=ema, 2=smoothed, 3=linear weighted";
extern string ______="Kerakli sozlamani 0 dan 3 gacha belgilang";
extern double Ma_Mode=1; //0=sma, 1=ema, 2=smoothed, 3=linear weighted
extern string Stochastic="Stochastic indikatori Sozlamasi";
extern double per_K=200;
extern double per_D=20;
extern double slow=20;
extern string Stochastic2="Stoch Levels, maximal Oshish yoki tushish, Ochiq Positsiyada Yordam";
extern double OverBought=10;
extern double OverSold=90;
extern string ExtraSozlama="Qo'shimcha sozlamalar";
extern int MaxBuy=15; //1=disabled
extern int MaxSell=15; //1=disabled
extern int Pulyechish=15000; //max profit in pips allowed per day
extern int Slippage=3;
extern bool Use_MaxSpread=true;
extern int MaxSpread=2; //max spread
double Magicbuy=555;
double Magicsell=556;
double openpricebuy,openpricesell,lotsbuy2,lotssell2,lastlotbuy,lastlotsell,tpb,tps,cnt,smbuy,smsell,lotstep,
ticketbuy,ticketsell,maxLot,free,balance,lotsell,lotbuy,dig,sig_buy,sig_sell,ask,bid;                           
double Balance=0.0;int err=0;

int OrdersTotalMagicbuy(int Magicbuy){
    int j=0;int r;
    for(r=0;r<OrdersTotal();r++){
        if(OrderSelect(r,SELECT_BY_POS,MODE_TRADES)){
          if(OrderMagicNumber()==Magicbuy) j++;
          }
        }   
    return(j); 
}

int OrdersTotalMagicsell(int Magicsell){
    int d=0;int n;
    for(n=0;n<OrdersTotal();n++){
        if(OrderSelect(n,SELECT_BY_POS,MODE_TRADES)){
          if(OrderMagicNumber()==Magicsell) d++;
        }
    }    
    return(d);
}     

int orderclosebuy(int ticketbuy){
    string symbol = Symbol();int cnt;
    for(cnt = OrdersTotal(); cnt >= 0; cnt--){
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);       
        if(OrderSymbol() == symbol && OrderMagicNumber()==Magicbuy) {
           ticketbuy=OrderTicket();OrderSelect(ticketbuy, SELECT_BY_TICKET, MODE_TRADES);lotsbuy2=OrderLots() ;                         
           double bid = MarketInfo(symbol,MODE_BID); 
           RefreshRates();
           OrderClose(ticketbuy,lotsbuy2,bid,3,Magenta); 
        }
    }
    lotsbuy2=BuyLot;return(0);
} 

int orderclosesell(int ticketsell){
    string symbol = Symbol();int cnt;   
    for(cnt = OrdersTotal(); cnt >= 0; cnt--){
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);       
        if(OrderSymbol() == symbol && OrderMagicNumber()==Magicsell) {
           ticketsell=OrderTicket();OrderSelect(ticketsell, SELECT_BY_TICKET, MODE_TRADES);lotssell2=OrderLots() ;                         
           double ask = MarketInfo(symbol,MODE_ASK); 
           RefreshRates();
           OrderClose(ticketsell,lotssell2,ask,3, Lime); 
        }
    }
    lotssell2=SellLot;return(0); 
}

int start(){
//----
    if(Balance!=0.0){
       if(Use_with_win==false){if(Balance<AccountBalance())LotKengayishi=1;}
       else if(Use_with_loss==false){if(Balance>AccountBalance())LotKengayishi=1;}
       else LotKengayishi=LotKengayishi;
    }Balance=AccountBalance();
    if(Use_MaxSpread==true)MaxSpread=MaxSpread; else if(Use_MaxSpread==false)MaxSpread=100;
    double MA=iMA(Symbol(),0,Ma_Period,0,Ma_Mode,PRICE_CLOSE,1); double profitbuy=0;double profitsell=0;string symbol = OrderSymbol();
    double spread = MarketInfo(symbol,MODE_SPREAD);double minLot = MarketInfo(symbol,MODE_MINLOT);
    if (minLot==0.01){dig=2;maxLot=MarketInfo(symbol,MODE_MAXLOT);}
    if (minLot==0.1){dig=1;maxLot=((AccountBalance()/2)/1000);}
    if(AccountEquity()<=Pulyechish) {
    if(OrdersTotalMagicbuy(Magicbuy)>0){
       double smbuy;
       for(cnt=0;cnt<OrdersTotal();cnt++){
            OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol() == Symbol() && OrderMagicNumber () == Magicbuy) {
               ticketbuy = OrderTicket();OrderSelect(ticketbuy,SELECT_BY_TICKET, MODE_TRADES);
               smbuy = smbuy+OrderLots();openpricebuy = OrderOpenPrice();lastlotbuy = OrderLots();
            }
       }
       {   
       if (smbuy+(NormalizeDouble((lastlotbuy*LotKengayishi),dig))<maxLot){     
           if(StepMode==0){
              if(Ask<=openpricebuy-Step*Point && Ask>MA && OrdersTotalMagicbuy(Magicbuy)<MaxBuy && (Ask-Bid)<MaxSpread){
                 lotsbuy2=lastlotbuy*LotKengayishi;
                 RefreshRates();ticketbuy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lotsbuy2,dig),Ask,Slippage,Ask - BittaPositsiyaSL * Point, Ask + BittaPositsiyaTP * Point,"SanityTREND",Magicbuy,0,Blue);
              }
           }
           if(StepMode==1){
              if(Ask<=openpricebuy-(Step+OrdersTotalMagicbuy(Magicbuy)+OrdersTotalMagicbuy(Magicbuy)-2)*Point && Ask>MA && OrdersTotalMagicbuy(Magicbuy)<MaxBuy && (Ask-Bid)<MaxSpread){
                 lotsbuy2=lastlotbuy*LotKengayishi;
                 RefreshRates();ticketbuy=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lotsbuy2,dig),Ask,Slippage,Ask - BittaPositsiyaSL * Point, Ask + BittaPositsiyaTP * Point,"SanityTREND",Magicbuy,0,Blue);
              } 
           }
       }
       }
    }
    if(OrdersTotalMagicsell(Magicsell)>0){
       double smsell;
       for(cnt=0;cnt<OrdersTotal();cnt++){
           OrderSelect(cnt,SELECT_BY_POS, MODE_TRADES);
           if(OrderSymbol() == Symbol() && OrderMagicNumber () == Magicsell){
              ticketsell = OrderTicket();OrderSelect(ticketsell,SELECT_BY_TICKET, MODE_TRADES);
              smsell = smsell + OrderLots();openpricesell = OrderOpenPrice();lastlotsell = OrderLots();
           }     
       }
       {
       if(smsell+(NormalizeDouble((lastlotsell*LotKengayishi),dig))<maxLot){
          if(StepMode==0){
             if(Bid>=openpricesell+Step*Point && Bid<MA && OrdersTotalMagicsell(Magicsell)<MaxSell && (Ask-Bid)<MaxSpread){
                lotssell2=lastlotsell*LotKengayishi;
                RefreshRates();ticketsell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lotssell2,dig),Bid,Slippage,Bid + BittaPositsiyaSL * Point,Bid - BittaPositsiyaTP * Point,"SanityTrend",Magicsell,0,Red);
             }
          }
          if(StepMode==1){
             if(Bid>=openpricesell+(Step+OrdersTotalMagicsell(Magicsell)+OrdersTotalMagicsell(Magicsell)-2)*Point && Bid<MA && OrdersTotalMagicsell(Magicsell)<MaxSell && (Ask-Bid)<MaxSpread){
                lotssell2=lastlotsell*LotKengayishi;
                RefreshRates();ticketsell=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lotssell2,dig),Bid,Slippage,Bid + BittaPositsiyaSL * Point,Bid - BittaPositsiyaTP * Point,"SanityTrend",Magicsell,0,Red);
             }
          }
       }
    }}  
}

if(AccountEquity()<=Pulyechish) {
if(Use_MaxSpread==true)MaxSpread=MaxSpread; else if(Use_MaxSpread==false)MaxSpread=100;
if(OrdersTotalMagicbuy(Magicbuy)<1){ 
   if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)>iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
   && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)>OverBought && Ask>MA && (Ask-Bid)<MaxSpread)ticketbuy = OrderSend(Symbol(),OP_BUY,BuyLot,Ask,Slippage,Ask - BittaPositsiyaSL * Point, Ask + BittaPositsiyaTP * Point,"SanityTrend",Magicbuy,0,Blue);
}
if(OrdersTotalMagicsell(Magicsell)<1){
   if(iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,0,1)<iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)
   && iStochastic(NULL,0,per_K,per_D,slow,MODE_LWMA,1,1,1)<OverSold && Bid<MA && (Ask-Bid)<MaxSpread)ticketsell = OrderSend(Symbol(),OP_SELL,SellLot,Bid,Slippage,Bid + BittaPositsiyaSL * Point,Bid - BittaPositsiyaTP * Point,"SanityTrend",Magicsell,0,Red);
}}

for(cnt=0;cnt<OrdersTotal();cnt++){
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()==Symbol() && OrderMagicNumber () == Magicbuy){
       ticketbuy = OrderTicket();OrderSelect(ticketbuy,SELECT_BY_TICKET, MODE_TRADES);profitbuy = profitbuy+OrderProfit() ;
       openpricebuy = OrderOpenPrice();
    }
}  

tpb = (OrdersTotalMagicbuy(Magicbuy)*UmumiyTP*Point)+openpricebuy;
double bid = MarketInfo(Symbol(),MODE_BID);
if(profitbuy>0 || AccountEquity()>=Pulyechish){
   if (Bid>=tpb) orderclosebuy(ticketbuy);
}
for(cnt=0;cnt<OrdersTotal();cnt++){   
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magicsell){
        ticketsell = OrderTicket();OrderSelect(ticketsell,SELECT_BY_TICKET, MODE_TRADES);profitsell = profitsell+OrderProfit();
        openpricesell = OrderOpenPrice(); 
    }
}
tps = openpricesell-(OrdersTotalMagicsell(Magicsell)*UmumiyTP*Point);
double ask = MarketInfo(Symbol(),MODE_ASK);    
if(profitsell>0 || AccountEquity()>=Pulyechish){
   if (Ask<=tps)orderclosesell(ticketsell);    
}
free = AccountFreeMargin();balance = AccountBalance();    
for(cnt=0;cnt< OrdersTotal();cnt++){   
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()==Symbol() && OrderMagicNumber () == Magicbuy)  ticketbuy = OrderTicket();
    if(OrderSymbol()==Symbol() && OrderMagicNumber () == Magicsell) ticketsell = OrderTicket();
}
if(OrdersTotalMagicbuy(Magicbuy)==0){
   profitbuy=0;ticketbuy=0;tpb=0;
}
if (OrdersTotalMagicsell(Magicsell)==0){
    profitsell=0;ticketsell=0;tps=0;
}
Comment(
"---------------------------------------------------------------",
"\n",
"Balance = ",NormalizeDouble(balance,0),
"\n",
"---------------------------------------------------------------",
"\n",
"UmumiyBUY = ",OrdersTotalMagicbuy(Magicbuy),"           Lot = ",smbuy,
"\n",
"UmmumiySELL = ",OrdersTotalMagicsell(Magicsell),"        Lot = ",smsell,"\n",
"\n",
"---------------------------------------------------------------",
"\n","FoydaBUY = ",profitbuy,
"\n","FoydaSELL = ",profitsell);

//----
for(int ii=0; ii<2; ii+=2){
    ObjectDelete("rect"+ii);
    ObjectCreate("rect"+ii,OBJ_HLINE, 0, 0,tps);
    ObjectSet("rect"+ii, OBJPROP_COLOR, Red);
    ObjectSet("rect"+ii, OBJPROP_WIDTH, 1);
    ObjectSet("rect"+ii, OBJPROP_RAY, False);
}    
for(int rr=0; rr<2; rr+=2){
    ObjectDelete("rect1"+rr);
    ObjectCreate("rect1"+rr,OBJ_HLINE, 0, 0,tpb);      
    ObjectSet("rect1"+rr, OBJPROP_COLOR, Blue);
    ObjectSet("rect1"+rr, OBJPROP_WIDTH, 1);
    ObjectSet("rect1"+rr, OBJPROP_RAY, False);     
}
if(ticketbuy<0||ticketsell<0){if (GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}return (-1);}

return(0);
}  
//+------------------------------------------------------------------+