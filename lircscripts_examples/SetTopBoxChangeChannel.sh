#!/bin/bash

# meta: name=settopboxchangechannel
# meta: displayname=Set Top Box Change Channel
# meta: intent=channel_action
# meta: action=CHANGE_CHANNEL
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=1

irsend SEND_ONCE Motorola_QIP6200-2 KEY_7
irsend SEND_ONCE Motorola_QIP6200-2 KEY_4
irsend SEND_ONCE Motorola_QIP6200-2 KEY_6
exit $?
