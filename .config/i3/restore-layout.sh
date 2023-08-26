RESURRECT_DIRECTORY=~/.config/i3/i3-resurrect

# Restore all workspaces
grep -l , $RESURRECT_DIRECTORY/* | \
  sort | \
  sed 's;.*/;;' | \
  cut -c 11- | \
  sed 's;_.*;;' | \
  uniq | \
  xargs -I @ i3-resurrect restore --directory $RESURRECT_DIRECTORY --workspace "@"

# Focus the previously focused workspace
cat $RESURRECT_DIRECTORY/focused | xargs i3-msg workspace number

# Multiply number workspaces by two to account for loading delays
NUM_WORKSPACES=$(( $(i3-msg -t get_workspaces | grep -o name | wc -l) * 2 ))

# Clear all window urgency after restoration
for WORKSPACE in $(seq $NUM_WORKSPACES); do
  # Wait for windows to finish loading
  sleep 1

  # Clear open windows urgency
  wmctrl -l | \
    cut -f 1 -d ' ' | \
    xargs -n 1 wmctrl -b remove,demands_attention -i -r
done
