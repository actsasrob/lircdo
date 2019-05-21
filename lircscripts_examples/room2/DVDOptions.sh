#!/bin/bash

# meta: name=dvdoptions
# meta: displayname=DVD Display Options Menu 
# meta: intent=lircdo
# meta: action=OPTIONS
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_OPTIONS 
exit $?
