# **Home Challenge 5**
##  **Bernardo Camajori Tedeschini (10584438), Luca Ferraro (10748116), Fabio Losavio (10567493)**

Is possible to find the project in this [*GitHub Repository*](https://github.com/LucaFerraro/IoT-HomeChallenge)
[*Thinkspeak channel*](https://thingspeak.com/channels/1069402)

The aim of the project was to develop a TinyOS application implementing a simulated radio communication between 3 motes sending messages every 5s.
The messages are created using a data structure, specified in the [Homechallenge5.h](https://github.com/LucaFerraro/IoT-HomeChallenge/blob/master/5/Homechallenge5.h), containing 2 integers:  
* Senderid : Id of the motes who sends the message.
* random_number : Integer value randolmy generated at each iteration.  

This structure will be then used in the application to generate sendable messages between the different motes.

The program contains 2 timers associated to mote2 and mote3, when one the two fires the program generates a message with the senderid set to TOS_NODE_ID and
a random value generated with the funtion rand(). In order not to generate the same numbers each time, we added the variable counter as a seed for the random 
function, it will be updated by the randomly generated value each time so that at each itaration and in both nodes the generated value will be different.
The 2 motes will then send in broadcast the generated message but only mote1 will be able to receive them. In mote1 we opened a socket, on port 60001, to connect
to Node-Red in which we filter the received messages and send them to [*Thingspeak*](https://thingspeak.com/channels/1069402). In field 1 we inserted messages
coming from mote 2 and in field 2 the ones from mote3.
