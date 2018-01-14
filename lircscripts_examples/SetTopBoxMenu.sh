#!/bin/bash

# meta: name=settopboxlaunchmenu
# meta: displayname=Launch Set Top Box Menu
# meta: intent=lircdo
# meta: action=MENU_SHOW
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_MENU
exit $?
