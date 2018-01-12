#!/bin/bash

# meta: name=dvdpowertoggle
# meta: displayname=Toggle DVD Power
# meta: intent=lircdo
# meta: action=POWER_ON,POWER_OFF
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_POWER --count=2
exit $?
