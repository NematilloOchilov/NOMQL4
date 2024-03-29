#property copyright "Programmed by Moses ©2021 hmuriithi6@gmail.com "
#property description   " "
#property description   " "
#property description "Release date 18.02.2021 \n\nPlease address all enquiries to hmuriithi6@gmail.com"
#property version   "1.0"
#property strict
#include <stdlib.mqh>

//If you want to restrict Expiry date, just put the date, e.g datetime ExpDate=D'2020.08.02'; (Format YYYY.MM.DD)
//If you dont want to restrict the expiry date, just put 0 e.g. datetime ExpDate=0;
datetime ExpDate=0;//D'2020.08.02';
//If you want to restrict to specific account number just the number below. e.g int ValidAccNumber=12345; will restrict to account number 12345
//If you do not want to restrict to specific account number just set to 0. e.g. int ValidAccNumber=0;
int ValidAccNumber=0;

#define EAPrefix "#MOSES_EA-"
#define UNUSED -1
#define FLAT 0
#define LONG 1
#define SHORT 2
#define VALID 3

enum ENUM_MODE{
   Unused,//Unused
   AsSignal,//As Signal
   AsFilter//As Filter
};

enum ENUM_SIGNAL_TO_USE{
   CurCandle=0,
   PrevCandle=1
};

string Name_Expert = "MOSES EA V1.0";

bool    ECNMode              = false;

input string Info1= "=== DISPLAY SETTINGS ===";
input bool DisplayInfo=true;
input color TextColor                           = clrWhite;
input int TextSize=8;
input int X=10;
input int Y=10;
input string Info2                              = "=== GENERAL SETTINGS ===";
input int     TradeMagic           =  5699;
input int     SuperTrendMagic           =  5670;
input int Slippage = 5;
input int MaxSpread=5;
input double Lots=0.01;
input double TP=0;
input double SL=0;
ENUM_SIGNAL_TO_USE SignalToUse=PrevCandle;
input bool CloseOnFriday=true;
input string CloseInFridayTime="23:00";
input bool CloseOnReverseSignal=true;
input string Info3                              = "=== SIGNAL SETTINGS ===";
input ENUM_MODE SignalMode=AsFilter;
input string SignalIndicatorFilename="Signal";
input string Info4                              = "=== TRENDALT SETTINGS ===";
input ENUM_MODE TrendAltMode=AsSignal;
input string TrendAltIndicatorFilename="trendalt_alert";
input int BarsCount=14;
input string Info5                              = "=== RENKO MAKER SETTINGS ===";
input ENUM_MODE RenkoMakerMode=AsFilter;
input string RenkoMakerIndicatorFilename="RenkoMaker_Confirm";
input string Info6 = "===TRAILING SETTINGS===";
input int BreakEven=10;
input bool UseTrailing=true;
input   int      TrailStart = 20;   
input   int      TrailDistance = 20;    

input string  Info8           =  "=== ALERTS SETTINGS ===";
input bool EnableAlert=true;
input string Info9="You Need to Enable and Set your email settings in menu Tools-Options-Email";
input bool EnableEmail=true;
input string Info10="You Need to Enable and Set Notifications in menu Tools-Options-Notification";
input bool EnableNotification=true;
input string Info11="Screenshoot file can be found at \\Data Folder\\MQL4\\Files";
input bool EnableScreenShot=true;

int TotalBuyOrd,TotalSellOrd;
double Stoplvl,Spread;
int TSlippage;
double TPoint;

int SignalTrend,TrendAltTrend,RenkoTrend,OverallSignal;
int SignalTREND,TrendAltTREND,RenkoTREND,OverallTrend;

