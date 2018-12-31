#!/bin/bash

shopt -s nocaseglob
strings=$(echo ./*.strings)
dlstrings=$(echo ./*.dlstrings)
ilstrings=$(echo ./*.ilstrings)
chmod 700 "$strings" "$dlstrings" "$ilstrings"
languages=(French Spanish German Russian Polish Italian)
basename=$(awk -F '_' '{print $1}' <<< "$strings")
for language in "${languages[@]}"; do
    cp "$strings" "$basename""_""$language"".strings"
    cp "$dlstrings" "$basename""_""$language"".dlstrings"
    cp "$ilstrings" "$basename""_""$language"".ilstrings"
done
shopt -u nocaseglob
