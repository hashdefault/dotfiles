#!/bin/sh
# Natural icon width, kept below ordinary windows.
exec trayer -l --edge top --align right --widthtype request --expand true \
  --height 24 --transparent true --alpha 0 --tint 0x121222 --distance 0 \
  --SetDockType true --SetPartialStrut true --monitor primary
