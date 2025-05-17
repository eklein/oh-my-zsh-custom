# Example tmux functions to aid in deployment operations.  Note that for the admin endpoints I have a custom auth function (not found here) and entries in
# my local /etc/hosts file for the admin hosts.  For auth you can use the netrc file found in the cba-deploy repo as an alternative.
# You can copy these functions and modify as desired.  Then just open a new terminal window that sources the function and run.  I run a different
# terminal window tab per function.

tmux-wd() {
    tmux has-session -t wd
    if [ $? != 0 ];then
        tmux new-session -s wd -n 'deploy' -d
        tmux send-keys -t wd:1 'cd ~/code/cba-deploy' C-m
        tmux new-window -d -n 'jump hosts'
        tmux new-window -d
        tmux new-window -d
        tmux new-window -d
        tmux new-window -d
        tmux new-window -d
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux select-layout -t wd:2 tiled
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux select-layout -t wd:2 tiled
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux split-window -h -t wd:2
        tmux select-layout -t wd:2 tiled
        tmux split-window -h -t wd:2
        tmux select-layout -t wd:2 tiled
        tmux send-keys -t wd:2.1 'bl_adminatlsales1'
        tmux send-keys -t wd:2.2 'bl_adminatlnprd'
        tmux send-keys -t wd:2.3 'bl_adminpdxnprd'
        tmux send-keys -t wd:2.4 'bl_admindubnprd'
        tmux send-keys -t wd:2.5 'bl_adminashprod'
        tmux send-keys -t wd:2.6 'bl_adminpdxprod'
        tmux send-keys -t wd:2.7 'bl_admindubprod'
        tmux send-keys -t wd:2.8 'bl_adminamsdr'
        tmux send-keys -t wd:2.9 'bl_adminashdr'
        tmux send-keys -t wd:2.10 'bl_adminatldr'
        tmux send-keys -t wd:2.11 'bl_adminatlperf'
        tmux send-keys -t wd:2.12 'bl_adminpdxnprdperf'
        tmux send-keys -t wd:2.13 'adminpdxeng'
        tmux select-pane -t wd:2.13
        tmux select-window -t wd:1
    fi
    tmux attach -t wd
}
