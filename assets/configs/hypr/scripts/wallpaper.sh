#!/bin/bash

WALL=$(find ~/.config/wallpapers -type f | shuf -n 1)

swww img "$WALL" \
--transition-type grow \
--transition-duration 1
