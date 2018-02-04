#!/bin/bash

# meta: name=settopboxplaypause
# meta: displayname=Set Top Box Play/Pause
# meta: intent=lircdo
# meta: action=PAUSE,UNPAUSE
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_PLAYPAUSE
exit $?
