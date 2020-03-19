// $Id: Homechallenge1.nc,v 1.5 2010-06-29 22:07:17 scipio Exp $

#include "Homechallenge1.h"


configuration Homechallenge1AppC {}
implementation {

  components MainC, Homechallenge1C as App, LedsC;

  components new AMSenderC(AM_RADIO_COUNT_MSG);

  components new AMReceiverC(AM_RADIO_COUNT_MSG);

  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;

  components ActiveMessageC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Timer1 -> Timer1;
  App.Timer2 -> Timer2;
  App.Packet -> AMSenderC;
}


