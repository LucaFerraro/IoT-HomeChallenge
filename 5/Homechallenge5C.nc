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
  }
}


implementation {

  message_t packet;

  uint16_t random_number;
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {

    if (err == SUCCESS) {

      // Defining the 2 timers
      call Timer0.startPeriodic( 5000 );
      call Timer1.startPeriodic( 5000 );

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

  	// Proceeding only if we're node 2
  	if(TOS_NODE_ID != 2){

     	 return;

  	}

	random_number = rand()%101; //generate a number between 0 and 100

    dbg("Homechallenge5", "Homechallenge5: timer fired, generated value is : %hu.\n", random_number);


    radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));

    if (rcm == NULL) {

	      return;

    }

      // Filling messages fields:
      rcm->random_number = random_number;       // Computed value 
      rcm->senderid = TOS_NODE_ID; 				// ID of the node

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge5", "Homechallenge5: packet sent.\n");


 	 }
  }


  // Timer 1 Expires, trigger mote3:
  event void Timer1.fired() {

    // Procedeeding only if we're node 3:
    if(TOS_NODE_ID != 3){

      return;

    }
	
	random_number = rand()%101; //generate a number between 0 and 100

    dbg("Homechallenge5", "Homechallenge5: timer fired, counter is %hu.\n", random_value);

	radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
	
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
  	
  	
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}

    else {

	  radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

	  dbg("Homechallenge5", "Homechallenge5 packet with value %hhu.\n", rcm->random_number );

      //CONNECT TO NODE RED
      printf("received %hd mote%d\n", rcm->random_number, rcm->senderid);
      printfflush();

      return bufPtr;

    }
    
  }
  
  

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
	return;
  }

}




