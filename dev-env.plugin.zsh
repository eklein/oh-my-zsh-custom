alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | head -1"

docker_dev() {
    docker_user_home=/home/docker.dev
    docker_repo_base=daspoonman
    image=${docker_repo_base}/${1}
    extra_args=${2}

    eval "docker_run \
        -v ${HOME}/code:${docker_user_home}/code \
        -v ${HOME}/docker/emacs.cache:${docker_user_home}/.emacs.d/.cache \
        -v ${HOME}/docker/.zsh_history:${docker_user_home}/.zsh_history \
        -v ${HOME}/.ssh/id_rsa:${docker_user_home}/.ssh/id_rsa \
        -v ${HOME}/.ssh/config:${docker_user_home}/.ssh/config \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e GITHUB_USER=${GITHUB_USER} \
        -e GITHUB_EMAIL=${GITHUB_EMAIL} \
        -e SKIP_PULL=${SKIP_PULL} \
        --add-host dockerhost:203.0.113.0 \
        -h dev \
        ${extra_args} \
        ${image}"
}

docker_dev_nobind() {
    docker_user_home=/home/docker.dev
    docker_repo_base=daspoonman
    image=${docker_repo_base}/${1}
    extra_args=${2}

    eval "docker_run \
        -v ${HOME}/docker/emacs.cache:${docker_user_home}/.emacs.d/.cache \
        -v ${HOME}/docker/.zsh_history:${docker_user_home}/.zsh_history \
        -v ${HOME}/.ssh/id_rsa:${docker_user_home}/.ssh/id_rsa \
        -v ${HOME}/.ssh/config:${docker_user_home}/.ssh/config \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -e GITHUB_USER=${GITHUB_USER} \
        -e GITHUB_EMAIL=${GITHUB_EMAIL} \
        -e SKIP_PULL=${SKIP_PULL} \
        --add-host dockerhost:203.0.113.0 \
        -h dev \
        ${extra_args} \
        ${image}"
}

sm() docker_dev spacemacs

golang() {
    declare extra_args

    if [[ -n "${EMACS_GUI}" ]]; then
        extra_args="-e DISPLAY=$(myip):0"
        open -a XQuartz
        socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
        sleep 2s
    fi

    docker_dev golang ${extra_args}

    if [[ -n "${EMACS_GUI}" ]]; then
        pkill -i xquartz
        pkill socat
    fi
}

golang_nobind() {
    declare extra_args

    if [[ -n "${EMACS_GUI}" ]]; then
        extra_args="-e DISPLAY=$(myip):0"
        open -a XQuartz
        socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
        sleep 2s
    fi

    docker_dev_nobind golang ${extra_args}

    if [[ -n "${EMACS_GUI}" ]]; then
        pkill -i xquartz
        pkill socat
    fi
}

java_dev() {
    open -a XQuartz
    socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
    sleep 2s

    extra_args="-v ${HOME}/.gradle:${docker_user_home}/.gradle \
       -v ${HOME}/.java:${docker_user_home}/.java \
       -v ${HOME}/.idea:${docker_user_home}/.IdeaIC2016.2 \
       -p 5050:5050 \
       -e DISPLAY=$(myip):0"

    docker_dev java $extra_args

    pkill -i xquartz
    pkill socat
}

tmux_local() {
    tmux has-session -t local
    if [ $? != 0 ];then
        tmux new-session -s local -n 'cba-deploy' -d
        tmux send-keys -t local:1 'cd ~/code/cba-deploy' C-m
        tmux new-window -d
        tmux new-window -d -n 'jump hosts'
        tmux split-window -v -p 33 -t local:3
        tmux split-window -v -t local:3.1
        tmux split-window -h -t local:3.1
        tmux split-window -h -t local:3.2
        tmux split-window -h -t local:3.3
        tmux send-keys -t local:3.1 'adminpdxeng'
        tmux send-keys -t local:3.3 'adminatlnprd'
        tmux send-keys -t local:3.6 'adminpdxnprd'
        tmux send-keys -t local:3.2 'adminpdxprod'
        tmux send-keys -t local:3.5 'adminashprod'
        tmux select-pane -t local:3.1
        tmux select-window -t local:1
    fi
    tmux attach -t local
}
