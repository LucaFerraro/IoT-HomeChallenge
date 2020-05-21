
# **Home Challenge 4**
##  **Bernardo Camajori Tedeschini (10584438), Luca Ferraro (10748116), Fabio Losavio (10567493)**

Is possible to find the project in this [*GitHub Repository*](https://github.com/LucaFerraro/IoT-HomeChallenge)

In this project we use NodeRed to parse a input csv file and send to ThingSpeak the data belonging to 4 particular topics:

* factory/department1/section1/plc
* factory/department3/section3/plc
* factory/department1/section1/hydraulic_valve
* factory/department3/section3/hydraulic_valve

The first 2 topics are sent to the field1 of [*this ThingSpeak channel*](https://thingspeak.com/channels/1064138), while the last 2 are sent to field2 of the same channel.

The steps of our flow are:

1) Open the csv file.
2) Parse for publish messages.
3) Divide the topics according to the above specified rule.
4) Extract the payload of the messages.
5) Select and decode the data.
6) Create MQTT ThingSpeak messages.
7) Make a single queue for all the messages to be sent to ThingSpeak.
8) Publish the messages, 1 every minute.