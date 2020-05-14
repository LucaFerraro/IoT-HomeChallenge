import pyshark
import numpy as np
import matplotlib.pyplot as plt, itertools
import matplotlib
import sys
import time,os

cap = pyshark.FileCapture('/Users/lucaferraro/Desktop/PoliMi/First_year/Internet_of_things/IoT-HomeChallenge/3/homework3.pcapng')

lwm = []

for packet in cap:
    try:
        if packet.mqtt.conflag_willflag == str(1):
            lwm.append(str(packet.mqtt.willmsg))
    except: 
        pass

print(lwm)

n_lwm = 0

for packet in cap:
    try:
        if packet.mqtt.msgtype == str(3):
            if(str(packet.mqtt.msg) in lwm):
                n_lwm = n_lwm + 1
    except:
        pass

print(n_lwm)