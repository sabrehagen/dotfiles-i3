PLUS_OR_MINUS=${1:-'+'}

GAP_SIZE=$(grep '^gaps inner' ~/.config/i3/config | sed 's;gaps inner ;;')
NEW_GAP_SIZE=$(expr $GAP_SIZE $PLUS_OR_MINUS 20 | tr -d -)

i3-msg gaps inner all set $NEW_GAP_SIZE
sed -i "s;^gaps inner .*;gaps inner $NEW_GAP_SIZE;" ~/.config/i3/config