string GVarLastBuyOPTime,GVarLastSellOPTime;
bool FirstInit;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   if(!IsValidAccExpiry(true)) return(INIT_FAILED);
   if(ValidAccNumber>0){//ACC Number Restricted
      if(AccountNumber()!=ValidAccNumber){
         Alert("INVALID ACCOUNT");
         return(INIT_FAILED);
      }
      if(ExpDate>0){
         if(TimeCurrent()>=ExpDate || TimeLocal()>=ExpDate){
            Alert(EAPrefix+" EXPIRED");
            return(INIT_FAILED);
         }
      }
   }
   else{//FREE ACC Number
      if(ExpDate>0){
         if(TimeCurrent()>=ExpDate || TimeLocal()>=ExpDate){
            Alert(EAPrefix+" EXPIRED");
            return(INIT_FAILED);
         }
      }
   }
   if(ExpDate) Alert(EAPrefix+" TRIAL VERSION VALID UNTIL :"+TimeToStr(ExpDate,TIME_DATE));   

   double a=iCustom(_Symbol,0,SignalIndicatorFilename,0,0);
   int err=GetLastError();
   if(err==4072){
      Alert(SignalIndicatorFilename+" is Not Exist!");
      return(INIT_PARAMETERS_INCORRECT);
   }

   double b=iCustom(_Symbol,0,TrendAltIndicatorFilename,"",false,false,"",false,BarsCount,0,0);
   err=GetLastError();
   if(err==4072){
      Alert(TrendAltIndicatorFilename+" is Not Exist!");
      return(INIT_PARAMETERS_INCORRECT);
   }

   double c=iCustom(_Symbol,0,RenkoMakerIndicatorFilename,false,false,"",false,1,0);
   err=GetLastError();
   if(err==4072){
      Alert(RenkoMakerIndicatorFilename+" is Not Exist!");
      return(INIT_PARAMETERS_INCORRECT);
   }

   GVarLastBuyOPTime=EAPrefix+" LastBuyOPTime"+_Symbol+DoubleToStr(TradeMagic,0);
   GVarLastSellOPTime=EAPrefix+" LastSellOPTime"+_Symbol+DoubleToStr(TradeMagic,0);
   if(IsTesting()){
      GVarLastBuyOPTime="TST_"+GVarLastBuyOPTime;
      GVarLastSellOPTime="TST_"+GVarLastSellOPTime;
   }
   FirstInit=true;
   
   if(SignalMode==AsFilter && RenkoMakerMode==AsFilter && TrendAltMode==AsFilter){
      Alert("One of indicator need to be set as Signal");
      return(INIT_PARAMETERS_INCORRECT);
   }

   Comment("Initializing....");
   OnTick();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   if(IsTesting()){
      GlobalVariablesDeleteAll("TST_");
   }
   ObjectsDeleteAll(0,EAPrefix);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   if(!IsValidAccExpiry(false)) ExpertRemove();
   
   if(FirstInit){
      Comment("");
      CreateObjects();
      FirstInit=false;
   }
   if (Digits ==5 || Digits ==3) {
      TPoint = Point * 10;
      Stoplvl = MarketInfo(Symbol(),MODE_STOPLEVEL)/10;
      Spread = MarketInfo(Symbol(), MODE_SPREAD)/10;
      TSlippage=Slippage*10;
   }
   else {
      TPoint = Point;
      Stoplvl = MarketInfo(Symbol(),MODE_STOPLEVEL);
      Spread = MarketInfo(Symbol(), MODE_SPREAD);
      TSlippage=Slippage;

   }
   
   TotalBuyOrd=0;
   TotalSellOrd=0;
   
   for (int counter = OrdersTotal(); counter >= 0; counter--) {
      if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderMagicNumber()==TradeMagic && OrderSymbol()==_Symbol){
         int ot=OrderType();
         if(ot==OP_BUY) {
            TotalBuyOrd++;
         }
         if(ot==OP_SELL) {
            TotalSellOrd++;
         }
      }
   }   
   
   CalculateIndicators();
   
   CheckAndCloseTrades();

   if(!IsTradeAllowed() || IsTradeContextBusy() || !IsConnected()) return;
   if(TotalBuyOrd>0 && OverallSignal==SHORT){
      Print("Attempt to close all Buy trade (Reverse Trend)");
      CloseAllOT(OP_BUY);
      TotalBuyOrd=0;
      if(TotalSellOrd==0){
         int ticket=OpenSell(Lots,TP,SL,TradeMagic,"");
         if(ticket>0){
            if(OrderSelect(ticket,SELECT_BY_TICKET)){
               GlobalVariableSet(GVarLastSellOPTime,OrderOpenTime());
            }
         }
      }
   }
   if(TotalSellOrd>0 && OverallSignal==LONG){
      Print("Attempt to close all Sell trade (Reverse Trend)");
      CloseAllOT(OP_SELL);
      if(TotalBuyOrd==0){
         int ticket=OpenBuy(Lots,TP,SL,TradeMagic,"");
         if(ticket>0){
            if(OrderSelect(ticket,SELECT_BY_TICKET)){
               GlobalVariableSet(GVarLastBuyOPTime,OrderOpenTime());
            }
         }
      }
   }
   
   if(Spread<MaxSpread && !IsFridayCloseTime()){
      datetime LastBuyOPTime=(datetime) GlobalVariableGet(GVarLastBuyOPTime);
      if(TotalBuyOrd==0 && LastBuyOPTime<Time[0]){
         if(OverallSignal==LONG){
            int ticket=OpenBuy(Lots,TP,SL,TradeMagic,"");
            if(ticket>0){
               if(OrderSelect(ticket,SELECT_BY_TICKET)){
                  GlobalVariableSet(GVarLastBuyOPTime,OrderOpenTime());
               }
            }
         }
      }
      datetime LastSellOPTime=(datetime)GlobalVariableGet(GVarLastSellOPTime);
      if(TotalSellOrd==0 && LastSellOPTime<Time[0]){
         if(OverallSignal==SHORT){
            int ticket=OpenSell(Lots,TP,SL,TradeMagic,"");
            if(ticket>0){
               if(OrderSelect(ticket,SELECT_BY_TICKET)){
                  GlobalVariableSet(GVarLastSellOPTime,OrderOpenTime());
               }
            }
         }
      }
   }
   
   PrintComments();      
  }
