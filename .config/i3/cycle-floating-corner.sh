STEP=${1:-1}
MARGIN=24

set -- $(i3-msg --type get_tree | jq --raw-output 'recurse(.nodes[]?, .floating_nodes[]?) | select(.sticky == true) | "\(.id) \(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)"' | head -n 1)
test $# -eq 5 || exit 0
WIN_ID=$1 WIN_X=$2 WIN_Y=$3 WIN_W=$4 WIN_H=$5

set -- $(i3-msg --type get_workspaces | jq --raw-output '.[] | select(.focused) | "\(.rect.width) \(.rect.height)"')
WS_W=$1 WS_H=$2

LEFT_X=$MARGIN
TOP_Y=$MARGIN
RIGHT_X=$(( WS_W - WIN_W - MARGIN ))
BOTTOM_Y=$(( WS_H - WIN_H - MARGIN ))

CX=$(( WIN_X + WIN_W / 2 ))
CY=$(( WIN_Y + WIN_H / 2 ))
RIGHT=$(( CX * 2 >= WS_W ))
BOTTOM=$(( CY * 2 >= WS_H ))
INDEX=$(( 2 * BOTTOM + (RIGHT + BOTTOM) % 2 ))
INDEX=$(( (INDEX + STEP + 4) % 4 ))

case $INDEX in
  0) X=$LEFT_X;  Y=$TOP_Y    ;;
  1) X=$RIGHT_X; Y=$TOP_Y    ;;
  2) X=$RIGHT_X; Y=$BOTTOM_Y ;;
  3) X=$LEFT_X;  Y=$BOTTOM_Y ;;
esac

i3-msg "[con_id=$WIN_ID] move position $X $Y"
