// $Id: Project.nc,v 1.5 2010-06-29 22:07:17 scipio Exp $

#include "Project.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"


configuration ProjectAppC {}
implementation {

  components MainC, ProjectC as App;

  components new AMSenderC(AM_RADIO_COUNT_MSG);

  components new AMReceiverC(AM_RADIO_COUNT_MSG);

  components new TimerMilliC() as Timer0;

  components ActiveMessageC;
  components SerialStartC;
  components PrintfC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;


  #ifdef __CC2420_H__
    components CC2420ActiveMessageC;
    App -> CC2420ActiveMessageC.CC2420Packet;
  #elif  defined(PLATFORM_IRIS)
    components  RF230ActiveMessageC;
    App -> RF230ActiveMessageC.PacketRSSI;
  #elif defined(PLATFORM_UCMINI)
    components  RFA1ActiveMessageC;
    App -> RFA1ActiveMessageC.PacketRSSI;
  #elif defined(TDA5250_MESSAGE_H)
    components Tda5250ActiveMessageC;
    App -> Tda5250ActiveMessageC.Tda5250Packet;
  #endif



}