//+------------------------------------------------------------------+

void CalculateIndicators(){
   int shift=SignalToUse;
   CalculateSignal(shift);
   CalculateTrendAlt(shift);
   CalculateRenkoMaker(shift);
   if(SignalTrend==UNUSED && TrendAltTrend==UNUSED && RenkoTrend==UNUSED)OverallSignal=UNUSED;
   else{
      OverallSignal=FLAT;
      if((SignalTrend==LONG || SignalTrend==UNUSED) && (TrendAltTrend==LONG || TrendAltTrend==UNUSED) && (RenkoTrend==LONG || RenkoTrend==UNUSED)) OverallSignal=LONG;
      if((SignalTrend==SHORT || SignalTrend==UNUSED) && (TrendAltTrend==SHORT || TrendAltTrend==UNUSED) && (RenkoTrend==SHORT || RenkoTrend==UNUSED)) OverallSignal=SHORT;
   }
   if(SignalTREND==UNUSED && TrendAltTREND==UNUSED && RenkoTREND==UNUSED)OverallTrend=UNUSED;
   else{
      OverallTrend=FLAT;
      if((SignalTREND==LONG || SignalTREND==UNUSED) && (TrendAltTREND==LONG || TrendAltTREND==UNUSED) && (RenkoTREND==LONG || RenkoTREND==UNUSED)) OverallTrend=LONG;
      if((SignalTREND==SHORT || SignalTREND==UNUSED) && (TrendAltTREND==SHORT || TrendAltTREND==UNUSED) && (RenkoTREND==SHORT || RenkoTREND==UNUSED)) OverallTrend=SHORT;
   }
}

void CalculateSignal(int shift){
   SignalTrend=UNUSED;
   SignalTREND=UNUSED;
   if(SignalMode==Unused) return;
   SignalTrend=FLAT;
   SignalTREND=FLAT;
   double Up=iCustom(_Symbol,0,SignalIndicatorFilename,0,shift);
   double UpS1=iCustom(_Symbol,0,SignalIndicatorFilename,0,shift+1);
   double Dn=iCustom(_Symbol,0,SignalIndicatorFilename,2,shift);
   double DnS1=iCustom(_Symbol,0,SignalIndicatorFilename,2,shift+1);
   if(SignalMode==AsSignal){
      if(Up>0 && Up!=EMPTY_VALUE){//Current up
         if(DnS1>0 && DnS1!=EMPTY_VALUE) SignalTrend=LONG;
      }
      if(Dn>0 && Dn!=EMPTY_VALUE){//Current Short
         if(UpS1>0 && UpS1!=EMPTY_VALUE) SignalTrend=SHORT;
      }
   }
   else if(SignalMode==AsFilter){
      if(Up>0 && Up!=EMPTY_VALUE) SignalTrend=LONG;
      if(Dn>0 && Dn!=EMPTY_VALUE) SignalTrend=SHORT;
   }
   if(Up>0 && Up!=EMPTY_VALUE) SignalTREND=LONG;
   if(Dn>0 && Dn!=EMPTY_VALUE) SignalTREND=SHORT;
}

