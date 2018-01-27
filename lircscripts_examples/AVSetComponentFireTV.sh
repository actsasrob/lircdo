#!/bin/bash

# meta: name=avsetcomponentfiretv
# meta: displayname=Change AVR Component To Fire TV
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_FIRETV,COMPONENT_DVR
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_DVR
exit $?
