if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    alias q='qs -c ii'
    alias update='sudo pacman -Syu' # update only standard pkgs
    alias updatelist='sudo pacman -Syyu' # Refresh pkglist & update standard pkgs
    alias yaysua='yay -Sua --noconfirm' # update only AUR pkgs (paru)
    alias yaysyu='yay -Syu --noconfirm' # update standard pkgs and AUR pkgs (paru)
    alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
    alias cleanup='sudo pacman -Rns $(pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)

    alias l='eza -l --icons'
    alias ls='eza --icons'
    alias la='eza -la --icons'
    alias grep='rg'
    alias vim='nvim'
    alias cd='z'
    alias find='fd'
    alias lg='lazygit'
    alias cat='bat'
    alias mkdir='mkdir -pv'
    alias dockerphp8='docker container stop php7_mariadb php7_phpmyadmin php7_apache && docker container start php8_mariadb php8_phpmyadmin php8_apache'
    alias dockerphp7='docker container stop php8_mariadb php8_phpmyadmin php8_apache && docker container start php7_mariadb php7_phpmyadmin php7_apache'

    zoxide init fish | source

    # Start (or attach to) the ssh-agent via keychain and load its
    # env vars (SSH_AUTH_SOCK / SSH_AGENT_PID) into this shell.
    # keychain 3.x's legacy --eval flag ignores the calling shell and
    # formats output based on $SHELL (zsh here), which fish can't parse.
    # `env --shell fish` asks for fish syntax explicitly.
    keychain --quiet add id_ed25519
    keychain env --shell fish | source

end
