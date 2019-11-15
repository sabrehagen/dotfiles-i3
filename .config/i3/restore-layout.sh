RESURRECT_DIRECTORY=~/.config/i3/i3-resurrect

# Restore all workspaces
grep -rl , $RESURRECT_DIRECTORY | \
  sort | \
  sed 's;.*/;;' | \
  cut -c 11- | \
  sed 's;_.*;;' | \
  uniq | \
  xargs -n 1 -I @ i3-resurrect restore --directory $RESURRECT_DIRECTORY --workspace "@"

# Focus the first workspace
i3-msg -t get_workspaces | \
  jq '.[].name' | \
  head -1 | \
  xargs -I @ i3-msg workspace "@" > /dev/null

# Clear all window urgency after restoration
for SAVED_WORKSPACE in $SAVED_WORKSPACES; do
  # Wait for windows to finish loading
  sleep 1

  # Clear open windows urgency
  wmctrl -l | \
    cut -f 1 -d ' ' | \
    xargs -n 1 wmctrl -b remove,demands_attention -i -r
done
