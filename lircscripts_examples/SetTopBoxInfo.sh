#!/bin/bash

# meta: name=settopboxinfo
# meta: displayname=Set Top Box Show Channel Info 
# meta: intent=lircdo
# meta: action=INFORMATION
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_INFO
exit $?
