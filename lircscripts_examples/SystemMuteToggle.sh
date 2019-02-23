#!/bin/bash

# meta: name=systemmutetoggle
# meta: displayname=Toggle System Mute 
# meta: intent=lircdo
# meta: action=MUTE,UNMUTE
# meta: component=COMPONENT_SYSTEM
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Denon_RC-1070_raw KEY_MUTE
exit $?
