WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$NEXT_WORKSPACES $PREVIOUS_WORKSPACES $CURRENT_WORKSPACE"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  MATCHING_WORKSPACE_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | grep -v $FOCUSED_WINDOW | head -1)

  if [ -n "$MATCHING_WORKSPACE_WINDOW" ]; then
    xdotool windowactivate $MATCHING_WORKSPACE_WINDOW
    break
  fi

done
