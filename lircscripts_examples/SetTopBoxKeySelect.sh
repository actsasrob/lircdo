#!/bin/bash

# meta: name=settopboxkeyselect
# meta: displayname=Set Top Box Select 
# meta: intent=lircdo
# meta: action=SELECT
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_OK
exit $?
