#!/bin/bash

# meta: name=dvdfavorites
# meta: displayname=DVD Show Favorites 
# meta: intent=lircdo
# meta: action=FAVORITES
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_FAVORITES 
exit $?
