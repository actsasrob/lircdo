#!/bin/bash

# meta: name=settopboxkeyselect
# meta: displayname=Set Top Box Key Select
# meta: intent=lircdo
# meta: action=KEY_OK
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_OK --count=2

exit $? 
