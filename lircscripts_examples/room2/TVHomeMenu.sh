#!/bin/bash

# meta: name=tvkeymenu
# meta: displayname=TV Menu
# meta: intent=lircdo
# meta: action=TOP_MENU
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MENU --count=1
status=$?
irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MENU --count=1

exit $?
