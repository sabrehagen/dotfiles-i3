renumber_workspaces() {

  WORKSPACE_COUNTER=1
  WORKSPACE_NUMBERS=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n)

  for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

    if [ $WORKSPACE_NUMBER -gt $WORKSPACE_COUNTER ]; then
      WORKSPACE_NAME=$(i3-msg -t get_workspaces | jq -r ".[] | select(.num==$WORKSPACE_NUMBER).name" | cut -c 4-)
      i3-msg rename workspace \"$WORKSPACE_NUMBER: $WORKSPACE_NAME\" to \"$WORKSPACE_COUNTER: $WORKSPACE_NAME\"
    fi

    WORKSPACE_COUNTER=$(( $WORKSPACE_COUNTER + 1 ))

  done

}

# Avoid conflicting with workspace restoration on startup
until ps aux | grep -v grep | grep -vqz i3-resurrect; do sleep 1; done

# Trigger renumber whenever a workspace event occurs
i3-msg -t subscribe -m '[ "workspace" ]' | \
  while read event; do sleep 0.2; renumber_workspaces; done
