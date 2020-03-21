# **Home Challenge 1**
##  **Bernardo Camajori Tedeschini (10584438), Luca Ferraro (10748116), Fabio Losavio (10567493)**

Is possible to find the project in this [*GitHub Repository*](https://github.com/LucaFerraro/IoT-HomeChallenge1)

The aim of the project was to develop a TinyOS application implementing a simulated radio communication between 3 motes sending messages at different frequencies.
The messages are created using a data structure, specified in the [Homechallenge1.h](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1.h), containing 2 integers:  
* SenderID : Id of the motes who sends the message.
* Counter : Integer value which counts the number of total sent messaages.  

This structure will be then used in the application to generate sendable messages between the different motes.

The [HomechallengeC.nc](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1C.nc) is the main program file, it contains all the executable functions used to correctly run the program. First of all it starts with the declaration of the used interfaces, the main ones are the radio interface (used to transmit and receive messages between different motes), the led interface (used to control the leds inside motes) and the timer interfaces.
After the start done event, the 3 timers will be initialized with different frequencies:
* 1Hz: frequency at which Mote1 sends messages.
* 3Hz: frequency at which Mote2 sends messages.
* 5Hz: frequency at which Mote3 sends messages.

When a timer expires, it triggers the corresponding function. Since Mote1 sends messages at 1Hz, Mote2 at 3Hz and Mote3 at 5Hz, the first check inside each function is on the *TOS_NODE_ID* of the node: if it doesn't match with the timer that has expired, the function return without doing anything.
Otherwise, the funtion increments the counter variable and creates the sendable message (*rcm*) assigning it the current counter and the *TOS_NODE_ID* of the sender. When the message is ready it's sent as a *broadcast message* and the lock will be released.  

When a message is received, the payload is extracted:

* If the counter value is a multiple of 10, all the leds will be turned *OFF*
* Otherwise the led associated to the sender id is turned *ON*

The [HomechallengeAppC.nc](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1AppC.nc) contains a logical link to the physical components of the used interfaces of the motes.