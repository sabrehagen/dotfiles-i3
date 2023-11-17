WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$NEXT_WORKSPACES $PREVIOUS_WORKSPACES $CURRENT_WORKSPACE"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

# Check current workspace for subsequent instances of application
WINDOWS_AFTER_FOCUSED_WINDOW=$(xdotool search --all --onlyvisible --desktop $(xprop -notype -root _NET_CURRENT_DESKTOP | cut -c 24-) "" 2>/dev/null | awk "/$FOCUSED_WINDOW/{p=1;next} p")

for WORKSPACE_WINDOW in $WINDOWS_AFTER_FOCUSED_WINDOW; do

  WORKSPACE_WINDOW_MATCHES_CLASS=$(xprop -id $WORKSPACE_WINDOW | grep WM_CLASS | grep -q $WINDOW_CLASS)

  if [ -z "$WORKSPACE_WINDOW_MATCHES_CLASS" ]; then
    xdotool windowactivate $WORKSPACE_WINDOW
    exit 0
  fi

done

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  WORKSPACE_MATCHING_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | grep -v $FOCUSED_WINDOW | head -1)

  if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
    break
  fi

done
