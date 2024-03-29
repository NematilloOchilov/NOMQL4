struct prices
  {
   string          symbol; // date
   int type, magic[];  // bid price
   double            ask;  // ask price
  };

void start() {
    int handle=FileOpen("currency.csv",FILE_READ|FILE_CSV,";");
    if(handle!=INVALID_HANDLE) {
        string symbol = FileReadString(handle);
        int type = StrToInteger(FileReadString(handle));
        double price = StrToDouble(FileReadString(handle));
        double sl = StrToDouble(FileReadString(handle));
        double tp = StrToDouble(FileReadString(handle));
        int magic = StrToInteger(FileReadString(handle));
        Print(symbol, type, price, sl, tp, magic);
        FileClose(handle);
        FileDelete("currency.csv");
    }
}