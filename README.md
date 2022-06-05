# Dotfiles 
my dotfiles to **zsh** , **NeoVim** and **tmux**


## Install Tmux Plugin Manager

**First**
Clone TPM:
```
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Second**
On your ```~/.tmux.conf``` file:
```
#List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'


# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

## Install Tmux Themes

Add plugin to the list of TPM plugins in .tmux.conf:
```
set -g @plugin 'jimeh/tmux-themepack'
```

Press  ```<prefix> + I```  to fetch the plugin and source it. The plugin should now be working.

Choose which theme is loaded by setting the @themepack option in your ```.tmux.conf```:

- ```set -g @themepack 'basic' (default)```
- ```set -g @themepack 'powerline/block/blue'```
- ```set -g @themepack 'powerline/block/cyan'```
- ```set -g @themepack 'powerline/default/green'```
- ```set -g @themepack 'powerline/double/magenta'```
- ...



## Install PowerLevel10k

**First**

```
$ git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

$ p10k configure
```

**Second**
```Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc.```

