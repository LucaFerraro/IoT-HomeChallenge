/*
 * Home Challenge 5.
 * Luca Ferraro, fabio Losavio, Bernardo Camajori Tedeschini.
 */
 
#include "Timer.h"
#include "Homechallenge5.h"
#include "stdlib.h"
#include "printf.h"

module Homechallenge5C @safe() {

  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as Timer0;
    interface Timer<TMilli> as Timer1;
    interface SplitControl as AMControl;
    interface Packet;

    /* new */
    interface AMSend as RssiMsgSend;
    interface Intercept as RssiMsgIntercept;
  }
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

  uint16_t random_number;
  uint32_t counter = 0;

  /* new */
  uint16_t getRssi(message_t *msg);
  
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {

    if (err == SUCCESS) {

      // Defining the 2 timers
      call Timer0.startPeriodic( 1000 );
      call Timer1.startPeriodic( 1000 );

    }

    else {

      call AMControl.start();

    }
  }


  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  

  // Timer zero expires, trigger mote2
  event void Timer0.fired() {
 	
  	radio_count_msg_t * rcm;
  	
  	if (counter == 0) {
  		counter = 2;
  	}

  	// Procedeeding only if we're not node 1:
  	if(TOS_NODE_ID == 1){

     	 return;

  	}

	srand(counter);
	counter = counter + 1;
	random_number = rand(); //generate a number between 0 and 100
	random_number = random_number % 101;

    dbg("Homechallenge5", "Homechallenge5: timer fired, generated value is : %hu.\n", random_number);


    rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));

    if (rcm == NULL) {

	      return;

    }

      // Filling messages fields:
      rcm->random_number = random_number;       // Computed value 
      rcm->senderid = TOS_NODE_ID; 				// ID of the node

      /* new */
      if (call RssiMsgSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge5", "Homechallenge5: packet sent.\n");


 	 }

    
  }


  // Timer 1 Expires, trigger mote2:
  event void Timer1.fired() {
  
  	radio_count_msg_t* rcm;

    // Procedeeding only if we're not node 1:
    if(TOS_NODE_ID == 1){

      return;

    }
    

	srand(counter);
	random_number = rand(); //generate a number 
	counter = counter + random_number;
	random_number = random_number % 101; //between 0 and 100


    dbg("Homechallenge5", "Homechallenge5: timer fired, counter is %hu.\n", random_value);

	rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
	
	if (rcm == NULL) {

 		return;

    }

    // Filling messages fields:
    rcm->random_number = random_number;      // Computed value 
    rcm->senderid = TOS_NODE_ID; 			   // ID of the node

    if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

    	dbg("Homechallenge5", "Homechallenge5: packet sent.\n");

    }
  }



  // When a packet is received:
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
  
  	//Only node 1 will deal with received messages
  	if(TOS_NODE_ID != 1){
  	
  		return;
  	}
  	
  	
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;
    }

    else {

	  radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

    /* new */
    rcm->rssi = getRssi(bufPtr);

	  dbg("Homechallenge5", "Homechallenge5 packet with value %hhu.\n", rcm->random_number );

      //CONNECT TO NODE RED
      /* new */
      printf("received %u mote%d rssi %d\n", rcm->random_number, rcm->senderid, rcm->rssi);
      
      printfflush();

      return bufPtr;

    }
    
  }

  /* new */
  event bool RssiMsgIntercept.forward(message_t *msg, void *payload, uint8_t len) {

    radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

    //Only node 1 will deal with received messages
  	if(TOS_NODE_ID != 1){

  		return;
  	}

	  

    rcm->rssi = getRssi(msg);

    dbg("Homechallenge5", "Homechallenge5 packet with value %hhu.\n", rcm->random_number );

    //CONNECT TO NODE RED
    printf("received %u mote%d rssi %d\n", rcm->random_number, rcm->senderid, rcm->rssi);
    
    printfflush();
    
    return TRUE;
  }
  
  

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
	return;
  }

  /* new */
  event void RssiMsgSend.sendDone(message_t *m, error_t error){
	return;
  }

  /* new */
  #ifdef __CC2420_H__  
    uint16_t getRssi(message_t *msg){
      return (uint16_t) call CC2420Packet.getRssi(msg);
    }
  #elif defined(CC1K_RADIO_MSG_H)
      uint16_t getRssi(message_t *msg){
      cc1000_metadata_t *md =(cc1000_metadata_t*) msg->metadata;
      return md->strength_or_preamble;
    }
  #elif defined(PLATFORM_IRIS) || defined(PLATFORM_UCMINI)
    uint16_t getRssi(message_t *msg){
      if(call PacketRSSI.isSet(msg))
        return (uint16_t) call PacketRSSI.get(msg);
      else
        return 0xFFFF;
    }
  #elif defined(TDA5250_MESSAGE_H)
    uint16_t getRssi(message_t *msg){
        return call Tda5250Packet.getSnr(msg);
    }
  #else
    #error Radio chip not supported! This demo currently works only \
          for motes with CC1000, CC2420, RF230, RFA1 or TDA5250 radios.  
  #endif

}




