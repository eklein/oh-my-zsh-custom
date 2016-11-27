oh-my-zsh-custom
================

This repository contains specific oh-my-zsh customizations.

Getting Started
---------------

1. If you already have oh-my-zsh installed then go ahead and delete it.

        rm -rf ~/.oh-my-zsh

2. Clone the oh-my-zsh repository

        git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
        
3. Clone the oh-my-zsh-custom repo

        git clone https://github.com/eklein/oh-my-zsh-custom.git ~/.oh-my-zsh-custom

4. OPTIONAL Backup your existing ~/.zshrc file

        cp ~/.zshrc ~/.zshrc.orig

5. Create a new zsh config by copying the zsh template.

        cp ~/.oh-my-zsh-custom/templates/zshrc.zsh-template ~/.zshrc

6. Edit the .zshrc and add the plugins you care about.  See the ~/.oh-my-zsh/plugins and ~/.oh-my-zsh-custom/plugins to 
see what is available.
        
7. If you are not already using zsh as your shell

        chsh -s /bin/zsh

8. Start / restart zsh (open a new terminal is easy enough…)
