#!/usr/bin/env bash 

# #To Pull all repos 
for repo in $(find . -name ".git" | cut -c 3- | sed 's/.git//g')
do
    current_branch=$(git -C "$repo" branch |grep '\*'|cut -d' ' -f2)
    echo  -e "Pulling repo: ${repo} \t on branch: ${current_branch}"
git -C "$repo" pull 
done




#If you want this to work with submodules
:; find . -type d  -name ".git" | xargs -n1 -P4 -I% git --git-dir=% --work-tree=%/.. fetch --all --recurse-submodules