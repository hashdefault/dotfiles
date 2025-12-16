function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    alias pamcan pacman
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    alias pacsyu='sudo pacman -Syu' # update only standard pkgs
    alias pacsyyu='sudo pacman -Syyu' # Refresh pkglist & update standard pkgs
    alias yaysua='yay -Sua --noconfirm' # update only AUR pkgs (paru)
    alias yaysyu='yay -Syu --noconfirm' # update standard pkgs and AUR pkgs (paru)
    alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock
    alias cleanup='sudo pacman -Rns $(pacman -Qtdq)' # remove orphaned packages (DANGEROUS!)

    alias l='eza -l --icons'
    alias ls 'eza --icons'
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
    alias vpnon='sudo systemctl start zerotier-one.service'
    alias vpnoff='sudo systemctl stop zerotier-one.service'

    zoxide init fish | source
    # 1. Start keychain (removed deprecated --agents flag)
    #    This ensures the background process is running.
    keychain --quiet id_ed25519

    # 2. IMPORTANT: Connect this terminal to the agent
    #    Without this line, your terminal doesn't know the agent exists.
    begin
        set -l host_name (uname -n)
        if test -f ~/.keychain/$host_name-fish
            source ~/.keychain/$host_name-fish
        end
    end

end
