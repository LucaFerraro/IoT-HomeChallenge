# **Home Challenge 1**
##  **Bernardo Camajori Tedeschini (10584438), Luca Ferraro (10748116), Fabio Losavio (10567493)**

Is possible to find the project in this [*GitHub Repository*](https://github.com/LucaFerraro/IoT-HomeChallenge1)

The aim of the project was to develop a TinyOS application implementing a simulated radio communication between 3 motes sending messages at different frequencies.
The messages are created using a data structure, specified in the [Homechallenge1.h](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1.h), containing 2 integers:  
* SenderID : Id of the motes who sends the message.
* Counter : Integer value which counts the number of total sent messaages.  

This structure will be then used in the application to generate sendable messages between the different motes.

The [HomechallengeC.nc](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1C.nc) is the main program file, it contains all the executable functions used to correctly run the program. First of all it starts with the declaration of the used interfaces, the main ones are the radio interface, used to transmit and receive messages between different motes, the led interface, used to control the leds inside motes and the timer interfaces.
After the start done event, the 3 timers will be initialized with different frequencies (1Hz, 3Hz and 5Hz) and after the given time interval, the expiring of one of the timers will trigger the corresponding function which will increment the counter variable and create the sendable message (*rcm*) assigning it the current counter and the *TOS_NODE_ID* of the sender. When the message is ready it will be sent as a *broadcast message* and the lock will be released.  

When a message is received, the payload is extracted:

* If the counter value is a multiple of 10, all the leds will be turned *OFF*
* Otherwise the led associated to the sender id is turned *ON*

The [HomechallengeAppC.nc](https://github.com/LucaFerraro/IoT-HomeChallenge1/blob/master/1/Homechallenge1AppC.nc) contains a logical link to the physical components of the used interfaces of the motes.