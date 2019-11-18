i3-msg workspace $(( $(i3-msg -t get_workspaces | jq '.[].num' | sort -rn | head -1) + 1 ))
