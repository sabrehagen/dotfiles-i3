# Clear previous workspace history
rm -rf ~/.i3/i3-resurrect/*

# Save all workspaces
i3-msg -t get_workspaces | \
  jq '.[].num' | \
  xargs -n 1 i3-resurrect save -w

i3-msg exit
