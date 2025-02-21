#!/bin/bash

# Output the current month calendar in a compact form
cal -3 | sed 's/  / /g'
