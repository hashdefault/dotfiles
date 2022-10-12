# Dotfiles 
My dotfiles to **zsh**  and **tmux**. And other initial configs...

## Some dependencies for this setup with openbox
```
- xorg
- openbox
- lightdm
- lightdm-gtk-greeter
- obconf
- plank
- nitrogen
- yay
- lxappearance
- obmenu-generator (AUR)
- nord-openbox-theme (AUR)
- plank-theme-nordic-night-git (AUR)
- polybar (AUR)
- polybar-themes-git (AUR)
- nerd-fonts-complete (AUR)


```
### Polybar dependencies
```
- Polybar : Ofcourse, the bar itself
- Rofi : For App launcher, network, power and style menus
- pywal : For pywal support
- calc : For random colors support
- networkmanager_dmenu : For network modules
```


## Initial configs shell and terminal

```
# command to set the default terminal  
$ sudo update-alternatives --config x-terminal-emulator  
```


```
#command to set the default shell
$ type -a zsh   
$ chsh -s /bin/zsh    
```


## Disable FN Lock from  Keychron k2v2 keyboard 

```
# command to disable fn lock key on keychron k2v2 keyboard
$ echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode     
```
### OR (if you want to make it permanent)
```
# command to disable fn lock key on keychron k2v2 keyboard
$ echo 'options hid_apple fnmode=0' | /etc/modprobe.d/hid_apple.conf
$ sudo update-initramfs -u 
$ reboot
```
