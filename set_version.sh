#!/usr/bin/env bash

# 环境变量
Pwd=$(realpath $(dirname $0))
Tag=$1 && shift

# Start release
cd $Pwd || exit
git stash
git flow release start "v$Tag"

# Set Mvn Version
cd $Pwd/mzzb-server || exit
mvn versions:set -DnewVersion="$Tag"
mvn versions:commit

# Set Npm Version
cd $Pwd/mzzb-ui || exit
npm version --no-commit-hooks --no-git-tag-version "$Tag"

# Finish release
cd $Pwd || exit
git add .
git commit -m "chore: Set version to v$Tag"
git flow release finish "v$Tag"
git stash apply
