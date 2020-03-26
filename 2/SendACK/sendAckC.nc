#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
	interface SplitControl;
	interface Packet;
    interface AMSend;
    interface Receive;

	//interface for timer
	interface Timer<TMilli> as requestTimer;

    //other interfaces, if needed
	interface PacketAcknowledgements;
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter = 0;
  // uint8_t rec_id;

  bool rec_id = FALSE; // Boolean if the ack is received
  message_t packet;

  void sendReq();
  //void sendReq( uint8_t counter );
  void sendResp();
  //void sendResp(uint8_t counter);
  
  
  //***************** Send request function ********************//
  void sendReq() {
	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));

	if (rcm == NULL) {

		return;

	}

	// Filling messages fields:
	rcm->counter = counter;      // Counter value 
	rcm->type = REQ; // Type of the msg

	call PacketAcknowledgements.requestAck(&packet); // Set the ACK

	// Send request to 2
	if(call AMSend.send(2 , &packet,sizeof(my_msg_t)) == SUCCESS){

		dbg("radio_send", "Packet passed to lower layer successfully!\n");
		dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
		dbg_clear("radio_pack","\t Payload Sent\n" );
		dbg_clear("radio_pack", "\t\t type: %hhu \n ", rcm->type);
		dbg_clear("radio_pack", "\t\t counter: %hhu \n", rcm->counter);
	
	}



 }        

  //****************** Task send response *****************//
  // Added counter from the message with the Request
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read done.
  	 */
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");

	dbg("boot","Application booted on node %u.\n", TOS_NODE_ID);
	call SplitControl.start();

  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){

    if(err == SUCCESS) {

    	dbg("radio", "Radio on!\n");

		if (TOS_NODE_ID == 1){

			call requestTimer.startPeriodic( 1000 );

		}
    }

    else{

		//dbg for error
		call SplitControl.start();

    }
  }
  
  event void SplitControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//
  event void requestTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */

	if (TOS_NODE_ID == 1 && !rec_id ){ // If we are in node 1 and If not yet received ack

		counter++;

		sendReq();
		//sendReq( counter );

	}
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

	if(&packet == buf && call PacketAcknowledgements.wasAcked( buf )){

		rec_id = TRUE;

		dbg("Ack", "Ack correctly received!\n");

	}

    else{
		// Do nothing -> The timer fired will send another Request
	}

  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

    if (len != sizeof(my_msg_t)) {

		return buf;

	}

    else {
		my_msg_t* mess = (my_msg_t*)payload;
		
		dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
		dbg("radio_pack"," Payload length %hhu \n", call Packet.payloadLength( buf ));
		dbg("radio_pack", ">>>Pack \n");
		dbg_clear("radio_pack","\t\t Payload Received\n" );
		dbg_clear("radio_pack", "\t\t type: %hhu \n ", mess->type);

		if (mess->type == REQ){

			dbg_clear("radio_pack", "\t\t data: %hhu \n", mess->data);

			sendResp(); // Send Response
			//sendResp( mess->counter); // Send Response

		}

		// It is a RESP, read fake data
		else{

			dbg_clear("radio_pack", "\t\t data: %hhu \n", mess->data);

		}
		
		return buf;
    }

    {
      	dbgerror("radio_rec", "Receiving error \n");
    }


  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */

	dbg("data","fake read done %f\n",data);

	my_msg_t* resp = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));

	if (resp == NULL) {

		return;

	}

	// Filling messages fields:
	resp->counter = counter;      // Counter value 
	resp->type = RESP; // Type of the msg
	resp->data = data; // Fake data

	// Send response to 1
	if(call AMSend.send(1 , &packet,sizeof(my_msg_t)) == SUCCESS){

		dbg("radio_send", "Packet passed to lower layer successfully!\n");
		dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
		dbg_clear("radio_pack","\t Payload Sent\n" );
		dbg_clear("radio_pack", "\t\t type: %hhu \n ", resp->type);
		dbg_clear("radio_pack", "\t\t counter: %hhu \n", resp->counter);
	
	}
 	}

}