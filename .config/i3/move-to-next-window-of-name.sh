WINDOW_NAME=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$NEXT_WORKSPACES $PREVIOUS_WORKSPACES $CURRENT_WORKSPACE"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  WORKSPACE_MATCHING_WINDOW=$(xdotool search --desktop $WORKSPACE_NUMBER --name $WINDOW_NAME | grep -v $FOCUSED_WINDOW | head -1)

  if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
    break
  fi

done
