MARGIN=24
STATE_FILE=$HOME/.cache/i3-floating-corner-cycle

WIN=$(i3-msg --type get_tree | jq --raw-output 'recurse(.nodes[]?, .floating_nodes[]?) | select(.sticky == true) | "\(.id) \(.rect.width) \(.rect.height)"' | head -n 1)
test ${WIN:+x} || exit 0
WIN_ID=${WIN%% *}
REST=${WIN#* }
WIN_W=${REST% *}
WIN_H=${REST#* }

WS=$(i3-msg --type get_workspaces | jq --raw-output '.[] | select(.focused) | "\(.rect.width) \(.rect.height)"')
WS_W=${WS% *}
WS_H=${WS#* }

LEFT_X=$MARGIN
TOP_Y=$MARGIN
RIGHT_X=$(expr $WS_W - $WIN_W - $MARGIN)
BOTTOM_Y=$(expr $WS_H - $WIN_H - $MARGIN)

INDEX=$(cat $STATE_FILE 2>/dev/null || echo 0)

case $INDEX in
  0) X=$LEFT_X;  Y=$TOP_Y    ;;
  1) X=$RIGHT_X; Y=$TOP_Y    ;;
  2) X=$RIGHT_X; Y=$BOTTOM_Y ;;
  3) X=$LEFT_X;  Y=$BOTTOM_Y ;;
esac

i3-msg "[con_id=$WIN_ID] move position $X $Y"
echo $(expr \( $INDEX + 1 \) % 4) > $STATE_FILE
