#!/bin/bash

# meta: name=tvplaypause
# meta: displayname=TV Play/Pause 
# meta: intent=lircdo
# meta: action=PAUSE,UNPAUSE,PLAY
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_PLAYPAUSE --count=2

exit $?
