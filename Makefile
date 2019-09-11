source_path=$(shell pwd)
target_path=~/.oh-my-zsh/themes
install:
	cp ${source_path}/cxzh.zsh-theme ${target_path}/cxzh.zsh-theme
uninstall:
	rm ${target_path}/cxzh.zsh-theme