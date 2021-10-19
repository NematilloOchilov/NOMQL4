#property copyright "2021, MetaQuotes Software Corp." 
#property link      "https://www.mql4.com" 
#property version   "1.01"





#define MAGICMA   20131111
#include <Object.mqh>
//  Kabul qiluvchilar
 double     Lots                    =1;
input double     MaximumRisk             =0.01;
input double     DecreaseFactor          =3; 
 int        MovingPeriod1           =9;
 int        MovingPeriod2           =50;
 int        MovingShift             =0;
double ma1; // qizil 8 Buy
double ma2; // ko'k 21 Sell
double parabolic;
int res,res1;
double Sl;
double Tp;
double narx;
int a,v;
double Svecha[1];
double chekraqam;
double macd;
double macdS;
bool yopish;
int rsi;

void SdelkaOchish(){
  ma1=iMA(_Symbol,_Period,MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,0);
 ma2=iMA(_Symbol,_Period,MovingPeriod2,MovingShift,MODE_EMA,PRICE_CLOSE,0);
  macd=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   macdS=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
  parabolic=iSAR(_Symbol,_Period,0.02,0.2,0);
  rsi=iRSI(Symbol(),Period(),14,PRICE_CLOSE,0);
  double K0=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_MAIN,0);
  double D0=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_SIGNAL,0);
  double K1=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_MAIN,1);
  double D1=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_SIGNAL,1);
  string signal="";
  if((K0<25) && (D0<25))
  if((D0<K0) && (D1>K1)){signal="buy2";}
  if((K0>80) && (D0>80))
  if((D0>K0) && (D1<K1)){signal="sell";}
  
  if((D0>K0) && (D1>K1) && D0<30){signal="buy";}
  double STo=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_MAIN,0);
  double STs=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,0,MODE_SIGNAL,0);
  
  
//for(int b=OrdersTotal()-1;b>=0;b--){chekraqam=OrderSelect(b,SELECT_BY_POS,MODE_TRADES);}
if(a==0 ){
if(  signal=="buy"   ){      //  (macd>0 && macd>macdS &&  signal=="buy") || signal=="buy2" 
  Comment(" Buy");
  
  
    narx=Ask; a=1;

    Sl=NormalizeDouble(narx-100*Point,Digits); 
    Tp=NormalizeDouble(narx+40*Point,Digits); 
      
   res=OrderSend(Symbol(),OP_BUY,0.30,narx,3,0,Tp,"Buy",MAGICMA,0,Blue); 
   //res1=OrderSend(Symbol(),OP_SELL,(AccountFreeMargin()*MaximumRisk/100),narx,3,0,Bid-(100*_Point),"Buy",MAGICMA,0,Red); 
  
  
  
  //res=OrderSend(_Symbol,OP_BUY,Lots,Ask,3,Ask-200*Point,Ask+200*Point," Buy ",MAGICMA,0,Blue);
  //Comment("Buy");
  
}}
 

if(a==1){
if( signal=="sell" ){
   
  Comment(" Sell");
  
  narx=Bid; a=0;
  
   Sl=NormalizeDouble(narx+100*Point,Digits); 
   Tp=NormalizeDouble(narx-35*Point,Digits); 
    //res=OrderSend(_Symbol,OP_SELL,1,narx,3,0,Tp,"Sell",MAGICMA,0,Red); 
    //res1=OrderSend(Symbol(),OP_BUY,(AccountFreeMargin()*MaximumRisk/100),narx,3,0,Bid-(100*_Point),"Sell",MAGICMA,0,Blue);
   //a=0;
  
   //res=OrderSend(_Symbol,OP_SELL,Bid,3,Bid+200*Point,Bid-200*Point,"",MAGICMA,0,Red);
  // Comment("Sell");
} 

 
}}

