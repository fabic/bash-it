#!/bin/bash
#
# F/2019-03-23

tmux rename-window 'LOGS'

tmux send-keys 'journalctl -b -f | ccze -A' 'C-m'

tmux split-window -v 'cd ~/dev/fabic.github.com/ && ./jekyll-serve.sh'
tmux split-window -h 'watch -n3 sensors'

tmux select-pane -t:.-1
tmux split-window -v 'tail -Fq -n1 /var/log/httpd/*log | ccze -A'
tmux split-window -v

tmux select-pane -t:.1
tmux split-window -h 'vnstat -l -ru -i enp2s0'
tmux split-window -v 'vnstat -l -ru -i wlp4s0'
tmux split-window -v 'sudo iotop -oP -d3'

