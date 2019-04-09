#!/bin/bash

export WINEARCH=win32 WINEPREFIX=/dream/win32
export FREETYPE_PROPERTIES="truetype:interpreter-version=35"

exec wine "$@"
