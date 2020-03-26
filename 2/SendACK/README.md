
# **Home Challenge 2**
##  **Bernardo Camajori Tedeschini (10584438), Luca Ferraro (10748116), Fabio Losavio (10567493)**

Is possible to find the project in this [*GitHub Repository*](https://github.com/LucaFerraro/IoT-HomeChallenge)

The aim of the project is to simulate a wireless sensor networ using **TOSSIM**, this is done using a TinyOS application.
The simulation consists in 2 motes, *mote 1* which sends one request per second containing a *type* fild (can be REQ for requests or RESP for responses) and an increasing counter defining the message sent. It will keep sending requests until an ACK is received.
*Mote 2* simulates a sensor, it receives the requests and sends a response to mote 1 containing:

* **type**: RESP
* **data**: the value read by the fake sensor
* **counter**: equal to the counter value of the request.

Also the response has to be acknowledged.

In our case mote 1 boots up at time 0 and starts a periodic timer. When the timer fires, every 1 second, a request is sent. If the mote 2 is not up the request will be lost and mote 1 will try again. After 5 seconds, mote 2 will boot up and will start getting the requests. When the request is correctly received, mote 2 will automatically send an ACK using the *PacketAcknowledgment interface*. This ACK will be collected by mote 1, in the event *AMSend.sendDone* with the call

```
call PacketAcknowledgements.requestAck(&packet); 
```
and **rec_id** will be set to *TRUE*. This will tell mote 1 to stop sending requests since it has been correctly received.  
After sending the ACK, mote 2 will prepare the response, reading the fake data using the call
```
call Read.read();
```
and send it back to mote 1. Even in this case an ACK will be sent back to mote 2.

To build and run the simulation use the following commands:
```
$ make micaz sim

$ python RunSimulationScript.py
```
At this point the simulation will run and will give its output. This output can be also found in the file [output.txt](https://github.com/LucaFerraro/IoT-HomeChallenge/blob/master/2/SendACK/output.txt) and contains for each sent packet the time at which the time is sent or received and displays the packet fields.  