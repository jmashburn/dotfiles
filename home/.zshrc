# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="juanghurtado"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias s='open -a "Sublime Text"'
alias ppw='ponyhost push www.moncefandjoanna.com'
alias cdo='cd ~/Dropbox/projects/octopress'
alias cdp='cd ~/Dropbox/projects/'
alias cdt='cd ~/Dropbox/tools/'
alias cdh='cd ~/Dropbox/projects/codeforamerica/human_services_finder'
alias cdoh='cd ~/Dropbox/projects/codeforamerica/ohana-api'
alias cdoa='cd ~/Dropbox/projects/codeforamerica/ohana-api-admin'
alias zshconf='slt ~/.zshrc'
alias cdw='cd /Applications/MAMP/htdocs/wordpress'
alias gpsdm='git push staging data-merge:master'
alias gpom='git push origin master'
alias gphm='git push heroku master'
alias p8080='passenger start -p 8080'
alias r8080='rails s -p 8080'
alias odb='cd ~/Dropbox/projects/codeforamerica/ohana-api-dev-box'
alias smco='cd ~/Dropbox/projects/smcgov/smc-ohana-api'
alias smcw='cd ~/Dropbox/projects/smcgov/smc-ohana-web-search'
alias smca='cd ~/Dropbox/projects/smcgov/smc-ohana-api-admin'
alias cfa='cd ~/Dropbox/projects/codeforamerica'
alias smc='cd ~/Dropbox/projects/smcgov'

# homesick
alias hsym='homesick symlink monfresh/dotfiles'
alias hp='homesick pull monfresh/dotfiles'
alias cdd='cd ~/.homesick/repos/monfresh/dotfiles'

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
alias zt='zeus rspec spec'

# brew
alias bd='brew doctor'
alias bu='brew update'

# httpie
alias http='nocorrect http'

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
plugins=(git heroku osx rvm rake)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"

# export ZSH_THEME_GIT_PROMPT_PREFIX=" %F{106}"
# ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[white]$bg[red]%}✖%{$reset_color%}%F{108}"
# ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✔%{$reset_color%}%F{108}"

#export PROMPT='%F{241}$(rvm-prompt)%F{009}⎬%{$fg_bold[green]%}%~ %F{172}%c%F{161}$(git_prompt_info)%{$fg_bold[blue]%} ❯ %{$reset_color%}'
#export PROMPT='%{$fg_bold[green]%}%~ %F{161}$(git_prompt_info)%{$fg_bold[blue]%} ❯ %{$reset_color%}'

export EDITOR='open -a "Sublime Text"'

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh
