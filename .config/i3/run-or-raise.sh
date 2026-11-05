WINDOW_CLASS=$1
COMMAND=$2

# Search all workspaces except the scratchpad, including the focused window
OPEN_WINDOWS=$(i3-msg -t get_tree | jq --raw-output '
  .. | objects | select(.type? == "workspace" and .num >= 0)
  | .. | objects | select(.window != null)
  | "\(.window_properties.class // "") \(.window_properties.instance // "")"
')

if echo "$OPEN_WINDOWS" | grep --extended-regexp --ignore-case --quiet $WINDOW_CLASS; then
  $HOME/.config/i3/move-to-window-of-type.sh $WINDOW_CLASS next
else
  $COMMAND
fi
