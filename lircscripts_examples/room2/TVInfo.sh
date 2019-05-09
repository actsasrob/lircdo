#!/bin/bash

# meta: name=tvinfo
# meta: displayname=TV Show Channel Info 
# meta: intent=lircdo
# meta: action=INFORMATION
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_INFO
exit $?
