if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias pacsyu='sudo pacman -Syu'                  # update only standard pkgs
alias pacsyyu='sudo pacman -Syyu'                # Refresh pkglist & update standard pkgs
alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages (DANGEROUS!)

#Alias
alias ls='exa --icons'
alias l='exa -l --icons'
alias la='exa -la --icons'
alias grep='rg'
alias vim='nvim'
alias lg='lazygit'
alias cat='bat'
alias mkdir='mkdir -pv'
alias dockerphp8='docker container stop php7_mariadb php7_phpmyadmin php7_apache && docker container start php8_mariadb php8_phpmyadmin php8_apache'
alias dockerphp7='docker container stop php8_mariadb php8_phpmyadmin php8_apache && docker container start php7_mariadb php7_phpmyadmin php7_apache'

starship init fish | source
