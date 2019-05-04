#!/bin/bash

# meta: name=tvhomemenu
# meta: displayname=TV Home Menu 
# meta: intent=lircdo
# meta: action=KEY_MENU
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV CH-MGR --count=2

exit $?