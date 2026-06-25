# import systemd bashrc
if [ -r /etc/bashrc ]; then
    . /etc/bashrc
fi

export EDITOR=hx

# .bash_profile exports BASH_ENV=~/.bashrc, so this file is also sourced by
# non-interactive bash processes. Keep aliases/functions available there, but
# guard readline- and prompt-specific setup below.
case $- in
    *i*) __bash_is_interactive=1 ;;
    *) __bash_is_interactive=0 ;;
esac

shopt -s histappend
export HISTCONTROL="ignoredups"
shopt -s cdspell
shopt -s cmdhist

clean_old_tasks() {
    tasks=$(apt-repo | grep -oP 'tasks/[^/]+/[^/]+/[^/]+/\K\d+|repo/\K\d+' | sort -u)
    for _task in ${tasks}; do
        _state="$(curl -s https://git.altlinux.org/tasks/${_task}/info.json | jq -r .state)"
        if [ "${_state}" == "EPERM" ] || [ "${_state}" == "TESTED" ]; then
            echo "Task ${_task} still available"
        else
            echo "Task ${_task} not available, delete it"
            sudo apt-repo rm ${_task}
        fi
    done
}

changelog_add() {
    _init=$1
    _spec=$(fd -I .spec$ .gear alt 2>/dev/null)
    if ! [ "${_spec}" ]; then
        echo "spec file not found"
    else
        _version=$(grep ^Version ${_spec} | cut -d' ' -f2)
        if [ "${_init}" == "init" ]; then
            echo "initial build"
            add_changelog -e "- Initial build for ALT." ${_spec}
        else
            echo "new version ${_version}"
            add_changelog -e "- Updated to version ${_version}." ${_spec}
        fi
    fi
}

vm() {
    _ip=$1
    ssh root@192.168.1.${_ip}
}

task_info() {
    _task=$1
    xdg-open https://beta.packages.altlinux.org/ru/tasks/$_task
}

disapprove() {
    _task=$1
    _subtask=$2
    _msg="$3"
    if [[ -z "$_task" || -z "$_subtask" || -z "$_msg" ]]; then
        echo "error" >&2
        return 1
    fi
    echo -e "${_msg}" | ssh girar task disapprove ${_task} ${_subtask}
}

disapprove_revoke() {
    _task=$1
    _subtask=$2
    ssh girar task disapprove --revoke ${_task} ${_subtask}
}

acs (){
    local pkg=$1
    apt-cache search $pkg | rg --ignore-case $pkg
}

u() {
    clean_old_tasks && sudo apt-get update
}

ud() {
    u && sudo apt-get -V dist-upgrade
}

udk() {
    ud && sudo update-kernel && cleannodepslibs
}

udkc() {
    sudo apt-repo clean && udk
}

cleannodepslibs() {
    mapfile -t _pkgs < <(apt-cache list-nodeps | grep -E '^lib[^-]*$|-common$|-compat$' | grep -Ev 'libvirt')
    if ((${#_pkgs[@]} > 0)); then
        sudo apt-get -V remove "${_pkgs[@]}"
    fi
}

# yazi
y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# tgpt
_tgpt_bash() {
    local cmd
    if [[ -n "$READLINE_LINE" ]]; then
        cmd=$(tgpt -q -w --provider pollinations --preprompt 'Ты shell assistant для Linux bash. Верни только одну bash-команду без markdown, без объяснений. Не выполняй команду.' "$READLINE_LINE")
        cmd=${cmd//$'\r'/}
        cmd=${cmd%$'\n'}
        READLINE_LINE=$cmd
        READLINE_POINT=${#READLINE_LINE}
    fi
}
if [ "$__bash_is_interactive" -eq 1 ]; then
    bind -x '"\ee": _tgpt_bash'
fi

alias ls='eza --icons --header --group-directories-first'
alias ll='ls -la'
alias l='ls -l'
alias ltree='eza -T --level '
alias df='duf'
alias ara='sudo apt-repo add'
alias arm='sudo apt-repo rm'
alias art='clean_old_tasks && sudo apt-repo test'
alias arl='apt-repo list'
alias agip='u && sudo apt-get -V install'
alias agrp='sudo apt-get -V remove'
alias acwd='apt-cache whatdepends'
alias sstat='systemctl status'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias ssres='sudo systemctl restart'
alias gpl='git pull'
alias gst='git status'
alias gdf='git diff'
alias gld='lumen diff'
alias gdfh='git diff HEAD'
alias gdfne='git diff --no-ext-diff'
alias glg='git log -p'
alias grst='git reset --hard'
alias gcl='git clone'
alias gad='git add'
alias gcm='git commit -m'
alias gpo='git push origin'
alias gfu='git fetch upstream'
alias grv='git remote -v'
alias gres='git restore'
alias lg='lazygit'
alias gplsm='git pull && git submodule update --init --recursive'
alias vhost='sudo vim /etc/hosts'
alias svim='sudo vim'
alias task_watch='neowatch -n 5 -d girar-show'
alias rm='trs -v'
alias cp='xcp'
alias zed='zed-editor'
alias vim='nvim'
alias h='hx'
alias girarbuild='ssh girar build'
alias girarbuildcom='ssh girar build --commit'
alias girarrun='ssh girar task run'
alias girarruncom='ssh girar task run --commit'
alias girarshow='ssh girar task show'
alias girarnew='ssh girar task new'
alias girarrm='ssh girar task rm'
alias giraradd='ssh girar task add'
alias girardel='ssh girar task delsub'
alias girardeps='ssh girar task deps'
alias girarls='zoryn task ls --user amakeenk'
alias gitaltinit='ssh git.alt init-db'
alias gitaltrm='ssh git.alt rm-db'
alias gitaltls='ssh git.alt ls packages'
alias gut='gear-update-tag -avc'
alias gct='gear-create-tag --force'
alias grr='gear-remotes-restore'
alias ztm='zoryn task manage'
alias zj='zellij'
alias calc='_(){ awk "BEGIN{print $*}";};_'
alias npmu='npm -g update --verbose'
alias npml='npm -g list'
alias fscl='fsel --cclip'
alias wlc='wl-copy'
alias wlp='wl-paste'
alias tvp='tv procs'
alias tvf='tv files'
alias tvt='tv text'

if [ "$__bash_is_interactive" -eq 1 ]; then
    eval "$(starship init bash)"
    eval "$(fzf --bash)"
    eval "$(zoxide init --cmd cd bash)"
    eval "$(atuin init bash)"
fi

# for kitty
export TERM=xterm-256color

# for aikido safe chain
export PATH=~/.npm-global/bin:$PATH

# import private bashrc
if [ -r ~/.bashrc_priv ]; then
    . ~/.bashrc_priv
fi

unset __bash_is_interactive
