#!/bin/bash

# meta: name=settopboxshowdvrmenu
# meta: displayname=Set Top Box Show DVR Menu 
# meta: intent=lircdo
# meta: action=DVR_MENU
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 dvr
exit $?
