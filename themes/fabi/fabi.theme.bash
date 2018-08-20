#!/usr/bin/env bash

prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  #PS1="(\t) $(scm_char) [$blue\u$reset_color@$green\h$reset_color] $red\j $yellow\w${reset_color}$(scm_prompt_info)$(ruby_version_prompt) $reset_color "
  #PS1="(\t) $(scm_char) [$blue\u$reset_color@$green\H$reset_color] $red\j $yellow\w${reset_color}$(scm_prompt_info) $reset_color "
  PS1="(\t) [$blue\u$reset_color@$green\H$reset_color] $red\j $yellow\w${reset_color} $ "
  PS2='> '
  PS4='+ '

  [ ! -z "${DUDE_BEWARE_ON_SERVER_YOU_ARE+x}" ] &&
    PS1="$background_red$bold_white(!!!)$normal $PS1"
}

PROMPT_COMMAND=prompt_setter

SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
