WINDOW_CLASS=$1
DIRECTION=$2

TREE=$(i3-msg -t get_tree)
CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused == true) | .num')
FOCUSED_WINDOW=$(echo $TREE | jq '.. | objects | select(.focused? == true and .window != null) | .window')

CURRENT_WORKSPACE_WINDOWS=$(echo $TREE | jq --argjson ws $CURRENT_WORKSPACE --raw-output '
  [.. | objects | select(.type? == "workspace" and .num == $ws)][0]
  | [.. | objects | select(.window != null)][]
  | "\(.window) \(.window_properties.class // "") \(.window_properties.instance // "")"
')

WINDOWS_AFTER_FOCUSED=$(echo "$CURRENT_WORKSPACE_WINDOWS" | awk --assign focused=$FOCUSED_WINDOW '$1 == focused {p=1; next} p')
WINDOWS_BEFORE_FOCUSED=$(echo "$CURRENT_WORKSPACE_WINDOWS" | awk --assign focused=$FOCUSED_WINDOW '$1 == focused {exit} {print}')

OTHER_WORKSPACE_WINDOWS=$(echo $TREE | jq --argjson ws $CURRENT_WORKSPACE --raw-output '
  (([.. | objects | select(.type? == "workspace" and .num > $ws)] | sort_by(.num)) +
   ([.. | objects | select(.type? == "workspace" and .num >= 0 and .num < $ws)] | sort_by(.num)))[]
  | [.. | objects | select(.window != null)][]
  | "\(.window) \(.window_properties.class // "") \(.window_properties.instance // "")"
')

# Forward cycle order: current-after, other workspaces, current-before
CANDIDATE_WINDOWS=$(printf '%s\n%s\n%s\n' "$WINDOWS_AFTER_FOCUSED" "$OTHER_WORKSPACE_WINDOWS" "$WINDOWS_BEFORE_FOCUSED" | grep --extended-regexp --ignore-case $WINDOW_CLASS | awk '{print $1}')

ORDER=cat
if [ $DIRECTION = previous ]; then
  ORDER=tac
fi

TARGET_WINDOW=$(echo "$CANDIDATE_WINDOWS" | $ORDER | head --lines 1)

if test ${TARGET_WINDOW:+x}; then
  xdotool windowactivate $TARGET_WINDOW
fi
