#!/bin/bash

me=$(basename "$0")
player='spotifyd'

display_usage() {
    echo 'This script shows info on what is currently playing'
    echo ''
    echo 'USAGE:'
    echo -e "\t$me [-h] [-p player]"
    echo ''
    echo 'FLAGS:'
    echo -e "\t-h\t\tPrints help information"
    echo -e "\t-p player\tThe player to control (defaults to $player)"
}

while getopts "h?p:" flag; do
    case "$flag" in
        h|\?)
            display_usage
            exit 0
            ;;
        p)
            player="$OPTARG"
            ;;
    esac
done

if pgrep -x "$player" > /dev/null; then
    metadata="$(
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2."$player" \
        /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get \
        string:org.mpris.MediaPlayer2.Player string:Metadata
    )"
    echo -n "$(sed -n '/title/{n;p}' <<< "$metadata" | cut -d \" -f 2) "

    # Artist info not provided for podcasts
    artist=$(sed -n '/artist/{n;n;p}' <<< "$metadata" | cut -d \" -f 2)
    if [[ -n "$artist" && "$artist" != " " ]]; then
        echo -n "by $(sed -n '/artist/{n;n;p}' <<< "$metadata" | cut -d \" -f 2) "
    fi

    echo "from $(sed -n '/album\"/{n;p}' <<< "$metadata" | cut -d \" -f 2)"
else
    echo "No music ;("
fi
