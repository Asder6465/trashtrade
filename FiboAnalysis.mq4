//+------------------------------------------------------------------+
//|                                                 FiboAnalysis.mq4 |
//|                                                      B.Kompanets |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "B.Kompanets"
#property link      ""
#property version   "1.03"
#property strict


input double Fibo_100, Fibo_0;
double takeprofit161, takeprofit261, stoploss; // Параметры для открытия ордеров
int ticket161, ticket261;      // Тикеты открытых ордеров
input int LossVolume     = 2;  //Допустимый объем потерь в процентах
input int Magic = 16384;       // Произвольное число, идентификатор советника
input bool StartImediate = true;      // ДА,если цена в корридоре

bool TestBoolean;
double DeltaSLTest;
int DeltaSL;                     //Stoploss в пипсах
bool AllowNewOrder = true;       // ДА, если график вошел в коридор
bool TimeNow;                    // ДА, если текущее время :00 минут
bool Order161, Order261;         // ДА, если ордер активен


double StartVolume       = 0;    //Рекомендуемый объем сделки



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   AllowNewOrder = StartImediate;

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
  
//+--------------Определение рекомендуемого объема сделки--------------------------------------------------  
void CalculationOrderVolume ()
{  
MqlTick last_tick; 
if (stoploss != 0)
  {
   TestBoolean = (SymbolInfoTick(Symbol(),last_tick)) ;
   DeltaSLTest = (last_tick.bid - stoploss);
   DeltaSL = MathAbs (DeltaSLTest/Point);
   StartVolume = (AccountBalance() * (LossVolume * 0.01))/(DeltaSL);
  }
}
//+--------------Конец определения рекомендуемого объема сделки--------------------------------------------------
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  // Проверка активности ордеров  
   int total = OrdersTotal ();
   Order161 = false;
   for(int pos=0;pos<total;pos++) 
      {
         if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue; 
         if (OrderSymbol() == Symbol()) 
            if (OrderMagicNumber() == Magic)
            {
               Order161 = true;   
               AllowNewOrder = false;
               
            }
      }
   Comment ("Fibo_0 = ", Fibo_0," SL = ",stoploss, " Fibo_100 = ", Fibo_100, " TP = ",takeprofit161, " Volume = ",StartVolume, " Order161 = ",Order161, " AllowNewOrder = ",AllowNewOrder); 

// Поиск точки времени.
//   Comment ("Fibo_0 = ", Fibo_0," SL = ",stoploss, " Fibo_100 = ", Fibo_100, " TP = ",takeprofit161, " Volume = ",StartVolume); 
if (TimeMinute(TimeCurrent()) == 0)
  {

  // Проверка возврата в коридор фибы
  
      if ((iClose (NULL,PERIOD_H1,1) < Fibo_100) && (iClose (NULL,PERIOD_H1,1) > Fibo_0))
        AllowNewOrder = true;
  
  // Проверка активности ордеров  
//     Order161 = OrderSelect(ticket161, SELECT_BY_TICKET,MODE_TRADES);
  
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  
//   if (OrderSelect(ticket161, SELECT_BY_TICKET,MODE_TRADES))
//     Order161 = true; 
/* 
     { 
      if (OrderCloseTime() == 0)
        Order161 = true;
      else 
        Order161 = false;
     }
*/     
//    else 
//      Order161 = false;     
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      
 if (AllowNewOrder)   
{  
//===============================================================  
//--------------- Если график идет вверх ------------------------  
   if (iClose (NULL,PERIOD_H1,1) > Fibo_100)
     {
// Расчет настроек.
//     CalculationOrderVolume ();
      takeprofit161 = Fibo_0 + ((Fibo_100 - Fibo_0) * 1.54);
      takeprofit261 = Fibo_0 + ((Fibo_100 - Fibo_0) * 2.50);
      stoploss = Fibo_0 - (20 * Point);
//---------------------------------
{  
MqlTick last_tick; 
if (stoploss != 0)
  {
   TestBoolean = (SymbolInfoTick(Symbol(),last_tick)) ;
   DeltaSLTest = (last_tick.ask - stoploss);
   DeltaSL = MathAbs (DeltaSLTest/Point);
   StartVolume = (AccountBalance() * (LossVolume * 0.01))/(DeltaSL);
  }
}      
//---------------------------------

// Проверка и открытие ордеров
      if (!Order161)
       { 
        if (iStochastic(NULL,PERIOD_D1,21,3,3,MODE_SMA,1,MODE_SIGNAL,0)<90) //Проверка стохастика в зоне 0-10. Если не в зоне - можно открывать Buy
          {
          string Order_Comment = Symbol () + " " + Magic + " " + "FiboAnalysis";  //Формируем коментарий
          ticket161=OrderSend(Symbol(),OP_BUY,StartVolume,Ask,5,stoploss,takeprofit161,Order_Comment,Magic,0,clrGreen);    //Окрываем ордер и запоминаем его тикет
          AllowNewOrder = false; // Блокировка последующего открытия ордеров пока график не вернулся в коридор FIBO
          }
       }
     }
     
//==============================================================     
//--------------- Если график идет вниз ------------------------  
   if (iClose (NULL,PERIOD_H1,1) < Fibo_0)
     {
// Расчет настроек.
//      CalculationOrderVolume ();
      takeprofit161 = Fibo_100 - ((Fibo_100 - Fibo_0) * 1.54);
      takeprofit261 = Fibo_100 - ((Fibo_100 - Fibo_0) * 2.50);
      stoploss = Fibo_100 + (20 * Point);
//---------------------------------
{  
MqlTick last_tick; 
if (stoploss != 0)
  {
   TestBoolean = (SymbolInfoTick(Symbol(),last_tick)) ;
   DeltaSLTest = (last_tick.bid - stoploss);
   DeltaSL = MathAbs (DeltaSLTest/Point);
   StartVolume = (AccountBalance() * (LossVolume * 0.01))/(DeltaSL);
  }
}      
//---------------------------------      
      
// Проверка и открытие ордеров
      if (!Order161)
       {
        if (iStochastic(NULL,PERIOD_D1,21,3,3,MODE_SMA,1,MODE_SIGNAL,0)>10)  //Проверка стохастика в зоне 0-10. Если не в зоне - можно открывать Sell
          {
          string Order_Comment = Symbol () + " " + Magic + " " + "FiboAnalysis";  //Формируем коментарий
          ticket161=OrderSend(Symbol(),OP_SELL,StartVolume,Bid,5,stoploss,takeprofit161,Order_Comment,Magic,0,clrGreen);   //Окрываем ордер и запоминаем его тикет
          AllowNewOrder = false; // Блокировка последующего открытия ордеров пока график не вернулся в коридор FIBO
          }
       }
     }
  }
}

}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
