#!/bin/bash

# meta: name=tvchannelguide
# meta: displayname=TV Channel Guide 
# meta: intent=lircdo
# meta: action=GUIDE
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV CH-MGR --count=2

exit $?
