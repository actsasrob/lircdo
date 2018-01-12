#!/bin/bash

# meta: name=avpoweroff
# meta: displayname=Power Off AV Device
# meta: intent=lircdo
# meta: action=POWE_OFF
# meta: component=COMPONENT_AVR
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw Off 
exit $?
