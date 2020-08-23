#!/usr/bin/env bash 

# #To Pull all repos 
for repo in $(find . -name ".git" | cut -c 3- | sed 's/.git//g')
do
    current_branch=$(git -C "$repo" branch |grep '\*'|cut -d' ' -f2)
    echo  -e "Pulling repo: ${repo} \t on branch: ${current_branch}"
git -C "$repo" pull 
done