WINDOW_CLASS=$1
DIRECTION=$2

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort --numeric-sort | awk --assign current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort --numeric-sort | awk --assign current=$CURRENT_WORKSPACE '$1 > current')

FOCUSED_WINDOW=$(xdotool getactivewindow 2>/dev/null || echo no-focused-window)

# All visible windows on the current workspace
CURRENT_WORKSPACE_WINDOWS=$(xdotool search --all --onlyvisible --desktop $(( $CURRENT_WORKSPACE - 1 )) '' 2>/dev/null | xargs --replace=@ sh -c "echo @-\$(xprop -id @ | grep WM_CLASS | cut --delimiter '\"' --fields 2)")

# Split the current workspace around the focused window
WINDOWS_AFTER_FOCUSED=$(echo $CURRENT_WORKSPACE_WINDOWS | tr ' ' '\n' | awk "/$FOCUSED_WINDOW.*/{p=1;next} p")
WINDOWS_BEFORE_FOCUSED=$(echo $CURRENT_WORKSPACE_WINDOWS | tr ' ' '\n' | awk "/$FOCUSED_WINDOW.*/{found=1} !found{print}")

# Class-matching windows on other workspaces
OTHER_WORKSPACE_WINDOWS=
for WORKSPACE_NUMBER in $NEXT_WORKSPACES $PREVIOUS_WORKSPACES; do
  OTHER_WORKSPACE_WINDOWS="$OTHER_WORKSPACE_WINDOWS $(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | grep --invert-match $FOCUSED_WINDOW | sed "s/\$/-$WINDOW_CLASS/")"
done

# Forward cycle order: current-after, other workspaces, current-before
CANDIDATE_WINDOWS=$(echo $WINDOWS_AFTER_FOCUSED $OTHER_WORKSPACE_WINDOWS $WINDOWS_BEFORE_FOCUSED | tr ' ' '\n' | grep --extended-regexp $WINDOW_CLASS | cut --delimiter - --fields 1)

# Reverse the candidate stream to cycle backwards
ORDER=cat
if [ $DIRECTION = previous ]; then
  ORDER=tac
fi

TARGET_WINDOW=$(echo "$CANDIDATE_WINDOWS" | $ORDER | head --lines 1)

if test ${TARGET_WINDOW:+x}; then
  xdotool windowactivate $TARGET_WINDOW
fi
