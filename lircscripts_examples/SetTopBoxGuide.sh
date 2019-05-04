#!/bin/bash

# meta: name=settopboxshowguide
# meta: displayname=Set Top Box Channel Guide 
# meta: intent=lircdo
# meta: action=GUIDE
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_EPG
exit $?
