#!/bin/bash

# 获取用户输入的目标分支名称
read -p "请输入目标分支名称: " release_branch

# 获取当前分支名称
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 保存当前工作区的修改，包括未跟踪的文件
git stash push --include-untracked

# 切换到目标分支
git checkout $release_branch

# 拉取最新的远程分支更新
git pull

# 合并当前分支到目标分支
git merge $current_branch --no-ff

# 推送合并后的目标分支到远程仓库
git push

# 切换回原来的分支
git checkout $current_branch

# 恢复之前保存的工作区修改
git stash pop

echo "操作完成！"
