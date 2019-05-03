#!/bin/bash

# meta: name=avsetcomponentdvd
# meta: displayname=Change AVR Component To DVD
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw TV_CBL 
exit $?
