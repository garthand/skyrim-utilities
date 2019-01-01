#!/bin/bash
mapfile -t files < <(find ./ -maxdepth 1 -iname "*[q|p|ti]f_*.psc")
if [ "${files[0]}" == "" ]; then
    echo "No source files found!"
    exit 1
fi
for file in "${files[@]}"; do
    chmod 700 "$file"
    file_no_extension=$(awk -F '.' '{print $2}' <<< "$file"|cut -c2-)
    newfile="newfile.psc"
    dos2unix "$file" 2>/dev/null
    lastfragment=$(grep -i fragment_ "$file"|awk -F '_' '{print $2}'|awk -F '(' '{print $1}'|sort -n|tail -1)
    nextfragment=$((lastfragment+1))
    {
    echo ";BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment"
    echo ";NEXT FRAGMENT INDEX" "$nextfragment"
    echo "Scriptname" "$file_no_extension" "Extends Quest Hidden"
    echo
    } >> "$newfile"
    mapfile -t referencealiases < <(grep -i referencealias "$file")
    for referencealias in "${referencealiases[@]}"; do
        alias_short_name=$(awk -F 'Alias_' '{print $2}' <<< "$referencealias"|awk '{print $1}')
        {
        echo ";BEGIN ALIAS PROPERTY" "$alias_short_name"
        echo ";ALIAS PROPERTY TYPE ReferenceAlias"
        echo "$referencealias"
        echo ";END ALIAS PROPERTY"
        echo
        } >> "$newfile"
    done

    mapfile -t fragments < <(grep -i fragment_ "$file")
    for fragment in "${fragments[@]}"; do
        basename=$(awk -F '(' '{print $1}' <<< "$fragment")
        fragmentname=$(awk '{print $2}' <<< "$basename")
        mysearch="$basename\("
        export mysearch
        {
        echo ";BEGIN FRAGMENT" "$fragmentname"
        perl -ne 'print if /^$ENV{mysearch}/ .. /^endFunction/' "$file"|sed '2 s/^.*$/;BEGIN CODE/'|sed '$i;END CODE'
        echo ";END FRAGMENT"
        echo
        } >> "$newfile"
        unset mysearch
    done

    echo ";END FRAGMENT CODE - Do not edit anything between this and the begin comment" >> "$newfile"
    echo >> "$newfile"
    mapfile -t otherproperties < <(grep -i property "$file"|grep -Evi referencealias)
    for property in "${otherproperties[@]}"; do
        echo "$property" >> "$newfile"
    done
    rm -f "$file"
    mv "$newfile" "$file"
    unix2dos "$file" 2>/dev/null
    echo "Successfully converted" "$file"
done
