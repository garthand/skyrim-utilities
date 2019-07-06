#!/bin/bash
modlist=./mymodlist.achlist
find . -type f|grep -Evi "SKSE|SSEEdit|*.bsa|*.esp|*.esm|*.zip|*.achlist|BGS_Logo.bik" > "$modlist"
# Replace single forward slashes with double back slashes
sed -i "s/\//\\\\\\\/g" "$modlist"
# Append replace local directory with Data header
sed -i "s/\./Data/" "$modlist"
# Quote beginning of each line
sed -i "s/^Data/\"Data/g" "$modlist"
# Quote the ending of each line and add a comma
sed -i "s/$/\",/g" "$modlist"
# Delete the comma from the last line
sed -i "$ s/.$//" "$modlist"
# Add an open bracket to the top of the file
sed -i "1i\[" "$modlist"
# Add a closing bracket to the end of the file
echo "]" >> "$modlist"
