# Restore all workspaces
grep -rl , ~/.i3/i3-resurrect | \
  sort | \
  sed 's;.*/;;' | \
  cut -c 11- | \
  uniq | \
  sed 's;_.*;;' | \
  head -1 | \
  xargs -n 1 -I @ i3-resurrect restore -w "@"

# Focus the first workspace
i3-msg workspace 1 > /dev/null

# Clear all window urgency after restoration
for SAVED_WORKSPACE in $SAVED_WORKSPACES; do
  # Wait for windows to finish loading
  sleep 1

  # Clear open windows urgency
  wmctrl -l | \
    cut -f 1 -d ' ' | \
    xargs -n 1 wmctrl -b remove,demands_attention -i -r
done
