#!/bin/bash

mapfile -t files < <(echo ./*.psc)
for file in "${files[@]}"; do
    file_no_extension=$(awk -F '.' '{print $1}' <<< "$file")
    newfile="newfile.psc"
    vim -c "%s/\r$//" -c "wq" "$file"

    {
    echo ";BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment"
    echo ";NEXT FRAGMENT INDEX 0"
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

    mapfile -t otherproperties < <(grep -i property sse_qf_ccffbsse001_quest_02000927.psc|grep -Evi referencealias)
    for property in "${otherproperties[@]}"; do
        echo "$property" >> "$newfile"
    done
    echo >> "$newfile"

    mapfile -t fragments < <(grep -i fragment_ "$file")
    for fragment in "${fragments[@]}"; do
        mysearch=${fragment::-2}
        export mysearch
        {
        echo ";BEGIN FRAGMENT" "$mysearch"
        perl -ne 'print if /^$ENV{mysearch}/ .. /^endFunction/' "$file"|sed '2 s/^.*$/;BEGIN CODE/'|sed '$i;END CODE'
        echo ";END FRAGMENT"
        echo
        } >> "$newfile"
        unset mysearch
    done

    echo ";END FRAGMENT CODE - Do not edit anything between this and the begin comment" >> "$newfile"
    rm -f "$file"
    mv "$newfile" "$file"
    vim -c "%s/\r$//" -c "wq" "$file"
done
