#!/bin/bash

# meta: name=dvdshowdisplay
# meta: displayname=DVD Show Display Options 
# meta: intent=lircdo
# meta: action=DISPLAY_SETTINGS
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_DISPLAY
exit $?
