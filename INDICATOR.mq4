pip install mt4_hst


double AC				=iAC(NULL, 0, 0);
double AD				=iAD(NULL, 0, 0);
double Alligator		=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 1);
double ADX				=iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0);
double ATR				=iATR(NULL,0,12,0);
double AO				=iAO(NULL, 0, 2);
double BearsPower		=iBearsPower(NULL, 0, 13,PRICE_CLOSE,0);
double Bands			=iBands(NULL,0,20,2,0,PRICE_LOW,MODE_LOWER,0);
double BandsOnArray	    =iBandsOnArray(rsi,0,2,0,0,MODE_LOWER,0);
double BullsPower		=iBullsPower(NULL, 0, 13,PRICE_CLOSE,0);
double Fractals		    =iFractals(NULL, 0, MODE_UPPER, 3);
double Force			=iForce(NULL, 0, 13,MODE_SMA,PRICE_CLOSE,0);
double EnvelopesOnArray =iEnvelopesOnArray(rsi,10,13,MODE_SMA,0,0.2,MODE_UPPER,0);
double Envelopes		=iEnvelopes(NULL, 0, 13,MODE_SMA,10,PRICE_CLOSE,0.2,MODE_UPPER,0);
double DeMarker		    =iDeMarker(NULL, 0, 13, 1);
double Custom			=iCustom(NULL, 0, "SampleInd",13,1,0);
double CCIOnArray		=iCCIOnArray(rsi,0,12,0);
double CCI				=iCCI(Symbol(),0,12,PRICE_TYPICAL,0);
double StdDevOnArray	=iStdDevOnArray(rsi,100,10,0,MODE_EMA,0);
double Stochastic		=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);
double WPR				=iWPR(NULL,0,14,0);
double StdDev			=iStdDev(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,0);
double RVI				=iRVI(NULL, 0, 10,MODE_MAIN,0);
double RSIOnArray		=iRSIOnArray(rsi,1000,14,0);
double RSI				=iRSI(NULL,0,14,PRICE_CLOSE,0);
double SAR				=iSAR(NULL,0,0.02,0.2,0);
double OBV				=iOBV(NULL, 0, PRICE_CLOSE, 1);
double MACD			    =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
double OsMA			    =iOsMA(NULL,0,12,26,9,PRICE_OPEN,1);
double MAOnArray		=iMAOnArray(rsi,0,5,0,MODE_LWMA,0);
double MA				=iMA(NULL,0,13,8,MODE_SMMA,PRICE_MEDIAN,0);
double MFI				=iMFI(NULL,0,14,0);
double MomentumOnArray  =iMomentumOnArray(rsi,100,12,0);
double Momentum		    =iMomentum(NULL,0,12,PRICE_CLOSE,0);
double BWMFI			=iBWMFI(NULL, 0, 0);
double Ichimoku		    =iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, 1);
double Gator			=iGator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_UPPER, 1);

*/