SAVED_WORKSPACES=$(grep -rl { ~/.i3/i3-resurrect | sort | sed 's;.*/;;' | cut -c 11 | uniq)

for SAVED_WORKSPACE in $SAVED_WORKSPACES; do
  i3-resurrect restore -w $SAVED_WORKSPACE
done

# Focus the first workspace
i3-msg workspace 1 > /dev/null

# Wait for windows to finish loading
sleep 1

# Clear all window urgency after restoration
wmctrl -l | \
  cut -f 1 -d ' ' | \
  xargs -n 1 wmctrl -b remove,demands_attention -i -r
