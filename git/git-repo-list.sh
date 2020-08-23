#!/usr/bin/env bash


# To get the repo list
for repo in $(find . -name ".git" | cut -c 3- | sed 's/.git//g');
do 
    current_branch=$(git -C "$repo" branch | grep '\*'| cut -d' ' -f2);
    echo  -e "repo: ${repo} \t on branch: ${current_branch}" 
done