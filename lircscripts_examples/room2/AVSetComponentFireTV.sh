#!/bin/bash

# meta: name=avsetsourcefiretv
# meta: displayname=Change Source To Fire TV
# meta: intent=avr_action
# meta: action=CHANGE_COMPONENT
# meta: component=COMPONENT_FIRETV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MENU --count=1
sleepenh 1.1
irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MENU --count=1
sleepenh 1.1 
irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_CYCLEWINDOWS --count=1
sleepenh 1.0 
irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_RIGHT --count=1
sleepenh 0.1
irsend SEND_ONCE Samsung_BN59-00516A_TV ENTER-OK --count=1

exit $?
