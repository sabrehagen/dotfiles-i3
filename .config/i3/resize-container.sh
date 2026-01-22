#!/usr/bin/env bash
set -euo pipefail

resize_key="${1:-}"
if [[ -z "$resize_key" ]]; then
  echo "Usage: $0 <h|j|k|l> [amount string]" >&2
  exit 1
fi

delta="${2:-10 px or 2 ppt}"
margin=5

IFS=$' \t' read -r container_x container_y container_width container_height floating_state < <(
  i3-msg -t get_tree | jq -r '
    .. | objects
    | select(
        .focused? == true
        and (.type? == "con" or .type? == "floating_con")
        and (
          (.window? != null)
          or ((.nodes // []) | length) == 0
        )
      )
    | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height) \(.floating // "auto_off")"' | head -n1
)

if [[ -z "$container_x" ]]; then
  exit 0
fi

is_floating=0
if [[ "$floating_state" == "auto_on" || "$floating_state" == "user_on" ]]; then
  is_floating=1
fi

if (( ! is_floating )); then
IFS=$' \t' read -r workspace_x workspace_y workspace_width workspace_height < <(
  i3-msg -t get_workspaces | jq -r '
    .[]
    | select(.focused == true)
    | .rect
    | "\(.x) \(.y) \(.width) \(.height)"'
)

  if [[ -z "$workspace_x" ]]; then
  exit 0
fi

right_edge=$(( (container_x + container_width) >= (workspace_x + workspace_width - margin) ))
bottom_edge=$(( (container_y + container_height) >= (workspace_y + workspace_height - margin) ))
fi

if (( is_floating )); then
  case "$resize_key" in
    h) cmd="resize shrink width $delta" ;;
    l) cmd="resize grow width $delta" ;;
    k) cmd="resize shrink height $delta" ;;
    j) cmd="resize grow height $delta" ;;
    *) echo "Invalid direction: $resize_key" >&2; exit 1 ;;
  esac
else
case "$resize_key" in
  h)
    if (( right_edge )); then
      cmd="resize grow width $delta"
    else
      cmd="resize shrink width $delta"
    fi
    ;;
  l)
    if (( right_edge )); then
      cmd="resize shrink width $delta"
    else
      cmd="resize grow width $delta"
    fi
    ;;
  k)
    if (( bottom_edge )); then
      cmd="resize grow height $delta"
    else
      cmd="resize shrink height $delta"
    fi
    ;;
  j)
    if (( bottom_edge )); then
      cmd="resize shrink height $delta"
    else
      cmd="resize grow height $delta"
    fi
    ;;
  *)
    echo "Invalid direction: $resize_key" >&2
    exit 1
    ;;
esac
fi

i3-msg "$cmd" >/dev/null
