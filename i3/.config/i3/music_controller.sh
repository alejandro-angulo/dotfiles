#!/bin/bash

me=$(basename "$0")
player='spotifyd'

display_usage() {
    echo 'This script controls Spotify via dbus'
    echo ''
    echo 'USAGE:'
    echo -e "\t$me [-h] [-p player] Play|Pause|PlayPause|Previous|Next"
    echo ''
    echo 'FLAGS:'
    echo -e "\t-h\t\tPrints help information"
    echo -e "\t-p player\tThe player to control (defaults to $player)"
    exit 1
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

shift $((OPTIND-1))
if [[ $# -ne 1 ]]; then
    display_usage
    exit 1
fi

action=$1

if [[ -n "$action" ]]; then
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2."$player" \
        /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$action"
    exit $?
fi
