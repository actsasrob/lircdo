#!/bin/bash

# meta: name=dvdstopplay
# meta: displayname=DVD Stop Play 
# meta: intent=lircdo
# meta: action=STOP_PLAY
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_STOP
exit $?
