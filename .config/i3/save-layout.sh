# Save all workspaces
i3-msg -t get_workspaces | \
  jq '.[].num' | \
  xargs -n 1 i3-resurrect save -w
