#!/bin/bash

find -type d \! -perm 755 -print0 | xargs -0r chmod 755 -c
find -type d -name .git -prune -o -type f \! -perm 644 -print0 | xargs -0r chmod 644 -c

setfacl -R -m u:http:rwX -m u:`whoami`:rwX app/{cache,config,database}/ extensions/ public/{extensions,files,theme,thumbs}/
setfacl -dR -m u:http:rwX -m u:`whoami`:rwX app/{cache,config,database}/ extensions/ public/{extensions,files,theme,thumbs}/
