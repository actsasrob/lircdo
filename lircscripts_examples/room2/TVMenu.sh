#!/bin/bash

# meta: name=tvkeymenu
# meta: displayname=TV Menu
# meta: intent=lircdo
# meta: action=MENU_SHOW
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MENU --count=1
status=$?

exit $?
