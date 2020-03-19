// $Id: Homechallenge1.nc,v 1.7 2010-06-29 22:07:17 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "Homechallenge1.h"
 
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

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
  uint16_t TOS_NODE_ID;
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {

    if (err == SUCCESS) {

      call Timer0.startPeriodic( 1000 );
      call Timer1.startPeriodic( 333 );
      call Timer2.startPeriodic( 200 );

    }

    else {

      call AMControl.start();

    }
  }


  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  

  // Timer 0 fired 
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

      rcm->counter = counter;

      rcm->senderid = TOS_NODE_ID;

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

	      locked = TRUE;

      }
    }
  }


  // Timer 1 fired 
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

      rcm->counter = counter;

      rcm->senderid = TOS_NODE_ID;

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

        locked = TRUE;

      }
    }
  }


  // Timer 2 fired
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

      rcm->counter = counter;

      rcm->senderid = TOS_NODE_ID;

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {

        dbg("Homechallenge1", "Homechallenge1: packet sent.\n", counter);

        locked = TRUE;

      }
    }
  }



  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {

    dbg("Homechallenge1", "Homechallenge1 packet of length %hhu.\n", len);

    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}

    else {

      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;

      if ((rcm->counter & 0x15) % 1010) {

        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();

        // return bufPtr;
      }

      else{

        if (rcm->senderid == 0) {

          call Leds.led0On();

        }

        if (rcm->senderid == 1) {

          call Leds.led1On();

        }

        if (rcm->senderid == 2) {

          call Leds.led2On();

        }

        // return bufPtr;

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



