# Sesh Configuration
# Smart terminal session manager for tmux
# https://github.com/joshmedeski/sesh

if command -v sesh &> /dev/null; then
    function sesh-sessions() {
        {
            exec </dev/tty
            exec <&1
            local session
            session=$(sesh list --icons | fzf-tmux -p 80%,70% \
                --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
                --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
                --bind 'tab:down,btab:up' \
                --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
                --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
                --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
                --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
                --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
                --preview-window 'right:55%' \
                --preview 'sesh preview {}')
            [[ -z "$session" ]] && return
            sesh connect "$session"
        }
    }
    zle -N sesh-sessions
    bindkey -M emacs '\C-s' sesh-sessions
    bindkey -M vicmd '\C-s' sesh-sessions
    bindkey -M viins '\C-s' sesh-sessions
fi
