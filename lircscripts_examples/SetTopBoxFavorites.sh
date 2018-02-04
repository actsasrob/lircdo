#!/bin/bash

# meta: name=settopboxfavorites
# meta: displayname=Set Top Box Show Favorites Guide
# meta: intent=lircdo
# meta: action=FAVORITES
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_FAVORITES
exit $?
