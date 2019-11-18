WORKSPACE_NUMBER=$(( $(i3-msg -t get_workspaces | jq '.[].num' | sort -rn | head -1) + 1 ))

# Move window to new workspace
i3-msg move container to workspace number $WORKSPACE_NUMBER

# Wait for the new workspace to be registered
sleep 0.1

# Focus new workspace
i3-msg workspace number $WORKSPACE_NUMBER
