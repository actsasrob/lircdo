#!/bin/bash

# meta: name=dvdtopmenu
# meta: displayname=DVD Top Menu
# meta: intent=lircdo
# meta: action=SHOW_TOP_MENU
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_TOP_MENU --count=2
exit $?
