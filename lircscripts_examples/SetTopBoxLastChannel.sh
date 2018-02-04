#!/bin/bash

# meta: name=settopboxlastchannel
# meta: displayname=Set Top Box Show Last Channel 
# meta: intent=lircdo
# meta: action=LAST_CHANNEL
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 KEY_LAST
exit $?
