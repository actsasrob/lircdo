#!/bin/bash

# meta: name=tvkeyselect
# meta: displayname=TV Key Previous
# meta: intent=lircdo
# meta: action=LAST_CHANNEL
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV PRE-CH --count=1

exit $?
