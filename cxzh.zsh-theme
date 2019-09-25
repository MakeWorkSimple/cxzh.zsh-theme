# ZSH Theme - Preview: http://dl.dropbox.com/u/4109351/pics/gnzh-zsh-theme.png
# Based on bira theme

setopt prompt_subst

() {

}

prompt_end(){
  echo -n "
╰─"
}


prompt_status(){
  if [[ $UID -ne 0 ]]; then # normal user
    ARROW_PROMPT='%f➤ %f'
  else # root
    ARROW_PROMPT='%f➤ %f'
  fi
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
  symbols+="${ARROW_PROMPT}"
  symbols=$(IFS='' ; echo "${symbols[*]}")
  echo -n "$symbols"
}


prompt_user_host(){ 
  if [[ $UID -ne 0 ]]; then # normal user
    PR_USER='%F{green}%n%f'
    PR_USER_OP='%F{green}%#%f'
  else # root
    PR_USER='%F{red}%n%f'
    PR_USER_OP='%F{red}%#%f'
  fi

  if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
    PR_HOST='%F{red}%M%f' # SSH
  else
    PR_HOST=''
  fi

  if [[ -z $PR_HOST ]]; then
      local user_host="${PR_USER}%F{cyan}"
  else
      local user_host="${PR_USER}%F{cyan}@${PR_HOST}"
  fi
  echo -n "╭─${user_host} "
}
prompt_dir(){ 
  current_dir="%B%F{blue}%~%f%b"
  echo -n "${current_dir} "
}

prompt_git() {
  (( $+commands[git] )) || return
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path color
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    color=yellow
    if [ -z ${vcs_info_msg_0_%% } ]; then
      color=green
    fi
    echo -n "%F{${color}}""${PL_BRANCH_CHAR}<${ref/refs\/heads\//}${vcs_info_msg_0_%% }>%f "
  fi
}

prompt_rvm_ruby(){
  local rvm_ruby=''
  if ${HOME}/.rvm/bin/rvm-prompt &> /dev/null; then # detect user-local rvm installation
    rvm_ruby='%F{red}‹$(${HOME}/.rvm/bin/rvm-prompt i v g s)›%f'
  elif which rvm-prompt &> /dev/null; then # detect system-wide rvm installation
    rvm_ruby='%F{red}‹$(rvm-prompt i v g s)›%f'
  elif which rbenv &> /dev/null; then # detect Simple Ruby Version Management
    rvm_ruby='%F{red}‹$(rbenv version | sed -e "s/ (set.*$//")›%f'
  fi
  if [[ -n rvm_ruby ]];then
    echo -n "${rvm_ruby} "
  else
    echo -n ""
  fi
}

prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

build_prompt() {
  RETVAL=$?
  prompt_user_host
  prompt_dir
  prompt_rvm_ruby
  prompt_virtualenv
  prompt_git
  # prompt_hg
  prompt_end
  prompt_status
  
}

PROMPT='%{%f%b%k%}$(build_prompt)'
RPROMPT='%(?..%F{red}%? ↵%f)'