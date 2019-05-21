#!/bin/bash

# meta: name=dvdtopmenu
# meta: displayname=DVD Top Menu
# meta: intent=lircdo
# meta: action=TOP_MENU
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U TOP_MENU
exit $?
