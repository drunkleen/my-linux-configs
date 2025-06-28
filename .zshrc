if [ -z "$TMUX" ]; then
    tmux
fi


# Oh-my-zsh installation path
ZSH=$HOME/.oh-my-zsh

# Powerlevel10k theme path
source $ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=(
  # git
  sudo
  zsh-256color
  zsh-autosuggestions
  zsh-syntax-highlighting
  archlinux
  fzf-tab
  # you-should-use
  zsh-bat
  pyenv
)

source $ZSH/oh-my-zsh.sh

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}


[[ -f "$HOME/.alias" ]] && source "$HOME/.alias"


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

# Start ssh-agent if not running and add GitHub key
# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#   eval "$(ssh-agent -s)"
#   ssh-add ~/.ssh/github > /dev/null
#   ssh-add ~/.ssh/aur > /dev/null
# fi


# ctrl + R
source <(fzf --zsh)

export PATH=$PATH:$HOME/go/bin

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export MOZ_ENABLE_WAYLAND=1


 fortune | cowsay | leenfetch

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
