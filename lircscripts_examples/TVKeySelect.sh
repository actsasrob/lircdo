#!/bin/bash

# meta: name=tvkeyselect
# meta: displayname=TV Key Previous
# meta: intent=lircdo
# meta: action=KEY_SELECT
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

irsend SEND_ONCE Samsung_BN59-00516A_TV ENTER-OK --count=2

exit $?
