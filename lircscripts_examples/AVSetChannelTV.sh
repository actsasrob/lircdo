#!/bin/bash

# meta: name=setavchanneltv
# meta: displayname=Change AV Channel To TV
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw TV_CBL 
exit $?
