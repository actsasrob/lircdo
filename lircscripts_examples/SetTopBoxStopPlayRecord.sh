#!/bin/bash

# meta: name=settopboxstop
# meta: displayname=Set Top Box Stop Play/Record 
# meta: intent=lircdo
# meta: action=STOP_PLAY
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_STOP
exit $?
