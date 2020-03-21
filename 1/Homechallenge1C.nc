/*
 * Home Challenge 1.
 * Luca Ferraro, fabio Losavio, Bernardo Camajori Tedeschini.
 */
 
#include "Timer.h"
#include "Homechallenge1.h"

module Homechallenge1C @safe() {

  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as Timer0;
    interface Timer<TMilli> as Timer1;
    interface Timer<TMilli> as Timer2;
    interface SplitControl as AMControl;
    interface Packet;
  }
}

implementation {

  message_t packet;

  bool locked;
  uint16_t counter = 0;
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {

    if (err == SUCCESS) {

      // Defining the 3 timers
      call Timer0.startPeriodic( 1000 ); // 1Hz
      call Timer1.startPeriodic( 333 );  // 3Hz
      call Timer2.startPeriodic( 200 );  // 5Hz

    }

    else {

      call AMControl.start();

    }
  }


  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  

  // Timer zero expires
  event void Timer0.fired() {

    counter++;

    dbg("Homechallenge1", "Homechallenge1: timer fired, counter is %hu.\n", counter);

    if (locked) {

      return;

    }

    else {

      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));

      if (rcm == NULL) {

	      return;

      }

      // Filling messages fields:
      rcm->counter = counter;      // Counter value 
      rcm->senderid = TOS_NODE_ID; // ID of the node

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

	      locked = TRUE;

      }
    }
  }


  // Timer 1 Expires:
  event void Timer1.fired() {

    counter++;

    dbg("Homechallenge1", "Homechallenge1: timer fired, counter is %hu.\n", counter);

    if (locked) {

      return;

    }

    else {

      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));

      if (rcm == NULL) {

  return;

      }

      // Filling messages fields:
      rcm->counter = counter;      // Counter value 
      rcm->senderid = TOS_NODE_ID; // ID of the node

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

        locked = TRUE;

      }
    }
  }


  // Timer 2 expires:
  event void Timer2.fired() {

    counter++;

    dbg("Homechallenge1", "Homechallenge1: timer fired, counter is %hu.\n", counter);

    if (locked) {

      return;

    }

    else {

      radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));

      if (rcm == NULL) {

  return;

      }

      // Filling messages fields:
      rcm->counter = counter;      // Counter value 
      rcm->senderid = TOS_NODE_ID; // ID of the node

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

        locked = TRUE;

      }
    }
  }


  // When a packet is received:
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {

    dbg("Homechallenge1", "Homechallenge1 packet of length %hhu.\n", len);

    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}

    else {

      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

      // Every 10 packets we turn all the leds off:
      if (rcm->counter % 10 == 0) {

        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();

      }

      // If counter is not multiple of 10 we turn on the leds depending
      // on the mote that has sent the packet
      else{

        // If sender is mote 1:
        if (rcm->senderid == 1) {

          call Leds.led0On(); // Red led on.

        }

        // If sender is mote 2:
        if (rcm->senderid == 2) {

          call Leds.led1On(); // Green led on.

        }

        // If sender is mote 3:
        if (rcm->senderid == 3) {

          call Leds.led2On(); // Blue led on.

        }
        
      }

      return bufPtr;

    }
    
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {

    if (&packet == bufPtr) {

      locked = FALSE;
      
    }
  }

}




