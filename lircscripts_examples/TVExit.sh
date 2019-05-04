#!/bin/bash

# meta: name=tvexit
# meta: displayname=TV Dismiss Menu 
# meta: intent=lircdo
# meta: action=DISMISS_MENU
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_EXIT
exit $?
