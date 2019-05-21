#!/bin/bash

# meta: name=dvdmenu
# meta: displayname=DVD Menu
# meta: intent=lircdo
# meta: action=SHOW_MENU
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_MENU
exit $?
