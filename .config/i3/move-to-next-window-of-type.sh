WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$CURRENT_WORKSPACE $NEXT_WORKSPACES $PREVIOUS_WORKSPACES"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  WORKSPACE_MATCHING_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS)

  # If searching the current workspace, only search for windows after the focused window
  if [ "$WORKSPACE_NUMBER" -eq "$CURRENT_WORKSPACE" ]; then
    WORKSPACE_MATCHING_WINDOW=$(echo $WORKSPACE_MATCHING_WINDOW | tr ' ' \\n | awk "/$FOCUSED_WINDOW/{p=1;next} p")
  fi

  if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
    break
  fi

done
