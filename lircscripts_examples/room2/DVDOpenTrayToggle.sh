#!/bin/bash

# meta: name=dvdopentraytoggle
# meta: displayname=Open/Close DVD Tray
# meta: intent=lircdo
# meta: action=TRAY_OPEN,TRAY_CLOSE
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_OPEN
exit $?
