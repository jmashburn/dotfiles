# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="sorin"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias slt='open -a "Sublime Text 2"'
alias ppw='ponyhost push www.moncefandjoanna.com'
alias cdo='cd ~/Dropbox/projects/octopress'
alias cda='cd ~/Dropbox/projects/adopt-a-hydrant'
alias cdp='cd ~/Dropbox/projects/'
alias zshconf='slt ~/.zshrc'
alias cdw='cd /Applications/MAMP/htdocs/wordpress'

# homesick
alias hsym='homesick symlink monfresh/dotfiles'
alias hp='homesick pull monfresh/dotfiles'

# calabash
alias cc='calabash-ios console'
alias ccv='curl http://localhost:37265/version'
alias guc='gem update calabash-cucumber'
alias ciosd='calabash-ios download'
alias cukenewsyc='DEVICE=iphone OS=ios5 NO_LAUNCH=1 cucumber --tags @tap'
alias cdn='cd ~/Dropbox/projects/newsyc'

alias gs='git status -sb'
alias fact="elinks -dump randomfunfacts.com | grep '^|' | tr -d \|"

# rvm
alias rubies='rvm list rubies'
alias gemsets='rvm gemset list'
alias gems='gem list'
alias rvmgs='rvm get stable --autolibs=enable'

# rails
alias bi='bundle install'

# brew
alias bd='brew doctor'
alias bu='brew update'


# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git heroku osx rvm)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
#export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/moncef/.rvm/bin
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/share/python:~/bin:/usr/local/share/npm/bin:$PATH"

export ZSH_THEME_GIT_PROMPT_PREFIX=" %F{106}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]$bg[red]%}✖%{$reset_color%}%F{108}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$reset_color%}%F{108}"
 
#export PROMPT='%F{241}$(rvm-prompt)%F{009}⎬%{$fg_bold[green]%}%~ %F{172}%c%F{161}$(git_prompt_info)%{$fg_bold[blue]%} ❯ %{$reset_color%}'
#export PROMPT='%{$fg_bold[green]%}%~ %F{161}$(git_prompt_info)%{$fg_bold[blue]%} ❯ %{$reset_color%}'