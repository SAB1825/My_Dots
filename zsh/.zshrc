# ~/.zshrc

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt share_history
setopt inc_append_history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

# ---------------------------------------------------------------------------
# Shell behaviour
# ---------------------------------------------------------------------------
setopt autocd              # type a directory name to cd into it
setopt auto_pushd          # cd pushes onto the directory stack
setopt pushd_ignore_dups
setopt interactive_comments
setopt no_beep
setopt prompt_subst
setopt complete_in_word

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats       ' %F{yellow}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}(%b|%a)%f'

PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_}
%F{green}❯%f '
RPROMPT='%(?..%F{red}[%?]%f)'

# ---------------------------------------------------------------------------
# Zoxide (smarter cd: z <dir>, zi for interactive)
# ---------------------------------------------------------------------------
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias c='clear'
alias h='history'
alias q='exit'
alias reload='source ~/.zshrc'

alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulpn'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'

# Nicer alternatives, used only if installed
if (( $+commands[eza] )); then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto --git'
    alias la='eza -A --group-directories-first --icons=auto'
    alias tree='eza --tree --level=2 --icons=auto'
fi

if (( $+commands[bat] )); then
    alias cat='bat --paging=never'
fi

if (( $+commands[nvim] )); then
    alias vim='nvim'
fi

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-R'

# ---------------------------------------------------------------------------
# SSH agent (systemd user socket: ssh-agent.socket)
# ---------------------------------------------------------------------------
if [[ -z "$SSH_AUTH_SOCK" && -n "$XDG_RUNTIME_DIR" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# ---------------------------------------------------------------------------
# Optional plugins (enabled automatically if the packages are installed)
# ---------------------------------------------------------------------------
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
