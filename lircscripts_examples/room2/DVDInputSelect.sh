#!/bin/bash

# meta: name=dvdinputselect
# meta: displayname=DVD Input Select 
# meta: intent=lircdo
# meta: action=SOURCE_SELECT
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U INPUT_SELECT 
exit $?
