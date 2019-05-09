#!/bin/bash

# meta: name=dvdplay
# meta: displayname=DVD Play
# meta: intent=lircdo
# meta: action=UNPAUSE
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_PLAY --count=2
exit $?
