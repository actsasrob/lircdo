#!/bin/bash

# meta: name=avpoweron
# meta: displayname=Power On AV Device
# meta: intent=lircdo
# meta: action=POWER_ON
# meta: component=COMPONENT_AVR
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_POWER
exit $?
