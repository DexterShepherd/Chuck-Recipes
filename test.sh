#!/bin/bash
recurse() {
 for i in "$1"/*;do
    if [ -d "$i" ];then
        echo "$i"
        recurse "$i"
    elif [ -f "$i" ]; then
        echo "*$i"
    fi
 done
}

recurse ./samples
