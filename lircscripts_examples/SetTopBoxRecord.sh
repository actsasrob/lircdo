#!/bin/bash

# meta: name=settopboxrecord
# meta: displayname=Set Top Box Record
# meta: intent=lircdo
# meta: action=RECORD
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_RECORD
exit $?
