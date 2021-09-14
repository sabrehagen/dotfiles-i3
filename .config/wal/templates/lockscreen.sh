# Create lockscreen image
IMAGE=$(mktemp).png
import -window root $IMAGE
convert $IMAGE -level 0%,100%,0.6 -scale 10% -scale 1000% $IMAGE

# Start screensaver
~/.config/scripts/screensaver.sh

# Start lockscreen on screensaver exit
i3lock \
  -i $IMAGE \
  -n \
  --bshlcolor={color2.strip}FF \
  --insidecolor={color6.strip}00 \
  --insidevercolor={color2.strip}FF \
  --insidewrongcolor={color2.strip}FF \
  --keyhlcolor={color6.strip}FF \
  --linecolor={background.strip}FF \
  --ringcolor={color2.strip}FF \
  --ringvercolor={color2.strip}FF \
  --ringwrongcolor={color6.strip}FF \
  --separatorcolor={background.strip}FF
