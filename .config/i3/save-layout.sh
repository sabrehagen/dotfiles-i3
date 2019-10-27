# Save all workspaces
i3-msg -t get_workspaces | \
  jq '.[].num' | \
  xargs -n 1 i3-resurrect save -w

until ps aux | grep -m 1 resurrect >/dev/null; do sleep 1; done
