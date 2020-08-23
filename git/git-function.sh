#cat /etc/profile.d/git_functions.sh


/bin/echo "Loading git functions."

function gap() {
  command git add -A && /usr/bin/git commit -v -a -m "$*" && /usr/bin/git push
  echo https://git.XYZ.com/`git remote -v | cut -f2 -d: | cut -f1 -d\.|head -1`/commit/`git log -1 | head -1 | cut -f2 -d' '`
}

function gapr() {
  export branch=${USER}-`/usr/bin/date +%Y%m%d-%H%M-%N`
  export repo=`/usr/bin/git remote -v | /usr/bin/cut -f2 -d: | /usr/bin/cut -f1 -d\. | /usr/bin/head -1 | /usr/bin/cut -f2 -d/`
  command git branch ${branch}
  command git checkout ${branch}
  command git add -A && /usr/bin/git commit -v -a -m "$*" && /usr/bin/git push --set-upstream origin ${branch}
  # Temporary unique folder for CLOUDSETUP repo checkout
  /bin/mkdir ${HOME}/.$$
  export cloudsetupPATH=${HOME}/.$$/CLOUDSETUP
  echo "----------------------------------------------"
  echo "Performing GIT CLONE on $cloudsetupPATH"
  echo "----------------------------------------------"
  command git clone git@git.XYZ.com:DEV/CLOUDSETUP ${cloudsetupPATH}
  /bin/echo -e "*** Done ***\n"
  ${cloudsetupPATH}/pullRequest/pullRequest.rb -r ${repo} --head ${branch} --title ${*} -d "TGIT gapr() pull request for $*"
  /bin/rm -rf ${HOME}/.$$
  /usr/bin/echo https://git.XYZ.com/`git remote -v | cut -f2 -d: | cut -f1 -d\.|head -1`/commit/`git log -1 | head -1 | cut -f2 -d' '`
  command git checkout master
  command git fetch --all --prune
}

function tp() {
  /opt/terraform/bin/terraform get -update
  /opt/terraform/bin/terraform plan
}

function git-update-all() {
  /usr/bin/find . -maxdepth 2 -type d \( ! -name . ! -name .git \) -exec bash -c "cd '{}' && pwd && git pull" \;
}

function git-check-status() {
  /usr/bin/find . -maxdepth 2 -type d \( ! -name . ! -name \.git \) -exec bash -c "cd '{}' && pwd && git status" \; | /usr/bin/grep --color=auto -v clean | /usr/bin/grep --color=auto -v 'up-to-date' | /usr/bin/grep --color=auto -v 'On branch master'  | /usr/bin/grep --color=auto -v 'Not a git repository'
}

function rm() {
  /usr/bin/rm -i $*
}

function mv() {
  /usr/bin/mv -i $*
}

function cp() {
  /usr/bin/cp -i $*
}
