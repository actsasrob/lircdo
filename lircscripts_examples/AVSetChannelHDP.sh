#!/bin/bash

# meta: name=setavchannelhdp
# meta: displayname=Change AV Channel to HDP
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_HDP,COMPONENT_PS4
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_HDP
exit $?
