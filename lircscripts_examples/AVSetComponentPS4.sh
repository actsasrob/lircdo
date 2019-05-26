#!/bin/bash

# meta: name=setavcomponentps
# meta: displayname=Change AVR Component to PlayStation
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_PS,COMPONENT_HDP
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_HDP
exit $?
