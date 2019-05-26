#!/bin/bash

# meta: name=settopboxshowondemand
# meta: displayname=Set Top Box On Demand 
# meta: intent=lircdo
# meta: action=ON_DEMAND
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=0

irsend SEND_ONCE Motorola_QIP6200-2 ondemand 
exit $?
