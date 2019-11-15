RESURRECT_DIRECTORY=~/.config/i3/i3-resurrect

# Clear previous workspace history
rm -rf $RESURRECT_DIRECTORY/*

# Save all workspaces
i3-msg -t get_workspaces | \
  jq '.[].name' | \
  xargs -n 1 -I @ i3-resurrect save --directory $RESURRECT_DIRECTORY --workspace "@"
