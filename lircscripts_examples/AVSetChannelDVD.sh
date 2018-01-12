#!/bin/bash

# meta: name=avsetchanneldvd
# meta: displayname=Change AV Channel To DVD
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_DVD
exit $?
