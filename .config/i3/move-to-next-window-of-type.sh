WINDOW_CLASS=$1

CURRENT_WORKSPACE=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).num')
PREVIOUS_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 < current')
NEXT_WORKSPACES=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n | awk -v current=$CURRENT_WORKSPACE '$1 > current')

WORKSPACE_NUMBERS="$NEXT_WORKSPACES $PREVIOUS_WORKSPACES $CURRENT_WORKSPACE"

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  MATCHING_WORKSPACE_WINDOW=$(xdotool search --desktop $(( $WORKSPACE_NUMBER - 1 )) --class $WINDOW_CLASS | head -1)

  if [ ! -z $MATCHING_WORKSPACE_WINDOW ]; then
    xdotool windowactivate $MATCHING_WORKSPACE_WINDOW
    break
  fi

done
