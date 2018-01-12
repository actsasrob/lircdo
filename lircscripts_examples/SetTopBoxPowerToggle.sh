#!/bin/bash

# meta: name=settopboxpowertoggle
# meta: displayname=Set Top Box Power Toggle
# meta: intent=lircdo
# meta: action=POWER_ON,POWER_OFF
# meta: component=COMPONENT_STB
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_POWER
exit $?
