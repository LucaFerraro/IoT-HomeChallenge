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

  // BOOL: it's set to TRUE when Mote1 receives the first ACK from Mote2:
  bool rec_id = FALSE; 

  message_t packet;

  void sendReq();
  void sendResp();
  
  //***************** Send request function ********************//
  void sendReq() {

	my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));

	if (rcm == NULL) {

		return;

	}

	// Filling messages fields:
	rcm->counter = counter;  // Counter value 
	rcm->type = REQ;         // Type of the msg

	// Indicates the message must be ACKed:
	call PacketAcknowledgements.requestAck(&packet);

	// Send REQUEST	message to Mote2:
	if(call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS){

		dbg("radio_send", "Packet passed to lower layer successfully!\n");
		dbg("radio_pack",">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ) );
		dbg_clear("radio_pack","\t Payload Sent at time %s\n", sim_time_string() );

		if (rcm->type == 1){

			dbg_clear("radio_pack", "\t\t type: REQ \n ");

		}
		else{

			dbg_clear("radio_pack", "\t\t type: RESP \n ");
			
		}

		dbg_clear("radio_pack", "\t\t counter: %hhu \n", rcm->counter);
	
	}



 }        

  //****************** Task send response *****************//
  void sendResp() {

	call Read.read();

  }

  //***************** Boot interface ********************//
  event void Boot.booted() {

	dbg("boot", "APPLICATION BOOTED!.\n");

	dbg("boot", "Application booted on node %u.\n", TOS_NODE_ID);
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

		call SplitControl.start();

    }
  }
  
  event void SplitControl.stopDone(error_t err){}

  //***************** MilliTimer interface ********************//
  event void requestTimer.fired() {

	// If we're Mote1 and the ACK hasn't already been received:
	if (TOS_NODE_ID == 1 && !rec_id ){

		counter++;

		sendReq();

	}
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf, error_t err){

	// If an ACK is received:
    if(&packet == buf && call PacketAcknowledgements.wasAcked( buf )){

	  	dbg("radio_ack", "ACK received!\n");

		if (TOS_NODE_ID == 1){

			rec_id = TRUE;

			dbg("radio_rec", "Received ACK from Mote 2 at time %s\n", sim_time_string());

		}

		if(TOS_NODE_ID == 2){

			dbg("radio_rec", "Received ACK from Mote 1 at time %s\n", sim_time_string());

		}

	}

    else{
		// Does nothing -> The timer fired will send another Request.
	}

  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf, void* payload, uint8_t len) {

    if (len != sizeof(my_msg_t)) {

		return buf;

	}

    else {

		my_msg_t* mess = (my_msg_t*)payload;
		
		dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
		dbg("radio_pack", "Payload length %hhu \n", call Packet.payloadLength( buf ));
		dbg("radio_pack", ">>>Pack \n");
		dbg_clear("radio_pack", "\t\t Payload Received\n" );

		if (mess->type == 1){

			dbg_clear("radio_pack", "\t\t type: REQ \n ");

		}
		else{

			dbg_clear("radio_pack", "\t\t type: RESP \n ");
			
		}

		if (mess->type == REQ && TOS_NODE_ID== 2 ){

			counter = mess->counter;

			// Sending RESPONSE:
			sendResp();

		}

		// It is a RESP, read fake data
		else{

			dbg_clear("radio_pack", "\t\t data: %hhu \n", mess->data);

		}

		dbg_clear("radio_pack", "\t\t counter: %hhu \n", mess->counter);

		return buf;
    }

    {
      	dbgerror("radio_rec", "Receiving error \n");
    }


  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {

	my_msg_t* resp = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
	
	dbg("role", "Fake read done %hhu\n",data);

	if (resp == NULL) {

		return;

	}

	// Filling messages fields:
	resp->counter = counter;  // Counter value 
	resp->type = RESP;        // Type of the msg
	resp->data = data;        // Fake data

	// Indicates the message must be ACKed:
	call PacketAcknowledgements.requestAck(&packet);

	// Send response to 1:
	if(call AMSend.send(1 , &packet, sizeof(my_msg_t)) == SUCCESS){

		dbg("radio_send", "Packet passed to lower layer successfully!\n");
		dbg("radio_pack", ">>>Pack\n \t Payload length %hhu \n", call Packet.payloadLength( &packet ));
		dbg_clear("radio_pack", "\t Payload Sent at time %s\n", sim_time_string());

		if (resp->type == 1){

			dbg_clear("radio_pack", "\t\t type: REQ \n ");

		}
		else{

			dbg_clear("radio_pack", "\t\t type: RESP \n ");
			dbg_clear("radio_pack", "\t\t data: %hhu \n ", resp->data);
			
		}
		dbg_clear("radio_pack", "\t\t counter: %hhu \n", resp->counter);
	
	  }
 	}
}