void CalculateTrendAlt(int shift){
   TrendAltTrend=UNUSED;
   TrendAltTREND=UNUSED;
   if(TrendAltMode==Unused) return;
   TrendAltTrend=FLAT;
   TrendAltTREND=FLAT;
   double a=iCustom(_Symbol,0,TrendAltIndicatorFilename,"",false,false,"",false,BarsCount,0,shift);
   double aS1=iCustom(_Symbol,0,TrendAltIndicatorFilename,"",false,false,"",false,BarsCount,0,shift+1);
   if(TrendAltMode==AsFilter){
      if(a>0) TrendAltTrend=LONG;
      if(a<0) TrendAltTrend=SHORT;
   }
   else if(TrendAltMode==AsSignal){
      if(a>0 && aS1<=0) TrendAltTrend=LONG;
      if(a<0 && aS1>=0) TrendAltTrend=SHORT;
   }
   if(a>0) TrendAltTREND=LONG;
   if(a<0) TrendAltTREND=SHORT;
}

void CalculateRenkoMaker(int shift){
   RenkoTrend=UNUSED;
   RenkoTREND=UNUSED;
   if(RenkoMakerMode==Unused) return;
   RenkoTrend=FLAT;
   RenkoTREND=FLAT;
   double Up=iCustom(_Symbol,0,RenkoMakerIndicatorFilename,false,false,"",false,1,shift);
   double UpS1=iCustom(_Symbol,0,RenkoMakerIndicatorFilename,false,false,"",false,1,shift+1);
   double Dn=iCustom(_Symbol,0,RenkoMakerIndicatorFilename,false,false,"",false,2,shift);
   double DnS1=iCustom(_Symbol,0,RenkoMakerIndicatorFilename,false,false,"",false,2,shift+1);
   if(RenkoMakerMode==AsFilter){
      if(Up>0 && Up!=EMPTY_VALUE) RenkoTrend=LONG;
      if(Dn<0) RenkoTrend=SHORT;
   }
   else if(RenkoMakerMode==AsSignal){
      if(Up>0 && Up!=EMPTY_VALUE && UpS1==0) RenkoTrend=LONG;
      if(Dn<0 && DnS1==0) RenkoTrend=SHORT;
   }
   if(Up>0 && Up!=EMPTY_VALUE) RenkoTREND=LONG;
   if(Dn<0) RenkoTREND=SHORT;
}

void CreateObjects(){
   RectLabelCreate(0,EAPrefix+"Background Top",0,X,Y+15,290,50,C'41,41,41',BORDER_FLAT,0);
   RectLabelCreate(0,EAPrefix+"Background Back",0,X,Y+65,290,250,C'41,41,41',BORDER_FLAT,0);
   string name=EAPrefix+"L0";
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0,name,OBJPROP_TEXT," ");
   ObjectSetInteger(0,name, OBJPROP_CORNER, 0);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, X+140);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, Y+35);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,12);
   ObjectSetString(0,name,OBJPROP_FONT,"Impact");
   name=EAPrefix+"L1";
   ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0,name,OBJPROP_TEXT," ");
   ObjectSetInteger(0,name, OBJPROP_CORNER, 0);
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE, X+20);
   ObjectSetInteger(0,name, OBJPROP_YDISTANCE, Y+45);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,TextSize);
   int cnt=16;
   for(int i=1;i<=cnt;i++){
      name=EAPrefix+"L"+DoubleToString(i,0)+"L";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0,name, OBJPROP_TEXT, " ");
      ObjectSetInteger(0,name, OBJPROP_CORNER, 0);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, X+130);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, Y+60+(i*15));
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,TextSize);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT);
      ObjectSetString(0,name,OBJPROP_FONT,"");

      name=EAPrefix+"L"+DoubleToString(i,0)+"R";
      ObjectCreate(0,name, OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0,name,OBJPROP_TEXT," ");
      ObjectSetInteger(0,name, OBJPROP_CORNER, 0);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, X+150);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, Y+60+(i*15));
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrNONE);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,TextSize);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString(0,name,OBJPROP_FONT,"");
   }
   ObjectSetText(EAPrefix+"L0","Initializing..",12,"Impact",C'0,141,236');
   ChartRedraw();
}

