#!/bin/bash

# meta: name=tvmute
# meta: displayname=TV Mute Toggle
# meta: intent=lircdo
# meta: action=MUTE,UNMUTE
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_MUTE --count=1

exit $? 
