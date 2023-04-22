#!/bin/bash

needed() {
	echo "Begining installation of base packages..."
	sudo pacman -Syyuu
	sudo pacman -S zsh curl base-devel git cmake make neovim go
	sudo pacman -S python nodejs
	sudo pacman -S python-pip npm cargo lazygit -y
	return 0
}

formatterslinters() {
	echo "installing linters and formatters..."
	sudo npm install -g prettier
	pip install pyright black djhtml
	cargo install stylua
	go install mvdan.cc/sh/v3/cmd/shfmt@latest
	return 0
}

aurpkg() {
	echo "installing yay aur helper..."
	cd /opt || return
	git clone https://aur.archlinux.org/yay.git
	cd yay || return
	makepkg -f --nocheck -si
	cd || return
	return 0
}

dockerconf() {
	echo "installing docker..."
	sudo pacman -S docker docker-compose
	if [ "$(pacman -S docker docker-compose)" == "0" ]; then
		groupadd docker
		users_array=$(ls /home)
		for current_user in "${users_array[@]}"; do
			usermod -aG docker "$current_user"
		done
	fi
	return 0
}

asdfinstall() {
	echo "installing asdf..."
	sudo git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
	return 0
}

zshsuggestions() {
	echo "installing zsh-suggestions..."
	sudo git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
	return 0
}

someuseful() {
	echo "installing ripgrep, exa, bat ..."
	sudo pacman -S ripgrep bat exa
	return 0
}

zshconf() {
	echo "installing oh-my-zsh and starship..."
	sudo curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh 
	sudo curl -sS https://starship.rs/install.sh | sh
	sudo chsh /bin/zsh
	return 0
}

finished_install=0

if needed; then
	finished_install=$((finished_install + 1))
	echo 'Nedded packages installed.'
	if zshsuggestions; then
		finished_install=$((finished_install + 1))
		echo "zshsuggestions fish like shell concluded."
		if zshconf; then
			finished_install=$((finished_install + 1))
			echo "zsh configured."
		fi
	fi
fi

if someuseful; then
	echo "Usefull packages installed."
fi

if dockerconf; then
	finished_install=$((finished_install + 1))
	echo "Docker installed and successfully configured."
fi
if asdfinstall; then
	finished_install=$((finished_install + 1))
	echo "asdf version manager installed."
fi
if formatterslinters; then
	finished_install=$((finished_install + 1))
	echo "Formatters and linters installed"
fi
if aurpkg; then
	finished_install=$((finished_install + 1))
	echo "AUR package manager yay installed."
fi

if [ $finished_install -gt 7 ]; then
	echo "All is successfully installed and configured."
else
	echo "Some errors may have ocurred, only $finished_install packs was finished."
fi
