// $Id: Homechallenge5.nc,v 1.5 2010-06-29 22:07:17 scipio Exp $

#include "Homechallenge5.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"


configuration Homechallenge5AppC {}
implementation {

  components MainC, Homechallenge5C as App;

  components new AMSenderC(AM_RADIO_COUNT_MSG);

  // new
  components new AMSenderC(AM_RSSIMSG) as RssiMsgSender;

  components new AMReceiverC(AM_RADIO_COUNT_MSG);

  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;

  components ActiveMessageC;
  components SerialStartC;
  components PrintfC;
  components RandomC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Timer0 -> Timer0;
  App.Timer1 -> Timer1;
  App.Packet -> AMSenderC;

  // new
  App.RssiMsgSend -> RssiMsgSender;

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

  // new
  //App-> BaseStationC.RadioIntercept[AM_RSSIMSG];

}