void pulqoidasi(){

 for (int i=OrdersTotal()-1;i>=0;i--)
   {    
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      
         if (OrderSymbol()==Symbol())
               
         if(OrderType()==OP_SELL){
            /* narx=NormalizeDouble(OrderOpenPrice(),Digits);// narx ochilgan paytdagi senasi
            double joriynarx=NormalizeDouble(Ask,Digits);// bozordagi buy narxi
            Sl=NormalizeDouble(narx+400*Point,Digits);
            Tp=NormalizeDouble(narx-30*Point,Digits);
            bool Modifikatsiya;
            bool yopish;
            if(OrderStopLoss()>Bid+(100*_Point))  {
            //bool yopish;
            //yopish= OrderClose(OrderTicket(),0.8,Bid,3,Red);
            Modifikatsiya= OrderModify(OrderTicket(),OrderOpenPrice(),Bid+(100*_Point),OrderTakeProfit(),0,CLR_NONE);  
            // Modifikatsiya= OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Sl-320*Point,Digits),0,1);
            Comment(" modifikatsiya bo'ldi sellga");
            } */
            
            if(OrderTakeProfit()>Bid-(40*_Point))  { 
               narx=Bid; Tp=NormalizeDouble(narx-30*Point,Digits);
               res=OrderSend(Symbol(),OP_BUY,(AccountFreeMargin()*MaximumRisk/200),Ask,3,0,Tp,"Buy",MAGICMA,0,Blue);
            
            }
             /*
            if(narx-(100*_Point)==joriynarx){
               yopish=OrderClose(OrderTicket(),OrderLots(),Bid,1);
               }
               */
            
            
            
            }
                    
         
  if(OrderType()==OP_BUY){
     /* narx=NormalizeDouble(OrderOpenPrice(),Digits);
       joriynarx=NormalizeDouble(Bid,Digits);
       Sl=NormalizeDouble(narx-400*Point,Digits);
       Tp=NormalizeDouble(narx+30*Point,Digits);
      
     if(OrderStopLoss()<Ask-(100*_Point)){
      //yopish= OrderClose(OrderTicket(),0.8,Ask,3,Red);
      Modifikatsiya=OrderModify(OrderTicket(),OrderOpenPrice(),Ask-(100*_Point),OrderTakeProfit(),0,CLR_NONE);  v=1;
      // Modifikatsiya=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Sl+320*Point,Digits),0,1);
      Comment(" modifikatsiya bo'ldi buyga");
     }  */
     
     if(OrderTakeProfit()<Ask+(40*_Point)){
         narx=Ask; Tp=NormalizeDouble(narx+30*Point,Digits);
         res=OrderSend(Symbol(),OP_SELL,(AccountFreeMargin()*MaximumRisk/200),Bid,3,0,Tp,"Sell",MAGICMA,0,Red); 
     
     
     }
     /*
     if(narx+(100*_Point)>=Ask){
      yopish=OrderClose(OrderTicket(),OrderLots(),Ask,1);
      }
      */
     
    



}}
  

}



void sdelkayopish(){
parabolic=iSAR(_Symbol,_Period,0.02,0.2,0);
 ma1=iMA(_Symbol,PERIOD_CURRENT,MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,0);
 ma2=iMA(_Symbol,PERIOD_CURRENT,MovingPeriod2,MovingShift,MODE_EMA,PRICE_CLOSE,0);
  macd=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
 for(int i=0; i<OrdersTotal();i++)
{
 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)  break;
 if( OrderSymbol()==Symbol()) {
 

            
            if(OrderType()==OP_SELL){
              
                  if(parabolic<Bid || macd>0   ){//parabolic<Bid ||
                 // bool yopish;
                  yopish= OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
                     
                    }
                    if(yopish==true){Comment("  OrderClose bilan yopildi");}
                    }
                
            if(OrderType()==OP_BUY){
               
                  if(parabolic>Ask   ||   macd<0){ //parabolic>Ask   ||
                  
                   yopish= OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
                     
                    }
                    if(yopish==true){Comment("  OrderClose bilan yopildi");}
                    }

}}}

int OnInit()
  {
 ma1=iMA(_Symbol,PERIOD_CURRENT,MovingPeriod1,MovingShift,MODE_EMA,PRICE_CLOSE,0);
 ma2=iMA(_Symbol,PERIOD_CURRENT,MovingPeriod2,MovingShift,MODE_EMA,PRICE_CLOSE,0);
  macd=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
  parabolic=iSAR(_Symbol,_Period,0.02,0.2,0);
  if(macd>0){a=0;}
  if(macd<0){a=1;}
   return(0);
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
  
  if( OrdersTotal()<10){


 SdelkaOchish();}
  
//pulqoidasi();
//sdelkayopish();
  
  
  
  
  }