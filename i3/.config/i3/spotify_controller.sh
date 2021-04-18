me=`basename "$0"`

display_usage() {
    echo 'This script controls Spotify via dbus'
    echo 'Usage'
    echo -e "\t$me <action>"
    echo -e '\taction: {Play,Pause,PlayPause,Previous,Next}'
    exit 1
}

action=$1
command='dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."$action"'

if [[ -z "$1" ]]; then
    display_usage
fi

if [[ -n "$action" ]]; then
    eval "$command"
    exit $?
fi

echo "No action specified!"
display_usage
