import pyshark
import numpy as np
import matplotlib.pyplot as plt, itertools
import matplotlib
import sys
import time,os

cap = pyshark.FileCapture('/Users/lucaferraro/Desktop/PoliMi/First_year/Internet_of_things/IoT-HomeChallenge/3/homework3.pcapng')

n_mqtt5 = 0
len_pkt = []

for packet in cap: 
    try:
        if packet.mqtt.ver == str(5) and packet.mqtt.msgtype == str(1):
            n_mqtt5 = n_mqtt5 + 1
            len_pkt.append(int(packet.mqtt.len))
    except:
        pass

print(len_pkt)

avg = sum(len_pkt)/len(len_pkt)

print(avg)