#!/bin/bash

# meta: name=settopboxclosecaptionstoggle
# meta: displayname=Set Top Box Toggle Close Captions 
# meta: intent=lircdo
# meta: action=CLOSE_CAPTIONS
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_NUMERIC_STAR
sleep 1
irsend SEND_ONCE Motorola_QIP6200-2 KEY_NUMERIC_STAR
exit $?
