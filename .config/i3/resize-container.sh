#!/usr/bin/env bash
set -euo pipefail

resize_key="${1:-}"
if [[ -z "$resize_key" ]]; then
  echo "Usage: $0 <h|j|k|l> [amount string]" >&2
  exit 1
fi

delta="${2:-10 px or 2 ppt}"
margin=5

IFS=$' \t' read -r container_x container_y container_width container_height floating_state workspace_name < <(
  i3-msg -t get_tree | jq -r '
    def is_leaf: (.window? != null) or ((.nodes // []) | length) == 0;
    def focused_node:
      .. | objects
      | select(
          .focused? == true
          and (.type? == "con" or .type? == "floating_con")
          and is_leaf
        );
    def focused_ws:
      .. | objects
      | select(
          .type? == "workspace"
          and ((.nodes + (.floating_nodes // [])) | .. | objects | select(.focused? == true))
        );
    (focused_node | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height) \(.floating // "auto_off")") as $focus
    | (focused_ws | .name) as $ws
    | "\($focus) \($ws)"' | head -n1
)

if [[ -z "$container_x" ]]; then
  exit 0
fi

is_floating=0
if [[ "$floating_state" == "auto_on" || "$floating_state" == "user_on" ]]; then
  is_floating=1
fi

if (( ! is_floating )); then
  IFS=$' \t' read -r workspace_x workspace_y workspace_width workspace_height min_x min_y max_x max_y < <(
    i3-msg -t get_tree | jq -r '
      def is_leaf: (.window? != null) or ((.nodes // []) | length) == 0;
      def focused_ws:
        .. | objects
        | select(
            .type? == "workspace"
            and ((.nodes + (.floating_nodes // [])) | .. | objects | select(.focused? == true))
          );
      focused_ws as $ws
      | ([
          $ws.nodes[]?
          | .. | objects
          | select(.type? == "con" and is_leaf and (.floating // "auto_off") == "auto_off")
          | .rect
        ]) as $rects
      | if ($rects | length) == 0 then "" else
          ($rects | map(.x) | min) as $min_x
          | ($rects | map(.y) | min) as $min_y
          | ($rects | map(.x + .width) | max) as $max_x
          | ($rects | map(.y + .height) | max) as $max_y
          | "\($ws.rect.x) \($ws.rect.y) \($ws.rect.width) \($ws.rect.height) \($min_x) \($min_y) \($max_x) \($max_y)"
        end'
  )

  if [[ -z "$workspace_x" ]]; then
    exit 0
  fi

  # Determine effective outer gaps from live container bounds.
  gap_left=$(( min_x - workspace_x ))
  gap_top=$(( min_y - workspace_y ))
  gap_right=$(( (workspace_x + workspace_width) - max_x ))
  gap_bottom=$(( (workspace_y + workspace_height) - max_y ))

  right_edge=$(( (container_x + container_width) >= (max_x - margin) ))
  bottom_edge=$(( (container_y + container_height) >= (max_y - margin) ))
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
