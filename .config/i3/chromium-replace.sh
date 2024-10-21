WORKSPACE_COUNTER=1
WORKSPACE_NUMBERS=$(i3-msg -t get_workspaces | jq '.[].num' | sort -n)

FOCUSED_WINDOW=$(xdotool getwindowfocus)

for WORKSPACE_NUMBER in $WORKSPACE_NUMBERS; do

  CHROMIUM_WINDOW=$(xdotool search --desktop $WORKSPACE_NUMBER --class chromium | head -1)

  if [ -n "$CHROMIUM_WINDOW" ]; then

    # Take screenshot of chromium window to display during replacement
    SCREENSHOT_PATH=/tmp/chromium-screenshot-$CHROMIUM_WINDOW.png
    maim --window $CHROMIUM_WINDOW > $SCREENSHOT_PATH

    # Switch to workspace
    i3-msg workspace number $WORKSPACE_NUMBER

    # Focus chromium
    xdotool windowactivate --sync $CHROMIUM_WINDOW

    # Create tabbed container around chromium to hold screenshot placeholder in
    i3-msg split h
    i3-msg layout tabbed

    # Wait for screenshot to open in tabbed container
    feh $SCREENSHOT_PATH &
    xdotool search --pid $! --sync

    # Move to parent and mark as destination for the restored chromium window
    i3-msg focus parent
    i3-msg focus parent
    i3-msg mark PLACEHOLDER

    # Kill chromium
    pkill -f chromium-browser

    # Start chromium and wait until window is visible
    i3-msg "exec chrome --class=i3-chromium-launch"
    sleep 1

    # Remove placeholder screenshot
    pkill -f chromium-screenshot

    # Move chromium-browser out of tabbed holding container
    i3-msg '[con_mark="PLACEHOLDER"] focus, focus child'
    $HOME/.config/i3/move-to-parent.sh

    # Restore window that was focused before starting replacement
    xdotool windowactivate $FOCUSED_WINDOW

    # Early exit as only one browser window is supported currently
    exit 0

  fi

  WORKSPACE_COUNTER=$(( $WORKSPACE_COUNTER + 1 ))

done
