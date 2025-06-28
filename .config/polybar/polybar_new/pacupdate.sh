#!/bin/bash

sleep 1s
echo "$(checkupdates | wc -l) updates"
