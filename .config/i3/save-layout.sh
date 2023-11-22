RESURRECT_DIRECTORY=$HOME/.config/i3/i3-resurrect

# Clear previous workspace history
rm -rf $RESURRECT_DIRECTORY/*

# Kill any i3bar build log windows before saving
tmux kill-session -t i3bar_desktop-environment-build*

# Save all workspaces
i3-msg -t get_workspaces | \
  jq '.[].name' | \
  xargs -I @ i3-resurrect save --directory $RESURRECT_DIRECTORY --workspace "@"

# Save active workspace
i3-msg -t get_workspaces | jq -c ".[] | select(.focused==true) | .num" > $RESURRECT_DIRECTORY/focused