void PrintComments(){
   if(!DisplayInfo) return;
   if(IsTesting() && !IsVisualMode()) return;
   
   ObjectSetText(EAPrefix+"L0",WindowExpertName(),12,"Impact",C'0,141,236');

   ObjectSetText(EAPrefix+"L1L","Status",TextSize,NULL,TextColor);
   if(!IsExpertEnabled()) ObjectSetText(EAPrefix+"L1R","Please Enable Auto Trading",TextSize,NULL,clrRed);
   else if(!IsTradeAllowed()) ObjectSetText(EAPrefix+"L1R","Please Allow Trading",TextSize,NULL,clrRed);
   else ObjectSetText(EAPrefix+"L1R","Running",TextSize,NULL,clrLime);

   ObjectSetText(EAPrefix+"L2L","Time",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L2R",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),TextSize,NULL,TextColor);
   
   ObjectSetText(EAPrefix+"L4L","Spread",TextSize,NULL,TextColor);
   if(Spread<MaxSpread) ObjectSetText(EAPrefix+"L4R",DoubleToStr(Spread,2),TextSize,NULL,TextColor);
   else ObjectSetText(EAPrefix+"L4R",DoubleToStr(Spread,2)+" (MAX)",TextSize,NULL,clrRed);
   
   double Balance=AccountBalance();
   ObjectSetText(EAPrefix+"L5L","Balance",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L5R",DoubleToString(Balance,2),TextSize,NULL,TextColor);
   
   double Equity=AccountEquity();
   ObjectSetText(EAPrefix+"L6L","Equity",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L6R",DoubleToString(Equity,2),TextSize,NULL,TextColor);
      
   double Floating=Equity-Balance;
   double FloatingPercent=0;
   if(Balance!=0 && Floating!=0) FloatingPercent=Floating/Balance*100;
   color clrText=TextColor;
   if(Floating>=0) clrText=clrLime;
   else clrText=clrRed;
   ObjectSetText(EAPrefix+"L7L","Acc Floating",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L7R",DoubleToString(Floating,2)+" ("+DoubleToString(FloatingPercent,3)+"%)",TextSize,NULL,clrText);
   
   ObjectSetText(EAPrefix+"L8L","Leverage",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L8R","1:"+DoubleToString(AccountInfoInteger(ACCOUNT_LEVERAGE),0),TextSize,NULL,TextColor);
   
   ObjectSetText(EAPrefix+"L9L","Account Name",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L9R",AccountInfoString(ACCOUNT_NAME)+" ["+DoubleToString(AccountInfoInteger(ACCOUNT_LOGIN),0)+"]",TextSize,NULL,TextColor);
   
   ObjectSetText(EAPrefix+"L10L","Account Server",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L10R",AccountInfoString(ACCOUNT_SERVER),TextSize,NULL,TextColor);
   
   if(SignalMode==AsFilter || SignalMode==Unused) ObjectSetText(EAPrefix+"L12L","Signal Trend",TextSize,NULL,TextColor);
   else if(SignalMode==AsSignal) ObjectSetText(EAPrefix+"L12L","Signal",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L12R",SignalToStr(SignalTrend),TextSize,NULL,TextColor);
   
   if(TrendAltMode==AsFilter || SignalMode==Unused) ObjectSetText(EAPrefix+"L13L","Trend Alt Trend",TextSize,NULL,TextColor);
   else if(TrendAltMode==AsSignal) ObjectSetText(EAPrefix+"L13L","Trend Alt Signal",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L13R",SignalToStr(TrendAltTrend),TextSize,NULL,TextColor);
   
   if(RenkoMakerMode==AsFilter || RenkoMakerMode==Unused) ObjectSetText(EAPrefix+"L14L","Renko Trend",TextSize,NULL,TextColor);
   else if(RenkoMakerMode==AsSignal) ObjectSetText(EAPrefix+"L14L","Renko Signal",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L14R",SignalToStr(RenkoTrend),TextSize,NULL,TextColor);
   
   ObjectSetText(EAPrefix+"L15L","Overall Signal",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L15R",SignalToStr(OverallSignal),TextSize,NULL,TextColor);
   
   ObjectSetText(EAPrefix+"L16L","Overall Trend",TextSize,NULL,TextColor);
   ObjectSetText(EAPrefix+"L16R",SignalToStr(OverallTrend),TextSize,NULL,TextColor);
   
}

int OpenBuy(double lot, double tp, double sl, int magic,string str) { 
   if(!IsTradeAllowed() || IsTradeContextBusy() || !IsConnected()) return(0);
   RefreshRates();
   double AskPrice = NormalizeDouble(Ask,Digits);
   double dtp=0,dsl=0;
   if(tp>0) dtp=AskPrice+tp*TPoint;
   if(sl>0) dsl=AskPrice-sl*TPoint;
   string Comm = Name_Expert + PeriodToStr(Period());
   Print ("Attempt to Open "+DoubleToStr(lot,2)+" Buy @"+DoubleToStr(AskPrice,_Digits) + " SL " + DoubleToStr(dsl,Digits) + " TP " + DoubleToStr(dtp,Digits)," str:",str);
   int ticket=0;
   if (!ECNMode){
      if(IsTradeAllowed() && !IsTradeContextBusy()) ticket = OrderSend(Symbol(),OP_BUY,lot,AskPrice,TSlippage,dsl,dtp,str,magic,0,Blue); 
   }
   else {
      if(IsTradeAllowed() && !IsTradeContextBusy()) ticket = OrderSend(Symbol(),OP_BUY,lot,AskPrice,TSlippage,0,0,str,magic,0,Blue); 
      if (ticket>0 && (dtp!=0 || dsl!=0)){
         int cnt=0;
         while (!OrderModify(ticket,OrderOpenPrice(),dsl,dtp,0,Yellow) && cnt <=1){Sleep(1000);cnt++;}
      }
   }
   int err = GetLastError();
   if (ticket >0) {
      Print ("Order Opened " + Comm);
      string msg=StringConcatenate("Buy Order #"+DoubleToStr(ticket,0)+" Opened on ",_Symbol," ",PeriodToStr(_Period));
      if(EnableAlert) Alert(msg);
      if(EnableEmail) SendMail(StringConcatenate("Acc# ",AccountNumber(),"Alert"),msg);
      if(EnableNotification) SendNotification(msg);
      if(EnableScreenShot) ChartScreenShot(0,StringConcatenate(DoubleToStr(ticket,0)+" Buy ",_Symbol," ",PeriodToStr(_Period)," ",TimeToStr(TimeCurrent(),TIME_DATE),"_",TimeHour(Time[1]),"_",TimeMinute(Time[1]),".gif"),800,600);
   }
   else Print ("Error : "+ErrorDescription(err));
   return (ticket);
} 

int OpenSell(double lots, double tp, double sl, int magic,string str) { 
   if(!IsTradeAllowed() || IsTradeContextBusy() || !IsConnected()) return(0);
   string Comm = Name_Expert + PeriodToStr(Period());
   RefreshRates();
   double BidPrice = NormalizeDouble(Bid,Digits);
   double dtp=0,dsl=0;
   if(tp>0) dtp=BidPrice-tp*TPoint;
   if(sl>0) dsl=BidPrice+sl*TPoint;
   Print ("Attempt to Open "+DoubleToStr(lots,2)+" Sell @" + DoubleToStr(BidPrice,_Digits) + " SL " + DoubleToStr(dsl,Digits) + " TP " + DoubleToStr(dtp,Digits));
   int ticket=0;
   if (!ECNMode){
      if(IsTradeAllowed() && !IsTradeContextBusy())ticket = OrderSend(Symbol(),OP_SELL,lots,BidPrice,TSlippage,dsl,dtp,str,magic,0,Red); 
   }
   else {
      if(IsTradeAllowed() && !IsTradeContextBusy())ticket = OrderSend(Symbol(),OP_SELL,lots,BidPrice,TSlippage,0,0,str,magic,0,Red); 
      if (ticket>0 && (dtp!=0 || dsl!=0)){
         int cnt=0;
         while (!OrderModify(ticket,OrderOpenPrice(),dsl,dtp,0,Yellow) && cnt <=1) {Sleep(1000);cnt++;}
      }
   }
   int err = GetLastError();
   if (ticket >0) {
      Print (Comm);
      string msg=StringConcatenate("Sell Order #"+DoubleToStr(ticket,0)+" Opened on ",_Symbol," ",PeriodToStr(_Period));
      if(EnableAlert) Alert(msg);
      if(EnableEmail) SendMail(StringConcatenate("Acc# ",AccountNumber(),"Alert"),msg);
      if(EnableNotification) SendNotification(msg);
      if(EnableScreenShot) ChartScreenShot(0,StringConcatenate(DoubleToStr(ticket,0)+" Sell ",_Symbol," ",PeriodToStr(_Period)," ",TimeToStr(TimeCurrent(),TIME_DATE),"_",TimeHour(Time[1]),"_",TimeMinute(Time[1]),".gif"),800,600);
   }
   else Print ("Error : "+ErrorDescription(err));
   return (ticket);
} 

string PeriodToStr(int a){
   if(a==PERIOD_M1) return("M1");
   if(a==PERIOD_M5) return("M5");
   if(a==PERIOD_M15) return("M15");
   if(a==PERIOD_M30) return("M30");
   if(a==PERIOD_H1) return("H1");
   if(a==PERIOD_H4) return("H4");
   if(a==PERIOD_D1) return("D1");
   if(a==PERIOD_W1) return("W1");
   if(a==PERIOD_MN1) return("MN1");
   return("M"+DoubleToStr(_Period,0));
}

string OTToStr(int ot){
   if(ot==OP_BUY) return("Buy");
   if(ot==OP_BUYLIMIT) return("Buy Limit");
   if(ot==OP_BUYSTOP) return("Buy Stop");
   if(ot==OP_SELL) return("Sell");
   if(ot==OP_SELLSTOP) return("Sell Stop");
   if(ot==OP_SELLLIMIT) return("Sell Limit");
   return("");
}

void CloseAllOT(int OT){
   if(IsTradeAllowed() && !IsTradeContextBusy() && IsConnected()){
      while(MyOrdersTotalOT(OT)>0){
         for (int counter = OrdersTotal(); counter >= 0; counter--) {
            if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderSymbol()==_Symbol && OrderMagicNumber()==TradeMagic){
               int ot=OrderType();
               int ticket=OrderTicket();
               if(OT==ot){
                  if(OT==OP_BUY){
                     if(OrderClose(ticket,OrderLots(),OrderClosePrice(),Slippage,clrBlue)) continue;
                  }
                  else if(OT==OP_SELL){
                     if(OrderClose(ticket,OrderLots(),OrderClosePrice(),Slippage,clrRed)) continue;
                  }
                  else if(OrderDelete(ticket,clrYellow)) {counter++;continue;}
               }
            }
         }
      }
   }
}

int MyOrdersTotalOT(int OT){
   int cnt=0;
   for (int counter = OrdersTotal(); counter >= 0; counter--) {
      if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderSymbol()==_Symbol && OrderMagicNumber()==TradeMagic){
         int ot=OrderType();
         if(OT==ot) cnt++; 
      }
   }
   return(cnt);
}

void CloseAll(){
   if(IsTradeAllowed() && !IsTradeContextBusy() && IsConnected()){
      while(MyOrdersTotal()>0){
         for (int counter = OrdersTotal(); counter >= 0; counter--) {
            if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderSymbol()==_Symbol && OrderMagicNumber()==TradeMagic){
               int ot=OrderType();
               int ticket=OrderTicket();
               if(ot==OP_BUY){
                  if(OrderClose(ticket,OrderLots(),OrderClosePrice(),Slippage,clrBlue)) continue;
               }
               else if(ot==OP_SELL){
                  if(OrderClose(ticket,OrderLots(),OrderClosePrice(),Slippage,clrRed)) continue;
               }
               else if(OrderDelete(ticket,clrYellow)) {counter++;continue;}
            }
         }
      }
   }
}

int MyOrdersTotal(){
   int cnt=0;
   for (int counter = OrdersTotal(); counter >= 0; counter--) {
      if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderSymbol()==_Symbol && OrderMagicNumber()==TradeMagic){
         cnt++; 
      }
   }
   return(cnt);
}

string SignalToStr( int a){
   if(a==UNUSED) return("UNUSED");
   if(a==LONG) return("LONG");
   if(a==SHORT) return("SHORT");
   if(a==VALID) return("VALID");
   return("FLAT");
}

void CheckAndCloseTrades(){
   if(CloseOnFriday){
      if(TotalBuyOrd+TotalSellOrd>0){
         if(IsFridayCloseTime()){
            Print("Attempt to close All trades (CloseOnFriday)");
            CloseAll();
            TotalBuyOrd=0;
            TotalSellOrd=0;
         }
      }
   }
   
   if(CloseOnReverseSignal){
      if(TotalBuyOrd>0 && OverallTrend==SHORT){
         Print("Attempt to Close All Buy (CloseOnReverseSignal)");
         CloseAllOT(OP_BUY);
         TotalBuyOrd=0;
      }
      if(TotalSellOrd>0 && OverallTrend==LONG){
         Print("Attempt to Close All Sell (CloseOnReverseSignal)");
         CloseAllOT(OP_SELL);
         TotalSellOrd=0;
      }
   }
   
   for (int counter = OrdersTotal(); counter >= 0; counter--) {
      if (OrderSelect(counter, SELECT_BY_POS) == TRUE && OrderSymbol() == Symbol() && OrderMagicNumber()==TradeMagic){
         int ticket=OrderTicket();
         double OrdSL=NormalizeDouble(OrderStopLoss(),_Digits);
         double OrdOP=NormalizeDouble(OrderOpenPrice(),_Digits);
         double OrdCL=NormalizeDouble(OrderClosePrice(),_Digits);
         double OrdLots=OrderLots();
         datetime OrdOPTime=OrderOpenTime();
         int OrdOPTimeShift=iBarShift(_Symbol,0,OrdOPTime);
         if(OrderType()==OP_BUY){
            //BE
            if(BreakEven>0 && OrdCL>=NormalizeDouble(OrdOP+BreakEven*TPoint,_Digits)){
               if(OrdSL==0 || OrdSL<OrdOP){
                  Print("Attempt to Modify Order #"+DoubleToStr(ticket,0)+" SL to BE");
                  if(OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),OrderExpiration(),clrNONE)){
                     continue;
                  }
                  else {
                     int err=GetLastError();
                     Print("Error Modify Order, err: "+ErrorDescription(err));
                  }
               }
            }
            //TRAILING
            if(UseTrailing && OrdOP<=OrdCL-TrailStart*TPoint){
               double dsl=OrdCL-TrailDistance*TPoint;
               if(OrdSL==0 || OrdSL<dsl){
                  Print("Attempt to Trail #",ticket," SL to "+DoubleToStr(dsl,_Digits));
                  if(OrderModify(ticket,OrderOpenPrice(),dsl,OrderTakeProfit(),OrderExpiration()))continue;
               }
            }
         }
         if(OrderType()==OP_SELL){
            //BE
            if(BreakEven>0 && OrdCL<=NormalizeDouble(OrdOP-BreakEven*TPoint,_Digits)){
               if(OrdSL==0 || OrdSL>OrdOP){
                  Print("Attempt to Modify Order #"+DoubleToStr(ticket,0)+" SL to BE");
                  if(OrderModify(ticket,OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),OrderExpiration(),clrNONE)){
                     continue;
                  }
                  else {
                     int err=GetLastError();
                     Print("Error Modify Order, err: "+ErrorDescription(err));
                 }
              }
            }
            //TRAILING
            if(UseTrailing && OrdOP>=OrdCL+TrailStart*TPoint){
               double dsl=OrdCL+TrailDistance*TPoint;
               if(OrdSL==0 || OrdSL>dsl){
                  Print("Attempt to Trail #",ticket," SL to "+DoubleToStr(dsl,_Digits));
                  if(OrderModify(ticket,OrderOpenPrice(),dsl,OrderTakeProfit(),OrderExpiration()))continue;
               }
            }
         }
      }
   }
}

bool IsFridayCloseTime(){
   if(DayOfWeek()==FRIDAY){
      datetime ST=StrToTime(TimeToStr(TimeCurrent(),TIME_DATE)+" "+CloseInFridayTime);
      if(TimeCurrent()>=ST) return(true);
      else return(false);
   }
   return(false);
}

//+------------------------------------------------------------------+ 
//| Create rectangle label                                           | 
//+------------------------------------------------------------------+ 
bool RectLabelCreate(const long             chart_ID=0,               // chart's ID 
                     const string           name="RectLabel",         // label name 
                     const int              sub_window=0,             // subwindow index 
                     const int              x=0,                      // X coordinate 
                     const int              y=0,                      // Y coordinate 
                     const int              width=50,                 // width 
                     const int              height=18,                // height 
                     const color            back_clr=C'236,233,216',  // background color 
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type 
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                     const color            clr=C'61,61,61',               // flat border color (Flat) 
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style 
                     const int              line_width=1,             // flat border width 
                     const bool             back=false,               // in the background 
                     const bool             selection=false,          // highlight to move 
                     const bool             hidden=true,              // hidden in the object list 
                     const long             z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create a rectangle label 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a rectangle label! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- set border type 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set flat border color (in Flat mode) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set flat border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set flat border width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the label by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
} 

bool IsValidAccExpiry(bool alert){
   if(ValidAccNumber>0){//ACC Number Restricted
      if(AccountNumber()!=ValidAccNumber){
         Alert("INVALID ACCOUNT");
         return(false);
      }
      if(ExpDate>0){
         if(TimeCurrent()>=ExpDate || TimeLocal()>=ExpDate){
            Alert(EAPrefix+" EXPIRED");
            return(false);
         }
      }
   }
   else{//FREE ACC Number
      if(ExpDate>0){
         if(TimeCurrent()>=ExpDate || TimeLocal()>=ExpDate){
            Alert(EAPrefix+" EXPIRED");
            return(false);
         }
      }
   }
   if(alert && ExpDate>0) Alert(EAPrefix+" TRIAL VERSION VALID UNTIL :"+TimeToStr(ExpDate,TIME_DATE));  
   return(true); 
}