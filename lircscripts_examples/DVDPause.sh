#!/bin/bash

# meta: name=dvdpause
# meta: displayname=DVD Pause
# meta: intent=lircdo
# meta: action=PAUSE
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_PAUSE --count=2
exit $?
