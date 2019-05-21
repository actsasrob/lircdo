#!/bin/bash

# meta: name=dvdselect
# meta: displayname=DVD Key Select 
# meta: intent=lircdo
# meta: action=SELECT
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_ENTER
exit $?
