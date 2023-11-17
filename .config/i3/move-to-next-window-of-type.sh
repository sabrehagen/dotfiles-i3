WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$CURRENT_WORKSPACE $NEXT_WORKSPACES $PREVIOUS_WORKSPACES"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  WORKSPACE_MATCHING_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | grep -v $FOCUSED_WINDOW | head -1)

  # If searching the current workspace, only search for windows after the focused window
  if [ "$WORKSPACE_NUMBER" -eq "$CURRENT_WORKSPACE" ]; then

    WORKSPACE_WINDOWS_AFTER_FOCUSED_WINDOW=$(xdotool search --all --onlyvisible --desktop $(( $WORKSPACE_NUMBER - 1 )) "" 2>/dev/null | xargs -I@ sh -c "echo @-\$(xprop -id @ | grep WM_CLASS | cut -d'\"' -f2)" | awk "/$FOCUSED_WINDOW.*/{p=1;next} p")
    WORKSPACE_MATCHING_WINDOW=$(echo $WORKSPACE_WINDOWS_AFTER_FOCUSED_WINDOW | tr ' ' \\n | grep $WINDOW_CLASS | cut -d- -f1 | head -n1)

  fi

  if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
    exit
  fi

done

# If a matchine window was not found, check windows before the focused window on the current workspace
WORKSPACE_WINDOWS_BEFORE_FOCUSED_WINDOW=$(xdotool search --all --onlyvisible --desktop $(( $WORKSPACE_NUMBER - 1 )) "" 2>/dev/null | xargs -I@ sh -c "echo @-\$(xprop -id @ | grep WM_CLASS | cut -d'\"' -f2)" | awk "/$FOCUSED_WINDOW.*/{found=1} !found{print}")
WORKSPACE_MATCHING_WINDOW=$(echo $WORKSPACE_WINDOWS_BEFORE_FOCUSED_WINDOW | tr ' ' \\n | grep $WINDOW_CLASS | cut -d- -f1 | head -n1)

if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
  xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
fi
