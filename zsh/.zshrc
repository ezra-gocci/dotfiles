autoload -Uz compinit && compinit
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

eval "$(/opt/homebrew/bin/brew shellenv)"
alias bi="brew install"
eval "$(starship init zsh)"
alias ....="source ~/.zshrc"

# Report user vars to iTerm2
iterm2_print_user_vars() {
  iterm2_set_user_var username $(whoami)
  iterm2_set_user_var hostname $(hostname -s)
  iterm2_set_user_var cwd $(basename "$PWD")
}
iterm2_set_user_var cwd $(if [ "$PWD" = "$HOME" ]; then echo "~"; else basename "$PWD"; fi)
alias tm="tmux -CC new -s main"
alias ta="tmux -CC attach -t main"
eval "$(atuin init zsh)"
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
eval "$(mise activate zsh)"
alias et="eza --tree --icons -L 2"
# Option+arrow word navigation
bindkey "\e[1;3D" backward-word    # Option+Left
bindkey "\e[1;3C" forward-word     # Option+Right
bindkey "\e\e[D" backward-word     # Alt+Left fallback
bindkey "\e\e[C" forward-word      # Alt+Right fallback
# Option+arrow word navigation
bindkey "\e[1;3D" backward-word    # Option+Left
bindkey "\e[1;3C" forward-word     # Option+Right
bindkey "\e\e[D" backward-word     # Alt+Left fallback
bindkey "\e\e[C" forward-word      # Alt+Right fallback
mkcd() { mkdir -p "$1" && cd "$1" }
rmcd() { local dir="$PWD"; cd .. && rm -rf "$dir" }
alias v="nvim"
export EDITOR="nvim"
source <(fzf --zsh)
# fzf + preview
alias fp="fzf --preview 'bat --color=always {}'"
alias vf='v $(fp)'
eval "$(zoxide init zsh)"
alias zl="zoxide query --list"
# eza aliases
alias l="eza --icons"
alias ll="eza --icons --long --git"
alias la="eza --icons --long --all --git"
alias lt="eza --icons --tree -L 2"
alias cat="bat -p"
