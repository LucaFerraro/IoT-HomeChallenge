// $Id: Homechallenge5.nc,v 1.5 2010-06-29 22:07:17 scipio Exp $

#include "Homechallenge5.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"


configuration Homechallenge5AppC {}
implementation {

  components MainC, Homechallenge5C as App;

  components new AMSenderC(AM_RADIO_COUNT_MSG);

  components new AMReceiverC(AM_RADIO_COUNT_MSG);

  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;

  components ActiveMessageC;
  components SerialStartC;
  components PrintfC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Timer0 -> Timer0;
  App.Timer1 -> Timer1;
  App.Packet -> AMSenderC;
}


