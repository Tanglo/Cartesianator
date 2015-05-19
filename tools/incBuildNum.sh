#!/bin/sh

if [ $# -ne 2 ]; then
    echo usage: $0 plist-file project-dir
    exit 1
fi

plist="$1"
dir="$2"

# Only increment the build number if source files have changed
if [ -n "$(find "$dir" \! -path "*xcuserdata*" \! -path "*.git" -newer "$plist")" ]; then
    buildnum=$(/usr/libexec/Plistbuddy -c "Print CFBundleVersion" "$plist")
    if [ -z "$buildnum" ]; then
        echo "No build number in $plist"
        exit 2
    fi
    buildnum=$(expr $buildnum + 1)
    /usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "$plist"
    echo "Incremented build number to $buildnum"
else
    echo "Not incrementing build number as source files have not changed"
fi
