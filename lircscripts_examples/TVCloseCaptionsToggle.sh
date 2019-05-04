#!/bin/bash

# meta: name=tvclosecaptiontoggle
# meta: displayname=TV Toggle Close Captions 
# meta: intent=lircdo
# meta: action=SUBTITLES,CLOSE_CAPTIONS
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_SUBTITLE
exit $?
