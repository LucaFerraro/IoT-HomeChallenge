
#ifndef HOMECHALLENGE1_H
#define HOMECHALLENGE1_H

typedef nx_struct radio_count_msg {

  nx_uint16_t counter;

  nx_uint16_t senderid;

} radio_count_msg_t;

enum {

  AM_RADIO_COUNT_MSG = 6,

};

#endif
