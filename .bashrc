EMOJIS=('😀' '😂' '☺️' '😋' '😛' '🧐' '😎' '🤓' '😜' '😳' '🤔' '🙄' '😬' '🥴' '👨' '🐿' '🦕' '🐬' '🐳' '🐋' '🌲' '🌳' '🐲' '🐇' '🧸' '🦠' '💯' '🐸' '🦊' '🐶' '🐱' '🙈' '🙉' '🙊' '🐒' '🐣' '🐍' '🐙' '🦍' '🌝' '🔥' '☔️' '🍻' '🎾' '⚽️' '🏀' '✅' '🌀' '🇮🇳' '🍺' '🌻' '🌼');

##EMOJIS=('🌄' '☀️' '☕️' '🍳' '🍞' '🐓' '🐔' '🌲' '🌳' '🌴' '🌵' '🌷' '🌺' '🌸' '🌹' '🌻' '🌼' '💐' '🌾' '🌿' '🍀' '🍁' '🍂' '🍃' '🍄' '☀️' '⛅️' '☁️' '☔️' '🌈' '🌊' '🗻' '🌍' '🌞' '💻' '🚽' '📚' '✂️' '🔪' '🍔' '🍕' '🍖' '🍗' '🍘' '🍙' '🍚' '🍛' '🍜' '🍝' '🍞' '🍟' '🍣' '🍤' '🍥' '🍱' '🍲' '🍳' '🍴' '🍏' '🍇' '🍉' '🍊' '🍌' '🍍' '🍑' '🍒' '🍓' '🍡' '🍢' '🍦' '🍧' '🍨' '🍩' '🍪' '🍫' '🍬' '🍭' '🍮' '🍰' '🍷' '🍸' '🍶' '🍹' '🍺' '🍻' '😴' '🌠' '🌑' '🌒' '🌔' '🌖' '🌘' '🌚' '🌝' '🌛' '🌜' '⛺️' '🌃' '🌉' '🌌');


RANDOM_EMOJI() {
  SELECTED_EMOJI=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]};
  echo $SELECTED_EMOJI;
}

export CLICOLOR=1;
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx;

function parse_git_branch {
  echo -n $(git branch --no-color 2>/dev/null | awk -v out=$1 '/^*/ { if(out=="") print $2; else print out}')
}

PS1='\n$(RANDOM_EMOJI)  \[\e[m\]\[\e[1;32m\]\[\e[4;32m\]\u\[\e[m\] \[\e[0;37m\]\w\[\e[m\] \[\e[0;33m\]$(parse_git_branch)\[\e[m\]\[\e[1;32m\]\n  \[\e[m\] \[\e[0;37m\]';
PS1='$(RANDOM_EMOJI)  \[\e[m\]\[\e[1;32m\]\[\e[4;32m\]\u\[\e[m\] \[\e[0;37m\]\w\[\e[m\] \[\e[0;33m\]$(parse_git_branch)\[\e[m\]\[\e[1;32m\]\n  \[\e[m\] \[\e[0;37m\] $(RANDOM_EMOJI)';
#clear;

#exports favourite editor
export EDITOR=vim;

#clear iTerm scrollback history
alias clearf="printf '\e]50;ClearScrollback\a'";

#git
alias gith='git log --all --graph --pretty=format:"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative';

#PS1="🤓 NAME 🤓 \W";
#PS1="🤓🐣🌀NAME 🌀🐣🤓 \w";
#export PS1;


alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES;
                Killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO;
                Killall Finder'

############ -----------------------#######################
#orange=$(tput setaf 166);
#yellow=$(tput setaf 228);
#green=$(tput setaf 71);
#white=$(tput setaf 15);
#bold=$(tput bold);
#reset=$(tput sgr0);
#PS1="\[${bold}\]\n";
#PS1+="🤡☠️ 🤡 \[${orange}\]\u";  #Username
#PS1+="\[${white}\] at ";
#PS1+="\[${yellow}\]\h";  #Hostname
#PS1+="\[${green}\]\W";   #Working Directory
#PS1+="\[${reset}]-"

###PS1+="\n";
###PS1+="\[${white}\]$ [${reset}\]";  # '$' and reset color
###PS1="\u @ \W -> ";   #Simple
#export PS1;

# $(tput setaf 166)    set the fore group color of the text
# $(tput sgr0)         Reset the applied color code
# \h    the hostname up to the first
# \n    newline
# \s    the name of the shell
# \u    the username of the current user
# \w    present working directory
# \w    the basename of the current working directory
