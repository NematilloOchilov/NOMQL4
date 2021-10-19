//+------------------------------------------------------------------+
//|                                         ZigZag_with_patterns.mq4 |
//|                                          modify by franiok |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "rewritten by CrazyChart, modify by franiok www.freefxsystem.com"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
//---- input parameters
//extern double    TakeProfit=250.0;
//extern double    Lots=1;
extern int       barn=1000;
extern int       Length=20;
extern int       PatternLength=10;
extern int        PatternWidth=4;
extern color       PatternColor = Yellow;
extern bool       DrawZigZag = true;
extern bool    ShowValues = true;
extern color   ValueColor = Orange;
//---- buffers
double ExtMapBuffer1[];
//double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexEmptyValue(0,0.0);
  //SetIndexDrawBegin(0, barn);
  if (DrawZigZag == true)  {SetIndexStyle(0,DRAW_SECTION);}
  else {SetIndexStyle(0,DRAW_NONE);}
   SetIndexBuffer(0,ExtMapBuffer1);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
ObjectsDeleteAll();
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
 
   int shift,Swing,Swing_n,alf,uzl,i,zu,zd,mv;
   double LL,HH,BH,BL,NH,NL; 
   double Uzel[10000][3]; 
   string text;
    
    ObjectDelete(OBJ_TREND);
    

// loop from first bar to current bar (with shift=0) 
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[barn];BL=Low[barn];zu=barn;zd=barn; 



for (shift=barn;shift>=0;shift--) { 
      LL=10000000;HH=-100000000; 
   for (i=shift+Length;i>=shift+1;i--) { 
         if (Low[i]< LL) {LL=Low[i];
           
         } 
         if (High[i]>HH) {HH=High[i];} 

  }
 
   if (Low[shift]<LL && High[shift]>HH){ 
      Swing=2; 
      if (Swing_n==1) {zu=shift+1;} 
      if (Swing_n==-1) {zd=shift+1;
 
      } 
      
   } else { 
      if (Low[shift]<LL) {Swing=-1;} 
      if (High[shift]>HH) {Swing=1;} 
   } 

   if (Swing!=Swing_n && Swing_n!=0) { 
   if (Swing==2) {
      Swing=-Swing_n;BH = High[shift];BL = Low[shift]; 
   } 
   uzl=uzl+1; 
   if (Swing==1) {
      Uzel[uzl][1]=zd;
      Uzel[uzl][2]=BL;
      NewSid(i,zd,BL);
     
   } 
   if (Swing==-1) {
      Uzel[uzl][1]=zu;
      Uzel[uzl][2]=BH; 
       NewSid(i,zu,BH);
   } 
      BH = High[shift];
      BL = Low[shift]; 
      

   } 
 
   
/*

 */
   
   

   if (Swing==1) { 
      if (High[shift]>=BH) {BH=High[shift];zu=shift;}} 
      if (Swing==-1) {
          if (Low[shift]<=BL) {BL=Low[shift]; zd=shift;}} 
      Swing_n=Swing; 
   } 

   

   
   for (i=1;i<=uzl;i++) { 
         mv=StrToInteger(DoubleToStr(Uzel[i][1],0));
      ExtMapBuffer1[mv]=Uzel[i][2];
      

   
   } 


   return(0);
  }
  
  void NewSid(int i, int re,  double Uzels)
{

int zed=re-PatternLength;

if (zed < 0)
   {
   ObjectCreate("priceLine1_"+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("priceLine1_"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet("priceLine1_"+i ,OBJPROP_PRICE1,Uzels);
  
   ObjectSet("priceLine1_"+i ,OBJPROP_TIME2,Time[re+PatternLength]); 
   ObjectSet("priceLine1_"+i ,OBJPROP_PRICE2,Uzels);   
    
   ObjectSet("priceLine1_"+i ,OBJPROP_COLOR,PatternColor);
   ObjectSet("priceLine1_"+i,OBJPROP_RAY, false);
   ObjectSet("priceLine1_"+i,OBJPROP_WIDTH,PatternWidth);
   

   }
   
   
   
   
  else {

   ObjectCreate("priceLine1_"+i,OBJ_TREND,0,0,0,0,0);
   ObjectSet("priceLine1_"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet("priceLine1_"+i ,OBJPROP_PRICE1,Uzels);
  
   ObjectSet("priceLine1_"+i ,OBJPROP_TIME2,Time[re-PatternLength]); 
   ObjectSet("priceLine1_"+i ,OBJPROP_PRICE2,Uzels);   
    
   ObjectSet("priceLine1_"+i ,OBJPROP_COLOR,PatternColor);
   ObjectSet("priceLine1_"+i,OBJPROP_RAY, false);
   ObjectSet("priceLine1_"+i,OBJPROP_WIDTH,PatternWidth);
}

      string high  = DoubleToStr(High[re],5);
      string low   = DoubleToStr(Low[re],5);
      string open  = DoubleToStr(Open[re],5);
      string close = DoubleToStr(Close[re],5);



if (ShowValues == true)

{
   ObjectCreate("price_text"+i,OBJ_TEXT,0,0,0);
   //ObjectSetText("price_text"+i,"Date: "+TimeToStr(Time[re],TIME_DATE | TIME_MINUTES)+" | Time: ",10,"Calibri", Green);
   
   ObjectSetText("price_text"+i,"Open: "+open+" | High: "+high+" | Low: "+low+" | Close: "+close,8,"Calibri", ValueColor);
   ObjectSet("price_text"+i ,OBJPROP_TIME1,Time[re]);
   ObjectSet("price_text"+i ,OBJPROP_PRICE1,Uzels);
}
}
//+------------------------------------------------------------------+