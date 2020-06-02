/*
 * IoT Project.
 * Luca Ferraro, fabio Losavio, Bernardo Camajori Tedeschini.
 */
 
#include "Timer.h"
#include "Project.h"
#include "stdlib.h"
#include "printf.h"


module ProjectC @safe() {

  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as Timer0;
    interface SplitControl as AMControl;
    interface Packet;
  }
  
  // Define the correct radio interface.
  #ifdef __CC2420_H__
  uses interface CC2420Packet;
  #elif defined(TDA5250_MESSAGE_H)
  uses interface Tda5250Packet;    
  #else
  uses interface PacketField<uint8_t> as PacketRSSI;
  #endif 
}


implementation {

  message_t packet;

  int16_t getRssi(message_t *msg);		// function to get received power (dBm)
  int16_t moteMemory[NUMBER_OF_MOTES][2];	// [mote1: bool, time][mote2: bool, time]...
  
  
  event void Boot.booted() {
    call AMControl.start();
  }


  event void AMControl.startDone(error_t err) {
    int8_t i;
 	int8_t j;

    if (err == SUCCESS) {
      // Defining mote sending timer
      call Timer0.startPeriodic( 500 );
      
      for(i=0; i < NUMBER_OF_MOTES; i++){
      	for(j=0; j < 2; j++){
      		moteMemory[i][j] = 0;
      	}
      }

    }
    else {
      call AMControl.start();
      
    }
  }


  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  


  // Timer expires, send a broadcast message:
  event void Timer0.fired() {
    int8_t i;
  	radio_count_msg_t* rcm;
  	
    rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
	
	if (rcm == NULL) {
		return;

    }

    // Filling messages fields:
    rcm->senderid = TOS_NODE_ID; // ID of the node
    
    for(i=0; i < NUMBER_OF_MOTES; i++){
    	if(moteMemory[i][0] == 1){
    		if(moteMemory[i][1] == NOTIFICATION_THRESHOLD){
    			moteMemory[i][1] = 0;
    			moteMemory[i][0] = 0;
    		}
    		else{
    		    moteMemory[i][1] += 1;
    		}
    	}
    }

    if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

    	dbg("Project", "Project: packet sent.\n");

    }
  
  }



  // When a packet is received:
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
  	
    if (len != sizeof(radio_count_msg_t)) {

      return bufPtr;
    
    }

    else {

	  radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

      rcm->rssi = getRssi(bufPtr);		// get the rssi
      
      if (rcm->rssi > POWER_THRESHOLD){
      	if(moteMemory[rcm->senderid-1][0] == 0){
      		moteMemory[rcm->senderid-1][0] = 1;
      		
			// print a message which will be sent to NodeRed
			printf("tx %u, rx %u, rssi %d \n", TOS_NODE_ID, rcm->senderid, rcm->rssi);
			printfflush();
		  
      	}
      }


      return bufPtr;

    }
    
  }

  
  

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
	  return;
  }


  // override the getRssi function according to the radio interface used by the mote
  #ifdef __CC2420_H__  
    int16_t getRssi(message_t *msg){
      return (int16_t) call CC2420Packet.getRssi(msg);
    }
  #elif defined(CC1K_RADIO_MSG_H)
      int16_t getRssi(message_t *msg){
      cc1000_metadata_t *md =(cc1000_metadata_t*) msg->metadata;
      return md->strength_or_preamble;
    }
  #elif defined(PLATFORM_IRIS) || defined(PLATFORM_UCMINI)
    int16_t getRssi(message_t *msg){
      if(call PacketRSSI.isSet(msg))
        return (int16_t) call PacketRSSI.get(msg);
      else
        return 0xFFFF;
    }
  #elif defined(TDA5250_MESSAGE_H)
    int16_t getRssi(message_t *msg){
        return call Tda5250Packet.getSnr(msg);
    }
  #else
    #error Radio chip not supported! This demo currently works only \
          for motes with CC1000, CC2420, RF230, RFA1 or TDA5250 radios.  
  #endif

}
