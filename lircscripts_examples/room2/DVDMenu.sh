#!/bin/bash

# meta: name=dvdmenu
# meta: displayname=DVD Menu
# meta: intent=lircdo
# meta: action=SHOW_MENU
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_MENU --count=2
exit $?
