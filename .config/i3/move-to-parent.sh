# Moved focused window or container to parent level in i3 tree
i3-msg \
  focus parent, focus parent, mark DESTINATION, \
  focus child, focus child, move container to mark DESTINATION, \
  focus parent, unmark DESTINATION, focus child
