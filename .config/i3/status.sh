i3status | while :
do
  read line
  DESKTOP_ENVIRONMENT_BUILD=$(timeago $(head -n1 $HOME/repositories/sabrehagen/desktop-environment/.dotfiles-cachebust))
  echo "Built $DESKTOP_ENVIRONMENT_BUILD | $line" || exit 1
done
