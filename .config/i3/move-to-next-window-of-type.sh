WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$CURRENT_WORKSPACE $NEXT_WORKSPACES $PREVIOUS_WORKSPACES"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)
FOCUSED_WINDOW_CLASS=$(xdotool getactivewindow | xargs -n1 xprop WM_CLASS -id | cut -d'"' -f2 2>/dev/null || echo no-focused-window)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  WORKSPACE_MATCHING_WINDOWS=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS)

  # If searching the current workspace, only search for windows after the focused window if the focused window is of the desired window type
  if [ "$WORKSPACE_NUMBER" -eq "$CURRENT_WORKSPACE" ] && [ "$FOCUSED_WINDOW_CLASS" = "$WINDOW_CLASS" ]; then

    WORKSPACE_MATCHING_WINDOWS=$(echo $WORKSPACE_MATCHING_WINDOWS | tr ' ' \\n | awk "/$FOCUSED_WINDOW/{p=1;next} p")

  fi

  WORKSPACE_FIRST_MATCHING_WINDOW=$(echo $WORKSPACE_MATCHING_WINDOWS | tr ' ' \\n | head -n1)

  if [ -n "$WORKSPACE_FIRST_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_FIRST_MATCHING_WINDOW
    break
  fi

done
