if [ "$1" = '-' ]; then
  DIRECTION=-1
else
  DIRECTION=1
fi

# Get the display the current workspace is on
WORKSPACE_DISPLAY=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).output')

# Get all workspaces on the current display
DISPLAY_WORKSPACES=$(i3-msg -t get_workspaces | jq ".[] | select(.output==$WORKSPACE_DISPLAY)")

# Get the number of workspaces on the current display
NUM_WORKSPACES=$(i3-msg -t get_workspaces | jq -c ".[] | select(.output==$WORKSPACE_DISPLAY)" | wc -l)

# Get the index of the current workspace on the display
WORKSPACE_INDEX=$(i3-msg -t get_workspaces | jq -c ".[] | select(.output==$WORKSPACE_DISPLAY)" | grep -n '"focused":true' | cut -f1 -d:)

# Calculate adjacent workspace number
ADJACENT_WORKSPACE_INDEX=$(( $WORKSPACE_INDEX + $DIRECTION ))

if [ "$ADJACENT_WORKSPACE_INDEX" -eq 0 ]; then
  ADJACENT_WORKSPACE_INDEX=$NUM_WORKSPACES
elif [ "$ADJACENT_WORKSPACE_INDEX" -eq $(( $NUM_WORKSPACES + 1 )) ]; then
  ADJACENT_WORKSPACE_INDEX=1
fi

# Get the adjacent workspace number from the index
ADJACENT_WORKSPACE_NUMBER=$(i3-msg -t get_workspaces | jq -c ".[] | select(.output==$WORKSPACE_DISPLAY)" | sed -n ${ADJACENT_WORKSPACE_INDEX}p | jq .num)

# Move to the adjacent workspace on the same display
i3-msg workspace number $ADJACENT_WORKSPACE_NUMBER
