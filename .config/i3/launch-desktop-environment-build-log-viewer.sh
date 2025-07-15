BUILD_TMUX_SESSION_MOST_RECENT=$(tmux list-sessions | grep 'desktop-environment-build-[clean|dotfiles].*:' | cut -d: -f1 | cut -d- -f5 | sort -nr | head -1)
BUILD_TMUX_SESSION=$(tmux list-sessions | grep 'desktop-environment-build-[clean|dotfiles].*:' | cut -d: -f1 | grep $BUILD_TMUX_SESSION_MOST_RECENT)

if [ -n "$BUILD_TMUX_SESSION" ]; then
  BUILD_LOG_SESSION_NAME=i3bar_desktop-environment-build-$(date +%s)

  # Kill any previous build log session
  tmux kill-session -t i3bar_desktop-environment-build*

  # If mouse coordinates are not set, script has been invoked manually, not by clicking the desktop-environment-build i3block
  if [ -z "$BLOCK_X" ] && [ -z "$BLOCK_Y" ]; then
    # Capture the current mouse position
    eval $(xdotool getmouselocation --shell)

    OUTPUT_ORIGIN_X=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.x')
    OUTPUT_ORIGIN_Y=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.y')
    OUTPUT_WIDTH=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.width')
    OUTPUT_HEIGHT=$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.height')

    BLOCK_X_OFFSET=1125
    BLOCK_Y_OFFSET=20
    BLOCK_X1=$(($OUTPUT_ORIGIN_X + $OUTPUT_WIDTH - $BLOCK_X_OFFSET))
    BLOCK_Y1=$(($OUTPUT_ORIGIN_Y + $OUTPUT_HEIGHT + $BLOCK_Y_OFFSET))

    # Move the mouse to the desktop-environment-build i3block
    xdotool mousemove $BLOCK_X1 $BLOCK_Y1
  fi

  # Create a new build log viewer
  alacritty \
    --option window.dimensions.columns=108 \
    --option window.dimensions.lines=50 \
    --title i3bar_desktop-environment-build \
    --command zsh -c "tmux new-session -s $BUILD_LOG_SESSION_NAME -t $BUILD_TMUX_SESSION" >/dev/null 2>&1 &

  # Turn off status bar in build log viewer session
  until tmux list-sessions | grep -q $BUILD_LOG_SESSION_NAME; do sleep 0.05; done
  tmux set-option -t $BUILD_LOG_SESSION_NAME status off

  # If the script has been invoked manually, return mouse to its original position
  if [ -z "$BLOCK_X" ] && [ -z "$BLOCK_Y" ]; then
    # Move mouse to original coordinates captured by xdotool
    xdotool mousemove $X $Y

    # Focus build log viewer after moving mouse
    xdotool windowactivate $(xdotool search --name i3bar_desktop-environment-build) 2>/dev/null
  fi
fi
