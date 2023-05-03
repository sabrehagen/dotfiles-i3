# Create lockscreen image
LOCKSCREEN_IMAGE=$(mktemp).png
import -window root $LOCKSCREEN_IMAGE
convert $LOCKSCREEN_IMAGE -level 0%,100%,0.6 -scale 10% -scale 1000% $LOCKSCREEN_IMAGE

# Start screensaver
~/.config/scripts/screensaver.sh

# Start lockscreen on screensaver exit
i3lock \
  --image $LOCKSCREEN_IMAGE \
  --nofork \
  --bshl-color={color2.strip}FF \
  --inside-color={color6.strip}00 \
  --insidever-color={color2.strip}FF \
  --insidewrong-color={color2.strip}FF \
  --keyhl-color={color6.strip}FF \
  --line-color={background.strip}FF \
  --ring-color={color2.strip}FF \
  --ringver-color={color2.strip}FF \
  --ringwrong-color={color6.strip}FF \
  --separator-color={background.strip}FF
