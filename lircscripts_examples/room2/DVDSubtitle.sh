#!/bin/bash

# meta: name=dvdsubtitles
# meta: displayname=DVD Subtitles
# meta: intent=lircdo
# meta: action=SUBTITLES
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-D185A_para_from_irscrut KEY_SUBTITLE --count=2
exit $?
