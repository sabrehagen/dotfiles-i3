WORKSPACE_COUNTER=1
WORKSPACE_NUMBERS=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n)

FOCUSED_WINDOW=$(xdotool getwindowfocus)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  CHROMIUM_WINDOW=$(xdotool search --desktop "$(( $WORKSPACE_NUMBER - 1 ))" --class chromium | head -1)

  if [ ! -z "$CHROMIUM_WINDOW" ]; then

    # Switch to workspace
    i3-msg workspace number $WORKSPACE_NUMBER

    # Focus chromium-browser
    xdotool windowactivate $CHROMIUM_WINDOW

    # Take screenshot of window to display during replacement
    SCREENSHOT_PATH=/tmp/chromium-screenshot-$CHROMIUM_WINDOW.png
    maim --window $CHROMIUM_WINDOW > $SCREENSHOT_PATH

    # Open screenshot placeholder in sibling tabbed container
    i3-msg split h
    i3-msg layout tabbed
    i3-msg mark TABBED
    i3-msg exec feh $SCREENSHOT_PATH
    i3-msg focus parent
    i3-msg mark PLACEHOLDER
  fi

  WORKSPACE_COUNTER=$(( $WORKSPACE_COUNTER + 1 ))

done

sleep 0.5

# Kill chromium
pkill -f chromium-browser

# Set chromium windows to open in placeholders
i3-msg "[class="i3-chromium-launch"] move window to mark PLACEHOLDER"

# Start chromium
i3-msg "exec chrome --class=i3-chromium-launch"

sleep 1.5

# Remove screenshot placeholders
pkill -f chromium-screenshot

# Restore focused window
xdotool windowactivate $FOCUSED_WINDOW
