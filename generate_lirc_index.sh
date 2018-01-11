#!/bin/bash

LIRCSCRIPTSDIR=./lircscripts

echo -n "<html><body>"
scripts=$(cd $LIRCSCRIPTSDIR; ls -1 *.sh)
if [ -n "$scripts" ]; then
   for ascript in $scripts; do
      echo -n "<form method=\"post\" action=\"/lircdo?script=${ascript}\">"
      echo -n "    <button type=\"submit\">${ascript}</button>"
      echo -n "</form>"
   done
else
   echo -n "No scripts found or an error occurred"
fi
echo -n "</body></html>"
