#!/bin/bash

# meta: name=dvdaudio
# meta: displayname=DVD Change Audio Settings 
# meta: intent=lircdo
# meta: action=AUDIO_SETTINGS
# meta: component=COMPONENT_DVD
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE RMT-VB201U KEY_AUDIO 
exit $?
