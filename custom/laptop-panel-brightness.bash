# custom/laptop-panel-brightness.bash

# sudo bash -c 'echo 4000 >> /sys/class/backlight/intel_backlight/brightness'
#
#   actual_brightness
#   bl_power
#   brightness
#   device
#   max_brightness
#   power
#   subsystem
#   type
#   uevent
brightness() {
  local there="/sys/class/backlight/intel_backlight"
  local max="$(cat $there/max_brightness)"
  local curr="$(cat $there/brightness)"
  local target="${1:-}"

  # todo: maybe compute half, 1 third, 2 third, 3 fourth, 4 fifth, 5 sixth
  # todo: and ... ?
  if [ -z "$target" ]; then
    let target=$max*5/6
  fi

  echo "~> Maximum: $max"
  echo "~> Current: $curr"
  echo "~> Setting to $target"
  sudo bash -c "echo $target >> /sys/class/backlight/intel_backlight/brightness"
  echo "~> Now reading value: $(cat $there/brightness)"
}
