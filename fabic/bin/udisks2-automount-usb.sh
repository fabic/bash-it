#!/bin/sh
#
# FABIC 2017-10-08
#
# Found at https://wiki.archlinux.org/index.php/Udisks#udevadm_monitor :
#
# « You may use udevadm monitor to monitor block events and mount drives when a
# new block device is created. Stale mount points are automatically removed by
# udisksd, such that no special action is required on deletion. »

pathtoname() {
    udevadm info -p /sys/"$1" | awk -v FS== '/DEVNAME/ {print $2}'
}

stdbuf -oL -- udevadm monitor --udev -s block | while read -r -- _ _ event devpath _; do
        if [ "$event" = add ]; then
            devname=$(pathtoname "$devpath")
            udisksctl mount --block-device "$devname" --no-user-interaction
        fi
done
