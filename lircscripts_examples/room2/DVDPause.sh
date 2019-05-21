#!/bin/bash

# meta: name=dvdpause
# meta: displayname=DVD Pause
# meta: intent=lircdo
# meta: action=PAUSE,UNPAUSE
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_PAUSE
exit $?
