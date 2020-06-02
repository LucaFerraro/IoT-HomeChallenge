
#ifndef Project_H
#define Project_H

typedef nx_struct radio_count_msg {

  nx_uint16_t senderid;

  nx_int16_t rssi;

} radio_count_msg_t;


enum {

  AM_RADIO_COUNT_MSG = 6,
  AM_RSSIMSG = 10,
  
  POWER_THRESHOLD=0,		//rssi threshold in dBm
  NOTIFICATION_THRESHOLD=120,		//time interval between two consecutive notifications (in multiple of timer duration(500ms))
  NUMBER_OF_MOTES=5,

};

#endif
