WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$CURRENT_WORKSPACE $NEXT_WORKSPACES $PREVIOUS_WORKSPACES $CURRENT_WORKSPACE"

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

# Used to search before or after the focused window depending if workspace search has looped back around
FIRST_ITERATION=true

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  # If searching the current workspace, we need to search for windows after or before the focused window
  if [ "$WORKSPACE_NUMBER" -eq "$CURRENT_WORKSPACE" ]; then

    WORKSPACE_WINDOWS=$(xdotool search --all --onlyvisible --desktop $(( $WORKSPACE_NUMBER - 1 )) "" 2>/dev/null | xargs -I@ sh -c "echo @-\$(xprop -id @ | grep WM_CLASS | cut -d'\"' -f2)")

    # Get windows after the focused window on the first search of current workspace, or get windows before the focused window on the second search of current workspace
    if [ "$FIRST_ITERATION" = "true" ]; then
      WORKSPACE_WINDOWS_AFTER_FOCUSED_WINDOW=$(echo $WORKSPACE_WINDOWS | tr ' ' '\n' | awk "/$FOCUSED_WINDOW.*/{p=1;next} p")
    else
      WORKSPACE_WINDOWS_BEFORE_FOCUSED_WINDOW=$(echo $WORKSPACE_WINDOWS | tr ' ' '\n' | awk "/$FOCUSED_WINDOW.*/{found=1} !found{print}")
    fi

    WORKSPACE_MATCHING_WINDOW=$(echo $WORKSPACE_WINDOWS_BEFORE_FOCUSED_WINDOW $WORKSPACE_WINDOWS_AFTER_FOCUSED_WINDOW | tr ' ' '\n' | grep -E $WINDOW_CLASS | cut -d- -f1 | head -n1)

  else

    # Search for all windows on the current workspace
    WORKSPACE_MATCHING_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | grep -v $FOCUSED_WINDOW | head -1)

  fi

  if [ -n "$WORKSPACE_MATCHING_WINDOW" ]; then
    xdotool windowactivate $WORKSPACE_MATCHING_WINDOW
    break
  fi

  FIRST_ITERATION=false

done
