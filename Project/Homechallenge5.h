
#ifndef HOMECHALLENGE5_H
#define HOMECHALLENGE5_H

typedef nx_struct radio_count_msg {

  nx_uint16_t random_number;

  nx_uint16_t senderid;

  nx_int16_t rssi;

} radio_count_msg_t;

typedef nx_struct RssiMsg{
  nx_int16_t rssi;
} RssiMsg;

enum {

  AM_RADIO_COUNT_MSG = 6,
  AM_RSSIMSG = 10,

};

#endif
