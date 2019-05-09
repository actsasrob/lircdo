#!/bin/bash

# meta: name=tvdismissmenu
# meta: displayname=TV Dismiss Menu
# meta: intent=lircdo
# meta: action=MENU_DISMISS
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_EXIT --count=1

exit $?
