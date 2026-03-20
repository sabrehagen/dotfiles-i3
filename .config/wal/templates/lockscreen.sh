# Create lockscreen image
LOCKSCREEN_IMAGE=$(mktemp).png
scrot - | convert - -level 0%,100%,0.6 -scale 10% -scale 1000% $LOCKSCREEN_IMAGE

# Start screensaver
# $HOME/.config/scripts/screensaver.sh

# Start lockscreen on screensaver exit
i3lock \
  --bshl-color {color2.strip}FF \
  --greeter-size 15 \
  --image $LOCKSCREEN_IMAGE \
  --inside-color {color6.strip}00 \
  --insidever-color {color2.strip}FF \
  --insidewrong-color {color2.strip}FF \
  --keyhl-color {color6.strip}FF \
  --line-color {background.strip}FF \
  --nofork \
  --noinput-text= \
  --ring-color {color2.strip}FF \
  --ringver-color {color2.strip}FF \
  --ringwrong-color {color6.strip}FF \
  --separator-color {background.strip}FF \
  --status-pos ix:iy+5 \
  --verif-font monospace \
  --verif-pos ix:iy+5 \
  --verif-size 20 \
  --wrong-font monospace \
  --wrong-pos ix:iy+5 \
  --wrong-size 20 \
  --wrong-text unauthorized
